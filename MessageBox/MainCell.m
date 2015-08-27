//
//  MainCell.m
//  Linkr
//
//  Created by liaosipei on 15/8/25.
//  Copyright (c) 2015年 liaosipei. All rights reserved.
//

#import "MainCell.h"

@implementation MainCell

- (void)awakeFromNib {
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setDetailText:(NSString *)text MaxLines:(NSInteger)numberOfLines
{
    CGRect cellFrame=[self frame];
    self.Detail.text=text;
    self.Detail.numberOfLines=numberOfLines;
    [self.Detail layoutIfNeeded];
    cellFrame.size.height=self.Detail.frame.size.height+45;
    self.frame=cellFrame;
}

@end
