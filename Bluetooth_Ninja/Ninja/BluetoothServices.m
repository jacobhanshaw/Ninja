//
//  BluetoothServices.m
//  
//
//  Created by Jacob Hanshaw on 10/26/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import "BluetoothServices.h"

@implementation BluetoothServices

@synthesize bluetoothSession, dataReceived, originOfData, sessionReceived, context, peersInGroup;
// peersInSession;

+ (id)sharedBluetoothSession
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    
    return _sharedObject;
}


//SessionID - unique string identifying session
//Name - unique string identifying the individual device within the session
//Mode - GKSessionModeServer, GKSessionModeClient, or GKSessionModePeer
//which makes this device a server, client, or both

-(void) setUpWithSessionID:(NSString *)inputSessionID displayName:(NSString *)inputName sessionMode:(GKSessionMode)inputMode andContext:(void *)inputContext {
    
    peersInSession = [[NSMutableArray alloc] init];
    self.peersInGroup = [[NSMutableArray alloc] init];
    
    self.bluetoothSession = [[GKSession alloc] initWithSessionID:inputSessionID displayName:inputName sessionMode:inputMode];
    self.bluetoothSession.delegate = self;
    [self.bluetoothSession setDataReceiveHandler:self withContext:inputContext];
    
    [self.bluetoothSession setAvailable:TRUE]; //don't forget to set to false later
}

//
// invalidate session
//
- (void)invalidateSession {
	if(self.bluetoothSession != nil) {
		[self.bluetoothSession disconnectFromAllPeers];
		self.bluetoothSession.available = NO;
		[self.bluetoothSession setDataReceiveHandler: nil withContext: NULL];
		self.bluetoothSession.delegate = nil;
	}
}


- (void) sendData:(void *)data toAll:(BOOL)shouldSendToAll
{
    NSData *packet = [NSData dataWithBytes:data length:sizeof(unsigned char)];
    NSError *dataSendingError;
    
    if(shouldSendToAll){
    if(![self.bluetoothSession sendDataToAllPeers:packet withDataMode:GKSendDataReliable error:nil])
        NSLog(@"BluetoothServices: SendingDataToAllPeers Failed with Error Message: %@", [dataSendingError localizedDescription]);
    }
    else{
        if(![self.bluetoothSession sendData: packet toPeers:self.peersInGroup withDataMode:GKSendDataReliable error:nil])
            NSLog(@"BluetoothServices: SendingDataToAllPeers Failed with Error Message: %@", [dataSendingError localizedDescription]);
    }
}

- (void) receiveData:(NSData *)inputData fromPeer:(NSString *)inputPeer inSession:(GKSession *)inputSession context:(void *)inputContext {

    self.dataReceived = inputData;
    self.originOfData = inputPeer;
    self.sessionReceived = inputSession;
    self.context = inputContext;
    
    NSNotification *receivedDataNotice = [NSNotification notificationWithName:@"NewDataReceived" object:self];
    [[NSNotificationCenter defaultCenter] postNotification:receivedDataNotice];
    
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(YOURMEHTODNAMEHERE) name:@"NewDataReceived" object:[BluetoothServices sharedBluetoothServices]];
    
}

-(NSMutableArray *) getPeersInSession{
    return peersInSession;
}


#pragma mark GKSessionDelegate Methods

// we've gotten a state change in the session
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    
    if(state == GKPeerStateDisconnected) {
        // We've been disconnected from the other peers.
        
        // Update user alert or throw alert if it isn't already up
        NSString *message = [NSString stringWithFormat:@"Could not reconnect with %@.", [session displayNameForPeer:peerID]];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Lost Connection" message:message delegate:self cancelButtonTitle:@"End Game" otherButtonTitles:nil];
        [alert show];
        
        // go back to start mode
       
    }
}

#pragma mark GKPeerPickerControllerDelegate Methods

-(void)startPicker {
    GKPeerPickerController *picker = [[GKPeerPickerController alloc] init]; // note: picker is released in various picker delegate methods when picker use is done.
    picker.delegate = self;
    [picker show]; // show the Peer Picker
}

- (void)peerPickerControllerDidCancel:(GKPeerPickerController *)picker {
    // Peer Picker automatically dismisses on user cancel. No need to programmatically dismiss.
    
    // autorelease the picker.
    //picker.delegate = nil;
    
    //if(self.bluetoothSession) [self invalidateSession];
}

/*
 *  Note: No need to implement -peerPickerController:didSelectConnectionType: delegate method since this app does not support multiple connection types.
 *      - see reference documentation for this delegate method and the GKPeerPickerController's connectionTypesMask property.
 */

//
// Provide a custom session that has a custom session ID. This is also an opportunity to provide a session with a custom display name.
//
- (GKSession *)peerPickerController:(GKPeerPickerController *)picker sessionForConnectionType:(GKPeerPickerConnectionType)type {
    if(!self.bluetoothSession){
        GKSession *defaultSession = [[GKSession alloc] initWithSessionID:definedSessionID displayName:nil sessionMode:GKSessionModePeer];
        self.bluetoothSession = defaultSession;
        peersInSession = [[NSMutableArray alloc] init];
        self.peersInGroup = [[NSMutableArray alloc] init];
        
        self.bluetoothSession.delegate = self;
        [self.bluetoothSession setDataReceiveHandler:self withContext:nil];
        
        [self.bluetoothSession setAvailable:TRUE]; //don't forget to set to false later
    }
    return self.bluetoothSession; // peer picker retains a reference, so autorelease ours so we don't leak.
}

- (void)peerPickerController:(GKPeerPickerController *)picker didConnectPeer:(NSString *)peerID toSession:(GKSession *)session {
    
    [peersInSession addObject:peerID];
    
    // Done with the Peer Picker so dismiss it.
    //[picker dismiss];
    
}

#pragma mark -
#pragma mark UIAlertViewDelegate Methods

// Called when an alert button is tapped.
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    // 0 index is "End Game" button
    if(buttonIndex == 0) {
        //Reattempt to Connect
    }
}






@end
