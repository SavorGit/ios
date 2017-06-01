//
//  RDScreenLocationView.m
//  定位功能测试
//
//  Created by 郭春城 on 2017/5/23.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "RDScreenLocationView.h"
#import "Masonry.h"
#import "RestaurantListModel.h"
#import "HSHomeRestaurantList.h"
#import "RestaurantListTableViewCell.h"
#import "RDLocationManager.h"
#import "RestaurantListViewController.h"
#import "WMPageController.h"

@interface RDScreenLocationView ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIView * loadingView; //加载的提示控件
@property (nonatomic, strong) UIView * faildView; //失败的提示控件
@property (nonatomic, strong) UIView * compeleteView; //加载完成的展示控件
@property (nonatomic, strong) UITableView * listView; //展示列表
@property (nonatomic, strong) UIView * bottomTabView; //底部选择器
@property (nonatomic, strong) NSMutableArray * dataSource; //数据源
@property (nonatomic, copy) NSString * cachePath;

@end

@implementation RDScreenLocationView

- (void)showWithStatus:(RDScreenLocationStatus)status
{
    if (!self.superview) {
        [self showWithAnimation];
    }
    
    UIView * view = [self viewWithTag:677];
    if (view) {
        [view removeFromSuperview];
    }
    
    switch (status) {
        case RDScreenLocation_Loading:
        {
            [self addSubview:self.loadingView];
            [self makeConstraintsWithUpstatusView:self.loadingView];
            [self readCacheDatas];
        }
            break;
            
        case RDScreenLocation_Compelete:
        {
            [self addSubview:self.compeleteView];
            [self makeConstraintsWithUpstatusView:self.compeleteView];
            [self.listView reloadData];
        }
            break;
            
        case RDScreenLocation_Faild:
        {
            [self addSubview:self.faildView];
            [self makeConstraintsWithUpstatusView:self.faildView];
        }
            break;
            
        default:
            break;
    }
}

//读取缓存数据
- (void)readCacheDatas{
    
    [self.dataSource removeAllObjects];
    BOOL isCache = [[NSFileManager defaultManager] fileExistsAtPath:self.cachePath];
    if (isCache) {
        
        //如果本地缓存的有数据，则先从本地读取缓存的数据
        NSArray * listArray = [NSArray arrayWithContentsOfFile:self.cachePath];
        for(NSDictionary *dict in listArray){
            
            RestaurantListModel *model = [[RestaurantListModel alloc] initWithDictionary:dict];
            [self.dataSource addObject:model];
        }
        [self showWithStatus:RDScreenLocation_Compelete];
    }
    
    [[RDLocationManager manager] startCheckUserLocationWithHandle:^(CLLocationDegrees latitude, CLLocationDegrees longitude, BOOL isUpdate) {
        NSString *latitudeStr = [NSString stringWithFormat:@"%f",latitude];
        NSString *longitudeStr = [NSString stringWithFormat:@"%f",longitude];
        if (isUpdate) {
            [self setUpDatasWithLatitude:latitudeStr longitude:longitudeStr];
        }else if (!isCache) {
            [self setUpDatasWithLatitude:latitudeStr longitude:longitudeStr];
        }
    }];
}

// 初始化数据
- (void)setUpDatasWithLatitude:(NSString *)latitude longitude:(NSString *)longitude{

    HSHomeRestaurantList *request = [[HSHomeRestaurantList alloc] initWithLng:longitude lat:latitude];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self.dataSource removeAllObjects];
        NSDictionary *dic = (NSDictionary *)response;
        NSArray * listArray = [dic objectForKey:@"result"];
        [SAVORXAPI saveFileOnPath:self.cachePath withArray:listArray];
        
        //解析获取当前分类下数据列表
        for(NSDictionary *dict in listArray){
            RestaurantListModel *model = [[RestaurantListModel alloc] initWithDictionary:dict];
            [self.dataSource addObject:model];
        }
        if (self.superview) {
            [self showWithStatus:RDScreenLocation_Compelete];
        }
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
         [self showWithStatus:RDScreenLocation_Faild];
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
         [self showWithStatus:RDScreenLocation_Faild];
    }];
}

//动画显示
- (void)showWithAnimation
{
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    [UIView animateWithDuration:.2f animations:^{
        self.alpha = 1.f;
    } completion:^(BOOL finished) {
        
    }];
    for (NSInteger i = 0; i < 4; i++) {
        UIButton * button = [self.bottomTabView viewWithTag:10 + i];
        CGPoint center = button.center;
        center.y = self.bottomTabView.frame.size.height / 2 - 10;
        if (button) {
            [UIView animateWithDuration:.5f delay:i * .05f usingSpringWithDamping:.6f initialSpringVelocity:10 options:UIViewAnimationOptionCurveLinear animations:^{
                button.center = center;
            } completion:^(BOOL finished) {
                
            }];
        }
    }
}

//动画隐藏
- (void)hiddenWithAnimation
{
    [HSHomeRestaurantList cancelRequest];
    for (NSInteger i = 0; i < 4; i++) {
        UIButton * button = [self.bottomTabView viewWithTag:10 + i];
        CGPoint center = button.center;
        center.y = self.bottomTabView.frame.size.height + button.frame.size.width / 2;
        if (button) {
            [UIView animateWithDuration:.5f delay:0.15f - i * 0.05f usingSpringWithDamping:.6f initialSpringVelocity:10 options:UIViewAnimationOptionCurveEaseOut animations:^{
                button.center = center;
            } completion:^(BOOL finished) {
                
            }];
        }
    }
    [UIView animateWithDuration:.1f delay:.3f options:UIViewAnimationOptionCurveLinear animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)makeConstraintsWithUpstatusView:(UIView *)view
{
    view.tag = 677;
    [view mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.equalTo(self.bottomTabView.mas_top).offset(0);
    }];
}

- (instancetype)init
{
    if (self = [super initWithFrame:[UIScreen mainScreen].bounds]) {
        [self setupViews];
         self.dataSource = [NSMutableArray new];
         self.cachePath = [NSString stringWithFormat:@"%@RestaurantHomeList.plist", CategoryCache];
    }
    return self;
}

- (void)setupViews
{
    UIView * whiteView = [[UIView alloc] initWithFrame:CGRectZero];
    whiteView.backgroundColor = [UIColor whiteColor];
    whiteView.alpha = 0.3f;
    [self addSubview:whiteView];
    [whiteView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    UIBlurEffect *effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    UIVisualEffectView *effectView = [[UIVisualEffectView alloc] initWithEffect:effect];
    [self addSubview:effectView];
    [effectView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    self.bottomTabView = [[UIView alloc] initWithFrame:CGRectMake(0, self.frame.size.height / 3 * 2, self.frame.size.width, self.frame.size.height / 3)];
    self.bottomTabView.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.bottomTabView];
    [self.bottomTabView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(self.frame.size.height / 3);
    }];
    
    //创建图片数组
    NSArray * tabArray = @[@"tupian", @"shipin", @"huandengpian", @"wenjian"];
    //循环创建4个button
    for (NSInteger i = 0; i < 4; i++) {
        UIImage * tabImage = [UIImage imageNamed:[tabArray objectAtIndex:i]];
        
        UIButton * tabButton = [UIButton buttonWithType:UIButtonTypeCustom];
        [tabButton setImage:tabImage forState:UIControlStateNormal];
        [tabButton setExclusiveTouch:YES];
        [self.bottomTabView addSubview:tabButton];
        
        tabButton.tag = 10 + i;
        //计算button的宽度
        CGFloat width = self.bottomTabView.frame.size.width / 4;
        //计算对应下标button中心距离左边的距离
        CGFloat distance = width * i + width / 2;
        
        tabButton.frame = CGRectMake(distance, self.bottomTabView.frame.size.height, width, width);
        tabButton.center = CGPointMake(distance, self.bottomTabView.frame.size.height + width / 2);
        
        [tabButton addTarget:self action:@selector(tabButtonDidBeClicked:) forControlEvents:UIControlEventTouchUpInside];
    }
    
    UIButton * backButton = [UIButton buttonWithType:UIButtonTypeCustom];
    backButton.layer.borderColor = [UIColor grayColor].CGColor;
    backButton.layer.borderWidth = .5f;
    [backButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"guanbi"] forState:UIControlStateNormal];
    [self.bottomTabView addSubview:backButton];
    [backButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(-1);
        make.bottom.mas_equalTo(1);
        make.right.mas_equalTo(1);
        make.height.mas_equalTo(50);
    }];
    [backButton addTarget:self action:@selector(hiddenWithAnimation) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel * tabTitlteLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    tabTitlteLabel.text = @"请选择您要投屏的资料";
    tabTitlteLabel.font = [UIFont systemFontOfSize:16];
    tabTitlteLabel.textColor = [UIColor blackColor];
    tabTitlteLabel.textAlignment = NSTextAlignmentCenter;
    [self.bottomTabView addSubview:tabTitlteLabel];
    [tabTitlteLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.height.mas_equalTo(50);
    }];
    
    self.alpha = 0.f;
}

- (void)tabButtonDidBeClicked:(UIButton *)button
{
    [self hiddenWithAnimation];
    if (self.delegate && [self.delegate respondsToSelector:@selector(RDScreenLocationViewDidSelectTabButtonWithIndex:)]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.4f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.delegate RDScreenLocationViewDidSelectTabButtonWithIndex:button.tag - 10];
        });
    }
}

- (void)moreButtonDidBeClicked
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(RDScreenLocationViewDidSelectMoreButton)]) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.4f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.delegate RDScreenLocationViewDidSelectMoreButton];
        });
    }
    [self hiddenWithAnimation];
}

#pragma mark -- UITableViewDelegate && UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RestaurantListTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"RDLocationCell" forIndexPath:indexPath];
    
    RestaurantListModel * model = [self.dataSource objectAtIndex:indexPath.row];
    [cell configModelData:model];
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    cell.backgroundColor = [UIColor clearColor];
    cell.bgView.backgroundColor = [UIColor clearColor];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat height = self.frame.size.height / 3 * 2;
    height = height - 183;
    height = height / 3;
    
    return height;
}

//加载完成的展示控件
- (UIView *)compeleteView
{
    if (!_compeleteView) {
        _compeleteView = [[UIView alloc] initWithFrame:CGRectZero];
        
        UIView * upView = [[UIView alloc] initWithFrame:CGRectZero];
        [_compeleteView addSubview:upView];
        [upView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.height.mas_equalTo(100);
        }];
        
        UIImageView * upImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [upImageView setImage:[UIImage imageNamed:@"zctpdct"]];
        [upView addSubview:upImageView];
        [upImageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.size.mas_equalTo(CGSizeMake(205, 28));
            make.centerX.mas_equalTo(0);
            make.centerY.mas_equalTo(10);
        }];
        
        UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
        [button setImage:[UIImage imageNamed:@"ckgd"] forState:UIControlStateNormal];
        [_compeleteView addSubview:button];
        [button mas_makeConstraints:^(MASConstraintMaker *make) {
            make.bottom.mas_equalTo(-43);
            make.right.mas_equalTo(-5);
            make.size.mas_equalTo(CGSizeMake(100, 30));
        }];
        [button addTarget:self action:@selector(moreButtonDidBeClicked) forControlEvents:UIControlEventTouchUpInside];
        
        [_compeleteView addSubview:self.listView];
        [self.listView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(upView.mas_bottom).offset(0);
            make.left.mas_equalTo(0);
            make.bottom.mas_equalTo(button.mas_top).offset(-10);
            make.right.mas_equalTo(0);
        }];
    }
    return _compeleteView;
}

- (UITableView *)listView
{
    if (!_listView) {
        _listView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        [_listView registerClass:[RestaurantListTableViewCell class] forCellReuseIdentifier:@"RDLocationCell"];
        _listView.backgroundColor = [UIColor clearColor];
        _listView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _listView.delegate = self;
        _listView.dataSource = self;
    }
    return _listView;
}

//加载的提示控件
- (UIView *)loadingView
{
    if (!_loadingView) {
        _loadingView = [[UIView alloc] initWithFrame:CGRectZero];
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [imageView setImage:[UIImage imageNamed:@"jiazai"]];
        [_loadingView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.centerY.mas_equalTo(-20);
            make.size.mas_equalTo(CGSizeMake(35, 35));
        }];
        
        CABasicAnimation * animation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
        animation.fromValue = [NSNumber numberWithInteger:0];
        animation.toValue = [NSNumber numberWithDouble:M_PI * 2];
        animation.repeatCount = MAXFLOAT;
        animation.duration = 1.f;
        animation.removedOnCompletion = NO;
        animation.fillMode = kCAFillModeForwards;
        [imageView.layer addAnimation:animation forKey:nil];
        
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.font = [UIFont systemFontOfSize:16];
        label.numberOfLines = 2;
        NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc] init];
        paragraphStyle.lineSpacing = 5;
        paragraphStyle.alignment = NSTextAlignmentCenter;
        NSMutableAttributedString * str = [[NSMutableAttributedString alloc] initWithString:@"正快速帮您查找支持投屏的餐厅\n客官请稍后~"];
        [str addAttribute:NSParagraphStyleAttributeName value:paragraphStyle range:NSMakeRange(0, str.length)];
        label.attributedText = str;
        [_loadingView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(imageView.mas_bottom).offset(10);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.centerX.mas_equalTo(0);
            make.height.mas_equalTo(50);
        }];
    }
    return _loadingView;
}

//失败的提示控件
- (UIView *)faildView
{
    if (!_faildView) {
        _faildView = [[UIView alloc] initWithFrame:CGRectZero];
        UIImageView * imageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        [imageView setImage:[UIImage imageNamed:@"shibai"]];
        imageView.userInteractionEnabled = YES;
        [_faildView addSubview:imageView];
        [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.centerX.mas_equalTo(0);
            make.centerY.mas_equalTo(-30);
            make.size.mas_equalTo(CGSizeMake(61, 51));
        }];
        UITapGestureRecognizer *singleTapRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(failViewTap)];
        singleTapRecognizer.numberOfTapsRequired = 1;
        [_faildView addGestureRecognizer:singleTapRecognizer];
        
        UILabel * label = [[UILabel alloc] initWithFrame:CGRectZero];
        label.font = [UIFont systemFontOfSize:16];
        label.textAlignment = NSTextAlignmentCenter;
        label.text = @"加载失败, 点击重试";
        [_faildView addSubview:label];
        [label mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(imageView.mas_bottom).offset(10);
            make.left.mas_equalTo(0);
            make.right.mas_equalTo(0);
            make.centerX.mas_equalTo(0);
            make.height.mas_equalTo(20);
        }];
    }
    return _faildView;
}

- (void)failViewTap{
    
    [self showWithStatus:RDScreenLocation_Loading];
    
}
@end
