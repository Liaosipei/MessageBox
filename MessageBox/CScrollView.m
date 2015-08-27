//
//  CScrollView.m
//  ScrollTest
//
//  Created by fan.gao on 14-7-26.
//  Copyright (c) 2014年 haoqi. All rights reserved.
//

#import "CScrollView.h"

@interface CScrollView()<UIScrollViewDelegate>
{
    UIScrollView *_menuScrollView;
    UIScrollView *_contentScrollView;
    
    //自适应宽度时，用来保存每个按钮的宽度，便于滑动时的定位
    NSMutableArray *_widthArray;
    NSMutableArray *_contentViewArray;
    NSMutableArray *_menuViewArray;
    UIButton *_selectedButton;
    
    NSInteger lastIndex;
    
    UIImage *colorImage;
    UIImageView *indicatorImgView;
    
    float sep;
}
@property (nonatomic ,strong)UIScrollView *contentScrollView;
@end

@implementation CScrollView

- (id)init
{
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        //初始化默认值
        self.menuHeight = 40;
        self.autoMenuWidth = YES;
        self.subMenuWidth = 50;
        self.subMenuTitleFont = [UIFont systemFontOfSize:15];
        self.subMenuNormalColor = [UIColor grayColor];
        self.subMenuSelectedColor = [UIColor blueColor];
        self.initSelectedIndex = 0;
        self.autoUnloadView = NO;
        self.showContentView = YES;
        sep = 5;
        
        // Initialization code
        _menuScrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0,0, frame.size.width, self.menuHeight)];
        _menuScrollView.exclusiveTouch=YES;
        _menuScrollView.scrollEnabled=YES;
        _menuScrollView.delegate=self;
        _menuScrollView.showsHorizontalScrollIndicator = NO;
        _menuScrollView.showsVerticalScrollIndicator = NO;
        [self addSubview:_menuScrollView];
        _menuScrollView.backgroundColor = [UIColor clearColor];
        [self addSubview:self.contentScrollView];
        
        lastIndex = 0;
    }
    return self;
}

- (UIScrollView *)contentScrollView
{
    if (_contentScrollView==nil) {
        _contentScrollView=[[UIScrollView alloc]initWithFrame:CGRectMake(0, self.menuHeight, self.frame.size.width, self.frame.size.height-self.menuHeight)];
        _contentScrollView.exclusiveTouch=YES;
        _contentScrollView.scrollEnabled=YES;
        _contentScrollView.pagingEnabled=YES;
        _contentScrollView.delegate=self;
        _contentScrollView.showsHorizontalScrollIndicator = NO;
        _contentScrollView.showsVerticalScrollIndicator = NO;
        _contentScrollView.backgroundColor = [UIColor clearColor];
    }
    return _contentScrollView;
}

- (void)layoutSubviews
{
    NSLog(@"layoutSubviews");
    //当menu的高度改变时，改变子视图的高度
    BOOL change = fabs(self.frame.size.width-_menuScrollView.frame.size.width)>0.1;
    _menuScrollView.frame = CGRectMake(0,0, self.frame.size.width, self.menuHeight);
    if (change && _menuViewArray && [_menuViewArray count]>0) {
        sep = 5;
        int count = (int)[_menuViewArray count];
        CGFloat currentWidth = sep;
        for( int i=0; i<count ; i++ )
        {
            UIButton *button= [_menuViewArray objectAtIndex:i];
            NSString *title = button.titleLabel.text;
            if (self.autoMenuWidth) {
                CGFloat titleWidth = [self getTextSizeWithText:title rect:CGSizeMake(MAXFLOAT, 40) font:button.titleLabel.font].width;
                button.frame=CGRectMake(currentWidth - sep,0, titleWidth + sep*2, self.menuHeight);
                
                if (i == count - 1) {
                    currentWidth += titleWidth + sep;
                } else {
                    currentWidth += titleWidth + sep*2;
                }
                
                [_widthArray replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:titleWidth + sep*2]];
            }else{
                button.frame = CGRectMake(self.subMenuWidth*i, 0, self.subMenuWidth, self.menuHeight);
            }
        }
        
        if (!self.autoMenuWidth) {
            currentWidth = self.subMenuWidth*count;
        }else{
            if (currentWidth < _menuScrollView.frame.size.width) {
                currentWidth = [self resizeAllButtonsFrame:currentWidth];
            }
        }
    }
    
    if (self.showContentView) {
        self.contentScrollView.frame = CGRectMake(0, self.menuHeight, self.frame.size.width, self.frame.size.height-self.menuHeight);
        
        if (_contentViewArray && [_contentViewArray count]>0) {
            int count = (int)[_contentViewArray count];
            for (int i=0; i < count; i++) {
                UIView *contentView = [_menuViewArray objectAtIndex:i];
                if (![contentView isKindOfClass:[NSNull class]]) {
                    CGRect frame = contentView.frame;
                    frame.size.height = _menuScrollView.frame.size.height;
                    contentView.frame = frame;
                }
                
                contentView = [_contentViewArray objectAtIndex:i];
                if (YES == [contentView isKindOfClass:[UIView class]]) {
                    //重新计算视图的frame
                    CGRect frame = _contentScrollView.frame;
                    frame.origin.x = _contentScrollView.frame.size.width * i;
                    frame.origin.y = 0;
                    contentView.frame = frame;
                }
            }
        }
        
        _contentScrollView.contentSize = CGSizeMake(_contentScrollView.frame.size.width*[_contentViewArray count], _contentScrollView.frame.size.height);
    }
    
    CGRect frame = _selectedButton.frame;
    frame.origin.x += sep/2;
    frame.size.width -= sep;
    frame.origin.y = frame.size.height -2;
    frame.size.height = 2;
    indicatorImgView.frame = frame;

    [super layoutSubviews];
}

//- (void)setFrame:(CGRect)frame
//{
//    super.frame = frame;
//}

- (void)setSubMenuSelectedColor:(UIColor *)subMenuSelectedColor
{
    _subMenuSelectedColor = subMenuSelectedColor;
    CGRect rect = CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [subMenuSelectedColor CGColor]);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    colorImage = image;
    if (indicatorImgView) {
        indicatorImgView.image = colorImage;
    }
}

- (void)reloadData
{
    [[_menuScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview) withObject:nil];
    
    int count = 0;
    if ( self.dataSource && [self.dataSource respondsToSelector:@selector(numberOfViewsForCScrollMenu:)] )
    {
        count = [self.dataSource numberOfViewsForCScrollMenu:self];
    }
    
    if (_contentViewArray) {
        [_contentViewArray removeAllObjects];
    }
    if (self.showContentView) {
        [[_contentScrollView subviews] makeObjectsPerformSelector:@selector(removeFromSuperview) withObject:nil];
        _contentViewArray = [NSMutableArray arrayWithCapacity:count];
    }else{
        [_contentScrollView removeFromSuperview];
    }
    
    indicatorImgView = [[UIImageView alloc] initWithImage:colorImage];
    [_menuScrollView addSubview:indicatorImgView];
    
    if (_widthArray) {
        [_widthArray removeAllObjects];
    }
    
    if (_menuViewArray) {
        [_menuViewArray removeAllObjects];
    }
    
    _widthArray = [NSMutableArray arrayWithCapacity:count];
    _menuViewArray = [NSMutableArray arrayWithCapacity:count];
    
    for (int i=0; i < count; i++) {
        if (self.autoMenuWidth) {
            [_widthArray addObject:[NSNull null]];
        }
        if (_contentViewArray) {
            [_contentViewArray addObject:[NSNull null]];
        }
        [_menuViewArray addObject:[NSNull null]];
    }
    
    CGFloat currentWidth = sep;
    for( int i=0; i<count ; i++ )
    {
        UIButton *button=[UIButton buttonWithType:UIButtonTypeCustom];
        button.tag=i;
        [button addTarget:self action:@selector(menuSubViewTouched:) forControlEvents:UIControlEventTouchUpInside];
        //字体
        button.titleLabel.font = self.subMenuTitleFont;
        //设置文字的正常显示和选中状态的颜色
        [button setTitleColor:self.subMenuNormalColor forState:UIControlStateNormal];
        [button setTitleColor:self.subMenuSelectedColor forState:UIControlStateSelected];
        //内容
        NSString *title ;
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(cScrollView:menuScrollView:menuTitleAtIndex:)]) {
            title = [self.dataSource cScrollView:self menuScrollView:_menuScrollView menuTitleAtIndex:i];
        }
        UIImage *image;
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(cScrollView:menuScrollView:menuImageAtIndex:)]) {
            image = [self.dataSource cScrollView:self menuScrollView:_menuScrollView menuImageAtIndex:i];
        }
        
        if (image && title) {
            title = [NSString stringWithFormat:@"  %@",title];
            [button setImage:image forState:UIControlStateNormal];
        }
        [button setTitle:title forState:UIControlStateNormal];
        
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(cScrollView:menuScrollView:menuSelectedImageAtIndex:)]) {
            UIImage *selectedImage = [self.dataSource cScrollView:self menuScrollView:_contentScrollView menuSelectedImageAtIndex:i];
            [button setImage:selectedImage forState:UIControlStateSelected];
        }
        
        if (self.autoMenuWidth) {
            CGFloat titleWidth = [self getTextSizeWithText:title rect:CGSizeMake(MAXFLOAT, 40) font:button.titleLabel.font].width;
            button.frame=CGRectMake(currentWidth - sep,0, titleWidth + sep*2, self.menuHeight);
            
            if (i == count - 1) {
                currentWidth += titleWidth + sep;
            } else {
                currentWidth += titleWidth + sep*2;
            }
            
            [_widthArray replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:titleWidth + sep*2]];
        }else{
            button.frame = CGRectMake(self.subMenuWidth*i, 0, self.subMenuWidth, self.menuHeight);
        }
        [_menuScrollView addSubview:button];
        [_menuViewArray replaceObjectAtIndex:i withObject:button];
        
        if (i == self.initSelectedIndex) {
            _selectedButton = button;
        }
    }
    
    if (self.showContentView) {
        _contentScrollView.contentSize = CGSizeMake(_contentScrollView.frame.size.width*count, _contentScrollView.frame.size.height);
    }
    if (!self.autoMenuWidth) {
        currentWidth = self.subMenuWidth*count;
    }else{
        if (currentWidth < _menuScrollView.frame.size.width) {
            currentWidth = [self resizeAllButtonsFrame:currentWidth];
        }
    }
    _menuScrollView.contentSize = CGSizeMake(currentWidth, self.menuHeight);
    
    _selectedButton.selected = YES;
    [self menuSubViewTouched:_selectedButton];
}

- (void)menuSubViewTouched:(id)sender
{
    UIButton *btn = (UIButton*)sender;
    // 滑动到所选择的按钮
    [self scrollToButtonWithIndex:btn.tag];
    lastIndex = btn.tag;
    
    if (_selectedButton==nil)
    {
        _selectedButton = btn;
    }else
    {
        _selectedButton.selected = NO;
        _selectedButton = btn;
    }
    
    _selectedButton.selected = YES;
    CGRect frame = _selectedButton.frame;
    frame.origin.x += sep/2;
    frame.size.width -= sep;
    frame.origin.y = frame.size.height -2;
    frame.size.height = 2;
    indicatorImgView.frame = frame;
    
    if (self.showContentView) {
        [_contentScrollView setContentOffset:CGPointMake(btn.tag*_contentScrollView.frame.size.width,0) animated:YES];
        [self loadContentView:btn.tag];
        
        if (self.autoUnloadView) {
            [self loadContentView:btn.tag + 1];
            [self loadContentView:btn.tag - 1];
            
            [self unloadContentView:btn.tag - 2];
            [self unloadContentView:btn.tag + 2];
        }
    }
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(cScrollView:displayView:index:)]) {
        UIView *view;
        if (_contentViewArray && _contentViewArray.count>0) {
            view = [_contentViewArray objectAtIndex:btn.tag];
        }
        [self.delegate cScrollView:self displayView:view index:(int)_selectedButton.tag];
    }
}

// 重置所有按钮的宽度,返回搜有按钮所占区域的width
- (CGFloat)resizeAllButtonsFrame:(float)width
{
    if (_widthArray && [_widthArray count]>0) {
        CGFloat count = [_widthArray count];
        sep = (_menuScrollView.frame.size.width-width)/(count*2);
        // 重置所有宽度
        for (int i = 0; i < count; i ++) {
            UIButton *btn = [_menuViewArray objectAtIndex:i];
            CGRect frame = btn.frame;
            frame.origin.x = frame.origin.x+sep*i*2;
            frame.size.width = frame.size.width+sep*2;
            btn.frame = frame;
            // 重置按钮宽度数组
            [_widthArray replaceObjectAtIndex:i withObject:[NSNumber numberWithFloat:frame.size.width]];
        }
    }
    
    return _menuScrollView.frame.size.width;
}

// 滑动按钮到相应位置
- (void)scrollToButtonWithIndex:(NSInteger)index
{
    CGFloat btnOffset = [self getButtonOriginXWithIndex:index];
    CGFloat btnWidth = self.subMenuWidth;
    if (self.autoMenuWidth && _widthArray && [_widthArray count]!=0) {
        btnWidth = [[_widthArray objectAtIndex:index] floatValue];
    }
    
    NSLog(@"width = %f",self.frame.size.width);
    CGFloat leftGap = (self.frame.size.width - btnWidth)/2;
    
    if (leftGap>0 && btnOffset > leftGap) {
        CGFloat contentWidth = _menuScrollView.contentSize.width;
        CGFloat offsetX = btnOffset - leftGap;
        float width = _menuScrollView.frame.size.width;
        if ((contentWidth - offsetX) < width) {
            // 如果现有的button不能满屏则不移动
            if (contentWidth > width) {
                [_menuScrollView setContentOffset:CGPointMake(contentWidth - width,0) animated:YES];
            }
        } else {
            [_menuScrollView setContentOffset:CGPointMake(btnOffset - leftGap,0) animated:YES];
        }
    } else {
        [_menuScrollView setContentOffset:CGPointZero animated:YES];
    }
}

// 获取指定index的originX位移
- (CGFloat)getButtonOriginXWithIndex:(NSInteger)index
{
    CGFloat retValue = 5;
    if (self.autoMenuWidth) {
        for (int i = 0; i < index; i ++) {
            retValue += [[_widthArray objectAtIndex:i] floatValue];
        }
    }else{
        retValue = index * self.subMenuWidth;
    }
    return retValue;
}

- (void)unloadContentView:(NSInteger)index
{
    if (index < 0 || index >= [_contentViewArray count]) {
        return;
    }
    
    id currentPhotoView = [_contentViewArray objectAtIndex:index];
    if ([currentPhotoView isKindOfClass:[UIView class]]) {
        [currentPhotoView removeFromSuperview];
        [_contentViewArray replaceObjectAtIndex:index withObject:[NSNull null]];
    }
}

- (void)loadContentView:(NSInteger)index
{
    if (index < 0 || index >= [_contentViewArray count]) {
        return;
    }
    
    id currentPhotoView = [_contentViewArray objectAtIndex:index];
    if (NO == [currentPhotoView isKindOfClass:[UIView class]]) {
        if (self.dataSource && [self.dataSource respondsToSelector:@selector(cScrollView:contentScrollView:contentViewAtIndex:)]) {
            //加载视图
            UIView *view = [self.dataSource cScrollView:self contentScrollView:_contentScrollView contentViewAtIndex:(int)index];
            if (view) {
                CGRect frame = _contentScrollView.frame;
                frame.origin.x = _contentScrollView.frame.size.width * index;
                frame.origin.y = 0;
                view.frame = frame;
                [_contentScrollView addSubview:view];
                [_contentViewArray replaceObjectAtIndex:index withObject:view];
            }
        }
    }
}

#pragma mark - label height

- (CGSize)getTextSizeWithText:(NSString*)text rect:(CGSize)size font:(UIFont*)font
{
    if (text == nil || [text isEqualToString:@""]) {
        return CGSizeZero;
    }
    
    if ( [[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0 )
    {
        NSDictionary *attributesDictionary = [NSDictionary dictionaryWithObjectsAndKeys:font, NSFontAttributeName,nil];
        NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:text
                                                                                   attributes:attributesDictionary];
        return [string boundingRectWithSize:CGSizeMake(size.width, MAXFLOAT)
                                    options:(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
                                    context:nil].size;
    } else {
        UILabel *label = [[UILabel alloc] init];
        label.text = text;
        label.font = font;
        return [label textRectForBounds:CGRectMake(0, 0, size.width, MAXFLOAT) limitedToNumberOfLines:0].size;
    }
}

#pragma mark - UIScrollViewDelegate
-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    if(_contentScrollView && scrollView == _contentScrollView)
    {
        NSInteger index = fabs(scrollView.contentOffset.x)/scrollView.frame.size.width;
        
        if (lastIndex != index) {
            UIButton *btn =[_menuViewArray objectAtIndex:index];
            [self menuSubViewTouched:btn];
        }
    }    
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if(self.dataSource && [self.dataSource respondsToSelector:@selector(cScrollViewDidScroll:)])
        [self.dataSource cScrollViewDidScroll:scrollView];
    if(scrollView.contentOffset.x<0)
        [scrollView setContentOffset:CGPointZero];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
