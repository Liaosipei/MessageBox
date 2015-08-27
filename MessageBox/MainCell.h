//
//  MainCell.h
//  Linkr
//
//  Created by liaosipei on 15/8/25.
//  Copyright (c) 2015年 liaosipei. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *Name;
@property (weak, nonatomic) IBOutlet UILabel *Date;
@property (weak, nonatomic) IBOutlet UILabel *Detail;

-(void)setDetailText:(NSString *)text MaxLines:(NSInteger) numberOfLines;

@end
