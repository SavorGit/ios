//
//  PhotoLibraryViewController.m
//  SavorX
//
//  Created by 郭春城 on 2017/7/4.
//  Copyright © 2017年 郭春城. All rights reserved.
//

#import "PhotoLibraryViewController.h"
#import "RDPhotoCollectionViewCell.h"
#import "RDVideoCollectionViewCell.h"
#import "PhotoManyViewController.h"
#import "PhotoSliderViewController.h"
#import "RDPhotoTool.h"

@interface PhotoLibraryViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UIButton * titleButton;

@property (nonatomic, strong) NSArray * photoLibrarySource;
@property (nonatomic, strong) RDPhotoLibraryModel * model;
@property (nonatomic, strong) UICollectionView * collectionView;
@property (nonatomic, strong) NSMutableArray * selectArray;

@property (nonatomic, strong) UITableView * tableView;

@property (nonatomic, assign) BOOL isAllChoose; //是否是全选
@property (nonatomic, assign) BOOL isChooseStatus; //是否是选择状态
@property (nonatomic, assign) BOOL isChooseLibrary; //是否是在选择相册

@property (nonatomic, strong) UIButton * screenButton;

@end

@implementation PhotoLibraryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadPhotoLibrary];
}

//加载手机内的相册列表
- (void)loadPhotoLibrary
{
    MBProgressHUD * hud = [MBProgressHUD showLoadingWithText:@"正在加载" inView:self.view];
    
    [RDPhotoTool loadPHAssetWithHander:^(NSArray *result, RDPhotoLibraryModel *cameraResult) {
        self.photoLibrarySource = result;
        self.model = cameraResult;
        [self createUI];
        [hud hideAnimated:NO];
    }];
}

- (void)createUI
{
    [self autoTitleButtonWith:self.model.title];
    
    self.selectArray = [NSMutableArray new];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"选择" style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonItemDidClicked)];
    
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CollectionViewCellSize;
    flowLayout.minimumInteritemSpacing = 3;
    flowLayout.minimumLineSpacing = 3;
    flowLayout.sectionInset = UIEdgeInsetsMake(3, 5, 50, 5);
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.view.bounds collectionViewLayout:flowLayout];
    [self.collectionView registerClass:[RDPhotoCollectionViewCell class] forCellWithReuseIdentifier:@"PhotoCell"];
    [self.collectionView registerClass:[RDVideoCollectionViewCell class] forCellWithReuseIdentifier:@"VideoCell"];
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
    
    self.tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(self.view);
        make.left.mas_equalTo(0);
        make.top.mas_equalTo(-self.view.frame.size.height);
        make.right.mas_equalTo(0);
    }];
    
    self.screenButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.screenButton addTarget:self action:@selector(screenButtonDidBeClicked) forControlEvents:UIControlEventTouchUpInside];
    self.screenButton.backgroundColor = [UIColor redColor];
    [self.view addSubview:self.screenButton];
    [self.screenButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.height.mas_equalTo(50);
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(50);
        make.right.mas_equalTo(0);
    }];
    
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:self.model.fetchResult.count - 1 inSection:0];
//        [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
//    });
    
//    [self.collectionView setContentOffset:CGPointMake(0, MAXFLOAT)];
}

//相册标题被点击的时候
- (void)titleButtonDidBeClicked
{
    if (self.isChooseLibrary) {
        [self closeLibraryChoose];
    }else{
        [self startLibraryChoose];
    }
}

//开始选择相册
- (void)startLibraryChoose
{
    UIButton * button = (UIButton *)self.navigationItem.titleView;
    button.userInteractionEnabled = NO;
    
    self.isChooseLibrary = YES;
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
    }];
    
    [UIView animateWithDuration:.3f animations:^{
        [self.view layoutIfNeeded];
        button.imageView.transform = CGAffineTransformMakeRotation(M_PI);
    } completion:^(BOOL finished) {
        button.userInteractionEnabled = YES;
    }];
}

//结束选择相册
- (void)closeLibraryChoose
{
    UIButton * button = (UIButton *)self.navigationItem.titleView;
    button.userInteractionEnabled = NO;
    
    self.isChooseLibrary = NO;
    [self.tableView mas_updateConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(-self.view.frame.size.height);
    }];
    [UIView animateWithDuration:.3f animations:^{
        [self.view layoutIfNeeded];
        button.imageView.transform = CGAffineTransformMakeRotation(0);
    } completion:^(BOOL finished) {
        button.userInteractionEnabled = YES;
    }];
}

- (void)autoTitleButtonWith:(NSString *)title
{
    UIButton * titleButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [titleButton setTintColor:[UIColor whiteColor]];
    [titleButton setImage:[UIImage imageNamed:@"RDDown"] forState:UIControlStateNormal];
    titleButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [titleButton addTarget:self action:@selector(titleButtonDidBeClicked) forControlEvents:UIControlEventTouchUpInside];
    titleButton.imageView.contentMode = UIViewContentModeCenter;
    
    CGFloat maxWidth = kMainBoundsWidth - 150;
    NSDictionary* attributes =@{NSFontAttributeName:[UIFont systemFontOfSize:16]};
    CGSize size = [title boundingRectWithSize:CGSizeMake(1000, 30) options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading|NSStringDrawingTruncatesLastVisibleLine attributes:attributes context:nil].size;
    if (size.width > maxWidth) {
        size.width = maxWidth;
    }
    titleButton.frame = CGRectMake(0, 0, size.width + 30, size.height);
    
    [titleButton setImageEdgeInsets:UIEdgeInsetsMake(0, size.width + 15, 0, 0)];
    [titleButton setTitleEdgeInsets:UIEdgeInsetsMake(0, 0, 0, 10 + 10)];
    
    [titleButton setTitle:title forState:UIControlStateNormal];
    self.navigationItem.titleView = titleButton;
}

//右上方的按钮被点击
- (void)rightButtonItemDidClicked
{
    if (self.isChooseStatus) {
        [self closeChooseStatus];
    }else{
        [self startChooseStatus];
    }
}

//开启选择状态
- (void)startChooseStatus
{
    UIButton * button = (UIButton *)self.navigationItem.titleView;
    [button setImage:[Helper imageWithColor:[UIColor clearColor] size:button.imageView.frame.size] forState:UIControlStateNormal];
    button.userInteractionEnabled = NO;
    
    [self.screenButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(0);
    }];
    [UIView animateWithDuration:.25f animations:^{
        [self.view layoutIfNeeded];
    }];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonItemDidClicked)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStyleDone target:self action:@selector(startAllChoose)];
    self.isChooseStatus = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:RDPhotoLibraryChooseChangeNotification object:nil userInfo:@{@"value":@(YES)}];
}

//结束选择状态
- (void)closeChooseStatus
{
    UIButton * button = (UIButton *)self.navigationItem.titleView;
    [button setImage:[UIImage imageNamed:@"RDDown"] forState:UIControlStateNormal];
    button.userInteractionEnabled = YES;
    
    [self.screenButton mas_updateConstraints:^(MASConstraintMaker *make) {
        make.bottom.mas_equalTo(50);
    }];
    [UIView animateWithDuration:.25f animations:^{
        [self.view layoutIfNeeded];
    }];
    
    [self.selectArray removeAllObjects];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"选择" style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonItemDidClicked)];
    [self setNavBackArrow];
    self.isChooseStatus = NO;
    self.isAllChoose = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:RDPhotoLibraryChooseChangeNotification object:nil userInfo:@{@"value":@(NO)}];
}

//全选按钮被点击了
- (void)startAllChoose
{
    NSInteger maxNumber = self.model.fetchResult.count > kMAXPhotoNum ? kMAXPhotoNum : self.model.fetchResult.count;
    NSInteger i = 0;
    while (i < maxNumber) {
        i++;
        if (i > self.model.fetchResult.count) {
            break;
        }
        PHAsset * asset = [self.model.fetchResult objectAtIndex:self.model.fetchResult.count - i];
        if ([self.selectArray containsObject:asset]) {
            continue;
        }else{
            [self.selectArray addObject:asset];
        }
        if (self.selectArray.count >= 50) {
            break;
        }
    }
    
    self.isAllChoose = YES;
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消全选" style:UIBarButtonItemStyleDone target:self action:@selector(cancelAllChoose)];
    [[NSNotificationCenter defaultCenter] postNotificationName:RDPhotoLibraryAllChooseNotification object:nil userInfo:@{@"objects":self.selectArray}];
}

//取消当前的全选状态
- (void)cancelAllChoose
{
    if (self.isAllChoose) {
        self.isAllChoose = NO;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStyleDone target:self action:@selector(startAllChoose)];
        [self.selectArray removeAllObjects];
        [[NSNotificationCenter defaultCenter] postNotificationName:RDPhotoLibraryAllChooseNotification object:nil userInfo:@{@"objects":self.selectArray}];
    }
}

#pragma mark - UICollectionView
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset * asset = [self.model.fetchResult objectAtIndex:indexPath.row];
    if (asset.mediaType == PHAssetMediaTypeVideo) {
        RDVideoCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"VideoCell" forIndexPath:indexPath];
        
        [cell configWithPHAsset:asset];
        [cell changeChooseStatus:self.isChooseStatus];
        return cell;
    }else{
        RDPhotoCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"PhotoCell" forIndexPath:indexPath];
        __weak typeof(self) weakSelf = self;
        __weak typeof(cell) weakCell = cell;
        [cell configWithPHAsset:asset completionHandle:^(PHAsset *asset, BOOL isSelect) {
            if (isSelect) {
                if (![weakSelf.selectArray containsObject:asset]) {
                    if (weakSelf.selectArray.count >= 50) {
                        [MBProgressHUD showTextHUDwithTitle:@"最多只能选择50张" delay:1.f];
                        [weakCell configSelectStatus:NO];
                    }else{
                        [weakSelf.selectArray addObject:asset];
                        if (weakSelf.selectArray.count == 50 ||
                            weakSelf.selectArray.count == weakSelf.model.fetchResult.count) {
                            weakSelf.isAllChoose = YES;
                            weakSelf.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消全选" style:UIBarButtonItemStyleDone target:weakSelf action:@selector(cancelAllChoose)];
                        }
                    }
                }
            }else{
                if ([weakSelf.selectArray containsObject:asset]) {
                    [weakSelf.selectArray removeObject:asset];
                    weakSelf.isAllChoose = NO;
                    weakSelf.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStyleDone target:weakSelf action:@selector(startAllChoose)];
                }
            }
        }];
        [cell changeChooseStatus:self.isChooseStatus];
        [cell configSelectStatus:[self.selectArray containsObject:asset]];
        return cell;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.model.fetchResult.count;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    PHAsset * asset = [self.model.fetchResult objectAtIndex:indexPath.row];
    if (asset.mediaType == PHAssetMediaTypeImage) {
        if ([GlobalData shared].isBindRD) {
            MBProgressHUD * hud = [MBProgressHUD showCustomLoadingHUDInView:self.view withTitle:@"正在加载"];
            PHAsset * asset = [self.model.fetchResult objectAtIndex:indexPath.row];
            NSString * name = asset.localIdentifier;
            [RDPhotoTool getImageFromPHAssetSourceWithAsset:asset success:^(UIImage *result) {
                
                PhotoManyViewController * vc = [[PhotoManyViewController alloc] initWithPHAssetSource:self.model.fetchResult andIndex:indexPath.row];
                
                [RDPhotoTool compressImageWithImage:result finished:^(NSData *minData, NSData *maxData) {
                    
                    [SAVORXAPI postImageWithURL:STBURL data:minData name:name type:1 isThumbnail:YES rotation:0 seriesId:nil force:0 success:^{
                        [hud hideAnimated:NO];
                        [self.navigationController pushViewController:vc animated:YES];
                        
                        [SAVORXAPI successRing];
                        
                        [SAVORXAPI postUMHandleWithContentId:@"picture_to_screen_play" key:nil value:nil];
                        [SAVORXAPI postImageWithURL:STBURL data:maxData name:name type:1 isThumbnail:NO rotation:0 seriesId:nil force:0 success:^{
                            
                        } failure:^{
                            
                        }];
                        
                    } failure:^{
                        [hud hideAnimated:NO];
                    }];
                    
                }];
                
            }];
        }else{
            PhotoManyViewController * vc = [[PhotoManyViewController alloc] initWithPHAssetSource:self.model.fetchResult andIndex:indexPath.row];
            [self.navigationController pushViewController:vc animated:YES];
        }
    }
}

#pragma mark - UITableView
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.photoLibrarySource.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"cellID"];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"cellID"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell.imageView setContentMode:UIViewContentModeScaleToFill];
    }
    
    RDPhotoLibraryModel * model = [self.photoLibrarySource objectAtIndex:indexPath.row];
    PHFetchResult * result = model.fetchResult;
    
    PHImageRequestOptions * option = [[PHImageRequestOptions alloc] init];
    option.synchronous = YES;
    option.resizeMode = PHImageRequestOptionsResizeModeExact;
    [[PHImageManager defaultManager] requestImageForAsset:[result lastObject] targetSize:CGSizeMake(100, 100) contentMode:PHImageContentModeAspectFill options:option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        [cell.imageView setImage:[RDPhotoTool makeThumbnailOfSize:CGSizeMake(70, 70) image:result]];
    }];
    
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    cell.textLabel.text = model.title;
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)result.count];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.view.frame.size.height / 5;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.model = [self.photoLibrarySource objectAtIndex:indexPath.row];
    [self autoTitleButtonWith:self.model.title];
    UIButton * button = (UIButton *)self.navigationItem.titleView;
    button.imageView.transform = CGAffineTransformMakeRotation(M_PI);
    [self.collectionView reloadData];
    [self closeLibraryChoose];
    [self.collectionView setContentOffset:CGPointMake(0, 0)];
}

- (void)screenButtonDidBeClicked
{
    [SAVORXAPI postUMHandleWithContentId:@"picture_to_screen_photo_slide" key:nil value:nil];
    if (self.selectArray.count == 0) {
        [MBProgressHUD showTextHUDwithTitle:@"请至少选择一张图片"];
        return;
    }
    
    PhotoSliderViewController * third = [[PhotoSliderViewController alloc] init];
    
    NSMutableArray * array = [[NSMutableArray alloc] initWithArray:self.selectArray];
    [array insertObject:[array lastObject] atIndex:0];
    [array addObject:[array objectAtIndex:1]];
    
    third.PHAssetSource = array;
    if ([GlobalData shared].isBindRD) {
        MBProgressHUD * hud = [MBProgressHUD showCustomLoadingHUDInView:self.view withTitle:@"正在投屏"];
        PHAsset * asset = [third.PHAssetSource objectAtIndex:1];
        NSString * name = asset.localIdentifier;
        
        [RDPhotoTool getImageFromPHAssetSourceWithAsset:asset success:^(UIImage *result) {
            
            [RDPhotoTool compressImageWithImage:result finished:^(NSData *minData, NSData *maxData) {
                
                [SAVORXAPI postImageWithURL:STBURL data:minData name:name type:1 isThumbnail:YES rotation:0 seriesId:nil force:0 success:^{
                    
                    [hud hideAnimated:NO];
                    [self.navigationController pushViewController:third animated:YES];
                    [SAVORXAPI successRing];
                    
                    [SAVORXAPI postImageWithURL:STBURL data:maxData name:name type:1 isThumbnail:NO rotation:0 seriesId:nil force:0 success:^{
                        
                    } failure:^{
                        
                    }];
                    
                } failure:^{
                    [hud hideAnimated:NO];
                }];
                
            }];
            
        }];
    }else{
        [self.navigationController pushViewController:third animated:YES];
    }
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