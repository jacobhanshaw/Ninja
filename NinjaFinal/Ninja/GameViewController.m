//
//  GameViewController.m
//  ProjectReality
//
//  Created by Jacob Hanshaw on 10/19/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import "GameViewController.h"

@implementation GameViewController

BOOL lightOn = NO;
int lightFlashes;

@synthesize minAccel, currentMagAccel, maxAccel, animationDuration, motionManager, playerNumber, playerColorHue, playerColorBrightness, shouldPulse, isAnimating, initialBrightness, lightFlashes, idleTimerInitiallyDisabled;

- (id)init
{
    self = [super init];
    if (self) {
        self.motionManager = [[CMMotionManager alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    lightOn = false;
    
    self.minAccel = 1.2;
    self.currentMagAccel = 0;
    self.maxAccel = 2.35;
    self.animationDuration = initialAnimationDuration;
    self.shouldPulse = NO;
    self.isAnimating = NO;
    self.initialBrightness = [UIScreen mainScreen].brightness;
    self.idleTimerInitiallyDisabled = [UIApplication sharedApplication].idleTimerDisabled;
    [UIApplication sharedApplication].idleTimerDisabled = YES;
    [self startMyMotionDetect];
    
}

-(void) viewWillAppear:(BOOL)animated {
    GameSetUpViewController *test = [[GameSetUpViewController alloc] init];
    [self presentViewController:test animated:YES completion:nil];
}

- (void) viewWillDisappear:(BOOL)animated{
    [timer invalidate];
    
    [[UIScreen mainScreen] setBrightness:self.initialBrightness];
    [UIApplication sharedApplication].idleTimerDisabled = self.idleTimerInitiallyDisabled;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startMyMotionDetect
{
    if(!self.motionManager.accelerometerAvailable) NSLog(@"Accelerometer not available");
    else [self.motionManager startAccelerometerUpdates];
}

-(void) pulse{
    if(self.shouldPulse){
        
        CMAccelerometerData *data = self.motionManager.accelerometerData;
        
        float accel = sqrtf(pow(data.acceleration.x,2) + pow(data.acceleration.y,2) + pow(data.acceleration.x,2));
        if (accel > self.maxAccel) [self hasLostGame];
        else if(accel > self.minAccel){
            
            float magnitudeAccel = (accel-self.minAccel)/(self.maxAccel-self.minAccel);
            
            if(magnitudeAccel > self.currentMagAccel) self.currentMagAccel = magnitudeAccel;
            
            
            if(!self.isAnimating){
                self.isAnimating = YES;
                [self flashScreen];
            }
        }
        else{
            self.playerColorBrightness = 1;
            UIColor *backgroundColor = [[UIColor alloc] initWithHue:self.playerColorHue saturation: 1 brightness:1 alpha:1];
            self.view.backgroundColor = backgroundColor;
        }
    }
}

-(void) flashScreen{
    if(self.animationDuration >= 0){
        if(self.playerColorBrightness == 1) self.playerColorBrightness = 0;
        else self.playerColorBrightness = 1;
        UIColor *backgroundColor = [[UIColor alloc] initWithHue:self.playerColorHue saturation:1 brightness:self.playerColorBrightness alpha:1];
        self.view.backgroundColor = backgroundColor;
        
        float delay = (1-self.currentMagAccel)/2;
        if(delay == 0) delay = .01;
        
        self.animationDuration -= delay;
        
        [self performSelector:@selector(flashScreen) withObject:nil afterDelay:delay];
    }
    else{
        self.isAnimating = NO;
        self.currentMagAccel = 0;
        self.animationDuration = initialAnimationDuration;
    }
}

-(void) flashLight{
    if(self.lightFlashes >= 0){
        AVCaptureDevice *device = [AVCaptureDevice defaultDeviceWithMediaType:AVMediaTypeVideo];
        if ([device hasTorch]) {
            [device lockForConfiguration:nil];
            if(lightOn){
                [device setTorchMode:AVCaptureTorchModeOff];
                lightOn = NO;
            }
            else{
                [device setTorchMode:AVCaptureTorchModeOn];
                lightOn = YES;
            }
            [device unlockForConfiguration];
        }
        self.lightFlashes--;
        [self performSelector:@selector(flashLight) withObject:nil afterDelay:0.2];
    }
}

-(void) newGameWithPlayerId: (int) playerId {
    NSNotification *newNotice = [NSNotification notificationWithName:@"NewGame" object:nil];
     [[NSNotificationCenter defaultCenter] postNotification:newNotice];
    self.shouldPulse = YES;
    self.playerNumber = playerId;
    
    self.isAnimating = NO;
    self.currentMagAccel = 0;
    self.animationDuration = initialAnimationDuration;
    
    switch(self.playerNumber){
        case 0: self.playerColorHue = 0;
            break;
        case 1: self.playerColorHue = 38;
            break;
        case 2: self.playerColorHue = 60;
            break;
        case 3: self.playerColorHue = 105;
            break;
        case 4: self.playerColorHue = 175;
            break;
        case 5: self.playerColorHue = 224;
            break;
        case 6: self.playerColorHue = 275;
            break;
        case 7: self.playerColorHue = 320;
            break;
    }
    
    self.playerColorHue = self.playerColorHue/360;
    
    UIColor *backgroundColor = [[UIColor alloc] initWithHue:self.playerColorHue saturation: 1 brightness:1 alpha:1];
    self.view.backgroundColor = backgroundColor;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:(0.02) target:self selector:@selector(pulse) userInfo:nil repeats:TRUE];
    
}

- (void) hasLostGame{
    
    [timer invalidate];
    
    [[UIScreen mainScreen] setBrightness:self.initialBrightness];
    
    self.shouldPulse = NO;
    [self vibrate];
    
    self.lightFlashes = initialNumberFlashes;
    [self flashLight];
    
    NSNotification *loseNotice = [NSNotification notificationWithName:@"PlayerLost" object:nil];
    [[NSNotificationCenter defaultCenter] postNotification:loseNotice];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Nice Try" message: @"You've Lost!" delegate: self cancelButtonTitle: nil otherButtonTitles: @"Play Again", nil];
	
	[alert show];
}

- (void) hasWonGame{
    [timer invalidate];
    
    [[UIScreen mainScreen] setBrightness:self.initialBrightness];
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle: @"Good Job" message: @"You've Won!" delegate: self cancelButtonTitle: nil otherButtonTitles: @"Play Again", nil];
	
	[alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *title = [alertView title];
    NSLog(@"%@", title);
    
    if([title isEqualToString:@"Nice Try"]) {
        
        //    if (buttonIndex == 1) {
        //  NSLog(@"User pressed Leave %d", buttonIndex);
        //    NSNotification *endNotice = [NSNotification notificationWithName:@"EndGame" object:nil];
        // [[NSNotificationCenter defaultCenter] postNotification:endNotice];
        // [self dismissViewControllerAnimated:YES completion:nil];
        // }
        //else {
            [self newGameWithPlayerId:self.playerNumber];
        // }
    }
    
    if([title isEqualToString:@"Good Job"]) {
        
        //if (buttonIndex == 1) {
        //  NSLog(@"User pressed Leave %d", buttonIndex);
        //   NSNotification *endNotice = [NSNotification notificationWithName:@"EndGame" object:nil];
        // [[NSNotificationCenter defaultCenter] postNotification:endNotice];
        //   [self dismissViewControllerAnimated:YES completion:nil];
        // [self dismissViewControllerAnimated:YES completion:nil];
        // }
        //else {
           [self newGameWithPlayerId:self.playerNumber];
        //}
    }
}

//Vibrate
- (void) vibrate{
	AudioServicesPlayAlertSound(kSystemSoundID_Vibrate); 
}

@end
