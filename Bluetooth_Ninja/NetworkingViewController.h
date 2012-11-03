//
//  NetworkingViewController.h
//  Ninja
//
//  Created by Jacob Hanshaw on 10/26/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NetworkingViewController : UIViewController {
    IBOutlet UILabel *title;
    IBOutlet UIActivityIndicatorView *refreshIndicator;
    IBOutlet UIButton *refresh, *leave, *start;
    IBOutlet UITableView *peers;
}

@end
