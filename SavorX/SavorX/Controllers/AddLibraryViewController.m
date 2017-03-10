//
//  AddLibraryViewController.m
//  SavorX
//
//  Created by 郭春城 on 16/10/20.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "AddLibraryViewController.h"
#import "AddSliderCollectionViewCell.h"
#import "SliderListViewController.h"
#import "PhotoTool.h"
#import "SliderViewController.h"
#import "PhotoShowViewController.h"

#define SliderListCollection @"PhotoListCollection"

@interface AddLibraryViewController ()<UICollectionViewDelegate, UICollectionViewDataSource, ADDSliderCollectionViewCellDelegate>

@property (nonatomic, strong) UICollectionView * collectionView; //展示图片列表视图
@property (nonatomic, strong) PHImageRequestOptions *option; //当前页面的图片导出参数
@property (nonatomic, strong) UIToolbar * bottomView; //底部控制栏
@property (nonatomic, strong) NSMutableArray * selectArray; //选择的数组
@property (nonatomic, strong) UIButton * chooseButton;

@end

@implementation AddLibraryViewController

- (instancetype)init
{
    if (self = [super init]) {
        self.currentNum = 10;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"选择照片";
    self.view.backgroundColor = VCBackgroundColor;
    self.selectArray = [NSMutableArray new];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStyleDone target:self action:@selector(allChoose)];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back"] style:UIBarButtonItemStylePlain target:self action:@selector(PageBack)];
    self.navigationItem.leftBarButtonItem.imageInsets = UIEdgeInsetsMake(2, -8, -2, 8);
    
    UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
    flowLayout.itemSize = CollectionViewCellSize;
    flowLayout.minimumInteritemSpacing = 1;
    flowLayout.minimumLineSpacing = 1;
    
    self.collectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:flowLayout];
    [self.collectionView registerClass:[AddSliderCollectionViewCell class] forCellWithReuseIdentifier:SliderListCollection];
    self.collectionView.dataSource = self;
    self.collectionView.delegate = self;
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:self.collectionView];
    
    [self.collectionView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.mas_equalTo(0);
        make.left.mas_equalTo(0);
        make.right.mas_equalTo(0);
        make.bottom.mas_equalTo(-50);
    }];
    
    self.bottomView = [[UIToolbar alloc] init];
    [self.view addSubview:self.bottomView];
    [self.bottomView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.left.mas_equalTo(0);
        make.bottom.mas_equalTo(0);
        make.size.mas_equalTo(CGSizeMake(kScreen_Width, 50));
    }];
    self.chooseButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.chooseButton setFrame:CGRectMake(0, 0, kScreen_Width, 50)];
    [self.chooseButton setBackgroundColor:[UIColor clearColor]];
    [self.chooseButton setTitle:@"请先选择图片" forState:UIControlStateNormal];
    [self.chooseButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    self.chooseButton.titleLabel.font = [UIFont systemFontOfSize:FontSizeBig];
    [self.chooseButton addTarget:self action:@selector(addPhotoToLibrary) forControlEvents:UIControlEventTouchUpInside];
    [self.bottomView addSubview:self.chooseButton];
    self.chooseButton.userInteractionEnabled = NO;
    
    NSIndexPath * indexPath = [NSIndexPath indexPathForItem:self.model.result.count - 1 inSection:0];
    if (self.model.result.count > 0) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(.1f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
        });
    }
}

- (void)SliderCollectionViewCellDidClicked:(AddSliderCollectionViewCell *)cell
{
    PhotoShowViewController * slider = [[PhotoShowViewController alloc] init];
    slider.result = self.model.result;
    
    NSIndexPath * indexPath = [self.collectionView indexPathForCell:cell];
    slider.indexPath = indexPath;
    [self.navigationController pushViewController:slider animated:YES];
}

- (void)chooseButtonDidClicked
{
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"提示" message:[NSString stringWithFormat:@"是否添加已勾选的这%ld张图片", (unsigned long)self.selectArray.count] preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"是" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
        [MBProgressHUD showLoadingHUDInView:self.view];
        NSMutableArray * array = [NSMutableArray new];
        PHFetchResult * result = self.model.result;
        
        for (NSInteger i = 0; i < self.selectArray.count; i++) {
            NSIndexPath * indexPath = [self.selectArray objectAtIndex:i];
            PHAsset * asset = [result objectAtIndex:indexPath.row];
            [array addObject:asset.localIdentifier];
        }
        if (array.count > 0) {
            [MBProgressHUD showTextHUDwithTitle:@"添加成功"];
            
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            UIViewController * listVC = [self currentSliderListViewController];
            UIViewController * sliderVC = [self currentSliderViewController];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
            if (listVC) {
                [self.navigationController popToViewController:listVC animated:YES];
            }else if (sliderVC){
                [self.navigationController popToViewController:sliderVC animated:YES];
            }else{
                [self.navigationController popViewControllerAnimated:YES];
            }
            if (self.delegate && [self.delegate respondsToSelector:@selector(libraryDidCreateByIDArray:)]) {
                [self.delegate libraryDidCreateByIDArray:array];
            }
            [self.selectArray removeAllObjects];
        }
        
    }];
    UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"否" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [self.navigationController popViewControllerAnimated:YES];
    }];
    UIAlertAction * action3 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    [alert addAction:action1];
    [alert addAction:action2];
    [alert addAction:action3];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)addPhotoToLibrary
{
    NSMutableArray * array = [NSMutableArray new];
    PHFetchResult * result = self.model.result;
    
    for (NSInteger i = 0; i < self.selectArray.count; i++) {
        NSIndexPath * indexPath = [self.selectArray objectAtIndex:i];
        PHAsset * asset = [result objectAtIndex:indexPath.row];
        [array addObject:asset.localIdentifier];
    }
    if (array.count > 0) {
        
        UIViewController * listVC = [self currentSliderListViewController];
        UIViewController * sliderVC = [self currentSliderViewController];
        
        if (listVC) {
            [self.navigationController popToViewController:listVC animated:YES];
        }else if (sliderVC){
            [self.navigationController popToViewController:sliderVC animated:YES];
        }else{
            [self.navigationController popViewControllerAnimated:YES];
        }
        if (self.delegate && [self.delegate respondsToSelector:@selector(libraryDidCreateByIDArray:)]) {
            [self.delegate libraryDidCreateByIDArray:array];
        }
        [self.selectArray removeAllObjects];
    }
}

//获取当前的幻灯片列表控制器
- (UIViewController *)currentSliderListViewController
{
    NSArray * VCs = self.navigationController.viewControllers;
    for (UIViewController * vc in VCs) {
        if ([vc isKindOfClass:[SliderListViewController class]]) {
            return vc;
        }
    }
    return nil;
}

//获取当前的幻灯片控制器
- (UIViewController *)currentSliderViewController
{
    NSArray * VCs = self.navigationController.viewControllers;
    for (UIViewController * vc in VCs) {
        if ([vc isKindOfClass:[SliderViewController class]]) {
            return vc;
        }
    }
    return nil;
}

//全选动作触发
- (void)allChoose
{
    NSInteger maxNum = self.model.result.count > kMAXPhotoNum - self.currentNum ? kMAXPhotoNum - self.currentNum : self.model.result.count;
    NSMutableArray * tempArray = [NSMutableArray new];
    for (NSInteger i = 0; i < maxNum; i++) {
        if (i >= self.model.result.count) {
            break;
        }
        if (self.selectArray.count > kMAXPhotoNum - self.currentNum - 1) {
            break;
        }
        NSIndexPath * indexPath = [NSIndexPath indexPathForItem:self.model.result.count - 1 - i inSection:0];
        if ([self.selectArray containsObject:indexPath]) {
            maxNum++;
            continue;
        }
        [self.selectArray addObject:indexPath];
    }
    
    if (tempArray.count > 0) {
        for (NSInteger i = 0; i < tempArray.count; i++) {
            [self.selectArray addObject:[tempArray objectAtIndex:tempArray.count - i - 1]];
        }
    }
    [self.collectionView reloadData];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消全选" style:UIBarButtonItemStyleDone target:self action:@selector(cancelAllChoose)];
    [self updateChooseButtonStatus];
}

- (void)cancelAllChoose
{
    if (self.selectArray.count > 0) {
        [self.selectArray removeAllObjects];
    }
    [self.collectionView reloadData];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStyleDone target:self action:@selector(allChoose)];
    [self updateChooseButtonStatus];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.model.result.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    AddSliderCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:SliderListCollection forIndexPath:indexPath];
    
    PHAsset * asset = [self.model.result objectAtIndex:indexPath.row];
    
    [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CollectionViewCellSize contentMode:PHImageContentModeAspectFill options:nil resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        [cell.bgImageView setImage:result];
    }];
    cell.delegate = self;
    
    if ([self.selectArray containsObject:indexPath]) {
        [cell changeSelectedTo:YES];
    }else{
        [cell changeSelectedTo:NO];
    }
    
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    AddSliderCollectionViewCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:SliderListCollection forIndexPath:indexPath];
    
    if ([self.selectArray containsObject:indexPath]) {
        [self.selectArray removeObject:indexPath];
        [cell changeSelectedTo:NO];
        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"全选" style:UIBarButtonItemStyleDone target:self action:@selector(allChoose)];
        [self updateChooseButtonStatus];
    }else{
        if (self.selectArray.count > kMAXPhotoNum - self.currentNum - 1) {
            [MBProgressHUD showTextHUDwithTitle:[NSString stringWithFormat:@"最多只能选择%d张", kMAXPhotoNum]];
            return;
        }
        
        [self.selectArray addObject:indexPath];
        [cell changeSelectedTo:YES];
        [collectionView reloadItemsAtIndexPaths:@[indexPath]];
        [self updateChooseButtonStatus];
    }
}

//更新选择按钮的状态
- (void)updateChooseButtonStatus
{
    if (self.selectArray.count > 0) {
        [self.chooseButton setTitleColor:PhotoToolTitleColor forState:UIControlStateNormal];
        [self.chooseButton setTitle:[NSString stringWithFormat:@"添加至幻灯片\"%@\"", self.libraryTitle] forState:UIControlStateNormal];
        self.title = [NSString stringWithFormat:@"%@(%ld/%d)", self.model.title, self.selectArray.count + self.currentNum, kMAXPhotoNum];
        self.chooseButton.userInteractionEnabled = YES;
    }else{
        [self.chooseButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
        [self.chooseButton setTitle:@"请先选择图片" forState:UIControlStateNormal];
        self.title = self.model.title;
        self.chooseButton.userInteractionEnabled = NO;
    }
}

//页面返回的时候判断是否有选择的图片
- (void)PageBack
{
    if (self.selectArray.count > 0) {
        [self chooseButtonDidClicked];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
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
