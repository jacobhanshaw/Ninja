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
        [hostPopOver.layer setCornerRadius:9.0];
        [peerTable.layer setCornerRadius:9.0];
        
        [startView setHidden:NO];
        [semiTransparentOverlay setHidden:YES];
        [clientPopOver setHidden:YES];
        [hostPopOver setHidden:YES];
        
        groupNameInput.delegate = self;
        nameInputHost.delegate = self;
        nameInputClient.delegate = self;
        
        playerNumber = -1;
        
        manualRefreshCounter = -1; //-1 means that the button is ready to be pressed
        
        appIdentifier = [[NSBundle mainBundle] bundleIdentifier];
        
        groupsNotAvailable = [[NSMutableArray alloc] init];
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    [startView setHidden:NO];
    [semiTransparentOverlay setHidden:YES];
    [clientPopOver setHidden:YES];
    [hostPopOver setHidden:YES];
    
    [startGroupButton addTarget:self action:@selector(startGroupSelected:) forControlEvents:UIControlEventTouchUpInside];
    [joinGroupButton addTarget:self action:@selector(joinGroupSelected:) forControlEvents:UIControlEventTouchUpInside];
    [editProfileButton addTarget:self action:@selector(editProfileSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    [hostGo addTarget:self action:@selector(hostGoSelected:) forControlEvents:UIControlEventTouchUpInside];
    [clientGo addTarget:self action:@selector(clientGoSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    [leave addTarget:self action:@selector(leaveSelected:) forControlEvents:UIControlEventTouchUpInside];
    [start addTarget:self action:@selector(startSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reset) name:@"UIApplicationDidEnterBackgroundNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateReceived:) name:@"NewDataReceived" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newPeer:) name:@"NewPeerConnected" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(peerDisconnected:) name:@"PeerDisconnected" object:nil];
    
    [self reset];  //NEWLY ADDED. WILL CAUSE PROBLEMS?
}

-(void) viewDidAppear:(BOOL)animated {
    
    [super viewDidAppear:animated];
    
    if([AppModel sharedAppModel].isFirstUse){
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Turn On Bluetooth" message: @"All games require bluetooth. Please ensure bluetooth is turned on in the settings menu." delegate: self cancelButtonTitle: nil otherButtonTitles: @"Continue", nil];
    
    [alert show];
    }
}

-(void) viewWillDisappear:(BOOL)animated {
    
    [super viewWillDisappear:animated];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) reset {
    
    [[BluetoothServices sharedBluetoothSession] invalidateSession];
    
    [startView setHidden:NO];
    [semiTransparentOverlay setHidden:YES];
    [clientPopOver setHidden:YES];
    [hostPopOver setHidden:YES];
    
    isInGroup = NO;
    playerNumber = -1;
    tableViewInfo = [[NSArray alloc] init];
    [peerTable reloadData];
}

#pragma mark Button Methods

- (IBAction)startGroupSelected:(UIButton *)sender{
    self.isHost = YES;
    isInGroup = NO;
    playerNumber = 0;
    [startView setHidden:YES];
    [self showPopOver:YES];
}

- (IBAction)joinGroupSelected:(UIButton *)sender{
    self.isHost = NO;
    isInGroup = NO;
    [clientGo setTitle:@"Go" forState:UIControlStateHighlighted]; //Set this in case the view was last used for edit profile
    [clientGo setTitle:@"Go" forState:UIControlStateNormal];
  //  if([AppModel sharedAppModel].isFirstUse){
    //    [AppModel sharedAppModel].isFirstUse = NO;
        [self showPopOver:NO];
    // }
    [startView setHidden:YES];
}

- (IBAction)editProfileSelected:(UIButton *)sender{
    [clientGo setTitle:@"Save" forState:UIControlStateHighlighted]; //Change button label to fit profile editing
    [clientGo setTitle:@"Save" forState:UIControlStateNormal];
    [self showPopOver:NO];
}

//IMPORTANT NOTE: DEVICE WILL REMEMBER LAST GROUP NAME IT JOINED AND USE IT FOR NEXT GROUP FORMED

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
    
    [groupNameInput resignFirstResponder];
    [nameInputHost resignFirstResponder];
    
    [self startTimer];
    [self refresh];
}

- (IBAction)clientGoSelected:(UIButton *)sender{
    [clientPopOver setHidden:YES];
    [semiTransparentOverlay setHidden:YES];
    
    NSString *personalName;
    if(!([nameInputClient.text isEqualToString:@""] || nameInputClient.text == nil)) personalName = nameInputClient.text;
    else if (!([[[BluetoothServices sharedBluetoothSession] getPersonalName] isEqualToString:@""] || [[BluetoothServices sharedBluetoothSession] getPersonalName] == nil)) personalName = [[BluetoothServices sharedBluetoothSession] getPersonalName];
    else personalName = [[[[UIDevice currentDevice] name] componentsSeparatedByString:@"’"] objectAtIndex:0];
    
    [nameInputClient resignFirstResponder];
    
    if (startView.hidden) { //If this is false then the person was editing their profile, not starting a game
        [[BluetoothServices sharedBluetoothSession] setUpWithSessionID:appIdentifier displayName:personalName sessionMode:GKSessionModePeer andContext:nil];
        [self startTimer];
        [self refresh];
    }
}

- (IBAction)leaveSelected:(UIButton *)sender{
    if (refreshIndicator.isAnimating) [self abortRefresh];
    
    if(self.isHost){
        int i = REJECTEDFROMSESSION;
        NSData *data = [NSData dataWithBytes: &i length: sizeof(i)];
        [[BluetoothServices sharedBluetoothSession] sendData:data toAll:YES];
    }
    [startView setHidden:NO];
    [hostPopOver setHidden:YES];
    [clientPopOver setHidden:YES];
    [self stopTimer];
    [self reset];  //NEWLY ADDED. WILL CAUSE PROBLEMS?
}

- (IBAction)startSelected:(UIButton *)sender{
    if (refreshIndicator.isAnimating) [self abortRefresh];
    
    [self stopTimer];
    
    [[BluetoothServices sharedBluetoothSession].bluetoothSession setAvailable: NO];
    
    int i = GAMESTARTED;
    NSData *data = [NSData dataWithBytes: &i length: sizeof(i)];
    [[BluetoothServices sharedBluetoothSession] sendData:data toAll:YES];
    //Send out to set session unavailable
    
    //Put your code to start here
    GameViewController *game = [[GameViewController alloc] init];
    game.playerNumber = playerNumber; //if(self.isHost) 
    [self presentViewController:game animated:YES completion:nil];
}

- (IBAction)colorSelectorSelected:(UIButton *)sender {
    //   if(sender.tag == 1) show button select
    [self performSelector:@selector(highlightButton:) withObject:sender afterDelay:0.0];
}

- (void)highlightButton:(UIButton *)button {
    [button setHighlighted:YES];
}

// YES to show host popOver, No to show client popOver
- (void)showPopOver:(BOOL)hostBool
{
    [semiTransparentOverlay setHidden:NO];
    if (hostBool) {
        [hostPopOver setHidden:NO];
        if([[[BluetoothServices sharedBluetoothSession] getPersonalName] isEqualToString:@""] || [[BluetoothServices sharedBluetoothSession] getPersonalName] == nil)
            nameInputHost.placeholder = [[[[UIDevice currentDevice] name] componentsSeparatedByString:@"’"] objectAtIndex:0];
        
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
        if([[[BluetoothServices sharedBluetoothSession] getPersonalName] isEqualToString:@""] || [[BluetoothServices sharedBluetoothSession] getPersonalName] == nil)
            nameInputClient.placeholder = [[[[UIDevice currentDevice] name] componentsSeparatedByString:@"’"] objectAtIndex:0];
        
        else nameInputClient.placeholder = [[BluetoothServices sharedBluetoothSession] getPersonalName];
        [screenTitle setText:@"Groups:"];
        [start setHidden:YES];
    }
}

#pragma mark Timer Methods

- (void)startTimer
{
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(refresh) userInfo:nil repeats:TRUE];
    [self refresh];
}

- (void)stopTimer
{
    [refreshTimer invalidate];
}

#pragma mark TextField Methods

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

#pragma mark Refresh Set-up Methods

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

#pragma mark Table Update Methods

- (void)refresh
{
    
    NSLog(@"Session is available: %d",[BluetoothServices sharedBluetoothSession].bluetoothSession.isAvailable);
    //recommend fetching data from appModel to populate peerData. Can also expand peer data beyond this.
    if(!personalPeerData) personalPeerData = [[PeerData alloc] initWithColor:playerNumber name:[[BluetoothServices sharedBluetoothSession] getPersonalName] peerID:[BluetoothServices sharedBluetoothSession].bluetoothSession.peerID score:0 andIcon:1];

    NSLog(@"Refresh player number: %d", playerNumber);
    
    if(playerNumber != -1) personalPeerData.colorSelection = playerNumber;
    else personalPeerData.colorSelection = RED;
    
    NSMutableArray *peersList = [[NSMutableArray alloc] init];
    if(self.isHost || isInGroup){
        NSArray *connectedPeers = [[BluetoothServices sharedBluetoothSession] getPeersInSession];
        int peerIndex = 0;
        for(int i = 0; i <= [connectedPeers count]; ++i){
            if(i == playerNumber || playerNumber == -1){
                [peersList addObject:personalPeerData];
            }
            else{
            if([[[BluetoothServices sharedBluetoothSession] getPeerData] objectForKey:[connectedPeers objectAtIndex:peerIndex]] != nil)
            [peersList addObject:[[[BluetoothServices sharedBluetoothSession] getPeerData] objectForKey:[connectedPeers objectAtIndex:peerIndex]]];
                
            else{
            NSString *peerDisplayName = [[BluetoothServices sharedBluetoothSession].bluetoothSession displayNameForPeer:[connectedPeers objectAtIndex:peerIndex]];
            unichar newline = '\n'; //separates the personal name from group name, so that the other players can parse and view both
            NSString *newLineCharacterString = [NSString stringWithCharacters:&newline length:1];
            if([peerDisplayName rangeOfString:newLineCharacterString].location != NSNotFound){
                NSString *peerName = [[peerDisplayName componentsSeparatedByString:newLineCharacterString] objectAtIndex:0];
                [peersList addObject:[[PeerData alloc] initWithColor:(i)%8 name: peerName peerID: [connectedPeers objectAtIndex:peerIndex] score:0 andIcon:0]];
            }
            else [peersList addObject:[[PeerData alloc] initWithColor:(i)%8 name: peerDisplayName peerID: [connectedPeers objectAtIndex:peerIndex] score:0 andIcon:0]];
            }
            peerIndex++;
            }
        }
    }
    else{
        NSArray *availablePeers = [[BluetoothServices sharedBluetoothSession] getAvailablePeers];
        for(int i = 0; i < [availablePeers count]; ++i){
            NSString *peerDisplayName = [[BluetoothServices sharedBluetoothSession].bluetoothSession displayNameForPeer:[availablePeers objectAtIndex:i]];
            unichar newline = '\n'; //separates the personal name from group name, so that the other players can parse and view both
            NSString *newLineCharacterString = [NSString stringWithCharacters:&newline length:1];
            if([peerDisplayName rangeOfString:newLineCharacterString].location != NSNotFound){
                NSString *groupName = [[peerDisplayName componentsSeparatedByString:newLineCharacterString] objectAtIndex:1];
                if(![groupsNotAvailable containsObject:groupName]){
                    [peersList addObject:[[PeerData alloc] initWithColor:(i)%8 name: groupName peerID: [availablePeers objectAtIndex:i] score:0 andIcon:0]];
                }
            }
        }
    }
    tableViewInfo = [NSArray arrayWithArray:peersList];
    [peerTable reloadData];
    
}

#pragma mark Bluetooth Notification Methods

- (void) updateReceived:(NSNotification *) sender {
    
    NSData *data = [BluetoothServices sharedBluetoothSession].dataReceived;
    int i;
    [data getBytes: &i length: sizeof(i)];
    NSData *rest = [NSData dataWithBytes:(void*)[data bytes] + sizeof(i) length:data.length - sizeof(i)];
    
    if(i == GAMESTARTED){
        if (refreshIndicator.isAnimating) [self abortRefresh];
        
        [self stopTimer];
        
        [[BluetoothServices sharedBluetoothSession].bluetoothSession setAvailable: NO];
        GameViewController *game = [[GameViewController alloc] init];
        game.playerNumber = playerNumber;
        [self presentViewController:game animated:YES completion:nil];
    }
    
    if(i == REJECTEDFROMSESSION){
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Group Unavailable" message:@"Your request to join that group has been denied or the host has left. Feel free to join another group." delegate:self cancelButtonTitle:@"Ok" otherButtonTitles: nil];
        [alert show];
        
        [groupsNotAvailable addObject:[screenTitle.text substringToIndex:[screenTitle.text length] - 1]];
        
        [screenTitle setText:@"Groups:"];
        
        [[BluetoothServices sharedBluetoothSession].bluetoothSession disconnectFromAllPeers];
        
        isInGroup = NO;
        [self refresh];
    }
    
    if(i == UPDATEPEERDATA){
        PeerData *peerData = [NSKeyedUnarchiver unarchiveObjectWithData:rest];
        [[[BluetoothServices sharedBluetoothSession] getPeerData] setObject:peerData forKey:[[BluetoothServices sharedBluetoothSession] originOfData]];
    }
    
    if(i >= 100){
        i -= 100;
        if(i < playerNumber && i != -1) playerNumber--;
    }
}

- (void) newPeer:(NSNotification *) sender {
    if(playerNumber == -1){
        
        //MOVE INTO GROUP VIEW
        isInGroup = YES;
        NSString *peerDisplayName = [[BluetoothServices sharedBluetoothSession].bluetoothSession displayNameForPeer: host];
        unichar newline = '\n'; //separates the personal name from group name, so that the other players can parse and view both
        NSString *newLineCharacterString = [NSString stringWithCharacters:&newline length:1];
        NSString *groupName = [[peerDisplayName componentsSeparatedByString:newLineCharacterString] objectAtIndex:1];
        [[BluetoothServices sharedBluetoothSession] setGroupName:groupName];
        groupName = [groupName stringByAppendingString:@":"];
        [screenTitle setText:groupName];
        
        
        playerNumber = [[[BluetoothServices sharedBluetoothSession] getPeersInSession] count];
        NSLog(@"New Peer player number: %d", playerNumber);
        [personalPeerData setColorSelection:playerNumber];
        int i = UPDATEPEERDATA;
        NSMutableData *data = [NSMutableData dataWithBytes: &i length: sizeof(i)];
        NSData *peerData = [NSKeyedArchiver archivedDataWithRootObject:personalPeerData];
        [data appendData:peerData];
        [[BluetoothServices sharedBluetoothSession] sendData:data toAll:YES];
    }

    [self refresh];
}

- (void) peerDisconnected:(NSNotification *) sender {
    int i = 100 + playerNumber;
    NSData *data = [NSData dataWithBytes: &i length: sizeof(i)];
    [[BluetoothServices sharedBluetoothSession] sendData:data toAll:YES];
    
    [self refresh];
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
            if(!self.isHost || indexPath.row == 0) ((CustomCell *)returnCell).picture.image = tempRef;
            ((CustomCell *)returnCell).colorSelector.tintColor = tintColor;
            if((self.isHost && indexPath.row == 0) || (!self.isHost && indexPath.row == 1)) ((CustomCell *)returnCell).colorSelector.tag = 1;
            else ((CustomCell *)returnCell).colorSelector.tag = 0;
            [((CustomCell *)returnCell).colorSelector addTarget:self action:@selector(colorSelectorSelected:) forControlEvents:UIControlEventTouchUpInside];
            [self highlightButton:((CustomCell *)returnCell).colorSelector];
            break;
            
        default:
            returnCell.textLabel.text = @"If you're reading this, something has gone horribly wrong";
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
        if(rowOfPeerToRemove != 0){
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Are you sure?" message:@"Are you sure you want to block this peer?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles: @"Yes", nil];
            [alert show];
        }
    }
    else if(!isInGroup){
        //JOIN SESSION
        NSString *peerToConnectWith = ((PeerData *)[tableViewInfo objectAtIndex:indexPath.row]).peerID;
        host = peerToConnectWith;
        [[BluetoothServices sharedBluetoothSession].bluetoothSession connectToPeer:peerToConnectWith withTimeout:5.0];
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
    
    if([title isEqualToString:@"Are you sure?"]) {
        if (buttonIndex == 1) {
            
            NSString *peerToRemove = ((PeerData *)[tableViewInfo objectAtIndex:rowOfPeerToRemove]).peerID;
            
            //Add peer to list of peers not to accept connections from
            NSMutableArray *peersBlocked = [[BluetoothServices sharedBluetoothSession] getPeersBlocked];
            [peersBlocked addObject:peerToRemove];
            [[BluetoothServices sharedBluetoothSession] setPeersBlocked:peersBlocked];
            
            //Notify peer of rejection
            int i = REJECTEDFROMSESSION;
            NSData *data = [NSData dataWithBytes: &i length: sizeof(i)];
            NSString *idOfPeerToRemove = ((PeerData *)[tableViewInfo objectAtIndex:rowOfPeerToRemove]).peerID;
            NSMutableArray *groupToSendRejection = [[NSMutableArray alloc] initWithObjects:idOfPeerToRemove, nil];
            [BluetoothServices sharedBluetoothSession].peersInGroup = groupToSendRejection;
            [[BluetoothServices sharedBluetoothSession] sendData:data toAll:NO];
            
            //Remove from list
            NSMutableArray *tempMutableArray = [NSMutableArray arrayWithArray:tableViewInfo];
            [tempMutableArray removeObjectAtIndex:rowOfPeerToRemove];
            tableViewInfo = [NSArray arrayWithArray:tempMutableArray];
            [peerTable reloadData];
            
            //Disconnect peer from session
            [[BluetoothServices sharedBluetoothSession].bluetoothSession disconnectPeerFromAllPeers:peerToRemove];
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
