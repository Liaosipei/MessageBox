//
//  CScrollView.h
//  ScrollTest
//
//  Created by fan.gao on 14-7-26.
//  Copyright (c) 2014年 haoqi. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CScrollView;

@protocol CScrollViewDelegate <NSObject>

//当前展示的view
- (void)cScrollView:(CScrollView *)scrollView displayView:(UIView *)view index:(int)index;

@end;

@protocol CScrollViewDataSource <NSObject>

@required
- (int)numberOfViewsForCScrollMenu:(CScrollView *)scroller;
@optional
- (UIImage *)cScrollView:(CScrollView *)scrollView menuScrollView:(UIScrollView *)menuScrollView menuImageAtIndex:(int)index;
- (UIImage *)cScrollView:(CScrollView *)scrollView menuScrollView:(UIScrollView *)menuScrollView menuSelectedImageAtIndex:(int)index;
- (NSString *)cScrollView:(CScrollView *)scrollView menuScrollView:(UIScrollView *)menuScrollView menuTitleAtIndex:(int)index;
- (UIView *)cScrollView:(CScrollView *)scrollView contentScrollView:(UIScrollView *)contentScrollView contentViewAtIndex:(int)index;

-(void)cScrollViewDidScroll:(UIScrollView *)scrollView;
@end

@interface CScrollView : UIView

@property (nonatomic, assign) BOOL showContentView;
@property (nonatomic, assign) float menuHeight;
@property (nonatomic, assign) BOOL autoMenuWidth;//子菜单的宽度是否根据文字长度来自动调节其宽度
@property (nonatomic, assign) float subMenuWidth;
@property (nonatomic, assign) BOOL autoUnloadView;
@property (nonatomic ,strong) UIFont *subMenuTitleFont;//字体和大小
@property (nonatomic ,strong) UIColor *subMenuNormalColor;//按钮正常状态时，文字颜色
@property (nonatomic ,strong) UIColor *subMenuSelectedColor;//按钮选中状态时，文字的颜色
@property (nonatomic, assign) int initSelectedIndex;
@property (nonatomic, weak) id<CScrollViewDelegate> delegate;
@property (nonatomic, weak) id<CScrollViewDataSource> dataSource;

- (void)reloadData;

@end
