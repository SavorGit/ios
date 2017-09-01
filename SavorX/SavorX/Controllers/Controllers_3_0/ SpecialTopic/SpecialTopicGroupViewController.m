//
//  SpecialTopicGroupViewController.m
//  SavorX
//
//  Created by 王海朋 on 2017/8/29.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "SpecialTopicGroupViewController.h"
#import "SpecialTextCell.h"
#import "SpecialImageCell.h"
#import "SpecialArtCell.h"
#import "SpecialTitleCell.h"
#import "SpecialHeaderView.h"
#import "RDFrequentlyUsed.h"
#import "SpecialTopGroupRequest.h"
#import "ImageTextDetailViewController.h"
#import "ImageArrayViewController.h"
#import "WebViewController.h"
#import "SpecialListViewController.h"

@interface SpecialTopicGroupViewController ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray * dataSource; //数据源
@property (nonatomic, assign) NSInteger categoryID;
@property (nonatomic, copy) NSString * cachePath;
@property (nonatomic, strong)  CreateWealthModel * topModel; //数据源
@property (nonatomic, copy) NSString *topGroupId;

@end

@implementation SpecialTopicGroupViewController

- (instancetype)initWithtopGroupID:(NSInteger )topGroupId
{
    if (self = [super init]) {
        self.topGroupId = [NSString stringWithFormat:@"%ld",topGroupId];;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initInfo];
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.cachePath]) {
        
        //如果本地缓存的有数据，则先从本地读取缓存的数据
        NSDictionary * dataDict = [NSDictionary dictionaryWithContentsOfFile:self.cachePath];
        
        self.topModel = [[CreateWealthModel alloc] init];
        self.topModel.name = [dataDict objectForKey:@"name"];
        self.topModel.title = [dataDict objectForKey:@"title"];
        self.topModel.img_url = [dataDict objectForKey:@"img_url"];
        self.topModel.desc = [dataDict objectForKey:@"desc"];
        
        NSArray *resultArr = [dataDict objectForKey:@"list"];
        for(int i = 0; i < resultArr.count; i ++){
            CreateWealthModel *tmpModel = [[CreateWealthModel alloc] initWithDictionary:resultArr[i]];
            [self.dataSource addObject:tmpModel];
        }
        if (dataDict != nil) {
            [self.tableView reloadData];
        }
        [self dataRequest];
    }else{
        [self showLoadingView];
        [self dataRequest];
    }
}

- (void)initInfo{
    self.categoryID = 103;
    _dataSource = [[NSMutableArray alloc] initWithCapacity:100];
    self.cachePath = [NSString stringWithFormat:@"%@%@.plist", CategoryCache, @"SpecialTopicGroup"];
}

- (void)dataRequest{
    
    SpecialTopGroupRequest * request = [[SpecialTopGroupRequest alloc] initWithId:self.topGroupId];
    [request sendRequestWithSuccess:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        
        [self hiddenLoadingView];
        
        NSDictionary *dic = (NSDictionary *)response;
        NSDictionary * dataDict = [dic objectForKey:@"result"];
        if (nil == dataDict || ![dataDict isKindOfClass:[NSDictionary class]] || dataDict.count == 0) {
            if (self.dataSource.count == 0) {
                [self showNoNetWorkView:NoNetWorkViewStyle_Load_Fail];
            }else{
                [self showTopFreshLabelWithTitle:RDLocalizedString(@"RDString_NetFailedWithData")];
            }
            return;
        }

        [SAVORXAPI saveFileOnPath:self.cachePath withDictionary:dataDict];
        
        self.topModel = [[CreateWealthModel alloc] init];
        self.topModel.name = [dataDict objectForKey:@"name"];
        self.topModel.title = [dataDict objectForKey:@"title"];
        self.topModel.img_url = [dataDict objectForKey:@"img_url"];
        self.topModel.desc = [dataDict objectForKey:@"desc"];
        
        NSArray *resultArr = [dataDict objectForKey:@"list"];
        [self.dataSource removeAllObjects];
        for (int i = 0; i < resultArr.count; i ++) {
            CreateWealthModel *tmpModel = [[CreateWealthModel alloc] initWithDictionary:resultArr[i]];
            [self.dataSource addObject:tmpModel];
        }
        
        [self.tableView reloadData];
        
    } businessFailure:^(BGNetworkRequest * _Nonnull request, id  _Nullable response) {
        [self hiddenLoadingView];
        if (self.dataSource.count == 0) {
            [self showNoNetWorkView:NoNetWorkViewStyle_Load_Fail];
        }
        if (_tableView) {
            [self showTopFreshLabelWithTitle:RDLocalizedString(@"RDString_NetFailedWithData")];
        }
        
    } networkFailure:^(BGNetworkRequest * _Nonnull request, NSError * _Nullable error) {
        [self hiddenLoadingView];
        if (self.dataSource.count == 0) {
            [self showNoNetWorkView:NoNetWorkViewStyle_No_NetWork];
        }
        if (_tableView) {
            
            if (error.code == -1001) {
                [self showTopFreshLabelWithTitle:RDLocalizedString(@"RDString_NetFailedWithTimeOut")];
            }else{
                [self showTopFreshLabelWithTitle:RDLocalizedString(@"RDString_NetFailedWithBadNet")];
            }
        }
    }];
}

-(void)retryToGetData{
    [self hideNoNetWorkView];
    if (self.dataSource.count == 0)  {
        [self showLoadingView];
    }
    [self dataRequest];
}

#pragma mark -- 懒加载
- (UITableView *)tableView
{
    if (!_tableView) {
        
        _tableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _tableView.dataSource = self;
        _tableView.delegate = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.backgroundView = nil;
        _tableView.showsVerticalScrollIndicator = NO;
        [self.view addSubview:_tableView];
        [_tableView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.mas_equalTo(0);
            make.left.mas_equalTo(0);
            make.bottom.mas_equalTo(0);
            make.right.mas_equalTo(0);
        }];
        
        SpecialHeaderView *topView = [[SpecialHeaderView alloc] initWithFrame:CGRectZero];
        topView.backgroundColor = UIColorFromRGB(0xf6f2ed);
        
        // 计算图片高度
        CGFloat imgHeight =kMainBoundsWidth *802.f/1242.f;//113
        CGFloat totalHeight = imgHeight + 25 + 40;// 25为下方留白 40为控件间隔
        // 计算描述文字内容的高度
        CGFloat descHeight = [RDFrequentlyUsed getAttrHeightByWidth:kMainBoundsWidth - 30 title:self.topModel.desc font:kPingFangLight(15)];
        totalHeight = totalHeight + descHeight;
        // 计算标题的高度
        CGFloat titleHeight = [RDFrequentlyUsed getHeightByWidth:kMainBoundsWidth - 30 title:self.topModel.title font:kPingFangMedium(22)];
        if (titleHeight > 31) {
            totalHeight = totalHeight + 62;
        }else{
            totalHeight = totalHeight + 31;
        }
        
        UIView *headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, totalHeight)];
        [headView addSubview:topView];
        [topView mas_makeConstraints:^(MASConstraintMaker *make) {
            make.top.left.right.mas_equalTo(0);
            make.height.mas_equalTo(totalHeight);
        }];
        [topView configModelData:self.topModel];
        
        _tableView.tableHeaderView = headView;
        
        UIView *footView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kMainBoundsWidth, 80)];
        footView.backgroundColor = UIColorFromRGB(0xf6f2ed);
        UILabel *recommendLabel = [[UILabel alloc] init];
        recommendLabel.frame = CGRectMake(kMainBoundsWidth/2 - 60, 25, 120, 30);
        recommendLabel.textColor = UIColorFromRGB(0x922c3e);
        recommendLabel.font = kPingFangRegular(15);
        recommendLabel.text = RDLocalizedString(@"RDString_IookHisstoryTopic");
        recommendLabel.layer.cornerRadius = 2.5;
        recommendLabel.layer.masksToBounds = YES;
        recommendLabel.layer.borderWidth = 0.5;
        recommendLabel.layer.borderColor = UIColorFromRGB(0x922c3e).CGColor;
        recommendLabel.textAlignment = NSTextAlignmentCenter;
        recommendLabel.userInteractionEnabled = YES;
        [footView addSubview:recommendLabel];
        
        _tableView.tableFooterView = footView;
        
        UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(singleTap:)];
        tapGesture.numberOfTapsRequired = 1;
        [recommendLabel addGestureRecognizer:tapGesture];
        
    }
    
    return _tableView;
}

#pragma mark -- 点击更多专题组
- (void)singleTap:(UIGestureRecognizer *)recognizer{
    
    SpecialListViewController *spVC = [[SpecialListViewController alloc] init];
    [self.navigationController pushViewController:spVC animated:YES];
    
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
    CreateWealthModel * model = [self.dataSource objectAtIndex:indexPath.row];
    // 1 文字  2 文章  3 图片  4 标题
    if (model.sgtype == 1){
        static NSString *cellID = @"SpecialTextCell";
        SpecialTextCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[SpecialTextCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = UIColorFromRGB(0xf6f2ed);
        
        [cell configWithText:model.stext];
        //        [cell configWithText:
        //                             @"这是测试文字数据,这是测试文字数据，这是测试文字数据，这是测试文字数据，这是测试文字数据，这是测试文字数据，这是测试文字数据，这是测试文字数据，这是测试文字数据。这是测试数据结束。"
        //                             @"\n"
        //                             @"近日由中央文献出版社出版，在全国发行。党的十八大以来，以习近平同志为核心的党中央坚定不移走中国特色社会主义政治发展道路。"
        //                             @"\n"
        //                             @"近日由中央文献出版社出版，在全国发行。"
        //         ];
        return cell;
        
    }else if (model.sgtype == 2){
        
        static NSString *cellID = @"SpecialArtCell";
        SpecialArtCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[SpecialArtCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = UIColorFromRGB(0xf6f2ed);
        
        [cell configModelData:model];
        
        return cell;
        
    }else if (model.sgtype == 3){
        static NSString *cellID = @"SpecialImgCell";
        SpecialImageCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[SpecialImageCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = UIColorFromRGB(0xf6f2ed);
        
        [cell configWithImageURL:model.img_url];
        
        return cell;
        
    }else if (model.sgtype == 4){
        static NSString *cellID = @"SpecialTitleCell";
        SpecialTitleCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[SpecialTitleCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = UIColorFromRGB(0xf6f2ed);
        
        [cell configWithText:model.stitle];
        
        return cell;
        
    }else{
        static NSString *cellID = @"defaultCell";
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellID];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellID];
        }
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.backgroundColor = [UIColor clearColor];
        cell.contentView.backgroundColor = [UIColor clearColor];
        
        return cell;
    }
    
    return nil;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{

    CreateWealthModel * model = [self.dataSource objectAtIndex:indexPath.row];
    CGFloat bottomBlank;
    if (indexPath.row < self.dataSource.count - 1) {
        bottomBlank = [self getBottomBlankWith:model nextModel:[self.dataSource objectAtIndex:indexPath.row + 1]];
    }else{
        bottomBlank = [self getBottomBlankWith:model nextModel:nil];
    }
    
    if (model.sgtype == 3) {
        CGFloat imgHeight =  (kMainBoundsWidth - 15) *(802.f/1242.f);
        return  imgHeight + bottomBlank;
    }else if (model.sgtype == 2){
        CGFloat artHeight= 130 *802.f/1242.f + 10;
        return  artHeight + bottomBlank;
    }else if (model.sgtype == 1){
        // 计算富文本的高度
//        CGFloat textHeight = [RDFrequentlyUsed getAttrHeightByWidth:kMainBoundsWidth - 30 title:@"这是测试文字数据,这是测试文字数据，这是测试文字数据，这是测试文字数据，这是测试文字数据，这是测试文字数据，这是测试文字数据，这是测试文字数据，这是测试文字数据。"
//                  @"\n"
//                  @"近日由中央文献出版社出版，在全国发行。党的十八大以来，以习近平同志为核心的党中央坚定不移走中国特色社会主义政治发展道路。"
//                  @"\n"
//                  @"近日由中央文献出版社出版，在全国发行。"
//                              
//        font:kPingFangLight(15)];
        CGFloat textHeight = [RDFrequentlyUsed getAttrHeightByWidth:kMainBoundsWidth - 30 title:model.stext font:kPingFangLight(15)];
        return  textHeight + bottomBlank;
    }
    return 22.5 + bottomBlank;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    CreateWealthModel *model = [self.dataSource objectAtIndex:indexPath.row];
    
    if (model.sgtype == 2) {
        //1 图文 2 图集 3 视频
        if (model.type == 1) {
            [SAVORXAPI postUMHandleWithContentId:@"home_click_article" key:nil value:nil];
            ImageTextDetailViewController *imtVC = [[ImageTextDetailViewController alloc] init];
            imtVC.imgTextModel = model;
            imtVC.categoryID = self.categoryID;
            [self.navigationController pushViewController:imtVC animated:YES];
            
        }else if (model.type == 2) {
            
            [SAVORXAPI postUMHandleWithContentId:@"home_click_pic" key:nil value:nil];
            ImageArrayViewController *iatVC = [[ImageArrayViewController alloc] initWithCategoryID:self.categoryID model:model];
            
            iatVC.parentNavigationController = self.navigationController;
            float version = [UIDevice currentDevice].systemVersion.floatValue;
            if (version < 8.0) {
                self.modalPresentationStyle = UIModalPresentationCurrentContext;
            } else {;
                iatVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
            }
            iatVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
            
            [self presentViewController:iatVC animated:YES completion:nil];
            
            
        } else if (model.type == 3 || model.type == 4){
            [SAVORXAPI postUMHandleWithContentId:@"home_click_video" key:nil value:nil];
            WebViewController * web = [[WebViewController alloc] initWithModel:model categoryID:self.categoryID];
            [self.navigationController pushViewController:web animated:YES];
        }
    }
}

- (CGFloat)getBottomBlankWith:(CreateWealthModel *)tmpModel nextModel:(CreateWealthModel *)nextModel{
   // 1 文字  2 文章  3 图片  4 标题
    if (nextModel != nil) {
        if (tmpModel.sgtype == 1) {
            if (nextModel.sgtype == 1) {
                return 25;
            }else if (nextModel.sgtype == 2){
                return 20;
            }else if (nextModel.sgtype == 3){
                return 20;
            }else if (nextModel.sgtype == 4){
                return 20;
            }
        }else if (tmpModel.sgtype == 2){
            if (nextModel.sgtype == 1) {
                return 25;
            }else if (nextModel.sgtype == 2){
                return 5;
            }else if (nextModel.sgtype == 3){
                return 15;
            }else if (nextModel.sgtype == 4){
                return 20;
            }
        }else if (tmpModel.sgtype == 3){
            if (nextModel.sgtype == 1) {
                return 25;
            }else if (nextModel.sgtype == 2){
                return 15;
            }else if (nextModel.sgtype == 3){
                return 25;
            }else if (nextModel.sgtype == 4){
                return 25;
            }
        }else if (tmpModel.sgtype == 4){
            if (nextModel.sgtype == 1) {
                return 25;
            }else if (nextModel.sgtype == 2){
                return 20;
            }else if (nextModel.sgtype == 3){
                return 25;
            }else if (nextModel.sgtype == 4){
                return 5;
            }
        }
    }else{
        return 0.0;
    }
    return 0.0;
}

- (void)didReceiveMemoryWarning {
    
    [super didReceiveMemoryWarning];
}


@end
