//
//  SliderShowViewController.m
//  SavorX
//
//  Created by 郭春城 on 16/11/9.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "SliderShowViewController.h"
#import "ShowPhotoCollectionViewCell.h"
#import "OpenFileTool.h"
#import "PhotoTool.h"

#define BIGCELL @"SLIDERBIGCELL"

@interface SliderShowViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, UIScrollViewDelegate>

@property (nonatomic, strong) UICollectionView * collectionView; //展示图片视图
@property (nonatomic, strong) PHImageRequestOptions * option; //图片导出参数
@property (nonatomic, assign) NSInteger currentIndex; //记录当前下标

@end

@implementation SliderShowViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"我的照片";

    self.view.backgroundColor = VCBackgroundColor;
    
    UICollectionViewFlowLayout* flowLayout = [[UICollectionViewFlowLayout alloc]init];
    flowLayout.itemSize = CGSizeMake(kScreen_Width, kScreen_Height - 64);
    flowLayout.minimumLineSpacing = 0;
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionHorizontal];
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height - NavHeight) collectionViewLayout:flowLayout];
    [self.collectionView registerClass:[ShowPhotoCollectionViewCell class] forCellWithReuseIdentifier:BIGCELL];
    self.collectionView.backgroundColor = [UIColor clearColor];
    self.collectionView.pagingEnabled = YES;
    self.collectionView.showsHorizontalScrollIndicator = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.collectionView.delegate = self;
    self.collectionView.dataSource = self;
    [self.view addSubview:self.collectionView];
    
    //导出图片的参数
    self.option = [PHImageRequestOptions new];
    //self.option.synchronous = YES; //开启线程同步
    self.option.resizeMode = PHImageRequestOptionsResizeModeExact; //标准的图片尺寸
    //self.option.version = PHImageRequestOptionsVersionCurrent; //获取用户操作的图片
    self.option.networkAccessAllowed = YES; //允许访问iCloud
    self.option.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat; //高质量
    
    self.currentIndex = self.indexPath.row + 1;
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.indexPath.row + 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
}

//图片滑动切换
- (void)scrollPhotos
{
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex + 1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:YES];
    self.currentIndex += 1;
    if (self.currentIndex == self.PHAssetSource.count - 1) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionRight animated:NO];
        self.currentIndex = 1;
    }else if (self.currentIndex == 0){
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.PHAssetSource.count - 2 inSection:0] atScrollPosition:UICollectionViewScrollPositionLeft animated:NO];
        self.currentIndex = self.PHAssetSource.count - 2;
    }
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.PHAssetSource.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    ShowPhotoCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:BIGCELL forIndexPath:indexPath];
    
    PHAsset * asset = [self.PHAssetSource objectAtIndex:indexPath.row];
    CGFloat width = asset.pixelWidth;
    CGFloat height = asset.pixelHeight;
    CGFloat scale = width / height;
    CGFloat tempScale = kScreen_Width / kScreen_Height;
    CGSize size;
    if (scale > tempScale) {
        size = CGSizeMake(kScreen_Width, kScreen_Width / scale);
    }else{
        size = CGSizeMake(kScreen_Height * scale, kScreen_Height);
    }
    //PHImageRequestOptions * options = [PHImageRequestOptions new];
    //options.deliveryMode = PHImageRequestOptionsDeliveryModeHighQualityFormat;
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        [cell.photoImage setImage:result];
    }];
    
    cell.photoImage.transform = CGAffineTransformMakeRotation(0);
    cell.isLandSpace = NO;
    
    return cell;
}

//视图结束滑动
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    NSInteger itemIndex = (scrollView.contentOffset.x + kScreen_Width * 0.5) / kScreen_Width;
    if (itemIndex == self.PHAssetSource.count - 1) {
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:1 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        itemIndex = 1;
    }else if (itemIndex == 0){
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.PHAssetSource.count - 2 inSection:0] atScrollPosition:UICollectionViewScrollPositionNone animated:NO];
        itemIndex = self.PHAssetSource.count - 2;
    }
    self.currentIndex = itemIndex;
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
