//
//  GlobalData.m
//  SavorX
//
//  Created by 郭春城 on 16/7/19.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "GlobalData.h"
#import "GCCUPnPManager.h"
#import "HSFirstUseRequest.h"

NSString * const RDDidBindDeviceNotification = @"RDDidBindDeviceNotification";
NSString * const RDDidDisconnectDeviceNotification = @"RDDidDisconnectDeviceNotification";
NSString * const RDDidFoundHotelIdNotification = @"RDDidFoundHotelIdNotification";
NSString * const RDDidNotFoundSenceNotification = @"RDDidNotFoundSenceNotification";
NSString * const RDDidFoundBoxSenceNotification = @"RDDidFoundBoxSenceNotification";
NSString * const RDDidFoundDLNASenceNotification = @"RDDidFoundDLNASenceNotification";

NSString * const RDQiutScreenNotification = @"RDQiutScreenNotification";

#define hasUseHotelID @"hasUseHotelID"
#define hasAlertDemandHelp @"hasAlertDemandHelp"

static GlobalData* single = nil;

@implementation GlobalData

+ (GlobalData *)shared
{
    @synchronized(self)
    {
        if (!single) {
            single = [[self alloc] init];
        }
    }
    return single;
}

- (id)init{
    if (self = [super init]) {
        [self initData];
    }
    return self;
}

- (void)initData {
    self.serverDic = [[NSMutableDictionary alloc] init];
    self.RDBoxDevice = [[RDBoxModel alloc] init];
    self.DLNADevice = [[DeviceModel alloc] init];
    self.scene = RDSceneNothing;
    self.hotelId = 0;
}

- (void)bindToDLNADevice:(DeviceModel *)model
{
    self.isBindDLNA = YES;
    self.DLNADevice = model;
    if (self.scene != RDSceneHaveDLNA) {
        self.scene = RDSceneHaveDLNA;
    }
    [[GCCUPnPManager defaultManager] setDeviceModel:model];
    [[NSNotificationCenter defaultCenter] postNotificationName:RDDidBindDeviceNotification object:nil];
}

- (void)bindToRDBoxDevice:(RDBoxModel *)model
{
    self.isBindRD = YES;
    self.RDBoxDevice = model;
    self.hotelId = model.hotelID;
    if (self.scene != RDSceneHaveRDBox) {
        self.scene = RDSceneHaveRDBox;
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:RDDidBindDeviceNotification object:nil];
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:hasAlertDemandHelp] boolValue]) {
        
        if ([NSStringFromClass([[Helper getRootNavigationController].topViewController class]) isEqualToString:@"WMPageController"]) {
            UIView * view = [Helper createHomePageSecondHelp];
            [[Helper getRootNavigationController].view addSubview:view];
            UITapGestureRecognizer * tap = [[UITapGestureRecognizer alloc] initWithTarget:view action:@selector(removeFromSuperview)];
            tap.numberOfTapsRequired = 1;
            [view addGestureRecognizer:tap];
        }
        [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:hasAlertDemandHelp];
        [[NSUserDefaults standardUserDefaults] synchronize];
    }
    
    NSString * message = [NSString stringWithFormat:@"\"%@\"连接成功, 可以投屏", model.sid];
    [MBProgressHUD showTextHUDwithTitle:message];
}

- (void)disconnectWithDLNADevice
{
    self.isBindDLNA = NO;
    self.DLNADevice = [[DeviceModel alloc] init];
}

- (void)disconnectWithRDBoxDevice
{
    self.isBindRD = NO;
    self.RDBoxDevice = [[RDBoxModel alloc] init];
}

- (void)disconnect
{
    [self disconnectWithRDBoxDevice];
    [self disconnectWithDLNADevice];
    [[NSNotificationCenter defaultCenter] postNotificationName:RDDidDisconnectDeviceNotification object:nil];
}

- (void)setHotelId:(NSInteger)hotelId
{
    if (_hotelId != hotelId) {
        _hotelId = hotelId;
        if (hotelId != 0) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RDDidFoundHotelIdNotification object:nil];
        }
    }
    if (![[[NSUserDefaults standardUserDefaults] objectForKey:hasUseHotelID] boolValue]
        && hotelId != 0) {
        
        HSFirstUseRequest * request = [[HSFirstUseRequest alloc] initWithHotelId:hotelId];
        [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            [[NSUserDefaults standardUserDefaults] setObject:@(YES) forKey:hasUseHotelID];
            [[NSUserDefaults standardUserDefaults] synchronize];
        } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
            
        } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
            
        }];
    }
}

- (void)setIsBindRD:(BOOL)isBindRD
{
    if (_isBindRD != isBindRD) {
        _isBindRD = isBindRD;
        if (isBindRD) {
            _isBindDLNA = NO;
            _DLNADevice = [[DeviceModel alloc] init];
        }
    }
}

- (void)setIsBindDLNA:(BOOL)isBindDLNA
{
    if (_isBindDLNA != isBindDLNA) {
        _isBindDLNA = isBindDLNA;
        if (isBindDLNA) {
            _isBindRD = NO;
            _RDBoxDevice = [[RDBoxModel alloc] init];
        }
    }
}

- (void)setScene:(RDScene)scene
{
    if (_scene != scene) {
        _scene = scene;
        if (scene == RDSceneNothing) {
            [[NSNotificationCenter defaultCenter] postNotificationName:RDDidNotFoundSenceNotification object:nil];
            if (_isBindRD || _isBindDLNA) {
                [self disconnect];
            }
            self.hotelId = 0;
            self.callQRCodeURL = @"";
        }else{
            [MBProgressHUD showTextHUDwithTitle:@"发现电视, 可以投屏"];
            if (scene == RDSceneHaveRDBox) {
                [[NSNotificationCenter defaultCenter] postNotificationName:RDDidFoundBoxSenceNotification object:nil];
            }else{
                self.hotelId = 0;
                [[NSNotificationCenter defaultCenter] postNotificationName:RDDidFoundDLNASenceNotification object:nil];
            }
        }
    }
}

- (void)setIsWifiStatus:(BOOL)isWifiStatus
{
    if (_isWifiStatus != isWifiStatus) {
        _isWifiStatus = isWifiStatus;
        if (!isWifiStatus) {
            self.scene = RDSceneNothing;
            [MBProgressHUD removeTextHUD];
        }
    }
}

- (void)setCacheModel:(RDBoxModel *)cacheModel
{
    if (_cacheModel != cacheModel) {
        _cacheModel = cacheModel;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(clearCacheModel) object:nil];
        [self performSelector:@selector(clearCacheModel) withObject:nil afterDelay:3 * 60.f];
    }
}

- (void)clearCacheModel
{
    self.cacheModel = [[RDBoxModel alloc] init];
}

@end
