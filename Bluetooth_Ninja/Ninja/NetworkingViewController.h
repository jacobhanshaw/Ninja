//
//  NetworkingViewController.h
//  Ninja
//
//  Created by Michael on 11/2/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface NetworkingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    //Pop Over Outlets
    IBOutlet UILabel     *groupNameLabel;
    IBOutlet UITextField *groupNameInput;
    IBOutlet UILabel     *nameLabel;
    IBOutlet UITextField *nameInput;
    IBOutlet UIButton    *startGroup;
    //End Pop Over Outlets
    
    //Peer table view Outlets
    IBOutlet UILabel *screenTitle;
    IBOutlet UITableView *peerTable;
    IBOutlet UIButton *leave, *start;
    
    IBOutlet UIActivityIndicatorView *refreshIndicator;
    IBOutlet UIImageView *refreshIcon;
    //End peer table view outlets
    
    NSTimer *refreshTimer;
    id delegate;
    NSArray *tableViewInfo;
}

//Pop Over Outlets
@property (nonatomic) IBOutlet UILabel     *groupNameLabel;
@property (nonatomic) IBOutlet UITextField *groupNameInput;
@property (nonatomic) IBOutlet UILabel     *nameLabel;
@property (nonatomic) IBOutlet UITextField *nameInput;
@property (nonatomic) IBOutlet UIButton    *startGroup;
//End Pop Over Outlets

//Peer table view Outlets
@property (nonatomic) IBOutlet UILabel *screenTitle;
@property (nonatomic) IBOutlet UITableView *peerTable;
@property (nonatomic) IBOutlet UIButton *leave;
@property (nonatomic) IBOutlet UIButton *start;
@property (nonatomic) IBOutlet UIActivityIndicatorView *refreshIndicator;
@property (nonatomic) IBOutlet UIImageView *refreshIcon;
//End peer table view outlets


@property (nonatomic) id delegate;

- (void)startViewWith:(BOOL) host;
- (void)updatePeersList:(NSArray *)peersList;

@end
