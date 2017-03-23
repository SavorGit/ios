//
//  SliderViewController.m
//  SavorX
//
//  Created by 郭春城 on 16/10/27.
//  Copyright © 2016年 郭春城. All rights reserved.
//

#import "SliderViewController.h"
#import "SliderListViewController.h"
#import "PhotoTool.h"
#import "AddPhotoListViewController.h"

#define sliderMaxNum 50

#define SLIDERCELLID @"SLIDERCELLID"

@interface SliderViewController ()<UITableViewDelegate, UITableViewDataSource, PhotoToolDelegate, AddPhotoListDelegate, SliderListDelegate>

@property (nonatomic, strong) NSMutableArray *results; //记录当前相册集合
@property (nonatomic, strong) NSArray * systemResults; //系统相册集合
@property (nonatomic, strong) UITableView * tableView; //当前相册展示列表视图
@property (nonatomic, strong) PHImageRequestOptions * option; //相片导出参数
@property (nonatomic, strong) NSMutableArray * idArray; //记录当前添加的id
@property (nonatomic, copy) NSString * currentTitle; //记录当前的幻灯片标题
@property (nonatomic, strong) UIView * firstView; //“创建您的第一张幻灯片”

@end

@implementation SliderViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self createUI];
}

- (void)viewDidAppear:(BOOL)animated{
    
    [SAVORXAPI postUMHandleWithContentId:@"slide_to_screen_list" key:nil value:nil];
}

- (void)createUI
{
    self.view.backgroundColor = VCBackgroundColor;
    
    self.results = [PhotoTool sharedInstance].sliderArray;
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
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 60)];
    UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreen_Width, 0.5f)];
    view.backgroundColor = [[UIColor lightGrayColor] colorWithAlphaComponent:.8f];
    [label addSubview:view];
    label.text = [NSString stringWithFormat:@"最多可以创建%d个幻灯片", sliderMaxNum];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor grayColor];
    label.font = [UIFont systemFontOfSize:FontSizeDefault];
    self.tableView.tableFooterView = label;
    
    if (self.results.count == 0) {
        [self createFirstView];
    }else{
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createPhotoLibrary)];
    }
    
    if (self.results.count >= sliderMaxNum) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    
    [PhotoTool sharedInstance].delegate = self;
    [[PhotoTool sharedInstance] startLoadPhotoAssetCollection];
}

#pragma mark -- PhotoToolDelegate
- (void)PhotoToolDidGetAssetPhotoGroups:(NSArray *)results
{
    if (!results || results.count == 0) {
        [MBProgressHUD showTextHUDwithTitle:@"相册空空如也"];
    }
    
    self.systemResults = [NSArray arrayWithArray:results];
}

#pragma mark -- AddPhotoListDelegate
- (void)PhotoDidCreateByIDArray:(NSArray *)array
{
    if (self.firstView) {
        [self.firstView removeFromSuperview];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(createPhotoLibrary)];
    }
    if (array.count > 0) {
        [self.idArray addObjectsFromArray:array];
        [[PhotoTool sharedInstance] addSliderItemWithIDArray:self.idArray andTitle:self.currentTitle];
        [self refreshUI];
        
        NSDictionary * dict = [self.results objectAtIndex:0];
        SliderListViewController * list = [[SliderListViewController alloc] init];
        list.infoDict = dict;
        list.systemResults = self.systemResults;
        list.delegate = self;
        [self.navigationController pushViewController:list animated:YES];
    }
}

#pragma mark -- SliderListDelegate
- (void)sliderListDidBeChange
{
    [self refreshUI];
}

//刷新列表视图
- (void)refreshUI
{
    self.results = [PhotoTool sharedInstance].sliderArray;
    if (self.results.count >= sliderMaxNum) {
        self.navigationItem.rightBarButtonItem.enabled = NO;
    }
    if (self.results.count == 0) {
        [self createFirstView];
    }
    [self.tableView reloadData];
}

- (void)createFirstView
{
    self.navigationItem.rightBarButtonItem = nil;
    self.firstView = [[UIView alloc] init];
    self.firstView.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:self.firstView];
    [self.firstView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(0);
    }];
    
    UIImageView * imageView = [[UIImageView alloc] init];
    [imageView setImage:[UIImage imageNamed:@"xiaolian"]];
    [self.firstView addSubview:imageView];
    [imageView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.centerY.mas_equalTo(-(kScreen_Width - 70) / 3);
        make.size.mas_equalTo(CGSizeMake(70, 100));
    }];
    
    UILabel * label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.textColor = UIColorFromRGB(0x444444);
    label.text = @"创建您的第一个幻灯片吧~";
    label.textAlignment = NSTextAlignmentCenter;
    label.font = [UIFont systemFontOfSize:17];
    [self.firstView addSubview:label];
    [label mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.equalTo(imageView.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(kMainBoundsWidth, 40));
    }];
    
    UIButton * button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setTitleColor:UIColorFromRGB(0xc4ab62) forState:UIControlStateNormal];
    button.layer.borderColor = [UIColor colorWithHexString:@"#c4ab62"].CGColor;
    button.layer.borderWidth = 1.f;
    button.layer.cornerRadius = 5;
    button.clipsToBounds = YES;
    [button setTitle:@"去创建" forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:17];
    [button addTarget:self action:@selector(createPhotoLibrary) forControlEvents:UIControlEventTouchUpInside];
    [self.firstView addSubview:button];
    [button mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerX.mas_equalTo(0);
        make.top.equalTo(label.mas_bottom).offset(10);
        make.size.mas_equalTo(CGSizeMake(90, 40));
    }];
}

//创建按钮被点击
- (void)createPhotoLibrary
{
    [SAVORXAPI postUMHandleWithContentId:@"slide_to_screen_creat" key:nil value:nil];
    UIAlertController * alert = [UIAlertController alertControllerWithTitle:@"新建幻灯片" message:@"为此幻灯片输入名称" preferredStyle:UIAlertControllerStyleAlert];
    [alert addTextFieldWithConfigurationHandler:^(UITextField * _Nonnull textField) {
        textField.placeholder = @"请输入名称";
        //添加监听，用户监听输入框字数
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(alertTextFieldDidChange) name:UITextFieldTextDidChangeNotification object:nil];
    }];
    UIAlertAction * leftAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
        [SAVORXAPI postUMHandleWithContentId:@"slide_to_screen_creat_name" key:@"slide_to_screen_creat_name" value:@"cancel"];
    }];
    UIAlertAction * rightAction = [UIAlertAction actionWithTitle:@"创建" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        [SAVORXAPI postUMHandleWithContentId:@"slide_to_screen_creat_name" key:@"slide_to_screen_creat_name" value:@"creat"];
        [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
        
        UITextField * textFiled = [alert.textFields firstObject];
        NSString * title = textFiled.text;
        
        for (NSDictionary * dict in self.results) {
            if ([[dict objectForKey:@"title"] isEqualToString:title]) {
                [MBProgressHUD showTextHUDwithTitle:@"已经存在相同名称的幻灯片"];
                return;
            }
        }
        
        self.idArray = [NSMutableArray new];
        self.currentTitle = title;
        
        AddPhotoListViewController * add = [[AddPhotoListViewController alloc] init];
        add.currentNum = 0;
        add.libraryTitle = title;
        add.results = [NSMutableArray arrayWithArray:self.systemResults];
        add.delegate = self;
        [self.navigationController pushViewController:add animated:YES];
    }];
    rightAction.enabled = NO;
    [alert addAction:leftAction];
    [alert addAction:rightAction];
    [self presentViewController:alert animated:YES completion:nil];
}

//只有字数大于0时才能进行幻灯片创建
- (void)alertTextFieldDidChange
{
    UIAlertController * alert = (UIAlertController *)self.presentedViewController;
    UITextField * textFiled = [alert.textFields firstObject];
    UIAlertAction * action = [alert.actions lastObject];
    if (textFiled.text.length > 0) {
        action.enabled = YES;
    }else{
        action.enabled = NO;
    }
}

#pragma mark -- UITableViewDataSource
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:SLIDERCELLID];
    if (nil == cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:SLIDERCELLID];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [cell.imageView setContentMode:UIViewContentModeScaleToFill];
    }
    
    NSDictionary * dict = [self.results objectAtIndex:indexPath.row];
    NSArray * array = [dict objectForKey:@"ids"];
    PHAsset * asset = [PHAsset fetchAssetsWithLocalIdentifiers:@[[array firstObject]]options:nil].firstObject;
    if (asset) {
        [[PHImageManager defaultManager] requestImageForAsset:asset targetSize:CGSizeMake(100, 100) contentMode:PHImageContentModeAspectFill options:self.option resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            [cell.imageView setImage:[self makeThumbnailOfSize:CGSizeMake(70, 70) image:result]];
        }];
    }else{
        [cell.imageView setImage:[UIImage imageNamed:@"SliderNULL"]];
    }
    
    cell.textLabel.lineBreakMode = NSLineBreakByTruncatingMiddle;
    cell.textLabel.text = [NSString stringWithFormat:@"%@ (%ld)", [dict objectForKey:@"title"], (unsigned long)array.count];
    cell.detailTextLabel.textColor = [UIColor grayColor];
    cell.detailTextLabel.text = [NSString stringWithFormat:@"更新日期: %@", [dict objectForKey:@"createTime"]];
    
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
    NSDictionary * dict = [self.results objectAtIndex:indexPath.row];
    SliderListViewController * list = [[SliderListViewController alloc] init];
    list.infoDict = dict;
    list.systemResults = self.systemResults;
    list.delegate = self;
    [self.navigationController pushViewController:list animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return YES;
}

//返回cell的编辑样式
- (UITableViewCellEditingStyle)tableView:(UITableView *)tableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [tableView setEditing:NO animated:YES];
        
        NSDictionary * dict = [self.results objectAtIndex:indexPath.row];
        
        UIAlertController * alert = [UIAlertController alertControllerWithTitle:[NSString stringWithFormat:@"确认删除幻灯片\"%@\"", [dict objectForKey:@"title"]] message:@"相片将不会从本地删除" preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction * cancleAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            
        }];
        UIAlertAction * removeAction = [UIAlertAction actionWithTitle:@"删除" style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action) {
            [[PhotoTool sharedInstance] removeSliderItemWithIndex:indexPath.row];
            self.results = [PhotoTool sharedInstance].sliderArray;
            [self.tableView beginUpdates];
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
            [self.tableView endUpdates];
            if (self.results.count == 0) {
                [self createFirstView];
            }
            self.navigationItem.rightBarButtonItem.enabled = YES;
        }];
        [alert addAction:removeAction];
        [alert addAction:cancleAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return @"  删 除  ";
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
