//
//  NetworkViewController.h
//  Ninja
//
//  Created by Michael on 11/2/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NetworkViewController : UIViewController
{
IBOutlet UILabel *label;

IBOutlet UIButton *leave, *start;
IBOutlet UITableView *peers;

IBOutlet UIActivityIndicatorView *refreshIndicator;
IBOutlet UIImageView *refreshIcon;

IBOutlet UIView *view;
}

@property (nonatomic) IBOutlet UILabel *label;
@property (nonatomic) IBOutlet UIButton *leave;
@property (nonatomic) IBOutlet UIButton *start;
@property (nonatomic) IBOutlet UITableView *peers;
@property (nonatomic) IBOutlet UIActivityIndicatorView *refreshIndicator;
@property (nonatomic) IBOutlet UIImageView *refreshIcon;
@property (nonatomic) IBOutlet UIView *view;

- (void)setValue:(id)value forKey:(NSString *)key;

@end

