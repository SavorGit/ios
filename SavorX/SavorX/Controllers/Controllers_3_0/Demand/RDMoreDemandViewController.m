//
//  RDMoreDemandViewController.m
//  SavorX
//
//  Created by 郭春城 on 2017/8/10.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "RDMoreDemandViewController.h"
#import "RDDemandTableViewCell.h"
#import "WebViewController.h"

@interface RDMoreDemandViewController ()<UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) NSArray * dataSource;

@property (nonatomic, strong) UITableView * tableView;

@end

@implementation RDMoreDemandViewController

- (instancetype)initWithModelSource:(NSArray *)source
{
    if (self = [super init]) {
        self.dataSource = [NSArray arrayWithArray:source];
        [self setupViews];
    }
    return self;
}

- (void)setupViews
{
    
    UIView * topView = [[UIImageView alloc] initWithFrame:CGRectZero];
    topView.userInteractionEnabled = YES;
    topView.contentMode = UIViewContentModeScaleToFill;
    topView.backgroundColor = kThemeColor;
    [self.view addSubview:topView];
    [topView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth, 64));
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
    }];
    
    UIButton * backButton = [[UIButton alloc] initWithFrame:CGRectMake(5,20, 40, 44)];
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateNormal];
    [backButton setImage:[UIImage imageNamed:@"back"] forState:UIControlStateSelected];
    [backButton addTarget:self action:@selector(navBackButtonClicked:) forControlEvents:UIControlEventTouchUpInside];
    [topView addSubview:backButton];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, kMainBoundsHeight) style:UITableViewStylePlain];
    self.tableView.backgroundColor = [UIColor clearColor];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    [self.tableView registerClass:[RDDemandTableViewCell class] forCellReuseIdentifier:@"DemandCell"];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(topView.mas_bottom);
        make.left.bottom.right.mas_equalTo(0);
    }];
    self.tableView.contentInset = UIEdgeInsetsMake(0, 0, 10, 0);
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.dataSource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RDDemandTableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"DemandCell" forIndexPath:indexPath];
    
    CreateWealthModel * model = [self.dataSource objectAtIndex:indexPath.row];
    [cell configWithInfo:model];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    __weak typeof(self) weakSelf  = self;
    cell.clickHandel = ^(BOOL isLeftClick, CreateWealthModel *model) {
        
        if (isLeftClick) {
            [weakSelf playOnPhone:model];
        }else{
            [weakSelf playOnTV:model];
        }
        
    };
    
    return cell;
}

- (void)playOnTV:(CreateWealthModel *)model
{
    [self.navigationController popViewControllerAnimated:YES];
    if (self.delegate && [self.delegate respondsToSelector:@selector(playOnTVButtonDidClickedWithModel:)]) {
        [self.delegate playOnTVButtonDidClickedWithModel:model];
    }
}

- (void)playOnPhone:(CreateWealthModel *)model
{
    WebViewController * web = [[WebViewController alloc] initWithModel:model categoryID:-2];
    [self.navigationController pushViewController:web animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat scale = kMainBoundsWidth / 375;
    CGFloat contentWidth = kMainBoundsWidth - 30 * scale;
    CGFloat height = contentWidth * .646 + 69;
    return height + 10;
}

- (void)viewWillAppear:(BOOL)animated
{
    [self.navigationController setNavigationBarHidden:YES animated:animated];
    [MobClick beginLogPageView:NSStringFromClass([self class])];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    self.navigationController.interactivePopGestureRecognizer.delegate = (id)self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
