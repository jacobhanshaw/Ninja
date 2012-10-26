//
//  ANetworkingViewController.m
//  Ninja
//
//  Created by Transition on 10/20/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import "ANetworkingViewController.h"

@implementation ANetworkingViewController


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // withOwner:self];
        // Custom initialization
        
        livePlayers = 0;
        died = FALSE;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerLost) name:@"PlayerLost" object:nil];
        for (int i = 0; i < 8; i++) {
            colorAvailability[i] = TRUE;
            colorIndex = -1;
            
            //serverPicker = [[ColorSelector alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
        }
    }
    return self;
}

//
//MY STUFF
//
- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context { 
    unsigned char *incomingPacket = (unsigned char *)[data bytes];
    switch (incomingPacket[0]) {
        case IveDied:
            [self killPlayer:incomingPacket[1]];
            break;
            
            case 1:
            NSLog(@"announceWinnerCase");
            [self announceWinner:incomingPacket[1]];
            break;
            
        case StartGame:
            [self startGame];
            break;
            
        case AssignColor:
            [self assignColor:incomingPacket[1]];
            break;
            
            case 4:
            [self reset];
            break;
            
        case 5:
            [self connected];
            break;
            
        default:
            break;
    }
}

- (void)reset
{
    died = FALSE;
    [game dismissViewControllerAnimated:YES completion:nil];
}

- (void)assignColor:(unsigned char)color
{
    colorIndex = color;
}

//Only used by servers
- (void)killPlayer:(unsigned char) index
{
    livePlayers--;
    if (livePlayers == 0) {
        NSLog(@"winner found");
        [self endGame:0];
    }
}

//Only used by servers
- (void)initiateGameStart
{
    
}



- (void)announceWinner:(int)index
{
    NSLog(@"announceWinner Method");
    if (!died) {
        
        [game hasWonGame];
    }
}

//Only used by servers
- (void)endGame:(int)winner
{
    unsigned char endgamePacket[2];
    endgamePacket[0] = 1;
    endgamePacket[1] = winner;
    [self announceWinner:0];
    [self sendData:endgamePacket];
}

- (void)sendData:(void *)data
{
    NSData *packet = [NSData dataWithBytes:data length:sizeof(unsigned char)];
    
    [thisSession sendDataToAllPeers:packet withDataMode:GKSendDataReliable error:nil];
}

- (void)startGame
{
    //if haven't selected color yet, assign color to undecided members
    //launch the gameview controller
        
    [colorPicker setHidden:TRUE];
    [serverPicker setHidden:TRUE];
    
    game = [[GameViewController alloc] init];
    
    [self presentViewController:game animated:YES completion:nil];
    [game newGameWithPlayerId:colorIndex];
}

- (void)playerLost
{
    NSLog(@"player lost");
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //serverPicker = [[ColorSelector alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height)];
	// Do any additional setup after loading the view.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
