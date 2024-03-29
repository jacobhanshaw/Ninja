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

@synthesize minAccel, currentMagAccel, maxAccel, animationDuration, motionManager, playerNumber, playerColorHue, playerColorBrightness, shouldPulse, isAnimating, initialBrightness, lightFlashes, idleTimerInitiallyDisabled, myAudioPlayer, tempMusicPlayer, alert;

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
    
}

- (void) viewWillAppear:(BOOL)animated {
    
    [super viewWillAppear:animated];
    
    lightOn = false;
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reset) name:@"UIApplicationDidEnterBackgroundNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateReceived:) name:@"NewDataReceived" object:nil];
    
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
    
    tempMusicPlayer = [MPMusicPlayerController iPodMusicPlayer];
    [self newGameWithPlayerId:self.playerNumber];
    
}

- (void) viewWillDisappear:(BOOL)animated{
    
    [super viewWillDisappear:animated];
    
    [self exit];
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
    
    if([[BluetoothServices sharedBluetoothSession] getHasNoPeers]){
        
        if(timer.isValid) [timer invalidate];
        if(timer) timer = nil;
        
        if(!(alert.hidden || [alert.title isEqualToString:@"No Other Players"])) {
        [alert dismissWithClickedButtonIndex:7 animated:YES];
        [self performSelector:@selector(displayAlertFunction:) withObject:[NSNumber numberWithInt:NOOTHERPLAYERS] afterDelay:0.01];
        }
        self.shouldPulse = NO;
    }
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

- (void) updateReceived:(NSNotification *) sender {
    
    NSData *data = [BluetoothServices sharedBluetoothSession].dataReceived;
    int i;
    [data getBytes: &i length: sizeof(i)];
    
    NSData *rest = [NSData dataWithBytes:(void*)[data bytes] + sizeof(i) length:data.length - sizeof(i)];
    
    if(i == PLAYEROUT){
        otherPlayersLeft--;
        if(otherPlayersLeft == 0 && !isOut){
            [self hasWonGame];
        }
    }
    if(i == NEWGAME) [self newGameWithPlayerId:self.playerNumber];
    if(i == PLAYSONG){
      //  myAudioPlayer = [AVPlayer playerWithPlayerItem:((AVPlayerItem *)rest)];
       // [myAudioPlayer play];
        MPMediaItemCollection *itemCollection = ((MPMediaItemCollection *) rest);
        [tempMusicPlayer setQueueWithItemCollection: itemCollection];
        [tempMusicPlayer play];
    }
}

-(void) newGameWithPlayerId: (int) playerId {
    if(!alert.hidden) [alert dismissWithClickedButtonIndex:7 animated:YES];
    self.shouldPulse = YES;
    self.playerNumber = playerId;
    
    otherPlayersLeft = [[[BluetoothServices sharedBluetoothSession] getPeersInSession] count];
    isOut = NO;
    
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
    
    if(timer.isValid) [timer invalidate];
    if(timer) timer = nil;
    
    timer = [NSTimer scheduledTimerWithTimeInterval:(0.02) target:self selector:@selector(pulse) userInfo:nil repeats:TRUE];
    
}

- (void) hasLostGame{
    
    //[timer invalidate];
    
    [[UIScreen mainScreen] setBrightness:self.initialBrightness];
    
    isOut = YES;
    
    self.shouldPulse = NO;
    [self vibrate];
    
    self.lightFlashes = initialNumberFlashes;
    [self flashLight];
    
    int i = PLAYEROUT;
    NSData *data = [NSData dataWithBytes: &i length: sizeof(i)];
    [[BluetoothServices sharedBluetoothSession] sendData:data toAll:YES];
    
    alert = [[UIAlertView alloc] initWithTitle: @"Nice Try" message: @"You've Lost!" delegate: self cancelButtonTitle: nil otherButtonTitles: @"Leave", @"Play Again", nil];
	
	[alert show];
   // [self showMediaPicker];
}

- (void) hasWonGame{
   // [timer invalidate];
    
    self.shouldPulse = NO;
    
    [[UIScreen mainScreen] setBrightness:self.initialBrightness];
    
    alert = [[UIAlertView alloc] initWithTitle: @"Good Job" message: @"You've Won!" delegate: self cancelButtonTitle: nil otherButtonTitles: @"Leave", @"Play Again", nil];
	
	[alert show];
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	NSString *title = [alertView title];
    NSLog(@"%@", title);
    NSLog(@"%d", buttonIndex);
    
    if([title isEqualToString:@"Nice Try"]) {
        
        if (buttonIndex == 0) [self exit];
        else {
            [self performSelector:@selector(displayAlertFunction:) withObject:[NSNumber numberWithInt:WAIT] afterDelay:0.01];
        }
    }
    
    if([title isEqualToString:@"Good Job"]) {
        
        if (buttonIndex == 0) [self exit];
        else {
            int i = NEWGAME;
            NSData *data = [NSData dataWithBytes: &i length: sizeof(i)];
            [[BluetoothServices sharedBluetoothSession] sendData:data toAll:YES];
            
           [self newGameWithPlayerId:self.playerNumber];
        }
    }
    
    if([title isEqualToString:@"No Other Players"]) {
        [(NetworkingViewController *)self.presentingViewController reset];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

//Implemented so I can dismiss things
- (void) alertView:(UIAlertView*)alert didDismissWithButtonIndex:(NSInteger)index{
    NSLog(@"Whatever");
}

//Alert

- (void) displayAlertFunction: (NSNumber *) alertsNumber {
    alerts = [alertsNumber intValue];
    if(alerts == WAIT) alert = [[UIAlertView alloc] initWithTitle: @"Please Wait" message: @"Please wait for the game to end." delegate: self cancelButtonTitle: @"Ok" otherButtonTitles: nil];
    else if(alerts == NOOTHERPLAYERS) alert = [[UIAlertView alloc] initWithTitle: @"No Other Players" message: @"All other players have left the game. Please press continue to start or join a new group." delegate: self cancelButtonTitle: nil otherButtonTitles: @"Continue", nil];
    [alert show];
}


//Vibrate
- (void) vibrate{
	AudioServicesPlayAlertSound(kSystemSoundID_Vibrate); 
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self showMediaPicker];
}

- (void) exit {
    if(self.view.subviews)  [self dismissViewControllerAnimated:YES completion:nil];
    if(timer.isValid) [timer invalidate];
    if(timer) timer = nil;
    
    [[UIScreen mainScreen] setBrightness:self.initialBrightness];
    [UIApplication sharedApplication].idleTimerDisabled = self.idleTimerInitiallyDisabled;
    
    [(NetworkingViewController *)self.presentingViewController reset];
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Media Picker

- (void) showMediaPicker
{
    MPMediaPickerController *mediaPicker = [[MPMediaPickerController alloc] initWithMediaTypes: MPMediaTypeAny];
    
    mediaPicker.delegate = self;
    mediaPicker.allowsPickingMultipleItems = NO;
    mediaPicker.prompt = @"Select a song to play";
    
  //  [self.view addSubview:mediaPicker.view];
    [self presentViewController:mediaPicker animated:YES completion:nil];
}

- (void) mediaPicker: (MPMediaPickerController *) mediaPicker didPickMediaItems: (MPMediaItemCollection *) mediaItemCollection
{
    if (mediaItemCollection) {
        [tempMusicPlayer setQueueWithItemCollection: mediaItemCollection];
        [tempMusicPlayer play];
     //   MPMediaItem *nowPlayingItem = tempMusicPlayer.nowPlayingItem;
      //  NSURL * mediaURL = [nowPlayingItem valueForProperty:MPMediaItemPropertyAssetURL];
       // AVPlayerItem * myAVPlayerItem = [AVPlayerItem playerItemWithURL:mediaURL];
        int i = PLAYSONG;
        NSMutableData *data = [NSMutableData dataWithBytes: &i length: sizeof(i)];
        NSMutableData *song = [NSMutableData dataWithBytes:(__bridge const void *)(mediaItemCollection) length:sizeof(mediaItemCollection)];
        [data appendData:song];
        [[BluetoothServices sharedBluetoothSession] sendData:data toAll:YES];
     //   [tempMusicPlayer stop];
    }
    
    [self dismissViewControllerAnimated:YES completion:nil];
  //  [mediaPicker.view removeFromSuperview];
}


- (void) mediaPickerDidCancel: (MPMediaPickerController *) mediaPicker
{
    [self dismissViewControllerAnimated:YES completion:nil];
  //  [mediaPicker.view removeFromSuperview];
}


@end
