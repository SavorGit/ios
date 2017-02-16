//
//  AlbumListViewController.m
//  SavorX
//
//  Created by 郭春城 on 16/8/9.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "AlbumListViewController.h"
#import "PhotoListViewController.h"
#import "PhotoTool.h"
#import "OpenFileTool.h"

#define ALBUMCELLID @"ALBUMCELLID"

@interface AlbumListViewController ()<UITableViewDelegate, UITableViewDataSource, PhotoToolDelegate>

@property (nonatomic, strong) NSMutableArray *results; //记录当前相册集合
@property (nonatomic, strong) UITableView * tableView; //当前相册展示列表视图
@property (nonatomic, strong) PHImageRequestOptions * option; //相片导出参数

@end

@implementation AlbumListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self createUI];
}

- (void)createUI
{
    self.view.backgroundColor = VCBackgroundColor;
    [MBProgressHUD showCustomLoadingHUDInView:self.view];
    
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, kScreen_Height - NavHeight) style:UITableViewStylePlain];
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:self.tableView];
    [self.tableView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    [self.tableView setSeparatorInset:UIEdgeInsetsZero];
    [self.tableView setLayoutMargins:UIEdgeInsetsZero];
    
    [PhotoTool sharedInstance].delegate = self;
    [[PhotoTool sharedInstance] startLoadPhotoAssetCollection];
}

#pragma mark -- PhotoToolDelegate
- (void)PhotoToolDidGetAssetPhotoGroups:(NSArray *)results
{
    self.results = [NSMutableArray arrayWithArray:results];
    
    if (!results || results.count == 0) {
        [MBProgressHUD showTextHUDwithTitle:@"相册空空如也"];
    }
    [self.tableView reloadData];
    [MBProgressHUD hideHUDForView:self.view animated:YES];
}

#pragma mark -- UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:ALBUMCELLID];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ALBUMCELLID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell.imageView setContentMode:UIViewContentModeScaleToFill];
    }
    
    PhotoLibraryModel * model = [self.results objectAtIndex:indexPath.row];
    PHFetchResult * result = model.result;
    [[PHImageManager defaultManager] requestImageForAsset:[result lastObject] targetSize:CGSizeMake(100, 100) contentMode:PHImageContentModeAspectFill options:self.option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        [cell.imageView setImage:[self makeThumbnailOfSize:CGSizeMake(70, 70) image:result]];
    }];
    
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    cell.textLabel.text = model.title;
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"%ld", (unsigned long)result.count];
    
    return cell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.results.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100.f;
}

#pragma mark -- UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PhotoLibraryModel * model = [self.results objectAtIndex:indexPath.row];
    PhotoListViewController * list = [[PhotoListViewController alloc] init];
    list.title = model.title;
    list.PHAssetSource = model.result;
    [self.navigationController pushViewController:list animated:YES];
}

/**
 *  对相册的缩略图进行处理
 *
 *  @param size 需要得到的size大小
 *  @param img  需要转换的image
 *
 *  @return 返回一个UIImage对象，即为所需展示缩略图
 */
- (UIImage *)makeThumbnailOfSize:(CGSize)size image:(UIImage *)img
{
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0);
    // draw scaled image into thumbnail context
    [img drawInRect:CGRectMake(0, 0, size.width, size.height)];
    UIImage *newThumbnail = UIGraphicsGetImageFromCurrentImageContext();
    // pop the context
    UIGraphicsEndImageContext();
    return newThumbnail;
}

- (PHImageRequestOptions *)option
{
    if (nil == _option) {
        _option = [[PHImageRequestOptions alloc] init];
        _option.synchronous = YES;
        _option.resizeMode = PHImageRequestOptionsResizeModeExact;
    }
    return _option;
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
