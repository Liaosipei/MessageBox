# MessageBox

MessageBox展示消息列表，类似于消息/邮件的收件箱，实现以下功能：  
1. 基于NavigationController的消息列表，使用自写的CScrollView实现两个tableView（收件箱和发件箱）的切换，NavigationBar下方显示当前位于收件箱还是发件箱，既可以左右滑动tableView切换，也可以点击收发件箱切换。  
2. 自定义tableViewCell，并在nib文件中使用AutoLayout布局。  
3. 使用ios8新功能来自动计算cell行高，仅需要下面两句话即可：  
    `tableView.estimatedRowHeight = 80;` //预估行高，给出一个较为平均的值即可  
    `tableView.rowHeight = UITableViewAutomaticDimension;` //这一句相当于实现了以前计算行高的函数，它会根据布局来自动计算行高  
4. 编辑Edit功能：点击右上角的Edit后，下方出现“Select All”和“Delete”按钮，分别实现选择全部和删除选中消息的功能。  

#使用说明

使用时，需要在AppDelegate.m中import文件"MessageNavigation.h"，并在函数application:didFinishLaunchingWithOptions:中添加如下代码：  
    `MessageNavigation *messageNav=[[MessageNavigation alloc]init];`  
    `self.window.rootViewController=messageNav;`  
    `[self.window makeKeyAndVisible];` 
