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
NSString * const RDBoxQuitScreenNotification = @"RDBoxQuitScreenNotification";

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
    self.projectId = @"projectId";
    self.deviceToken = @"";
    self.latitude = 0.f;
    self.longitude = 0.f;
    self.viewLatitude = 0.f;
    self.viewLongitude = 0.f;
    self.VCLatitude = 0.f;
    self.VCLongitude = 0.f;
    
    [self getAreaId];
}

- (void)getAreaId
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    if ([userDefaults objectForKey:RDAreaID]) {
        NSString * areaId = [userDefaults objectForKey:RDAreaID];
        if (!isEmptyString(areaId)) {
            _areaId = areaId;
        }
    }
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
    
    NSString * message = [NSString stringWithFormat:@"\"%@\"%@", model.sid, RDLocalizedString(@"RDString_ConnectSuccessCanScreen")];
    [MBProgressHUD showTextHUDwithTitle:message delay:2.f];
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
            [self disconnect];
            self.hotelId = 0;
            self.callQRCodeURL = @"";
            [[NSNotificationCenter defaultCenter] postNotificationName:RDDidNotFoundSenceNotification object:nil];
        }else{
            [SAVORXAPI postUMHandleWithContentId:@"home_find_tv" key:@"home_find_tv" value:[NSString stringWithFormat:@"%ld",self.hotelId]];
            [MBProgressHUD showTextHUDwithTitle:RDLocalizedString(@"RDString_FindTVCanScreen")];
            if (scene == RDSceneHaveRDBox) {
                [[NSNotificationCenter defaultCenter] postNotificationName:RDDidFoundBoxSenceNotification object:nil];
            }else{
                self.hotelId = 0;
                [[NSNotificationCenter defaultCenter] postNotificationName:RDDidFoundDLNASenceNotification object:nil];
            }
        }
    }
}

- (void)setNetworkStatus:(RDNetworkStatus )networkStatus
{
    if (_networkStatus != networkStatus) {
        _networkStatus = networkStatus;
        if (_networkStatus != RDNetworkStatusReachableViaWiFi) {
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

- (void)setAreaId:(NSString *)areaId
{
    if (![_areaId isEqualToString:areaId]) {
        _areaId = areaId;
        NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
        [userDefaults setObject:areaId forKey:RDAreaID];
        [userDefaults synchronize];
    }
}

@end
