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
//@synthesize groupName;
//, peersInSession;

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
    
    unichar newline = '\n'; //separates the personal name from group name, so that the other players can parse and view both
    NSString *newLineCharacterString = [NSString stringWithCharacters:&newline length:1];
    if([inputName rangeOfString:newLineCharacterString].location != NSNotFound){
        personalName = [[inputName componentsSeparatedByString:newLineCharacterString] objectAtIndex:0];
        groupName = [[inputName componentsSeparatedByString:newLineCharacterString] objectAtIndex:0];
    }
    else personalName = inputName;
    
    failedConnections = 0;
    
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


- (void) sendData:(NSData *)data toAll:(BOOL)shouldSendToAll
{
    NSError *dataSendingError;
    
    if(shouldSendToAll){
    if(![self.bluetoothSession sendDataToAllPeers: data withDataMode:GKSendDataReliable error:&dataSendingError])
        NSLog(@"BluetoothServices: SendingDataToAllPeers Failed with Error Message: %@", [dataSendingError localizedDescription]);
    }
    else{
        if(![self.bluetoothSession sendData: data toPeers:self.peersInGroup withDataMode:GKSendDataReliable error:&dataSendingError])
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

-(NSArray *) getPeersInSession{
    return [self.bluetoothSession peersWithConnectionState:GKPeerStateConnected];
}

-(NSArray *) getAvailablePeers{
    return [self.bluetoothSession peersWithConnectionState:GKPeerStateAvailable];
}

-(void) setGroupName:(NSString *)newGroupName {
    groupName = newGroupName;
}

-(NSString *) getGroupName {
    return groupName;
}

-(void) setPersonalName:(NSString *)newPersonalName {
    personalName = newPersonalName;
}

-(NSString *) getPersonalName {
    return personalName;
}

#pragma mark GKSessionDelegate Methods
/*
// we've gotten a state change in the session
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    
    if (state == GKPeerStateConnected) {
        [peersInSession addObject:peerID];
    }
    else if (state == GKPeerStateDisconnected) {
        [peersInSession removeObject:peerID];
      //  if ([peersInSession count] < MAX_PLAYERS) [self.bluetoothSession setAvailable:TRUE];
    }
}
*/
//Should have more logic, prompt user?
- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    [self.bluetoothSession acceptConnectionFromPeer:peerID error:nil];
    /*
    //Called when a client tries to connect to a server
    if (![peersInSession containsObject:peerID]) {
        NSError *acceptConnectionError;
        if(![self.bluetoothSession acceptConnectionFromPeer:peerID error:&acceptConnectionError])
            NSLog(@"Session Fail with Error: %@", [acceptConnectionError localizedDescription]);
     //   if ([peersInSession count] == MAX_PLAYERS) [thisSession setAvailable:FALSE];
    }
    else [self.bluetoothSession denyConnectionFromPeer:peerID];
     */
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
    NSLog(@"Session Fail with Error: %@", [error localizedDescription]);
}


- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
    NSLog(@"Connection with Peer Failed with Error: %@", [error localizedDescription]);
    if(failedConnections < 10){
    [bluetoothSession connectToPeer:peerID withTimeout:5.0];
    failedConnections++;
    }
}


@end
