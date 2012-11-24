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
@synthesize delegate, isHost;

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

#pragma mark refresh set-up methods

- (IBAction)refreshRequest:(id)sender
{
    if (manualRefreshCounter == -1) {
        [refreshTimer invalidate];
        refreshTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:self selector:@selector(refreshRequest:) userInfo:nil repeats:YES];
        [refreshIcon setHidden:YES];
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
        [refreshIcon setHidden:NO];
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

- (IBAction)startGroupSelected:(UIButton *)sender{
    self.isHost = YES;
    isInGroup = NO;
    [startView setHidden:YES];
    [self showPopOver:YES];
}

- (IBAction)joinGroupSelected:(UIButton *)sender{
    self.isHost = NO;
    isInGroup = NO;
    [clientGo setTitle:@"Go" forState:UIControlStateHighlighted]; //Set this in case the view was last used for edit profile
    [clientGo setTitle:@"Go" forState:UIControlStateNormal];
    if([AppModel sharedAppModel].isFirstUse){
        [AppModel sharedAppModel].isFirstUse = NO;
        [self showPopOver:NO];
    }
    [startView setHidden:YES];
}

- (IBAction)editProfileSelected:(UIButton *)sender{
    [clientGo setTitle:@"Save" forState:UIControlStateHighlighted]; //Change button label to fit profile editing
    [clientGo setTitle:@"Save" forState:UIControlStateNormal];
    [self showPopOver:NO];
}

- (IBAction)hostGoSelected:(UIButton *)sender{
    [hostPopOver setHidden:YES];
    [semiTransparentOverlay setHidden:YES];
    
    NSString *displayName;
    if(!([nameInputHost.text isEqualToString:@""] || nameInputHost.text == nil)) [[BluetoothServices sharedBluetoothSession] setPersonalName: nameInputHost.text];
    else if (([[[BluetoothServices sharedBluetoothSession] getPersonalName] isEqualToString:@""] || [[BluetoothServices sharedBluetoothSession] getPersonalName] == nil))
        [[BluetoothServices sharedBluetoothSession] setPersonalName: [[[[UIDevice currentDevice] name] componentsSeparatedByString:@"’"] objectAtIndex:0]];
    
    displayName = [[BluetoothServices sharedBluetoothSession] getPersonalName];
    
    unichar newline = '\n'; //separates the personal name from group name, so that the other players can parse and view both
    displayName = [displayName stringByAppendingString:[NSString stringWithCharacters:&newline length:1]];
    
    if(!([groupNameInput.text isEqualToString:@""] || groupNameInput.text == nil))
        [[BluetoothServices sharedBluetoothSession] setGroupName: groupNameInput.text];
    else if (([[[BluetoothServices sharedBluetoothSession] getGroupName] isEqualToString:@""] || [[BluetoothServices sharedBluetoothSession] getGroupName] == nil))
        [[BluetoothServices sharedBluetoothSession] setGroupName:[[UIDevice currentDevice] name]];

    [[BluetoothServices sharedBluetoothSession] setGroupName: [[[BluetoothServices sharedBluetoothSession] getGroupName] stringByReplacingOccurrencesOfString:@"iPhone" withString:@"Group"]];
    
    displayName = [displayName stringByAppendingString:[[BluetoothServices sharedBluetoothSession] getGroupName]];
    
    [[BluetoothServices sharedBluetoothSession] setUpWithSessionID:appIdentifier displayName:displayName sessionMode:GKSessionModePeer andContext:nil];
    [self startTimer];
}

- (IBAction)clientGoSelected:(UIButton *)sender{
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

- (IBAction)leaveSelected:(UIButton *)sender{
    if (refreshIndicator.isAnimating) {
        [self abortRefresh];
    }
    [startView setHidden:NO];
    [hostPopOver setHidden:YES];
    [clientPopOver setHidden:YES];
    [self stopTimer];
}

- (IBAction)startSelected:(UIButton *)sender{
    if (refreshIndicator.isAnimating) {
        [self abortRefresh];
    }
    [self stopTimer];
    
    //Put your code to start here
}

- (IBAction)colorSelectorSelector:(UIButton *)sender {
 //   if(sender.tag == 1) show button select
    [self performSelector:@selector(highlightButton:) withObject:sender afterDelay:0.0];
}

- (void)highlightButton:(UIButton *)button {
    [button setHighlighted:YES];
}

// YES to show host popOver, No to show client popOver
- (void)showPopOver:(BOOL)host
{
    [semiTransparentOverlay setHidden:NO];
    if (host) {
        [hostPopOver setHidden:NO];
        if([[[BluetoothServices sharedBluetoothSession] getPersonalName] isEqualToString:@""] || [[BluetoothServices sharedBluetoothSession] getPersonalName] == nil){
            nameInputHost.placeholder = [[[[UIDevice currentDevice] name] componentsSeparatedByString:@"’"] objectAtIndex:0];
        }
        else nameInputHost.placeholder = [[BluetoothServices sharedBluetoothSession] getPersonalName];
        if([[[BluetoothServices sharedBluetoothSession] getGroupName] isEqualToString:@""] || [[BluetoothServices sharedBluetoothSession] getGroupName] == nil){
            groupNameInput.placeholder = [[UIDevice currentDevice] name];
            groupNameInput.placeholder = [groupNameInput.placeholder stringByReplacingOccurrencesOfString:@"iPhone" withString:@"Group"];
        }
        else groupNameInput.placeholder = [[BluetoothServices sharedBluetoothSession] getGroupName];
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

#pragma mark Table Update Methods

- (void)refresh
{
    //[delegate refreshLobby];
    if(!personalPeerData) personalPeerData = [[PeerData alloc] initWithColor:0 name:[[BluetoothServices sharedBluetoothSession] getPersonalName] peerID:[BluetoothServices sharedBluetoothSession].bluetoothSession.peerID score:0 andIcon:1];
    NSMutableArray *peersList = [[NSMutableArray alloc] init];
    if(self.isHost || isInGroup){
        [peersList addObject:personalPeerData];
        NSArray *connectedPeers = [[BluetoothServices sharedBluetoothSession] getPeersInSession];
        for(int i = 0; i < [connectedPeers count]; ++i){
            NSString *peerDisplayName = [[BluetoothServices sharedBluetoothSession].bluetoothSession displayNameForPeer:[connectedPeers objectAtIndex:i]];
            [peersList addObject:[[PeerData alloc] initWithColor:i+1 name: peerDisplayName peerID: [connectedPeers objectAtIndex:i] score:0 andIcon:0]];
        }
    }
    else{
        NSArray *availablePeers = [[BluetoothServices sharedBluetoothSession] getAvailablePeers];
        for(int i = 0; i < [availablePeers count]; ++i){
            NSLog(@"%@", [availablePeers objectAtIndex:i]);
            NSString *peerDisplayName = [[BluetoothServices sharedBluetoothSession].bluetoothSession displayNameForPeer:[availablePeers objectAtIndex:i]];
            NSLog(@"%@", peerDisplayName);
            unichar newline = '\n'; //separates the personal name from group name, so that the other players can parse and view both
            NSString *newLineCharacterString = [NSString stringWithCharacters:&newline length:1];
            if([peerDisplayName rangeOfString:newLineCharacterString].location != NSNotFound){
                NSString *groupName = [[peerDisplayName componentsSeparatedByString:newLineCharacterString] objectAtIndex:1];
                [peersList addObject:[[PeerData alloc] initWithColor:i+1 name: groupName peerID: [availablePeers objectAtIndex:i] score:0 andIcon:0]];
            }
        }
    }
    [self updatePeersList:peersList]; 
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

#pragma mark TableView Delegate Methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    UITableViewCell *returnCell;
    if ((returnCell = [peerTable dequeueReusableCellWithIdentifier:@"group"]) == NULL) {
        [peerTable registerNib:[UINib nibWithNibName:@"CustomCell" bundle:nil] forCellReuseIdentifier:@"group"];
        returnCell = [peerTable dequeueReusableCellWithIdentifier:@"group"];
    }
    
    UIColor *tintColor;
    float hue;
    switch (((PeerData *)tableViewInfo[indexPath.row]).colorSelection) {
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
    switch (((PeerData *)tableViewInfo[indexPath.row]).iconLevel) {
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
            ((CustomCell *)returnCell).name.text = ((PeerData *)tableViewInfo[indexPath.row]).name;
            ((CustomCell *)returnCell).score.text = [NSString stringWithFormat:@"%i", ((PeerData *)tableViewInfo[indexPath.row]).score];
            if(!self.isHost) ((CustomCell *)returnCell).picture.image = tempRef;
            ((CustomCell *)returnCell).colorSelector.tintColor = tintColor;
            if((self.isHost && indexPath.row == 0) || (!self.isHost && indexPath.row == 1)) ((CustomCell *)returnCell).colorSelector.tag = 1;
            else ((CustomCell *)returnCell).colorSelector.tag = 0;
            [((CustomCell *)returnCell).colorSelector addTarget:self action:@selector(colorSelectorSelector:) forControlEvents:UIControlEventTouchUpInside];
            [self highlightButton:((CustomCell *)returnCell).colorSelector];
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(self.isHost){
        
        rowOfPeerToRemove = indexPath.row;
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"Are you sure you want to block this peer?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Yes", nil];
        [alert show];
        
    }
    else if(!isInGroup){
        //JOIN SESSION
        //MAY NEED TO DO SOMETHING SPECIAL HERE AS THE HOST PEERID IS DIFFERENT
        NSString *peerToConnectWith = ((PeerData *)[tableViewInfo objectAtIndex:indexPath.row]).peerID;
        [[BluetoothServices sharedBluetoothSession].bluetoothSession connectToPeer:peerToConnectWith withTimeout:5.0];
        
        //MOVE INTO GROUP VIEW
        isInGroup = YES;
        NSString *peerDisplayName = [[BluetoothServices sharedBluetoothSession].bluetoothSession displayNameForPeer: peerToConnectWith];
        unichar newline = '\n'; //separates the personal name from group name, so that the other players can parse and view both
        NSString *newLineCharacterString = [NSString stringWithCharacters:&newline length:1];
        NSString *groupName = [[peerDisplayName componentsSeparatedByString:newLineCharacterString] objectAtIndex:1];
        [[BluetoothServices sharedBluetoothSession] setGroupName:groupName];
        groupName = [groupName stringByAppendingString:@":"];
        [screenTitle setText:groupName];
        [self refresh];
    }
}

// Apple's Method of Removing Rows
/*
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    return self.isHost;
}
*/

// Alertview to confirm removal of peer
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *title = [alertView title];
    NSLog(@"%@", title);
    
    if([title isEqualToString:@"Are you sure?"]) {
        if (buttonIndex == 1) {
            NSLog(@"user pressed Yes");
            NSMutableArray *tempMutableArray = [NSMutableArray arrayWithArray:tableViewInfo];
            NSString *peerToRemove = ((PeerData *)[tempMutableArray objectAtIndex:rowOfPeerToRemove]).peerID;
            [tempMutableArray removeObjectAtIndex:rowOfPeerToRemove];
            tableViewInfo = [NSArray arrayWithArray:tempMutableArray];
            [peerTable reloadData];
            
            //DISCONNECT FROM SESSION
            NSMutableArray *peersBlocked = [[BluetoothServices sharedBluetoothSession] getPeersBlocked];
            [peersBlocked addObject:peerToRemove];
            [[BluetoothServices sharedBluetoothSession] setPeersBlocked:peersBlocked];
            [[BluetoothServices sharedBluetoothSession].bluetoothSession disconnectPeerFromAllPeers:peerToRemove];
        }
        else {
            NSLog(@"user pressed Cancel");
        }
    }
}


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
