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
@synthesize clientGo, screenTitle, peerTable, leave, start, refreshIcon, refreshIndicator; //Peer table view
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
        
        appIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        
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
    [start addTarget:self action:@selector(startSelected:) forControlEvents:UIControlEventTouchUpInside];
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
    
    NSString *personalName;
    if(!([nameInputHost.text isEqualToString:@""] || nameInputHost.text == nil)) personalName = nameInputHost.text;
    else if (!([[[BluetoothServices sharedBluetoothSession] getPersonalName] isEqualToString:@""] || [[BluetoothServices sharedBluetoothSession] getPersonalName] == nil)) personalName = [[BluetoothServices sharedBluetoothSession] getPersonalName];
    else personalName = [[[[UIDevice currentDevice] name] componentsSeparatedByString:@"’"] objectAtIndex:0];
    
    unichar newline = '\n'; //separates the personal name from group name, so that the other players can parse and view both
    personalName = [personalName stringByAppendingString:[NSString stringWithCharacters:&newline length:1]];
    
    if(!([groupNameInput.text isEqualToString:@""] || groupNameInput.text == nil))
        [BluetoothServices sharedBluetoothSession].groupName = groupNameInput.text;
    else [BluetoothServices sharedBluetoothSession].groupName = [[UIDevice currentDevice] name];
    
    personalName = [personalName stringByAppendingString:[BluetoothServices sharedBluetoothSession].groupName];
    
    [[BluetoothServices sharedBluetoothSession] setUpWithSessionID:appIdentifier displayName:[BluetoothServices sharedBluetoothSession].groupName sessionMode:GKSessionModePeer andContext:nil];
    [self startTimer];
}

- (void)clientGoSelected:(id)sender{
    [clientPopOver setHidden:YES];
    [semiTransparentOverlay setHidden:YES];
    
    NSString *personalName;
    if(!([nameInputClient.text isEqualToString:@""] || nameInputClient.text == nil)) personalName = nameInputClient.text;
    else if (!([[[BluetoothServices sharedBluetoothSession] getPersonalName] isEqualToString:@""] || [[BluetoothServices sharedBluetoothSession] getPersonalName] == nil)) personalName = [[BluetoothServices sharedBluetoothSession] getPersonalName];
    else personalName = [[[[UIDevice currentDevice] name] componentsSeparatedByString:@"’"] objectAtIndex:0];;
    
    if (startView.hidden == TRUE) { //If this is true then the person was editing their profile, not starting a game
        [[BluetoothServices sharedBluetoothSession] setUpWithSessionID:appIdentifier displayName:personalName sessionMode:GKSessionModePeer andContext:nil];
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

- (void)startSelected:(id)sender{
    if (refreshIndicator.isAnimating) {
        [self abortRefresh];
    }
    [self stopTimer];
    
    //Put your code to start here
}

- (void)showPopOver:(BOOL)host
{
    [semiTransparentOverlay setHidden:NO];
    if (host) {
        [hostPopOver setHidden:NO];
        if([[[BluetoothServices sharedBluetoothSession] getPersonalName] isEqualToString:@""] || [[BluetoothServices sharedBluetoothSession] getPersonalName] == nil){
            nameInputHost.placeholder = [[[[UIDevice currentDevice] name] componentsSeparatedByString:@"’"] objectAtIndex:0];
        }
        else nameInputHost.placeholder = [[BluetoothServices sharedBluetoothSession] getPersonalName];
        if([[BluetoothServices sharedBluetoothSession].groupName isEqualToString:@""] || [BluetoothServices sharedBluetoothSession].groupName == nil){
            groupNameInput.placeholder = [[UIDevice currentDevice] name];
        }
        else groupNameInput.placeholder = [BluetoothServices sharedBluetoothSession].groupName;
        [screenTitle setText:@"Members:"];
        [start setHidden:NO];
    }
    else {
        [clientPopOver setHidden:NO];
        if([[[BluetoothServices sharedBluetoothSession] getPersonalName] isEqualToString:@""] || [[BluetoothServices sharedBluetoothSession] getPersonalName] == nil){
            nameInputClient.placeholder = [[[[UIDevice currentDevice] name] componentsSeparatedByString:@"’"] objectAtIndex:0];
        }
        else nameInputClient.placeholder = [[BluetoothServices sharedBluetoothSession] getPersonalName];
        [screenTitle setText:@"Groups:"];
        [start setHidden:YES];
    }
}

#pragma mark timer methods

- (void)startTimer
{
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(refresh) userInfo:nil repeats:TRUE];
    [self refresh];
}

- (void)stopTimer
{
    [refreshTimer invalidate];
}

#pragma mark textField methods

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField.text.length >= MAX_LENGTH && range.length == 0) return NO; // return NO to not change text
    else return YES;
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
    
    UIColor *tintColor;
    float hue;
    switch (((CellData *)tableViewInfo[indexPath.row]).colorSelection) {
        case 0:
            hue = 0;
            break;
        case 1:
            hue = 38;
            break;
        case 2:
            hue = 60;
            break;
        case 3:
            hue = 105;
            break;
        case 4:
            hue = 175;
            break;
        case 5:
            hue = 224;
            break;
        case 6:
            hue = 275;
            break;
        case 7:
            hue = 320;
            break;
        default:
            hue = 0;
            break;
    }
    tintColor = [UIColor colorWithHue:hue / 360 saturation:1.0 brightness:1 alpha:1];
        
    UIImage *tempRef;
    switch (((CellData *)tableViewInfo[indexPath.row]).iconLevel) {
        case 0:
            tempRef = [UIImage imageNamed:@"star0.jpg"];
            break;
            
        case 1:
            tempRef = [UIImage imageNamed:@"star1.jpg"];
            break;
            
        case 2:
            tempRef = [UIImage imageNamed:@"star2"];
            break;
            
        default:
            break;
    }
    
    switch (indexPath.section) {
        case 0:
            ((CustomCell *)returnCell).name.text = ((CellData *)tableViewInfo[indexPath.row]).name;
            ((CustomCell *)returnCell).score.text = [NSString stringWithFormat:@"%i", ((CellData *)tableViewInfo[indexPath.row]).score];
            ((CustomCell *)returnCell).picture.image = tempRef;
            ((CustomCell *)returnCell).colorSelector.tintColor = tintColor;
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

//Makes keyboard disappear on touch outside of keyboard or textfield, only used when an input view thingy is visible
- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (!hostPopOver.isHidden) {
        [groupNameInput resignFirstResponder];
        [nameInputHost resignFirstResponder];
    }
    else if(!clientPopOver.isHidden)
        [nameLabelClient resignFirstResponder];
    
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
