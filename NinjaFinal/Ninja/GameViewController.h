//
//  GameViewController.h
//  ProjectReality
//
//  Created by Jacob Hanshaw on 10/19/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreMotion/CoreMotion.h>
#import <AudioToolbox/AudioServices.h>

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

//#import "NetworkingViewController.h"
#import "GameSetUpViewController.h"

#define initialAnimationDuration 1.5
#define initialNumberFlashes 5

@interface GameViewController : UIViewController {
    
    int playerNumber;
    int lightFlashes;
    float initialBrightness;
    float playerColorHue;
    float playerColorBrightness;
    float minAccel;
    float currentMagAccel;
    float maxAccel;
    float animationDuration;
    BOOL shouldPulse;
    BOOL isAnimating;
    BOOL idleTimerInitiallyDisabled;
    CMMotionManager *motionManager;
    NSTimer *timer;
    
    //NetworkingViewController *owner;
    
}

@property(readwrite) int playerNumber;
@property(readwrite) int lightFlashes;
@property(readwrite) BOOL shouldPulse;
@property(readwrite) BOOL isAnimating;
@property(readwrite) BOOL idleTimerInitiallyDisabled;
@property(readwrite) float minAccel;
@property(readwrite) float currentMagAccel;
@property(readwrite) float maxAccel;
@property(readwrite) float animationDuration;
@property(readwrite) float initialBrightness;
@property(readwrite) float playerColorHue;
@property(readwrite) float playerColorBrightness;
@property(nonatomic, retain) CMMotionManager *motionManager;
//@property (nonatomic) NetworkingViewController *owner;

-(void) newGameWithPlayerId: (int) playerId;
- (void)hasWonGame;
@end
