#import "ViewController.h"
#import "HXProgress.h"
@interface ViewController ()<UITableViewDelegate, UITableViewDataSource> {
    UITableView * tableV;
    NSArray * sectionRowsTitles;
}
@end
@implementation ViewController
#pragma mark- cycle life
- (void)viewDidLoad {
    [super viewDidLoad];
    [self initNav];
    [self initUI];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}
#pragma mark- initUI
- (void)initUI {
    CGRect tableVFrame = self.view.frame;
    tableV = [[UITableView alloc] initWithFrame:tableVFrame style:UITableViewStyleGrouped];
    tableV.delegate = self;
    tableV.dataSource = self;
    [self setExtraCellLineHidden:tableV];
    [self.view addSubview:tableV];
}
- (void)initNav {
    UIButton * rightBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 20)];
    [rightBtn addTarget:self action:@selector(rightBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [rightBtn setTitle:@"push" forState:UIControlStateNormal];
    [rightBtn setTitleColor:[UIColor blueColor] forState:UIControlStateNormal];
    UIBarButtonItem* item = [[UIBarButtonItem alloc] initWithCustomView:rightBtn];
    self.navigationItem.rightBarButtonItem = item;
    self.title = NSLocalizedString(@"你好", nil);//@"你好";
}
#pragma mark- Event
- (void)rightBtnClick {
    NSLog(@"right");
}
#pragma mark- Setting Getting
#pragma mark -TableView DataSource
-  (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    sectionRowsTitles = @[@[@"toast默认",@"toast设置消失时间",@"自定义toast"],
                          @[@"Progress默认没文字",@"Progress有文字",@"Progress文字图片",@"上传长时间操作"],@[@"消失",@"消失带图片成功",@"消失失败"]];
    return [sectionRowsTitles[section] count];
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"testCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:CellIdentifier];
    }
    cell.textLabel.text  = sectionRowsTitles[indexPath.section][indexPath.row];
    return cell;
}
#pragma mark TableView Delegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0: {
                    [HXProgress showToastWithMsg:@"固定2秒的提示"];
                }
                    break;
                case 1: {
                    [HXProgress showToastWithMsg:@"固定2秒的提示" title:@"标题" image:[UIImage imageNamed:@"LOGO.png"] tapBlock:^(BOOL didTap) {
                        NSLog(@"点击了 Toast");
                    }] ;
                }
                    break;
                case 2: {
                    [HXProgress showToastWithCustomView:({
                        UIView * view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 100, 100)];
                        view.backgroundColor = [UIColor yellowColor];
                        view;
                    })];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 1: {
            switch (indexPath.row) {
                case 0: { 
                    [HXProgress showHUD];
                }
                    break;
                case 1: { 
                    [HXProgress showWithStatus:@"加载中..."];
                }
                    break;
                case 2: { 
                    [HXProgress showImage:[UIImage imageNamed:@"qqq.png"] status:@"带图片的HUD"];
                }
                    break;
                case 3: { 
                    dispatch_async(dispatch_get_main_queue(), ^{
                        for (int i = 1; i < 101; i ++) {
                            [HXProgress showProgress:i/100.0 status:[NSString stringWithFormat:@"已上传 %d %%",i]];
                            if (i == 100) {
                                sleep(0.1);
                                [HXProgress dismissHUD:[UIImage imageNamed:@"qqq.png"] status:@"操作完成!!"];
                            }
                        }
                    });
                }
                    break;
                default:
                    break;
            }
        }
            break;
        case 2: {
            switch (indexPath.row) {
                case 0: {
                    [HXProgress dismissHUD];
                }
                    break;
                case 1: {
                    [HXProgress dismissHUD:[UIImage imageNamed:@"qqq.png"]];
                }
                    break;
                case 2: {
                    [HXProgress dismissHUD:[UIImage imageNamed:@"qqq.png"] status:@"带文字消失"];
                }
                    break;
                default:
                    break;
            }
        }
            break;
        default:
            break;
    }
}
- (void)setExtraCellLineHidden: (UITableView *)tableView{
    UIView *view =[ [UIView alloc]init];
    view.backgroundColor = [UIColor clearColor];
    [tableView setTableFooterView:view];
}
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45;
}
#pragma mark- tableV headView Custom
- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    NSArray * titleArr = @[@"Toast",@"Progress",@"消失"];
    UIView * headView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 320, 25)];
    UILabel * timeLab = [[UILabel alloc] initWithFrame:CGRectMake(20, 0, 200, 25)];
    NSString * headStr = [titleArr objectAtIndex:section];
    timeLab.text = headStr;
    timeLab.textColor = [UIColor lightGrayColor];
    timeLab.font = [UIFont systemFontOfSize:14];
    [headView addSubview:timeLab];
    headView.backgroundColor = [UIColor clearColor];
    return headView;
}
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 25;
}
- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.00001f;
}
@end
