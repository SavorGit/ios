//
//  ImageTextDetailViewController.m
//  小热点餐厅端Demo
//
//  Created by 王海朋 on 2017/7/4.
//  Copyright © 2017年 wanghaipeng. All rights reserved.
//

#import "ImageTextDetailViewController.h"
#import "Masonry.h"
#import "CreateWealthModel.h"
#import "CreatWealthDetialTableViewCell.h"
#import "HotTopicShareView.h"

@interface ImageTextDetailViewController ()<UIScrollViewDelegate,UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) UIWebView * webView;
@property (nonatomic, strong) UIView * testView;

@property (nonatomic, strong) UITableView * tableView; //表格展示视图
@property (nonatomic, strong) NSMutableArray * dataSource; //数据源

@end

@implementation ImageTextDetailViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self createWebView];
    [self setUpDatas];

}

- (void)createWebView
{
    CGFloat width = [UIScreen mainScreen].bounds.size.width;
    CGFloat height = self.view.bounds.size.height - (self.navigationController.navigationBar.frame.origin.y + self.navigationController.navigationBar.frame.size.height);
    self.webView = [[UIWebView alloc] init];
    self.webView.frame = CGRectMake(0, 0, width, height);
    NSURLRequest * request = [[NSURLRequest alloc] initWithURL:[NSURL URLWithString:@"http://admin.littlehotspot.com/content/3505.html"]];
    [self.webView loadRequest:request];
    self.webView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.webView];
    
    self.testView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 0)];
    self.testView.backgroundColor = [UIColor lightGrayColor];
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
    CGFloat theight = (self.dataSource.count *150 + 50) + 8 + 130;
    CGFloat height = self.webView.scrollView.contentSize.height;
    CGRect frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, theight);
    CGSize contentSize = self.webView.scrollView.contentSize;
    frame.origin.y = height + 10;
    self.testView.frame = frame;
    [self.webView.scrollView addSubview:self.testView];
    [self.webView.scrollView setContentSize:CGSizeMake(contentSize.width, contentSize.height + theight + 10 + 8)];
    
    [self addObserver];
    
    [self shareBoardByDefined];
}

- (void)shareBoardByDefined {
    
    BOOL hadInstalledWeixin = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"weixin://"]];
    BOOL hadInstalledQQ = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"mqq://"]];
    
    NSMutableArray *titlearr = [NSMutableArray arrayWithCapacity:5];
    NSMutableArray *imageArr = [NSMutableArray arrayWithCapacity:5];
    
    int startIndex = 0;
    
//    if (hadInstalledWeixin) {
//        [titlearr addObjectsFromArray:@[@"微信", @"微信朋友圈"]];
//        [imageArr addObjectsFromArray:@[@"wechat",@"friend"]];
//    } else {
//        startIndex += 2;
//    }
//    
//    if (hadInstalledQQ) {
//        [titlearr addObjectsFromArray:@[@"QQ"]];
//        [imageArr addObjectsFromArray:@[@"qq"]];
//    } else {
//        startIndex += 2;
//    }
    
    [titlearr addObjectsFromArray:@[@"微信", @"微信朋友圈"]];
    [imageArr addObjectsFromArray:@[@"wechat",@"friend"]];
    
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

#pragma mark - 初始化下方推荐数据
- (void)setUpDatas{
    
    _dataSource = [[NSMutableArray alloc] initWithCapacity:100];
    
    for (int i = 0; i < 3; i ++) {
        CreateWealthModel *model = [[CreateWealthModel alloc] init];
        model.type = 0;
        if (i == 2) {
            model.type = 1;
        }else if (i == 3 || i == 5 || i == 6){
            model.type = 2;
        }
        model.title = @"这是新闻的标题";
        model.imageUrl = @"4.jpg";
        model.source = @"网易新闻";
        model.time = @"2017.06.19";
        model.sourceImage = @"sourceImage";
        [_dataSource addObject:model];
    }
    [self.tableView reloadData];
}

#pragma mark -- 懒加载
- (UITableView *)tableView
{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor darkGrayColor];
        _tableView.backgroundView = nil;
        _tableView.scrollEnabled = NO;
        [self.testView addSubview:_tableView];
        
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(138);
            make.left.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.right.mas_equalTo(0);
        }];

        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, 50)];
        headView.backgroundColor = [UIColor clearColor];
        UILabel *recommendLabel = [[UILabel alloc] init];
        recommendLabel.frame = CGRectMake(10, 10, 100, 30);
        recommendLabel.textColor = [UIColor blackColor];
        recommendLabel.font = [UIFont systemFontOfSize:16];
        recommendLabel.text = @"为您推荐";
        [headView addSubview:recommendLabel];
        _tableView.tableHeaderView = headView;
    }
    
    return _tableView;
}

#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellID = @"imageTextTableCell";
    CreatWealthDetialTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
    if (cell == nil) {
        cell = [[CreatWealthDetialTableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
    }
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.contentView.backgroundColor = [UIColor clearColor];
    
    CreateWealthModel * model = [self.dataSource objectAtIndex:indexPath.row];
    [cell configModelData:model];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150.f;
}

- (void)dealloc{
    
    [self removeObserver];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

@end