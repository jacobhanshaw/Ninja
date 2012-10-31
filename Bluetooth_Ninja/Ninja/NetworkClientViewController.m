//
//  NetworkClientViewController.m
//  Ninja
//
//  Created by Transition on 10/20/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import "NetworkClientViewController.h"

@interface NetworkClientViewController ()


- (void)refreshServersList;

@end

@implementation NetworkClientViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        myMode = GKSessionModeClient;
        peersInGroup = [[NSMutableArray alloc] init]; //Holds the list of available servers
        thisSession = [[GKSession alloc] initWithSessionID:ninjaSessionID displayName:myPeerID sessionMode:GKSessionModeClient];
        thisSession.delegate = self;
        [thisSession setDataReceiveHandler:self withContext:NULL];
    }
    return self;
}

- (void)findServers
{
    [peersInGroup removeAllObjects];
    NSArray *servers = [thisSession peersWithConnectionState:GKSessionModeServer];
    if (servers != nil) {
        if ([servers count] > 0) {
            [self.view setBackgroundColor:[UIColor orangeColor]];
            [clientInstructions setText:@"Server Found, Tap Once to Connect"];
            [clientInstructions setHidden:FALSE];
        }
        [peersInGroup addObjectsFromArray:servers];
    }
}

- (void)connected
{
    
    [clientInstructions setText:@"Connected"];
    
    [self.view setBackgroundColor:[UIColor greenColor]];
}

- (void)refreshServersList
{
    if ([peersInGroup count] != 0) {
        
        [thisSession connectToPeer:[peersInGroup objectAtIndex:0] withTimeout:5.0];
    }
    [self findServers];
    
    //Code here to update tableView;
}

- (void)selectServer:(int) tableIndex
{
    [thisSession connectToPeer:[peersInGroup objectAtIndex:tableIndex] withTimeout:5.0];
    // launch color selector
}

- (void)playerLost
{
    unsigned char deathPacket[2];
    deathPacket[0] = 0;
    deathPacket[1] = colorIndex;
  //  died = TRUE;
    [self sendData:deathPacket];
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    
    clientInstructions = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, 300, 100)];
    [clientInstructions setBackgroundColor:[UIColor clearColor]];
    [clientInstructions setOpaque:FALSE];
    [clientInstructions setText:@"Tap to search for servers"];
    [self.view addSubview:clientInstructions];
    [self.view addSubview:serverPicker];
    [thisSession setAvailable:TRUE];
    [self refreshServersList];
    
    
    // Do any additional setup after loading the view from its nib.
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self refreshServersList];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

@end
