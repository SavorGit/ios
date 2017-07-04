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
#import "RDPhotoTool.h"

@interface PhotoLibraryViewController ()<UICollectionViewDelegate, UICollectionViewDataSource>

@property (nonatomic, strong) NSArray * photoLibrarySource;
@property (nonatomic, strong) RDPhotoLibraryModel * model;
@property (nonatomic, strong) UICollectionView * collectionView;

@property (nonatomic, strong) NSMutableArray * selectArray;

@property (nonatomic, assign) BOOL isAllChoose; //是否是全选
@property (nonatomic, assign) BOOL isChooseStatus;

@end

@implementation PhotoLibraryViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self loadPhotoLibrary];
}

- (void)loadPhotoLibrary
{
    [RDPhotoTool loadPHAssetWithHander:^(NSArray *result, RDPhotoLibraryModel *cameraResult) {
        self.photoLibrarySource = result;
        self.model = cameraResult;
        [self createUI];
    }];
}

- (void)createUI
{
    self.title = self.model.title;
    
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
}

- (void)rightButtonItemDidClicked
{
    if (self.isChooseStatus) {
        [self closeChooseStatus];
    }else{
        [self startChooseStatus];
    }
}

- (void)startChooseStatus
{
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonItemDidClicked)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStyleDone target:self action:@selector(startAllChoose)];
    self.isChooseStatus = YES;
    [[NSNotificationCenter defaultCenter] postNotificationName:RDPhotoLibraryChooseChangeNotification object:nil userInfo:@{@"value":@(YES)}];
}

- (void)closeChooseStatus
{
    NSLog(@"本次一共选择了%ld张", self.selectArray.count);
    [self.selectArray removeAllObjects];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"选择" style:UIBarButtonItemStyleDone target:self action:@selector(rightButtonItemDidClicked)];
    [self setNavBackArrow];
    self.isChooseStatus = NO;
    [[NSNotificationCenter defaultCenter] postNotificationName:RDPhotoLibraryChooseChangeNotification object:nil userInfo:@{@"value":@(NO)}];
}

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

- (void)cancelAllChoose
{
    if (self.isAllChoose) {
        self.isAllChoose = NO;
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStyleDone target:self action:@selector(startAllChoose)];
        [self.selectArray removeAllObjects];
        [[NSNotificationCenter defaultCenter] postNotificationName:RDPhotoLibraryAllChooseNotification object:nil userInfo:@{@"objects":self.selectArray}];
    }
}

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
                        if (weakSelf.selectArray.count == 50) {
                            weakSelf.isAllChoose = YES;
                            weakSelf.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消全选" style:UIBarButtonItemStyleDone target:weakSelf action:@selector(cancelAllChoose)];
                        }
                    }
                }
            }else{
                if ([weakSelf.selectArray containsObject:asset]) {
                    [weakSelf.selectArray removeObject:asset];
                    self.isAllChoose = NO;
                    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStyleDone target:self action:@selector(startAllChoose)];
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
