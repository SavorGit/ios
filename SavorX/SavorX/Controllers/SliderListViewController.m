//
//  SliderListViewController.m
//  SavorX
//
//  Created by 郭春城 on 16/10/31.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "SliderListViewController.h"
#import "SliderShowViewController.h"
#import "PhotoTool.h"
#import "OpenFileTool.h"
#import "PhotoSliderViewController.h"
#import "PhotoListCollectionViewCell.h"
#import "AddPhotoListViewController.h"
#import "GCCUPnPManager.h"

#define SliderListCollection @"SliderListCollection"

@interface SliderListViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, AddPhotoListDelegate, UITextFieldDelegate>

@property (nonatomic, strong) UIButton * sliderButton;
@property (nonatomic, strong) NSMutableArray * PHAssetSource; //该相册所有的照片信息
@property (nonatomic, strong) UICollectionView * collectionView; //展示图片列表视图
@property (nonatomic, strong) PHImageRequestOptions *option; //当前页面的图片导出参数
@property (nonatomic, assign) BOOL isChooseStatus; //当前是否在选择状态
@property (nonatomic, strong) UIView * bottomView; //底部控制栏
@property (nonatomic, assign) BOOL isAllChoose; //是否是全选
@property (nonatomic, strong) NSMutableArray * selectArray; //选择的数组
@property (nonatomic, strong) UIButton * removeButton;
@property (nonatomic, strong) UIButton * doneItem;
@property (nonatomic, strong) UIButton * addButton;

@end

@implementation SliderListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.PHAssetSource = [self.infoDict objectForKey:@"ids"];
    
    [self createUI];
}

//初始化界面
- (void)createUI
{
    self.title = [self.infoDict objectForKey:@"title"];
    
    self.view.backgroundColor = VCBackgroundColor;
    self.selectArray = [NSMutableArray new];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonItemDidClicked)];
    
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CollectionViewCellSize;
    flowLayout.minimumInteritemSpacing = 3;
    flowLayout.minimumLineSpacing = 3;
    flowLayout.sectionInset = UIEdgeInsetsMake(3, 5, 50, 5);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height - NavHeight) collectionViewLayout:flowLayout];
    [self.collectionView registerClass:[PhotoListCollectionViewCell class] forCellWithReuseIdentifier:SliderListCollection];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.collectionView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
    }];
    
    self.bottomView = [[UIView alloc] init];
    self.bottomView.backgroundColor = [UIColorFromRGB(0x202020) colorWithAlphaComponent:.94f];
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_bottom).offset(0);
        make.left.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(kScreen_Width, 50));
    }];
    
    self.sliderButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.sliderButton.backgroundColor = [UIColorFromRGB(0x202020) colorWithAlphaComponent:.94f];
    self.sliderButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.sliderButton setTitleColor:FontColor forState:UIControlStateNormal];
    [self.sliderButton setTitle:@"投 屏" forState:UIControlStateNormal];
    [self.sliderButton addTarget:self action:@selector(photoArrayToPlay) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.sliderButton];
    [self.sliderButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(kScreen_Width, 50));
    }];

    self.doneItem = [UIButton buttonWithType:UIButtonTypeCustom];
    self.doneItem.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.doneItem setTitleColor:FontColor forState:UIControlStateNormal];
    [self.doneItem setTitle:@"全选" forState:UIControlStateNormal];
    [self.doneItem addTarget:self action:@selector(allChoose) forControlEvents:UIControlEventTouchUpInside];
    
    self.removeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.removeButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.removeButton setTitleColor:FontColor forState:UIControlStateNormal];
    [self.removeButton setTitle:@"删除" forState:UIControlStateNormal];
    [self.removeButton addTarget:self action:@selector(removePhoto) forControlEvents:UIControlEventTouchUpInside];
    self.removeButton.enabled = NO;
    
    self.addButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.addButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.addButton setTitleColor:FontColor forState:UIControlStateNormal];
    [self.addButton setImage:[UIImage imageNamed:@"tianjia"] forState:UIControlStateNormal];
    [self.addButton setTitle:@" 添加图片" forState:UIControlStateNormal];
    [self.addButton addTarget:self action:@selector(addPhotos) forControlEvents:UIControlEventTouchUpInside];
    
    [self.bottomView addSubview:self.doneItem];
    [self.bottomView addSubview:self.addButton];
    [self.bottomView addSubview:self.removeButton];
    
    [self.doneItem mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(15);
        make.top.mas_equalTo(5);
        make.size.mas_equalTo(CGSizeMake(70, 40));
    }];
    [self.addButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.bottomView);
        make.size.mas_equalTo(CGSizeMake(100, 40));
    }];
    [self.removeButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.right.mas_equalTo(-20);
        make.top.mas_equalTo(5);
        make.size.mas_equalTo(CGSizeMake(50, 40));
    }];
    
    
    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:self.PHAssetSource.count - 1 inSection:0];
    if (self.PHAssetSource.count > 0) {
        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:YES];
    }
}

- (void)removePhoto
{
    if (self.selectArray.count == 0) {
        [MBProgressHUD showTextHUDwithTitle:@"请至少选择一张图片"];
        return;
    }
    
    UIAlertController * alert;
    BOOL isAllRemove = NO;
    NSString * title = [NSString stringWithFormat:@"是否从幻灯片\"%@\"删除这%ld张照片", [self.infoDict objectForKey:@"title"], (unsigned long)self.selectArray.count];
    if (self.selectArray.count >= self.PHAssetSource.count) {
        isAllRemove = YES;
        alert = [UIAlertController alertControllerWithTitle:title message:@"相片将不会从本地删除\n(本幻灯片也将被删除)" preferredStyle:UIAlertControllerStyleAlert];
    }else{
        alert = [UIAlertController alertControllerWithTitle:title message:@"相片将不会从本地删除" preferredStyle:UIAlertControllerStyleAlert];
    }
    
    UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"不允许" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
        if (isAllRemove) {
            [[PhotoTool sharedInstance] removeSliderItemWithTitle:[self.infoDict objectForKey:@"title"]];
            if (self.delegate && [self.delegate respondsToSelector:@selector(sliderListDidBeChange)]) {
                [self.delegate sliderListDidBeChange];
            }
            [self.navigationController popViewControllerAnimated:YES];
        }else{
            [MBProgressHUD showCustomLoadingHUDInView:self.view];
            
            [self.selectArray sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
                NSIndexPath * indexPath1 = (NSIndexPath *)obj1;
                NSIndexPath * indexPath2 = (NSIndexPath *)obj2;
                return indexPath1.row < indexPath2.row;
            }];
            
            self.infoDict = [[PhotoTool sharedInstance] removeSliderItemWithIndexPaths:[NSArray arrayWithArray:self.selectArray] withTitle:[self.infoDict objectForKey:@"title"]];
            self.PHAssetSource = [self.infoDict objectForKey:@"ids"];
            if (self.delegate && [self.delegate respondsToSelector:@selector(sliderListDidBeChange)]) {
                [self.delegate sliderListDidBeChange];
            }
            [self.selectArray removeAllObjects];
            [self.collectionView reloadData];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        }
        
        if (self.isChooseStatus) {
            [self rightButtonItemDidClicked];
        }
    }];
    
    [alert addAction:action1];
    [alert addAction:action2];
    [self presentViewController:alert animated:YES completion:nil];
}

//右上方导航栏按钮被点击
- (void)rightButtonItemDidClicked
{
    if (self.isChooseStatus) {
        if (self.isAllChoose) {
            [self.doneItem setTitle:@"全选" forState:UIControlStateNormal];
        }
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"编辑" style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonItemDidClicked)];
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_bottom).offset(0);
        }];
        self.sliderButton.hidden = NO;
        self.isChooseStatus = NO;
        self.isAllChoose = NO;
        [self.selectArray removeAllObjects];
    }else{
        self.removeButton.enabled = NO;
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonItemDidClicked)];
        [self.doneItem setTitle:@"全选" forState:UIControlStateNormal];
        [self.doneItem addTarget:self action:@selector(allChoose) forControlEvents:UIControlEventTouchUpInside];
        [self.bottomView mas_updateConstraints:^(MASConstraintMaker *make) {
            make.top.equalTo(self.view.mas_bottom).offset(-50);
        }];
        self.sliderButton.hidden = YES;
        self.isChooseStatus = YES;
    }
    [self.collectionView reloadData];
}

//全选动作触发
- (void)allChoose
{
    self.isAllChoose = YES;
    self.removeButton.enabled = YES;
    [self.doneItem setTitle:@"取消全选" forState:UIControlStateNormal];
    [self.doneItem addTarget:self action:@selector(cancelAllChoose) forControlEvents:UIControlEventTouchUpInside];
    
    NSInteger maxNum = self.PHAssetSource.count > 50 ? 50 : self.PHAssetSource.count;
    for (NSInteger i = 0; i < maxNum; i++) {
        if (self.selectArray.count > 49) {
            break;
        }
        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:i inSection:0];
        if ([self.selectArray containsObject:indexPath]) {
            if (maxNum + 1 > self.PHAssetSource.count) {
                continue;
            }
            maxNum++;
            continue;
        }
        [self.selectArray addObject:indexPath];
    }
    [self.collectionView reloadData];
}

- (void)cancelAllChoose
{
    if (self.selectArray.count > 0) {
        [self.selectArray removeAllObjects];
    }
    self.isAllChoose = NO;
    self.removeButton.enabled = NO;
    [self.doneItem setTitle:@"全选" forState:UIControlStateNormal];
    [self.doneItem addTarget:self action:@selector(allChoose) forControlEvents:UIControlEventTouchUpInside];
    [self.collectionView reloadData];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.PHAssetSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoListCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:SliderListCollection forIndexPath:indexPath];
    
    PHAsset * asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[[self.PHAssetSource objectAtIndex:indexPath.row]] options:nil].firstObject;
    
    if (asset) {
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CollectionViewCellSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            [cell.bgImageView setImage:result];
        }];
    }else{
        [cell.bgImageView setImage:[UIImage imageNamed:@"remove"]];
    }
    
    if (self.isChooseStatus) {
        [cell setSelectedStatus:YES];
        if ([self.selectArray containsObject:indexPath]) {
            [cell changeSelectedTo:YES];
        }else{
            [cell changeSelectedTo:NO];
        }
    }else{
        [cell setSelectedStatus:NO];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!self.isChooseStatus) {
        [self showSliderListWithIndex:indexPath];
        return;
    }
    PhotoListCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:SliderListCollection forIndexPath:indexPath];
    if ([self.selectArray containsObject:indexPath]) {
        [self.selectArray removeObject:indexPath];
        [cell changeSelectedTo:NO];
        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
        if (self.isAllChoose) {
            self.isAllChoose = NO;
            [self.doneItem setTitle:@"全选" forState:UIControlStateNormal];
            [self.doneItem addTarget:self action:@selector(allChoose) forControlEvents:UIControlEventTouchUpInside];
        }
    }else{
        if (self.selectArray.count > 49) {
            [MBProgressHUD showTextHUDwithTitle:@"最多只能选择50张"];
            return;
        }
        [self.selectArray addObject:indexPath];
        [cell changeSelectedTo:YES];
        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
    }
    if (self.selectArray.count > 0) {
        self.removeButton.enabled = YES;
    }else{
        self.removeButton.enabled = NO;
    }
}

- (void)showSliderListWithIndex:(NSIndexPath *)indexPath
{
    SliderShowViewController * slider = [[SliderShowViewController alloc] init];
    NSMutableArray * array = [NSMutableArray new];
    NSIndexPath * tempIndexPath = [NSIndexPath indexPathForRow:indexPath.row inSection:indexPath.section];
    for (NSString * idString in self.PHAssetSource) {
        PHAsset * asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[idString] options:nil].firstObject;
        if (asset) {
            [array addObject:[PHAsset fetchAssetsWithLocalIdentifiers:@[idString] options:nil].firstObject];
        }else{
            if (indexPath.row > [self.PHAssetSource indexOfObject:idString]){
                NSString * tempStr = [self.PHAssetSource objectAtIndex:indexPath.row];
                PHAsset * tempAsset = [PHAsset fetchAssetsWithLocalIdentifiers:@[tempStr] options:nil].firstObject;
                if (tempAsset && [tempStr isEqualToString:idString]) {
                    continue;
                }
                tempIndexPath = [NSIndexPath indexPathForRow:tempIndexPath.row - 1 inSection:0];
            }
        }
    }
    [array insertObject:[array lastObject] atIndex:0];
    [array addObject:[array objectAtIndex:1]];
    slider.PHAssetSource = array;
    slider.indexPath = tempIndexPath;
    slider.infoDict = self.infoDict;
    [self.navigationController pushViewController:slider animated:YES];
}

- (void)addPhotos
{
    if (self.PHAssetSource.count >= 50) {
        [MBProgressHUD showTextHUDwithTitle:@"最多只能添加50张照片哦~"];
        return;
    }
    
    if (self.isChooseStatus) {
        [self rightButtonItemDidClicked];
    }
    
    AddPhotoListViewController * add = [[AddPhotoListViewController alloc] init];
    add.currentNum = self.PHAssetSource.count;
    add.libraryTitle = [self.infoDict objectForKey:@"title"];
    add.delegate = self;
    add.results = [NSMutableArray arrayWithArray:self.systemResults];
    [self.navigationController pushViewController:add animated:YES];
}

- (void)PhotoDidCreateByIDArray:(NSArray *)array
{
    [MBProgressHUD showTextHUDwithTitle:@"添加成功"];
    self.infoDict = [[PhotoTool sharedInstance] addSliderItemWithIDArray:array andTitle:[self.infoDict objectForKey:@"title"]];
    self.PHAssetSource = [self.infoDict objectForKey:@"ids"];
    [self.collectionView reloadData];
    if (self.delegate && [self.delegate respondsToSelector:@selector(sliderListDidBeChange)]) {
        [self.delegate sliderListDidBeChange];
    }
}

//多选图片进行幻灯片操作
- (void)photoArrayToPlay
{
    [SAVORXAPI postUMHandleWithContentId:@"slide_to_screen_start" key:nil value:nil];
    if (self.PHAssetSource.count == 0) {
        [MBProgressHUD showTextHUDwithTitle:@"请至少选择一张图片"];
        return;
    }
    
    PhotoSliderViewController * slider = [[PhotoSliderViewController alloc] init];
    slider.title = @"幻灯片";
    slider.seriesId = [Helper getTimeStamp];
    NSMutableArray * array = [NSMutableArray new];
    for (NSString * idString in self.PHAssetSource) {
        PHAsset * asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[idString] options:nil].firstObject;
        if (asset) {
            [array addObject:[PHAsset fetchAssetsWithLocalIdentifiers:@[idString] options:nil].firstObject];
        }
    }
    
    if (array.count == 0) {
        [MBProgressHUD showTextHUDwithTitle:@"没有可以操作的图片"];
        return;
    }
    
    PHAsset * asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[[self.PHAssetSource objectAtIndex:0]] options:nil].firstObject;
    
    if (asset) {
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CollectionViewCellSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            
        }];
    }
    
    [array insertObject:[array lastObject] atIndex:0];
    [array addObject:[array objectAtIndex:1]];
    slider.PHAssetSource = array;
    if ([GlobalData shared].networkStatus == RDNetworkStatusReachableViaWiFi) {
        if ([GlobalData shared].isBindRD) {
                
            MBProgressHUD * hud = [MBProgressHUD showCustomLoadingHUDInView:self.view withTitle:@"正在投屏"];
            PHAsset * asset = [slider.PHAssetSource objectAtIndex:1];
            NSString * name = asset.localIdentifier;
            
            [[PhotoTool sharedInstance] getImageFromPHAssetSourceWithAsset:asset success:^(UIImage *result) {
                
                [[PhotoTool sharedInstance] compressImageWithImage:result finished:^(NSData *minData, NSData *maxData) {
                    
                    [SAVORXAPI postImageWithURL:STBURL data:minData name:name type:3 isThumbnail:YES rotation:0 seriesId:slider.seriesId force:0 success:^{
                        [hud hideAnimated:NO];
                        
                        
                        [self.navigationController pushViewController:slider animated:YES];
                        [SAVORXAPI successRing];
                        
                        [SAVORXAPI postImageWithURL:STBURL data:maxData name:name type:3 isThumbnail:NO rotation:0 seriesId:slider.seriesId force:0 success:^{
                            
                        } failure:^{
                            
                        }];
                        
                    } failure:^{
                        [hud hideAnimated:NO];
                    }];
                    
                }];
                
            }];
            
            return;
        }else if ([GlobalData shared].isBindDLNA) {
            [MBProgressHUD showCustomLoadingHUDInView:self.view withTitle:@"正在投屏"];
            [self screenImageWithPHAsset:[array objectAtIndex:1] index:1 success:^(UIImage *result, NSString *keyStr) {
                
                NSString *asseturlStr = [NSString stringWithFormat:@"%@image?%@", [HTTPServerManager getCurrentHTTPServerIP],keyStr];
                [[GCCUPnPManager defaultManager] setAVTransportURL:asseturlStr Success:^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [self.navigationController pushViewController:slider animated:YES];
                    
                    [SAVORXAPI successRing];
                } failure:^{
                    [MBProgressHUD hideHUDForView:self.view animated:YES];
                    [MBProgressHUD showTextHUDwithTitle:ScreenFailure];
                }];
            }];
            return;
        }
    }
    
    [self.navigationController pushViewController:slider animated:YES];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (!string.length) {
        return YES;
    }
    if (textField.text.length > 6) {
        return NO;
    }
    return YES;
}

//投屏某一张图片
- (void)screenImageWithPHAsset:(PHAsset *)asset index:(NSInteger)index success:(void (^)(UIImage * result, NSString * keyStr))success
{
    //导出图片的参数
    PHImageRequestOptions *option = [PHImageRequestOptions new];
    option.synchronous = YES; //开启线程同步
    option.resizeMode = PHImageRequestOptionsResizeModeExact; //标准的图片尺寸
    option.version = PHImageRequestOptionsVersionCurrent; //获取用户操作的图片
    option.networkAccessAllowed = YES; //允许访问iCloud
    option.deliveryMode = PHImageRequestOptionsDeliveryModeFastFormat; //高质量
    
    //为了能正常缓存，此处用不同的下标标记图片
    NSString * keyStr = [NSString stringWithFormat:@"savorPhoto%ld.png", (long)index];
    
    //机顶盒输出尺寸为1920*1080，为了更好的用户效果，这里对图片进行相应的转换
    CGFloat width = asset.pixelWidth;
    CGFloat height = asset.pixelHeight;
    CGFloat scale = width / height;
    CGFloat tempScale = 1920 / 1080.f;
    CGSize size;
    if (scale > tempScale) {
        size = CGSizeMake(1920, 1920 / scale);
    }else{
        size = CGSizeMake(1080 * scale, 1080);
    }
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        [OpenFileTool writeImageToSysImageCacheWithImage:result andName:keyStr handle:^(NSString *keyStr) {
            success(result, keyStr);
        }];
    }];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [OpenFileTool deleteFileSubPath:SystemImage];
}

- (void)viewDidAppear:(BOOL)animated{
    [SAVORXAPI postUMHandleWithContentId:@"home_slide" key:nil value:nil];
}

- (void)navBackButtonClicked:(UIButton *)sender {
    [self.navigationController popViewControllerAnimated:YES];
    [SAVORXAPI postUMHandleWithContentId:@"slide_to_screen_back_list" key:nil value:nil];
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
