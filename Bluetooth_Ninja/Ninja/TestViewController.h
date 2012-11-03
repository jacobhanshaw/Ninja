//
//  TestViewController.h
//  Ninja
//
//  Created by Michael on 11/2/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TestViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    IBOutlet UILabel *screenTitle;
    IBOutlet UITableView *peerTable;
    IBOutlet UIButton *leave, *start;
    
    IBOutlet UIActivityIndicatorView *refreshIndicator;
    IBOutlet UIImageView *refreshIcon;
    
    NSTimer *refreshTimer;
    
    id delegate;
    
    NSArray *tableViewInfo;
    
    BOOL host2;
}

@property (nonatomic) IBOutlet UILabel *screenTitle;
@property (nonatomic) IBOutlet UITableView *peerTable;
@property (nonatomic) IBOutlet UIButton *leave;
@property (nonatomic) IBOutlet UIButton *start;
@property (nonatomic) IBOutlet UIActivityIndicatorView *refreshIndicator;
@property (nonatomic) IBOutlet UIImageView *refreshIcon;

@property (nonatomic) id delegate;

- (void)startViewWith:(BOOL) host;
- (void)updatePeersList:(NSArray *)peersList;

@end
