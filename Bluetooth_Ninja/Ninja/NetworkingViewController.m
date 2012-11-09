//
//  NetworkingViewController.m
//  Ninja
//
//  Created by Michael on 11/2/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import "NetworkingViewController.h"

@interface NetworkingViewController ()

@end

@implementation NetworkingViewController

@synthesize startView, startGroupButton, joinGroupButton, editProfileButton;
@synthesize semiTransparentOverlay, hostPopOver, clientPopOver;
@synthesize groupNameInput, groupNameLabel, nameInputHost, nameLabelHost, nameInputClient, nameLabelClient, hostGo;
@synthesize clientGo, screenTitle, peerTable, leave, start, refreshIcon, refreshIndicator, customCell; //Peer table view
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        [self.view addSubview:startView];
        [self.view addSubview:semiTransparentOverlay];
        [self.view addSubview:clientPopOver];
        [self.view addSubview:hostPopOver];
        
        [clientPopOver.layer setCornerRadius:9.0];
        [hostPopOver.layer setCornerRadius: 9.0];
        
        [startView setHidden:NO];
        [semiTransparentOverlay setHidden:YES];
        [clientPopOver setHidden:YES];
        [hostPopOver setHidden:YES];
        
        groupNameInput.delegate = self;
        nameInputHost.delegate = self;
        nameInputClient.delegate = self;
        
        peerTable.layer.cornerRadius = 9.0;
        manualRefreshCounter = -1; //-1 means that the button is ready to be pressed
        
    }
    return self;
}

- (IBAction)refreshRequest:(id)sender
{
    if (manualRefreshCounter == -1) {
        [refreshTimer invalidate];
        refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(refreshRequest:) userInfo:nil repeats:TRUE];
        [refreshIcon setHidden:TRUE];
        [refreshIndicator startAnimating];
    }
    if (manualRefreshCounter < 2) {
        [self refresh];
        ++manualRefreshCounter;
    }
    else {
        [refreshTimer invalidate];
        manualRefreshCounter = -1;
        [self startTimer];
        [refreshIndicator stopAnimating];
        [refreshIcon setHidden:FALSE];
    }
}

- (void)abortRefresh
{
    [refreshTimer invalidate];
    manualRefreshCounter = -1;
    [refreshIndicator stopAnimating];
    [refreshIcon setHidden:FALSE];
}

-(void) viewWillAppear:(BOOL)animated {
    [startView setHidden:NO];
    
    [startGroupButton addTarget:self action:@selector(startGroupSelected:) forControlEvents:UIControlEventTouchUpInside];
    [joinGroupButton addTarget:self action:@selector(joinGroupSelected:) forControlEvents:UIControlEventTouchUpInside];
    [editProfileButton addTarget:self action:@selector(editProfileSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    [hostGo addTarget:self action:@selector(hostGoSelected:) forControlEvents:UIControlEventTouchUpInside];
    [clientGo addTarget:self action:@selector(clientGoSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    [leave addTarget:self action:@selector(leaveSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    //   [leave setTitle:@"Main Menu" forState:UIControlStateNormal];
    //   [start setTitle:@"Start" forState:UIControlStateNormal];
}

#pragma mark Button Methods

- (void)startGroupSelected:(id)sender{
    [startView setHidden:YES];
    [self showPopOver:YES];
}

- (void)joinGroupSelected:(id)sender{
    [clientGo setTitle:@"Go" forState:UIControlStateHighlighted]; //Set this in case the view was last used for edit profile
    [clientGo setTitle:@"Go" forState:UIControlStateNormal];
    if([AppModel sharedAppModel].isFirstUse){
        [AppModel sharedAppModel].isFirstUse = NO;
    [self showPopOver:NO];
}
    [startView setHidden:YES];
}

- (void)editProfileSelected:(id)sender{
    [clientGo setTitle:@"Save" forState:UIControlStateHighlighted]; //Change button label to fit profile editing
    [clientGo setTitle:@"Save" forState:UIControlStateNormal];
    [self showPopOver:NO];
}

- (void)hostGoSelected:(id)sender{
    [hostPopOver setHidden:YES];
    [semiTransparentOverlay setHidden:YES];
    if(!([nameInputHost.text isEqualToString:@""] || nameInputHost.text == nil)) [BluetoothServices sharedBluetoothSession].personalName = nameInputHost.text;
    else [BluetoothServices sharedBluetoothSession].personalName = [[UIDevice currentDevice] name];
    if(!([groupNameInput.text isEqualToString:@""] || groupNameInput.text == nil)) [BluetoothServices sharedBluetoothSession].groupName = groupNameInput.text;
    else [BluetoothServices sharedBluetoothSession].groupName= [[UIDevice currentDevice] name];
    [[BluetoothServices sharedBluetoothSession] setUpWithSessionID:definedSessionID displayName:[BluetoothServices sharedBluetoothSession].groupName sessionMode:GKSessionModePeer andContext:nil];
    [self startTimer];
}

- (void)clientGoSelected:(id)sender{
    [clientPopOver setHidden:YES];
    [semiTransparentOverlay setHidden:YES];
    if(!([nameInputClient.text isEqualToString:@""] || nameInputClient.text == nil)) [BluetoothServices sharedBluetoothSession].personalName = nameInputClient.text;
    else [BluetoothServices sharedBluetoothSession].personalName = [[UIDevice currentDevice] name];
    
    if (startView.hidden == TRUE) { //If this is true then the person was editing their profile, not starting a game
        [[BluetoothServices sharedBluetoothSession] setUpWithSessionID:definedSessionID displayName:[BluetoothServices sharedBluetoothSession].personalName sessionMode:GKSessionModePeer andContext:nil];
        [self startTimer];
    }
}

- (void)leaveSelected:(id)sender{
    if (refreshIndicator.isAnimating) {
        [self abortRefresh];
    }
    [startView setHidden:NO];
    [hostPopOver setHidden:YES];
    [clientPopOver setHidden:YES];
    [self stopTimer];
}

- (void)showPopOver:(BOOL)host
{
    [semiTransparentOverlay setHidden:NO];
    if (host) {
        [hostPopOver setHidden:NO];
        if([[BluetoothServices sharedBluetoothSession].personalName isEqualToString:@""] || [BluetoothServices sharedBluetoothSession].personalName == nil){
            nameInputHost.placeholder = [[UIDevice currentDevice] name];
        }
        else nameInputHost.placeholder =[BluetoothServices sharedBluetoothSession].personalName;
        if([[BluetoothServices sharedBluetoothSession].groupName isEqualToString:@""] || [BluetoothServices sharedBluetoothSession].groupName == nil){
            groupNameInput.placeholder = [[[[UIDevice currentDevice] name] componentsSeparatedByString:@"'"] objectAtIndex:0];
        }
        else groupNameInput.placeholder = [BluetoothServices sharedBluetoothSession].groupName;
        [screenTitle setText:@"Members:"];
        [start setHidden:NO];
    }
    else {
        [clientPopOver setHidden:NO];
        if([[BluetoothServices sharedBluetoothSession].personalName isEqualToString:@""] || [BluetoothServices sharedBluetoothSession].personalName == nil){
            nameInputClient.placeholder = [[UIDevice currentDevice] name];
        }
        else nameInputClient.placeholder = [BluetoothServices sharedBluetoothSession].personalName;
        [screenTitle setText:@"Groups:"];
        [start setHidden:YES];
    }
}

- (void)startTimer
{
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(refresh) userInfo:nil repeats:TRUE];
    [self refresh];
}

- (void)stopTimer
{
    [refreshTimer invalidate];
}


- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [textField resignFirstResponder];
    return YES;
}

- (void)refresh
{
    [delegate refreshLobby];
}

- (void)updatePeersList:(NSArray *)peersList
{
    if (![tableViewInfo isEqualToArray:peersList]) {
        NSMutableArray *deletePaths = [[NSMutableArray alloc] init];
        NSMutableArray *insertPaths = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < [tableViewInfo count]; i++) {
            if (![peersList containsObject:[tableViewInfo objectAtIndex:i]]) {
                [deletePaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
        }
        
        for (int i = 0; i < [peersList count]; i++) {
            if (![tableViewInfo containsObject:[peersList objectAtIndex:i]]) {
                [insertPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
        }
        
        tableViewInfo = [NSArray arrayWithArray:peersList];
        
        [peerTable beginUpdates];
        [peerTable deleteRowsAtIndexPaths:deletePaths withRowAnimation:UITableViewRowAnimationFade];
        [peerTable insertRowsAtIndexPaths:insertPaths withRowAnimation:UITableViewRowAnimationFade];
        [peerTable endUpdates];
    }
    
}

//TableView delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *returnCell;
    if ((returnCell = [peerTable dequeueReusableCellWithIdentifier:@"group"]) == NULL) {
        [peerTable registerNib:[UINib nibWithNibName:@"CustomCell" bundle:nil] forCellReuseIdentifier:@"group"];
        returnCell = [peerTable dequeueReusableCellWithIdentifier:@"group"];
    }
    
    switch (indexPath.section) {
        case 0:
            ((CustomCell *)returnCell).name.text = tableViewInfo[indexPath.row];
            break;
            
        default:
            returnCell.textLabel.text = @"if you're reading this, something has gone horribly wrong";
            break;
    }
    
    return returnCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [tableViewInfo count];
            break;
            
        default:
            return 0;
            break;
    }
}



//End table view delegate

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
