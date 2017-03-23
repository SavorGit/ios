//
//  AddPhotoListViewController.m
//  SavorX
//
//  Created by 郭春城 on 16/11/1.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "AddPhotoListViewController.h"
#import "PhotoListViewController.h"
#import "PhotoTool.h"
#import "OpenFileTool.h"
#import "AddLibraryViewController.h"

#define ADDPOTHOCELLID @"ADDPOTHOCELLID"

@interface AddPhotoListViewController ()<UITableViewDelegate, UITableViewDataSource, AddLibraryDelegate>

@property (nonatomic, strong) UITableView * tableView; //当前相册展示列表视图
@property (nonatomic, strong) PHImageRequestOptions * option; //相片导出参数

@end

@implementation AddPhotoListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUI];
}

- (void)viewDidAppear:(BOOL)animated{
    [SAVORXAPI postUMHandleWithContentId:@"slide_to_screen_open_album" key:nil value:nil];
}

- (void)libraryDidCreateByIDArray:(NSArray *)array
{
    self.currentNum = self.currentNum + array.count;
    if (self.delegate && [self.delegate respondsToSelector:@selector(PhotoDidCreateByIDArray:)]) {
        [self.delegate PhotoDidCreateByIDArray:array];
    }
}

- (void)createUI
{
    self.title = @"选择相册";
    
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
}

#pragma mark -- UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:ADDPOTHOCELLID];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ADDPOTHOCELLID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell.imageView setContentMode:UIViewContentModeScaleToFill];
    }
    
    PhotoLibraryModel * model = [self.results objectAtIndex:indexPath.row];
    PHFetchResult * result = model.result;
    [[PHImageManager defaultManager] requestImageForAsset:[result lastObject] targetSize:CGSizeMake(100, 100) contentMode:PHImageContentModeAspectFill options:self.option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        [cell.imageView setImage:[self makeThumbnailOfSize:CGSizeMake(70, 70) image:result]];
    }];
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
    [SAVORXAPI postUMHandleWithContentId:@"slide_to_screen_click_album" key:nil value:nil];
    if (self.currentNum >= 50) {
        [MBProgressHUD showTextHUDwithTitle:@"该幻灯片已经有50张照片"];
        return;
    }
    
    PhotoLibraryModel * model = [self.results objectAtIndex:indexPath.row];
    AddLibraryViewController * add = [[AddLibraryViewController alloc] init];
    add.model = model;
    add.currentNum = self.currentNum;
    add.libraryTitle = self.libraryTitle;
    add.delegate = self;
    [self.navigationController pushViewController:add animated:YES];
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
