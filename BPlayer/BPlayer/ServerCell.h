//
//  ServerCell.h
//  uulife
//
//  Created by Bruce on 15/7/16.
//  Copyright (c) 2015年 Bruce. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ServerCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *iconIv;
@property (weak, nonatomic) IBOutlet UILabel *friendlyNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *ipLabel;

@end
