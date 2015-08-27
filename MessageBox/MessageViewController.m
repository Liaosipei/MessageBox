//
//  MessageViewController.m
//  Linkr
//
//  Created by liaosipei on 15/8/24.
//  Copyright (c) 2015年 liaosipei. All rights reserved.
//

#import "MessageViewController.h"
#import "GetData.h"
#import "MainCell.h"

#define SCREEN_WIDTH ([UIScreen mainScreen].bounds.size.width)
#define SCREEN_HEIGHT ([UIScreen mainScreen].bounds.size.height)
#define purpleColor [UIColor colorWithRed:192/255.0 green:158/255.0 blue:224/255.0 alpha:1]
#define blueColor [UIColor colorWithRed:135/255.0 green:206/255.0 blue:235/255.0 alpha:1]
#define fontBlueColor [UIColor colorWithRed:89.0/255 green:166.0/255 blue:212.0/255 alpha:1.0]
static NSString *MainCellReuseIdentifier=@"MainCell";

@interface MessageViewController ()<UITableViewDataSource,UITableViewDelegate,CScrollViewDataSource,CScrollViewDelegate,UIGestureRecognizerDelegate>{
    NSArray *menuTitle;
    NSArray *menuImage;
    MainCell *tempcell;
    BOOL isInbox;
    BOOL isEditing;
}

@property(nonatomic,strong)NSMutableArray *data;
@property(nonatomic,strong)UIView *editOptionBar;
@property(nonatomic,strong)UIButton *selectAllButton, *deleteButton;

@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    isInbox=YES;
    isEditing=NO;
    self.view.backgroundColor=[UIColor whiteColor];
    //设置navigation bar
    [self.navigationController.navigationBar setTranslucent:NO];
    self.title=@"Messages";
    self.navigationController.navigationBar.titleTextAttributes=@{NSForegroundColorAttributeName:[UIColor whiteColor],NSFontAttributeName:[UIFont boldSystemFontOfSize:20]};
    self.navigationController.navigationBar.barTintColor=blueColor;
    self.navigationController.navigationBar.tintColor=[UIColor whiteColor];
    
    //设置导航条的右按钮Edit
    UIBarButtonItem *editBarBtn=[[UIBarButtonItem alloc]initWithTitle:@"Edit" style:UIBarButtonItemStylePlain target:self action:@selector(clickEditButton:)];
    editBarBtn.tintColor=[UIColor whiteColor];
    editBarBtn.width=30;
    self.navigationItem.rightBarButtonItem=editBarBtn;
    //获取数据
    GetData *d=[[GetData alloc]init];
    self.data=[d getData];
    //NSLog(@"%@",self.data);
    //设置收件箱Inbox的table
    self.InboxTable=[[UITableView alloc]init];
    //self.InboxTable.rowHeight=90;
    self.InboxTable.dataSource=self;
    self.InboxTable.delegate=self;
    self.InboxTable.tag=1;
    //设置发件箱Sendbox的table
    self.SendboxTable=[[UITableView alloc]init];
    self.SendboxTable.rowHeight=90;
    self.SendboxTable.tag=2;
    UINib *cellNib=[UINib nibWithNibName:@"MainCell" bundle:nil];
    [self.InboxTable registerNib:cellNib forCellReuseIdentifier:MainCellReuseIdentifier];
    [self.SendboxTable registerNib:cellNib forCellReuseIdentifier:MainCellReuseIdentifier];
    self.tableView=[NSMutableArray arrayWithObjects:self.InboxTable,self.SendboxTable, nil];
    //设置tableView自动适应高度
    _InboxTable.estimatedRowHeight = 80;
    _InboxTable.rowHeight = UITableViewAutomaticDimension;
    
    //设置滚动视图MenuScrollView
    menuTitle=[NSArray arrayWithObjects:@"Inbox",@"Sendbox", nil];
    menuImage=[NSArray arrayWithObjects:@"message_receive",@"message_send",@"message_receive_p",@"message_send_p", nil];
    self.menuScrollView=[[CScrollView alloc]init];
    self.menuScrollView.dataSource=self;
    self.menuScrollView.delegate=self;
    
    [self.view addSubview:self.menuScrollView];
    //添加约束
    [self.menuScrollView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.menuScrollView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.menuScrollView attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeBottom multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.menuScrollView attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0 constant:0]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.menuScrollView attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0 constant:0]];
    
    self.menuScrollView.backgroundColor=[[UIColor grayColor]colorWithAlphaComponent:0.05];;
    [self.menuScrollView setSubMenuNormalColor:[[UIColor grayColor] colorWithAlphaComponent:0.8f]];
    [self.menuScrollView setSubMenuSelectedColor:fontBlueColor];
    [self.menuScrollView setInitSelectedIndex:0];
    [self.menuScrollView setSubMenuTitleFont:[UIFont fontWithName:@"Helvetica" size:14]];
    [self.menuScrollView setSubMenuWidth:SCREEN_WIDTH/2];
    [self.menuScrollView setAutoMenuWidth:NO];
    [self.menuScrollView reloadData];
}


#pragma mark - Edit

-(void)clickEditButton:(UIBarButtonItem *)button
{
    
    [self.selectAllButton setTitle:@"Select All" forState:UIControlStateNormal];
    if(isInbox==YES)
    {
        if(!_editOptionBar)
            [self creatEditOptionBar];
        if([button.title isEqualToString:@"Edit"])
        {
            isEditing=YES;
            CGRect frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64-40-45);
            self.InboxTable.frame=frame;
            self.editOptionBar.hidden=NO;
            
            [button setTitle:@"Done"];
            [self.InboxTable setAllowsMultipleSelectionDuringEditing:YES];
            [self.InboxTable setEditing:YES animated:YES];
        }else
        {
            isEditing=NO;
            CGRect frame=CGRectMake(0, 0, SCREEN_WIDTH, SCREEN_HEIGHT-64-40);
            self.InboxTable.frame=frame;
            self.editOptionBar.hidden=YES;
            
            [button setTitle:@"Edit"];
            [self.InboxTable setAllowsMultipleSelectionDuringEditing:NO];
            [self.InboxTable setEditing:NO animated:YES];
            
        }
    }
}

-(void)creatEditOptionBar
{
    
    self.editOptionBar=[[UIView alloc]initWithFrame:CGRectMake(0, SCREEN_HEIGHT-64-45, SCREEN_WIDTH, 45)];
    self.editOptionBar.backgroundColor=[[UIColor grayColor]colorWithAlphaComponent:0.1f];
    //选择全部按钮
    self.selectAllButton=[UIButton buttonWithType:UIButtonTypeCustom];
    self.selectAllButton.frame=CGRectMake(0, 0, SCREEN_WIDTH/2, 45);
    [self.selectAllButton setTitle:@"Select All" forState:UIControlStateNormal];
    [self.selectAllButton setTitleColor:fontBlueColor forState:UIControlStateNormal];
    [self.selectAllButton addTarget:self action:@selector(selectAllButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    //删除按钮
    self.deleteButton=[UIButton buttonWithType:UIButtonTypeCustom];
    self.deleteButton.frame=CGRectMake(SCREEN_WIDTH/2, 0, SCREEN_WIDTH/2, 45);
    [self.deleteButton setTitle:@"Delete" forState:UIControlStateNormal];
    [self.deleteButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
    [self.deleteButton addTarget:self action:@selector(deleteButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.editOptionBar addSubview:self.selectAllButton];
    [self.editOptionBar addSubview:self.deleteButton];
    [self.view addSubview:self.editOptionBar];
}

-(void)selectAllButtonPressed:(UIButton *)button
{
    if([self.selectAllButton.titleLabel.text isEqualToString:@"Select All"])
    {
        for(int row=0;row<self.data.count;row++)
        {
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:row inSection:0];
            [self.InboxTable selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
        }
        [self.selectAllButton setTitle:@"Unselect All" forState:UIControlStateNormal];
    }else
    {
        for(int row=0;row<self.data.count;row++)
        {
            NSIndexPath *indexPath=[NSIndexPath indexPathForRow:row inSection:0];
            [self.InboxTable deselectRowAtIndexPath:indexPath animated:NO];
        }
        [self.selectAllButton setTitle:@"Select All" forState:UIControlStateNormal];
    }
    
}

-(void)deleteButtonPressed:(UIButton *)button
{
    NSArray *selectedRows=[self.InboxTable indexPathsForSelectedRows];
    if(selectedRows>0)
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"When you delete this message, it will be permanently removed." delegate:self cancelButtonTitle:@"Delete" otherButtonTitles:@"Cancel", nil];
        [alert show];
    }
    else
    {
        UIAlertView *alert=[[UIAlertView alloc]initWithTitle:nil message:@"You haven't select any message!" delegate:nil cancelButtonTitle:nil otherButtonTitles:@"Cancel", nil];
        [alert show];
    }
}

//根据被点击按钮的索引处理点击事件
-(void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSArray *selectedRows=[self.InboxTable indexPathsForSelectedRows];
    if(buttonIndex==0)//删除
    {
        NSMutableIndexSet *deleteIndexSet=[NSMutableIndexSet new];
        for (NSIndexPath *selectedIndexPath in selectedRows)
            [deleteIndexSet addIndex:selectedIndexPath.row];
        [self.data removeObjectsAtIndexes:deleteIndexSet];
        [self.InboxTable deleteRowsAtIndexPaths:selectedRows withRowAnimation:UITableViewRowAnimationAutomatic];
    }
}

#pragma mark - UITableViewDataSource
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    MainCell *cell=[tableView dequeueReusableCellWithIdentifier:MainCellReuseIdentifier forIndexPath:indexPath];
    //cell.selectionStyle=UITableViewCellSelectionStyleNone;
    NSDictionary *cellData=[self.data objectAtIndex:indexPath.row];
    cell.Name.text=[cellData objectForKey:@"name"];
    [cell setDetailText:[cellData objectForKey:@"detail"] MaxLines:5];
    cell.Date.text=[cellData objectForKey:@"date"];
    return cell;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.data count];
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(isEditing==NO)
        [self.InboxTable deselectRowAtIndexPath:indexPath animated:NO];
}

//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
//{
//    if (tempcell == nil ){
//        tempcell = [tableView dequeueReusableCellWithIdentifier:MainCellReuseIdentifier];
//    }
//    NSDictionary *cellData=[self.data objectAtIndex:indexPath.row];
//    tempcell.Name.text=[cellData objectForKey:@"name"];
//    [tempcell setDetailText:[cellData objectForKey:@"detail"] MaxLines:5];
//    tempcell.Date.text=[cellData objectForKey:@"date"];
//    return [tempcell systemLayoutSizeFittingSize:UILayoutFittingCompressedSize].height+1;
//    
//}

#pragma mark - CScrollViewDelegate
- (void)cScrollView:(CScrollView *)scrollView displayView:(UIView *)view index:(int)index
{
    NSLog(@"displayView");
}

#pragma mark - CScrollViewDataSource
-(int)numberOfViewsForCScrollMenu:(CScrollView *)scroller
{
    NSLog(@"numberOfViewsForCScrollMenu:%i",(int)[self.tableView count]);
    return (int)[self.tableView count];
}
-(UIImage *)cScrollView:(CScrollView *)scrollView menuScrollView:(UIScrollView *)menuScrollView menuImageAtIndex:(int)index
{
    NSLog(@"menuImageAtIndex");
    return [UIImage imageNamed:[menuImage objectAtIndex:index]];
}
-(UIImage *)cScrollView:(CScrollView *)scrollView menuScrollView:(UIScrollView *)menuScrollView menuSelectedImageAtIndex:(int)index
{
    NSLog(@"menuSelectedImageAtIndex");
    return [UIImage imageNamed:[menuImage objectAtIndex:index+2]];
}
-(NSString *)cScrollView:(CScrollView *)scrollView menuScrollView:(UIScrollView *)menuScrollView menuTitleAtIndex:(int)index
{
    NSLog(@"menuTitleAtIndex");
    return [menuTitle objectAtIndex:index];
}
-(UIView *)cScrollView:(CScrollView *)scrollView contentScrollView:(UIScrollView *)contentScrollView contentViewAtIndex:(int)index
{
    NSLog(@"contentViewAtIndex");
    UIView *temp=[self.tableView objectAtIndex:index];
    return temp;
}


@end
