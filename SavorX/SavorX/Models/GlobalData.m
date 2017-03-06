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
NSString * const RDDidFoundSenceNotification = @"RDDidFoundSenceNotification";

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
    self.isBindRD = NO;
    self.isBindDLNA = NO;
    self.isWifiStatus = NO;
    self.RDBoxDevice = [[RDBoxModel alloc] init];
    self.DLNADevice = [[DeviceModel alloc] init];
    self.scene = RDSceneNothing;
    self.hotelId = 0;
}

- (void)bindToDLNADevice:(DeviceModel *)model
{
    self.isBindDLNA = YES;
    self.DLNADevice = model;
    [[GCCUPnPManager defaultManager] setDeviceModel:model];
    [[NSNotificationCenter defaultCenter] postNotificationName:RDDidBindDeviceNotification object:nil];
}

- (void)bindToRDBoxDevice:(RDBoxModel *)model
{
    self.isBindRD = YES;
    self.RDBoxDevice = model;
    self.hotelId = model.hotelID;
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
    self.hotelId = 0;
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
        [[NSNotificationCenter defaultCenter] postNotificationName:RDDidFoundHotelIdNotification object:nil];
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
    _isBindRD = isBindRD;
    if (isBindRD) {
        _isBindDLNA = NO;
        _DLNADevice = [[DeviceModel alloc] init];
    }
}

- (void)setIsBindDLNA:(BOOL)isBindDLNA
{
    _isBindDLNA = isBindDLNA;
    if (isBindDLNA) {
        _isBindRD = NO;
        _RDBoxDevice = [[RDBoxModel alloc] init];
    }
}

- (void)setScene:(RDScene)scene
{
    _scene = scene;
    if (scene == RDSceneNothing) {
        [[NSNotificationCenter defaultCenter] postNotificationName:RDDidNotFoundSenceNotification object:nil];
        if (_isBindRD || _isBindDLNA) {
            [self disconnect];
        }
        self.callQRCodeURL = @"";
    }else{
        [[NSNotificationCenter defaultCenter] postNotificationName:RDDidFoundSenceNotification object:nil];
    }
}

- (void)setIsWifiStatus:(BOOL)isWifiStatus
{
    _isWifiStatus = isWifiStatus;
    if (!isWifiStatus) {
        _scene = RDSceneNothing;
        [MBProgressHUD removeTextHUD];
    }
}

@end
