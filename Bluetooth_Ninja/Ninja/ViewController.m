//
//  ViewController.m
//  BluetoothLobby
//
//  Created by Michael on 11/1/12.
//  Copyright (c) 2012 Michael. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end



@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    /*namesCreated = 0;
    
    names[0] = @"James";
    names[1] = @"Billy";
    names[2] = @"Bob";
    names[3] = @"Joe";
    names[4] = @"Alice";
    names[5] = @"Sandy";
    names[6] = @"Nick";
    names[7] = @"Mike";
    names[8] = @"Albert";
    names[9] = @"Morgan";

    peers = [[NSMutableArray alloc] init];
    groups = [[NSMutableArray alloc] init];
    
    lobbyView = [[LobbyView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) andName:@""];
    lobbyView.delegate = self;
    [lobbyView setUserInteractionEnabled:FALSE];
    [self.view addSubview:lobbyView];

    [self.view setBackgroundColor:[UIColor purpleColor]];
    nameView = [[NameInputView alloc] initWithFrame:CGRectMake(40, 60, self.view.frame.size.width - 80, self.view.frame.size.height - 120) andDefaultName:[[UIDevice currentDevice] name]];
    nameView.delegate = self;
    [self.view addSubview:nameView];*/
}

- (void)nameSelected:(NSString *)finalName
{
    [lobbyView setName:finalName];
    [UIView animateWithDuration:0.5 animations:^(void) {
        [nameView setFrame:CGRectMake(40, self.view.frame.size.height, nameView.frame.size.width, nameView.frame.size.width)];
        [nameView setAlpha:0.0];
    } completion:^(BOOL complete) {
        [nameView setHidden:TRUE];
        [lobbyView setUserInteractionEnabled:TRUE];
    }];
    
}

- (void)refreshLobby
{
    int remove = arc4random() % 6;
    
    int add = arc4random() % 6;
    
    for (int i = 0; i < remove; i++) {
        int peersornot = arc4random() % 2;
        if (peersornot == 0) {
            int count = [peers count];
            if (count > 0) {
                count = arc4random() % count;
                [peers removeObjectAtIndex:count];
            }
        }
        else {
            int count = [groups count];
            if (count > 0) {
                count = arc4random() % count;
                [groups removeObjectAtIndex:count];
            }
        }
    }
    
    for (int i = 0; i < add; i++) {
        int peersornot = arc4random() % 2;
        if (peersornot == 0) {
                int count = arc4random() % 10;
                [peers addObject:[NSString stringWithFormat:@"%@%i", names[count], namesCreated]];
            namesCreated++;
        }
        else {
                int count = arc4random() % 10;
            [groups addObject:[NSString stringWithFormat:@"%@%i", names[count], namesCreated]];
            namesCreated++;
        }

    }
    
    /*NSLog(@"groups");
    for (NSString *s in groups) {
        NSLog(@"%@\n",s);
    }
    
    NSLog(@"peers");
    for (NSString *s in peers) {
        NSLog(@"%@\n",s);
    }*/
    
    [lobbyView updateLobbyWithGroups:groups andPeers:peers];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
