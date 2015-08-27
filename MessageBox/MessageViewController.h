//
//  MessageViewController.h
//  Linkr
//
//  Created by liaosipei on 15/8/24.
//  Copyright (c) 2015年 liaosipei. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CScrollView.h"


@interface MessageViewController : UIViewController

@property(nonatomic,strong)CScrollView *menuScrollView;
@property(nonatomic,strong)UITableView *InboxTable, *SendboxTable;
@property(nonatomic,strong)NSMutableArray *tableView;


@end
