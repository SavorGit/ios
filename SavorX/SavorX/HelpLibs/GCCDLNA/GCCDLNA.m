//
//  GCCDLNA.m
//  DLNATest
//
//  Created by 郭春城 on 16/10/10.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "GCCDLNA.h"
#import "GCDAsyncUdpSocket.h"
#import "GDataXMLNode.h"
#import "DeviceModel.h"
#import "HSGetIpRequest.h"
#import "RDLogStatisticsAPI.h"

static NSString *ssdpForPlatform = @"238.255.255.250"; //监听小平台ssdp地址
static NSString *ssdpForDLNA = @"239.255.255.250"; //搜索DLNA设备地址

static UInt16 platformPort = 11900; //监听小平台ssdp端口
static UInt16 DLNAPort = 1900; //搜索DLNA设备地址

//DLNA的SSDP设备发现类型：此类型为投屏互动

static NSString *serviceAVTransport = @"urn:schemas-upnp-org:service:AVTransport:1";
static NSString *serviceRendering = @"urn:schemas-upnp-org:service:RenderingControl:1";

@interface GCCDLNA ()<GCDAsyncUdpSocketDelegate, NSXMLParserDelegate>

@property (nonatomic, strong) NSMutableArray * locationSource;
@property (nonatomic, strong) GCDAsyncUdpSocket * socket;
@property (nonatomic, assign) BOOL isSearchPlatform;
@property (nonatomic, assign) BOOL hasUploadLog;

@end

@implementation GCCDLNA

+ (GCCDLNA *)defaultManager
{
    static dispatch_once_t once;
    static GCCDLNA *manager;
    dispatch_once(&once, ^ {
        manager = [[GCCDLNA alloc] init];
    });
    return manager;
}

- (instancetype)init
{
    if (self = [super init]) {
        self.hasUploadLog = NO;
        self.locationSource = [NSMutableArray new];
        self.socket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        NSError *error = nil;
        if (![self.socket bindToPort:platformPort error:&error])
        {
            NSLog(@"Error binding: %@", error);
        }
        if (![self.socket joinMulticastGroup:ssdpForPlatform error:&error])
        {
            NSLog(@"Error join: %@", error);
        }
        if (![self.socket beginReceiving:&error])
        {
            NSLog(@"Error receiving: %@", error);
        }
        self.isSearchPlatform = YES;
    }
    return self;
}

//配置DLNA设备搜索的socket相关端口信息
- (void)setUpSocketForDLNA
{
    NSError *error = nil;
    if (![self.socket bindToPort:DLNAPort error:&error])
    {
        NSLog(@"Error binding: %@", error);
    }
    if (![self.socket joinMulticastGroup:ssdpForDLNA error:&error])
    {
        NSLog(@"Error join: %@", error);
    }
    if (![self.socket beginReceiving:&error])
    {
        NSLog(@"Error receiving: %@", error);
    }
}

//配置小平台设备搜索的socket相关端口信息
- (void)setUpSocketForPlatform
{
    NSError *error = nil;
    if (![self.socket bindToPort:platformPort error:&error])
    {
        NSLog(@"Error binding: %@", error);
    }
    if (![self.socket joinMulticastGroup:ssdpForPlatform error:&error])
    {
        NSLog(@"Error join: %@", error);
    }
    if (![self.socket beginReceiving:&error])
    {
        NSLog(@"Error receiving: %@", error);
    }
}

//开始搜索DLNA设备
- (void)startSearchDevice
{
    if ([GlobalData shared].scene == RDSceneHaveRDBox) {
        return;
    }
    self.isSearch = YES;
    if (!self.socket.isClosed) {
        [self socketShouldBeClose]; //先关闭当前的socket连接
    }
    [self setUpSocketForDLNA]; //配置DLNA搜索的socket地址和端口
    self.isSearchPlatform = NO;
    [self.locationSource removeAllObjects];
    if ([self.delegate respondsToSelector:@selector(GCCDLNADidStartSearchDevice:)]) {
        [self.delegate GCCDLNADidStartSearchDevice:self];
    }
    
    //发送搜索信息
    NSData * sendData = [[NSString stringWithFormat:@"M-SEARCH * HTTP/1.1\r\nMAN: \"ssdp:discover\"\r\nMX: 5\r\nHOST: %@:%d\r\nST: %@\r\n\r\n", ssdpForDLNA, DLNAPort, serviceAVTransport] dataUsingEncoding:NSUTF8StringEncoding];
    [self.socket sendData:sendData toHost:ssdpForDLNA port:DLNAPort withTimeout:-1 tag:1];
    [self performSelector:@selector(stopSearchDevice) withObject:nil afterDelay:6.f];
}

- (void)startSearchPlatform
{
    if ([GlobalData shared].isBindRD) {
        if ([HTTPServerManager checkHttpServerWithBoxIP:[GlobalData shared].RDBoxDevice.BoxIP]) {
            return;
        }
    }else if ([GlobalData shared].isBindDLNA) {
        if ([HTTPServerManager checkHttpServerWithDLNAIP:[GlobalData shared].DLNADevice.headerURL]) {
            return;
        }
    }
    
    if (self.isSearch) {
        [self resetSearch];
    }
    
    self.isSearch = YES;
    
    if (!self.socket.isClosed) {
        [self socketShouldBeClose]; //先关闭当前的socket连接
    }
    [GlobalData shared].scene = RDSceneNothing;
    self.isSearchPlatform = YES;
    
    [GlobalData shared].callQRCodeURL = @"";
    [GlobalData shared].boxCodeURL = @"";
    [GlobalData shared].secondCallCodeURL = @"";
    [GlobalData shared].thirdCallCodeURL = @"";
    
    [self setUpSocketForPlatform]; //若当前socket处于关闭状态，先配置socket地址和端口
    [self callQRcodeFromPlatform];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopSearchDevice) object:nil];
    [self performSelector:@selector(stopSearchDevice) withObject:nil afterDelay:10.f];
//    [self performSelector:@selector(startSearchDevice) withObject:nil afterDelay:6.f];
}

- (void)callQRcodeFromPlatform
{
    HSGetIpRequest * request = [[HSGetIpRequest alloc] init];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        NSInteger code = [response[@"code"] integerValue];
        if(code == 10000){
            
            NSString *localIp = response[@"result"][@"localIp"];
            NSString *hotelId = response[@"result"][@"hotelId"];
            NSString *type = response[@"result"][@"type"];
            NSString *command_port = response[@"result"][@"command_port"];
            [GlobalData shared].areaId = response[@"result"][@"area_id"];
            
            if (!self.hasUploadLog && !isEmptyString([GlobalData shared].areaId)) {
                [RDLogStatisticsAPI checkAndUploadLog];
                self.hasUploadLog = YES;
            }
            
            if (!isEmptyString(localIp) && !isEmptyString(hotelId)) {
                if ([GlobalData shared].secondCallCodeURL.length > 0) {
                    NSString * codeURL = [NSString stringWithFormat:@"http://%@:%@/%@",localIp,command_port,[type lowercaseString]];
                    
                    if (![[GlobalData shared].secondCallCodeURL isEqualToString:codeURL]) {
                        [GlobalData shared].thirdCallCodeURL = codeURL;
                    }
                }else{
                    [GlobalData shared].secondCallCodeURL = [NSString stringWithFormat:@"http://%@:%@/%@",localIp,command_port,[type lowercaseString]];
                }
                [GlobalData shared].hotelId = [hotelId integerValue];
                [GlobalData shared].scene = RDSceneHaveRDBox;
                self.isSearch = NO;
            }
        }
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        
    }];
}

//停止设备搜索
- (void)stopSearchDevice
{
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startSearchDevice) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopSearchDevice) object:nil];
    
    if (!self.socket.isClosed) {
        [self socketShouldBeClose]; //调用socket关闭
    }
    
    self.isSearch = NO;
}

- (void)resetSearch
{
    [HSGetIpRequest cancelRequest];
//    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(startSearchDevice) object:nil];
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(stopSearchDevice) object:nil];
}

- (void)socketShouldBeClose
{
    [self.socket close];
    [self.locationSource removeAllObjects];
    if ([self.delegate respondsToSelector:@selector(GCCDLNADidEndSearchDevice:)]) {
        [self.delegate GCCDLNADidEndSearchDevice:self];
    }
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag
{
    
}

- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error
{
    
}

//获取到设备反馈信息
- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(nullable id)filterContext{
    
    if (self.isSearchPlatform) {
        [self getPlatformHeadURLWith:data];
    }else{
        NSURL *location = [self deviceUrlWithData:data];
        if (location) {
           [self getDeviceInfoFromLocationURL:location];
        }
    }
}

//解析从小平台获取的SSDP的discover信息，得到小平台呼出二维码地址
- (NSString *)getPlatformHeadURLWith:(NSData *)data
{
    NSString * str = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    
    str = [str stringByReplacingOccurrencesOfString:@"\r" withString:@""];
    str = [str stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSArray * array = [str componentsSeparatedByString:@"\n"];
    NSMutableDictionary * dict = [[NSMutableDictionary alloc] init];
    
    for (NSString * infoStr in array) {
        NSArray * dictArray = [infoStr componentsSeparatedByString:@":"];
        if (dictArray.count == 2) {
            [dict setObject:[dictArray objectAtIndex:1] forKey:[dictArray objectAtIndex:0]];
        }
    }
    
    NSString * host = [dict objectForKey:@"Savor-HOST"];
    NSString * boxHost = [dict objectForKey:@"Savor-Box-HOST"];
    if (host.length || boxHost.length) {

        if ([[dict objectForKey:@"Savor-Type"] isEqualToString:@"box"]) {
            [GlobalData shared].boxCodeURL = [NSString stringWithFormat:@"http://%@:8080", [dict objectForKey:@"Savor-Box-HOST"]];
            if ([GlobalData shared].secondCallCodeURL.length > 0) {
                
                NSString * codeURL = [NSString stringWithFormat:@"http://%@:%@/small", [dict objectForKey:@"Savor-HOST"], [dict objectForKey:@"Savor-Port-Command"]];
                if (![[GlobalData shared].secondCallCodeURL isEqualToString:codeURL]) {
                    [GlobalData shared].thirdCallCodeURL = codeURL;
                }
                
            }else{
                [GlobalData shared].secondCallCodeURL = [NSString stringWithFormat:@"http://%@:%@/small", [dict objectForKey:@"Savor-HOST"], [dict objectForKey:@"Savor-Port-Command"]];
            }
            [GlobalData shared].hotelId = [[dict objectForKey:@"Savor-Hotel-ID"] integerValue];
            [GlobalData shared].scene = RDSceneHaveRDBox;
            self.isSearch = NO;
        }else{
            [GlobalData shared].callQRCodeURL = [NSString stringWithFormat:@"http://%@:%@/%@", [dict objectForKey:@"Savor-HOST"], [dict objectForKey:@"Savor-Port-Command"], [[dict objectForKey:@"Savor-Type"] lowercaseString]];
            [GlobalData shared].hotelId = [[dict objectForKey:@"Savor-Hotel-ID"] integerValue];
            [GlobalData shared].scene = RDSceneHaveRDBox;
            self.isSearch = NO;
        }
    }
    
    return nil;
}

//对设备信息进行提取解析
- (void)getDeviceInfoFromLocationURL:(NSURL *)url
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURLRequest  *request=[NSURLRequest requestWithURL:url];
        NSURLSession *session = [NSURLSession sharedSession];
        NSURLSessionDataTask *dataTask = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            
            NSString *_dataStr = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
            GDataXMLDocument *xmlDoc = [[GDataXMLDocument alloc] initWithXMLString:_dataStr options:0 error:nil];
            GDataXMLElement *xmlEle = [xmlDoc rootElement];
            GDataXMLElement * deviceEle = [[xmlEle elementsForName:@"device"] firstObject];
            if (deviceEle) {
                DeviceModel * device = [[DeviceModel alloc] init];
                device.headerURL = [NSString stringWithFormat:@"%@://%@:%@", [url scheme], [url host], [url port]];
                NSArray * deviceArray = [deviceEle children];
                for (GDataXMLElement *element in deviceArray) {
                    if ([[element.name lowercaseString] isEqualToString:@"friendlyname"]) {
                        
                        device.name = [element stringValue];
                        
                    }else if ([[element.name lowercaseString] isEqualToString:@"udn"]) {
                        
                        device.UUID = [element stringValue];
                        
                    }else if ([[element.name lowercaseString] isEqualToString:@"servicelist"]){
                        
                        NSArray * serviceArray = [element children];
                        for (GDataXMLElement * service in serviceArray) {
                            if ([[service.name lowercaseString] isEqualToString:@"service"]) {
                                if ([[service stringValue] containsString:serviceAVTransport]) {
                                    [device.AVTransport setInfoWithArray:[service children]];
                                }
                                if ([[service stringValue] containsString:serviceRendering]) {
                                    [device.Rendering setInfoWithArray:[service children]];
                                }
                            }
                        }
                        
                    }else if ([[element.name lowercaseString] isEqualToString:@"devicelist"]){
                        NSArray * deviceList = [element children];
                        for (GDataXMLElement * subDevice in deviceList) {
                            if ([[subDevice.name lowercaseString] isEqualToString:@"device"]) {
                                NSArray * subDeviceList = [subDevice children];
                                for (GDataXMLElement * subServiceList in subDeviceList) {
                                    if ([[subServiceList.name lowercaseString] isEqualToString:@"friendlyname"]) {
                                        
                                        device.name = [subServiceList stringValue];
                                        
                                    }else if ([[subServiceList.name lowercaseString] isEqualToString:@"servicelist"]){
                                        
                                        NSArray * serviceArray = [subServiceList children];
                                        for (GDataXMLElement * service in serviceArray) {
                                            if ([[service.name lowercaseString] isEqualToString:@"service"]) {
                                                if ([[service stringValue] containsString:serviceAVTransport]) {
                                                    [device.AVTransport setInfoWithArray:[service children]];
                                                }
                                                if ([[service stringValue] containsString:serviceRendering]) {
                                                    [device.Rendering setInfoWithArray:[service children]];
                                                }
                                            }
                                        }
                                        
                                    }
                                }
                            }
                        }
                    }
                }
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (device.AVTransport.controlURL) {
                        if ([self.delegate respondsToSelector:@selector(GCCDLNA:didGetDevice:)]) {
                            [self.delegate GCCDLNA:self didGetDevice:device];
                        }
                        if ([GlobalData shared].scene == RDSceneNothing) {
                            [GlobalData shared].scene = RDSceneHaveDLNA;
                            self.isSearch = NO;
                        }
                    }
                });
            }
        }];
        [dataTask resume];
    });
}

// 解析搜索设备获取Location
- (NSURL *)deviceUrlWithData:(NSData *)data{
    NSString *string = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSArray *subArray = [string componentsSeparatedByString:@"\n"];
    for (int j = 0 ; j < subArray.count; j++){
        NSArray *dicArray = [subArray[j] componentsSeparatedByString:@": "];
        if ([[dicArray[0] lowercaseString] isEqualToString:@"location"]) {
            if (dicArray.count > 1) {
                NSString *location = dicArray[1];
                location = [location stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];;
                BOOL isHave = NO;
                for (NSString * str in self.locationSource) {
                    if ([str isEqualToString:location]) {
                        isHave = YES;
                    }
                }
                if (!isHave) {
                    [self.locationSource addObject:location];
                    return [NSURL URLWithString:location];
                }
                return nil;
            }
        }
    }
    return nil;
}

@end
