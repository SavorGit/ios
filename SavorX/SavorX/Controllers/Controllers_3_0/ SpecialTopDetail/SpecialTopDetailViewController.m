//
//  SpecialTopDetailViewController.m
//  SavorX
//
//  Created by 王海朋 on 2017/7/7.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "SpecialTopDetailViewController.h"
#import "Masonry.h"
#import "HotTopicShareView.h"

@interface SpecialTopDetailViewController ()

@property (nonatomic, strong) UIWebView * webView;
@property (nonatomic, strong) UIView * testView;

@end

@implementation SpecialTopDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createWebView];
}

- (void)createWebView
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = self.view.bounds.size.height - (self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height);
    self.webView = [[UIWebView alloc] init];
    self.webView.frame = CGRectMake(0, 0, width, height);
    NSString *urlStr;
    if (!isEmptyString(self.specilDetailModel.contentURL)) {
        urlStr =  [NSString stringWithFormat:@"%@?sourceid=1",self.specilDetailModel.contentURL];
    }else{
        urlStr = @"";
    }
    NSURLRequest * request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:urlStr]];
    [self.webView loadRequest:request];
    self.webView.backgroundColor = [UIColor whiteColor];  
    [self.view addSubview:self.webView];
    
    self.testView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 140)];
    self.testView.backgroundColor = [UIColor clearColor];
    [self.webView.scrollView addSubview:self.testView];
    [self addObserver];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"contentSize"]) {
        [self footViewShouldBeReset];
    }
}

- (void)footViewShouldBeReset
{
    [self removeObserver];
    
    if (self.testView.superview) {
        [self.testView removeFromSuperview];
    }
    CGFloat theight =140;
    CGFloat height = self.webView.scrollView.contentSize.height;
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, theight);
    CGSize contentSize = self.webView.scrollView.contentSize;
    frame.origin.y = height + 10;
    
    self.testView.frame = frame;
    [self.webView.scrollView addSubview:self.testView];
    [self.webView.scrollView setContentSize:CGSizeMake(contentSize.width, contentSize.height + theight + 10 )];
    
    [self addObserver];
    
    [self shareBoardByDefined];
}

- (void)shareBoardByDefined {
    
    BOOL hadInstalledWeixin = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]];
    BOOL hadInstalledQQ = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqq://"]];
    
    NSMutableArray *titlearr = [NSMutableArray arrayWithCapacity:5];
    NSMutableArray *imageArr = [NSMutableArray arrayWithCapacity:5];
    
    int startIndex = 0;
    
        if (hadInstalledWeixin) {
            [titlearr addObjectsFromArray:@[@"微信", @"微信朋友圈"]];
            [imageArr addObjectsFromArray:@[@"wechat",@"friend"]];
        } else {
            startIndex += 2;
        }
    
        if (hadInstalledQQ) {
            [titlearr addObjectsFromArray:@[@"QQ"]];
            [imageArr addObjectsFromArray:@[@"qq"]];
        } else {
            startIndex += 1;
        }
    
    [titlearr addObjectsFromArray:@[@"微信", @"微信朋友圈"]];
    [imageArr addObjectsFromArray:@[@"WeChat",@"friends"]];
    
    [titlearr addObjectsFromArray:@[@"QQ"]];
    [imageArr addObjectsFromArray:@[@"qq"]];
    
    [titlearr addObjectsFromArray:@[@"微博"]];
    [imageArr addObjectsFromArray:@[@"weibo"]];
    
    HotTopicShareView *shareView = [[HotTopicShareView alloc] initWithShareHeadOprationWith:titlearr andImageArry:imageArr andY:0];
    [self.testView addSubview:shareView];
    
    [shareView setBtnClick:^(NSInteger btnTag) {
        NSLog(@"\n点击第几个====%d\n当前选中的按钮title====%@",(int)btnTag,titlearr[btnTag]);
        switch (btnTag + startIndex) {
            case 0: {
                // 微信
                
            }
                break;
            case 1: {
                // 微信朋友圈
                
            }
                break;
            case 2: {
                // QQ
                
            }
                break;
            case 3: {
                // 微博
                
            }
                break;
            default:
                break;
        }
    }];
}

- (void)addObserver
{
    [self.webView.scrollView addObserver:self forKeyPath:@"contentSize" options:NSKeyValueObservingOptionNew context:nil];
}

- (void)removeObserver
{
    [self.webView.scrollView removeObserver:self forKeyPath:@"contentSize" context:nil];
}

- (void)dealloc{
    
    [self removeObserver];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end
