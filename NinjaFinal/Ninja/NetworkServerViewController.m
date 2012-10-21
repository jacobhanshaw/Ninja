//
//  NetworkServerViewController.m
//  Ninja
//
//  Created by Transition on 10/20/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import "NetworkServerViewController.h"

@interface NetworkServerViewController ()


@end

@implementation NetworkServerViewController

- (id)init
{
    self = [super init];
    if (self) {
       
        // Custom initialization
        members = 0;
        membersInGame = [[UILabel alloc] initWithFrame:CGRectMake(50, 50, 20, 20)];
        [membersInGame setText:@"--"];
        myMode = GKSessionModeServer;
        peersInGroup = [[NSMutableArray alloc] initWithCapacity:MAX_PLAYERS];
        thisSession = [[GKSession alloc] initWithSessionID:ninjaSessionID displayName:myPeerID sessionMode:GKSessionModeServer];
         thisSession.delegate = self;
        [thisSession setDataReceiveHandler:self withContext:NULL];
        
[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(newGame) name:@"NewGame" object:nil];
        
    }
    return self;
}

- (void)newGame
{
    if (livePlayers == 0) {
        unsigned char reset[1];
        reset[0] = 4;
        
        [self sendData:reset];
        [self initiateGameStart];
    }
}   

- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state
{
    //Called when client's connect to peer is successful or when a peer disconnects
    if (state == GKPeerStateConnected) {
        [peersInGroup addObject:peerID];
        members++;
        livePlayers++;
        originalPlayers = livePlayers;
        
        unsigned char connect[1];
        connect[0] = 5;
        
        [self updateMembersLabel];
        
        [self sendData:connect];
    }
    else if (state == GKPeerStateDisconnected) {
        [peersInGroup removeObject:peerID];
        if ([peersInGroup count] < MAX_PLAYERS)
            [thisSession setAvailable:TRUE];
    }
}

- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    //Called when a client tries to connect to a server
    if (![peersInGroup containsObject:peerID]) {
        [session acceptConnectionFromPeer:peerID error:NULL];
        if ([peersInGroup count] == MAX_PLAYERS) {
             [thisSession setAvailable:FALSE];
        }
    }
    else {
        [session denyConnectionFromPeer:peerID];
    }
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
    //FUCK YOU error methods
}

- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
    //Code to handle failed connection
}


-(void) startSelected:(id)sender{
    [self initiateGameStart];
}

- (void)initiateGameStart
{
    unsigned char assignColors[2];
    
    assignColors[0] = AssignColor;
    died = FALSE;
    if (game != NULL) {
        
        [game dismissViewControllerAnimated:YES completion:nil];
    }
    livePlayers = originalPlayers;
    for (int i = 0; i < 1; ++i) {
        assignColors[1] = i;
        
        if (i >= colorIndex) {
            assignColors[1] += 1;
        }
        
        NSArray *thisObject = [peersInGroup objectAtIndex:i];
    
        NSData *packet = [NSData dataWithBytes:assignColors length:sizeof(assignColors)];
        
        [thisSession sendDataToAllPeers:packet withDataMode:GKSendDataReliable error:nil];
        // [thisSession sendData:packet toPeers:thisObject withDataMode:GKSendDataReliable error:nil];
    }
    
    unsigned char data[1];
    
    data[0] = StartGame;
    
    [self sendData:data];
    
    //Send start notification to all clients
    [self startGame];
}



-(void) colorSelected:(id)sender{
    NSLog(@"colorSelected");
    /*UIButton *button = (UIButton*)sender;
    int playerNumber = button.tag;
    *
    colorIndex = playerNumber;
    [button setTitle:myPeerID forState:UIControlStateNormal];
    [button setBackgroundColor:[UIColor grayColor]];
    */
    colorIndex = 0;
    colorAvailability[colorIndex] = FALSE;
    [thisSession setAvailable:TRUE];
    [self.view addSubview:membersInGame];
}

- (void)updateMembersLabel
{
    [membersInGame setText:[NSString stringWithFormat:@"%i", members]];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self initiateGameStart];
}

- (void)playerLost
{
    NSLog(@"serverLost");
    if (!died) {
        died = TRUE;
        [self killPlayer:colorIndex];
    }
    
}

- (void)viewDidLoad
{
    //colorPicker = [[ColorSelector alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];// withOwner:self];

         [super viewDidLoad];
    NSLog(@"viewDidLoad");
    [self colorSelected:nil];
    //[self.view addSubview:colorPicker];
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
