//
//  NetworkingViewController.h
//  Ninja
//
//  Created by Michael on 11/2/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "BluetoothServices.h"
#import "AppModel.h"     //REMOVE
#import "CustomCell.h"
#import "PeerData.h"
#import "ColorSelector.h"

#define MAX_LENGTH 16

enum dataMessages {
    //COLORSAVAILABLEUPDATED,
    GAMESTARTED
}dataMessages;

@interface NetworkingViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate>
{
    //Start View Outlets
    IBOutlet UIView      *startView;
    IBOutlet UIButton    *startGroupButton;
    IBOutlet UIButton    *joinGroupButton;
    IBOutlet UIButton    *editProfileButton;
    //End Start View Outlets
    
    //Pop Over Outlets
    IBOutlet UIView      *semiTransparentOverlay;  //obscure's background to draw focus to pop over
    IBOutlet UIView      *hostPopOver;             //views allowing users to specify personal and group names
    IBOutlet UIView      *clientPopOver;
    IBOutlet UILabel     *groupNameLabel;
    IBOutlet UITextField *groupNameInput;
    IBOutlet UILabel     *nameLabelHost;
    IBOutlet UITextField *nameInputHost;
    IBOutlet UILabel     *nameLabelClient;
    IBOutlet UITextField *nameInputClient;
    IBOutlet UIButton    *hostGo;                 //proceed after popover
    IBOutlet UIButton    *clientGo;
    //End Pop Over Outlets
    
    //Peer table view Outlets
    IBOutlet UILabel *screenTitle;                //title above table
    IBOutlet UITableView *peerTable;
    IBOutlet UIButton *leave, *start;
    
    IBOutlet UIActivityIndicatorView *refreshIndicator;
    IBOutlet UIButton *refreshIcon;
    int manualRefreshCounter; //Tracks how many times we've refreshed due to a manual refresh, used to stop the activity indicator and reset the refresh button
    //End peer table view outlets
    
    NSTimer *refreshTimer;                        //timer to automatically refresh after a certain number of time
    id delegate;
    NSArray *tableViewInfo;
    NSString *appIdentifier;                      //bundle identifier, used as sessionID, unique to each app
    BOOL isInGroup;                               //used only for peers other than the host, indicates if the peer has joined a group
    BOOL isHost;
    int  rowOfPeerToRemove;                       //if host decides to remove a peer, save the row in this variable
    PeerData *personalPeerData;                   //variable used to hold cell data for this user
    NSMutableArray *colorsAvailable;              //colors available
}

//Start View Outlets
@property (nonatomic) IBOutlet UIView      *startView;
@property (nonatomic) IBOutlet UIButton    *startGroupButton;
@property (nonatomic) IBOutlet UIButton    *joinGroupButton;
@property (nonatomic) IBOutlet UIButton    *editProfileButton;
//End Start View Outlets

//Pop Over Outlets
@property (nonatomic) IBOutlet UIView      *semiTransparentOverlay;
@property (nonatomic) IBOutlet UIView      *hostPopOver;
@property (nonatomic) IBOutlet UIView      *clientPopOver;
@property (nonatomic) IBOutlet UILabel     *groupNameLabel;
@property (nonatomic) IBOutlet UITextField *groupNameInput;
@property (nonatomic) IBOutlet UILabel     *nameLabelHost;
@property (nonatomic) IBOutlet UITextField *nameInputHost;
@property (nonatomic) IBOutlet UILabel     *nameLabelClient;
@property (nonatomic) IBOutlet UITextField *nameInputClient;
@property (nonatomic) IBOutlet UIButton    *hostGo;
@property (nonatomic) IBOutlet UIButton    *clientGo;
//End Pop Over Outlets

//Peer table view Outlets
@property (nonatomic) IBOutlet UILabel *screenTitle;
@property (nonatomic) IBOutlet UITableView *peerTable;
@property (nonatomic) IBOutlet UIButton *leave;
@property (nonatomic) IBOutlet UIButton *start;
@property (nonatomic) IBOutlet UIActivityIndicatorView *refreshIndicator;
@property (nonatomic) IBOutlet UIButton *refreshIcon;
//End peer table view outlets

@property (nonatomic) id delegate;
@property (readwrite) BOOL isHost;

- (void)showPopOver:(BOOL) host;              //YES for hostPopOver, NO for clientPopOver
- (void)updatePeersList:(NSArray *)peersList; //update the table to be the provided list
- (void)startTimer;
- (IBAction)refreshRequest:(id)sender;
- (void)abortRefresh;                         //Called if manual refresh needs to stop -- go back to main menu, game started, etc

@end
