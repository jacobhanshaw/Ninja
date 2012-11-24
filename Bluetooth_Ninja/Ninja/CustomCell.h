//
//  CustomCell.h
//  Bluetooth API
//
//  Created by Michael on 11/9/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CustomCell : UITableViewCell

@property (nonatomic, weak) IBOutlet UIButton *colorSelector;
@property (nonatomic, weak) IBOutlet UILabel *name;
@property (nonatomic, weak) IBOutlet UILabel *score;
@property (nonatomic, weak) IBOutlet UIImageView *picture;
@end
