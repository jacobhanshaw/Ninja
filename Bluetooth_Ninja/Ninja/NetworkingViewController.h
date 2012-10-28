//
//  NetworkingViewController.h
//  Ninja
//
//  Created by Jacob Hanshaw on 10/26/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GameKit/GameKit.h>
//#import "ColorSelector.h"
#import "GameViewController.h"
#import "AppModel.h"

#define ninjaSessionID @"ninjaBitches" //If we plan on making a solid API, shouldn't this be a variable with a timestamp to allow multiple sessions in the same area
#define MAX_PLAYERS 7 //Same for this

typedef enum packetTypes {
    IveDied = 0,
    GameOver = 1,
    StartGame = 2,
    AssignColor = 3
}packetTypes;

@interface NetworkingViewController : UIViewController <GKSessionDelegate> {
    
}

@end
