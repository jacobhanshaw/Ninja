//
//  NetworkingViewController.h
//  Ninja
//
//  Created by Jacob Hanshaw on 10/26/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NetworkingViewController : UIViewController {
    IBOutlet UILabel *label;

    IBOutlet UIButton *leave, *start;
    IBOutlet UITableView *peers;
    
    IBOutlet UIActivityIndicatorView *refreshIndicator;
    IBOutlet UIImageView *refreshIcon;
}

@property (nonatomic) IBOutlet UILabel *label;
@property (nonatomic) IBOutlet UIButton *leave;
@property (nonatomic) IBOutlet UIButton *start;
@property (nonatomic) IBOutlet UITableView *peers;
@property (nonatomic) IBOutlet UIActivityIndicatorView *refreshIndicator;
@property (nonatomic) IBOutlet UIImageView *refreshIcon;

@end
