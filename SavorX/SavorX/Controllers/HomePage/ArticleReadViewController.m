//
//  ArticleReadViewController.m
//  SavorX
//
//  Created by 郭春城 on 17/2/13.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "ArticleReadViewController.h"
#import "UMCustomSocialManager.h"

@interface ArticleReadViewController ()<UIWebViewDelegate>

@property (nonatomic, strong) UIImage * image;
@property (nonatomic, strong) HSVodModel * model;;
@property (nonatomic, strong) UIButton * collectButton;
@property (nonatomic, strong) UIWebView * webView;

@end

@implementation ArticleReadViewController

- (instancetype)initWithVodModel:(HSVodModel *)model andImage:(UIImage *)image
{
    if (self = [super init]) {
        self.image = image;
        self.model = model;
        self.title = model.title;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self setupViews];
}

- (void)setupViews
{
    self.title = @"";
    
    UIBarButtonItem * shareItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"icon_share"] style:UIBarButtonItemStyleDone target:self action:@selector(shareAction)];
    self.collectButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.collectButton setImage:[UIImage imageNamed:@"icon_collect"] forState:UIControlStateNormal];
    [self.collectButton setImage:[UIImage imageNamed:@"icon_collect_yes"] forState:UIControlStateSelected];
    self.collectButton.frame = CGRectMake(0, 0, 40, 35);
    [self.collectButton addTarget:self action:@selector(collectAction) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * collectItem = [[UIBarButtonItem alloc] initWithCustomView:self.collectButton];
    self.navigationItem.rightBarButtonItems = @[shareItem, collectItem];
    
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"MyFavorites"] isKindOfClass:[NSArray class]]) {
        NSMutableArray *theArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"MyFavorites"]];
        __block BOOL iscollect = NO;
        [theArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[obj objectForKey:@"contentURL"] isEqualToString:self.model.contentURL]) {
                iscollect = YES;
                *stop = YES;
                return;
            }
        }];
        self.collectButton.selected = iscollect;
    }
    
    self.webView = [[UIWebView alloc] init];
    self.webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView];
    [self.webView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    self.webView.delegate = self;
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self.webView;
    NSURLRequest * request = [NSURLRequest requestWithURL:[NSURL URLWithString:[[self.model.contentURL stringByAppendingString:@"?location=newRead"] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    self.webView.opaque = NO;
    [self.webView loadRequest:request];
    [MBProgressHUD showWebLoadingHUDInView:self.webView];
}

- (void)shareAction
{
    [UMCustomSocialManager defaultManager].image = self.image;
    [[UMCustomSocialManager defaultManager] showUMSocialSharedWithModel:self.model andController:self andType:0];
    [SAVORXAPI postUMHandleWithContentId:@"details_page_share" key:nil value:nil];
}

- (void)collectAction
{
    if (!self.model.contentURL || !(self.model.contentURL.length > 0)) {
        [MBProgressHUD showTextHUDwithTitle:@"该内容暂不支持收藏" delay:1.5f];
    }
    
    NSMutableArray *favoritesArray = [NSMutableArray array];
    if ([[[NSUserDefaults standardUserDefaults] objectForKey:@"MyFavorites"] isKindOfClass:[NSArray class]]) {
        favoritesArray = [NSMutableArray arrayWithArray:[[NSUserDefaults standardUserDefaults] objectForKey:@"MyFavorites"]];
    }
    if (self.collectButton.selected) {
        [favoritesArray enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([[obj objectForKey:@"contentURL"] isEqualToString:self.model.contentURL]) {
                [favoritesArray removeObject:obj];
                *stop = YES;
            }
        }];
        [SAVORXAPI postUMHandleWithContentId:self.model.cid withType:cancleCollectHandle];
        [MBProgressHUD showSuccessHUDInView:self.view title:@"取消成功"];
        [SAVORXAPI postUMHandleWithContentId:@"details_page_cancel_collection" key:@"details_page_cancel_collection" value:@"success"];
        [[NSUserDefaults standardUserDefaults] setObject:favoritesArray forKey:@"MyFavorites"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.collectButton.selected = NO;
    }else{
        [SAVORXAPI postUMHandleWithContentId:self.model.cid withType:collectHandle];
        [favoritesArray addObject:[self.model toDictionary]];
        [MBProgressHUD showSuccessHUDInView:self.view title:@"收藏成功"];
        [SAVORXAPI postUMHandleWithContentId:@"details_page_collection" key:@"details_page_collection" value:@"success"];
        [[NSUserDefaults standardUserDefaults] setObject:favoritesArray forKey:@"MyFavorites"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        self.collectButton.selected = YES;
    }
}

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType
{
    if ([request.URL.absoluteString hasSuffix:@"mp4"]) {
        return NO;
    }
    return YES;
}

- (void)navBackButtonClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [SAVORXAPI postUMHandleWithContentId:@"details_page_back" key:nil value:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView
{
    [MBProgressHUD hideHUDForView:self.webView animated:NO];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
