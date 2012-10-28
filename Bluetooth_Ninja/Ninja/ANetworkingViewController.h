//
//  ANetworkingViewController.h
//  Ninja
//
//  Created by Transition on 10/20/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

typedef enum packetTypes {
    IveDied = 0,
    GameOver = 1,
    StartGame = 2,
    AssignColor = 3
    }packetTypes;

@interface ANetworkingViewController : UIViewController <GKSessionDelegate>

{
    
    UILabel *clientInstructions;
    
    GKSession *thisSession; //Created in subclass
    NSString *myPeerID; //Created here
    NSMutableArray *peersInGroup; //Created in subclass
    GKSessionMode myMode; //Created in subclass
    GameViewController *game;
    
    
    int colorIndex; //Created here
    BOOL playerAlive[8];
    BOOL colorAvailability[8];
    
    UIView *colorPicker, *serverPicker;
}
- (void)receiveData:(NSData *)data fromPeer:(NSString *)peer inSession:(GKSession *)session context:(void *)context;

- (void)sendData:(void *)data;
- (void)startGame;
//- (void)selectColor;
- (void)assignColor:(unsigned char)color;
- (void)colorSelected:(id)sender;
- (void)startSelected:(id)sender;
- (void)initiateGameStart;
- (void)announceWinner:(int)index;
- (void)playerLost;//:(int)index;
- (void)killPlayer:(unsigned char) index;
- (void)connected;
@end
