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
    
    //if the inputName contains the newline character then the host is calling this function, so we should parse out the
    //personalName and groupName
    
    unichar newline = '\n'; //separates the personal name from group name, so that the other players can parse and view both
    NSString *newLineCharacterString = [NSString stringWithCharacters:&newline length:1];
    if([inputName rangeOfString:newLineCharacterString].location != NSNotFound){
        personalName = [[inputName componentsSeparatedByString:newLineCharacterString] objectAtIndex:0];
        groupName = [[inputName componentsSeparatedByString:newLineCharacterString] objectAtIndex:0];
    }
    else personalName = inputName;
    
    failedConnections = 0;
    
    peerData = [[NSMutableDictionary alloc] init];
    
    peersBlocked = [[NSMutableArray alloc] init];
    peersInGroup = [[NSMutableArray alloc] init];
    
    self.bluetoothSession = [[GKSession alloc] initWithSessionID:inputSessionID displayName:inputName sessionMode:inputMode];
    self.bluetoothSession.delegate = self;
    [self.bluetoothSession setDataReceiveHandler:self withContext:inputContext];
    
    [self.bluetoothSession setAvailable:YES]; //don't forget to set to false later
}

//
// invalidate session
//
- (void)invalidateSession {
	if(self.bluetoothSession != nil) {
		[self.bluetoothSession disconnectFromAllPeers];
		[self.bluetoothSession setAvailable: NO];
		[self.bluetoothSession setDataReceiveHandler: nil withContext: nil];
		self.bluetoothSession.delegate = nil;
	}
}

//send data using this method
//will send either to all peers or the peers specified in peersInGroup, so set that value (using a subset of peersInSession) beforehand

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

//when data is received a notification is posted in the notification center. Your model or viewcontroller should receive
//the information by implementing the line of code below and accessing the information received from the sharedBluetoothSession
//[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(YOURMEHTODNAMEHERE) name:@"NewDataReceived" object:nil];

- (void) receiveData:(NSData *)inputData fromPeer:(NSString *)inputPeer inSession:(GKSession *)inputSession context:(void *)inputContext {
    
    self.dataReceived = inputData;
    self.originOfData = inputPeer;
    self.sessionReceived = inputSession;
    self.context = inputContext;
    
    NSNotification *receivedDataNotice = [NSNotification notificationWithName:@"NewDataReceived" object:self];
    [[NSNotificationCenter defaultCenter] postNotification:receivedDataNotice];
}

#pragma mark setters/getters

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

-(void) setPeersBlocked:(NSMutableArray *)newPeersBlocked {
    peersBlocked = newPeersBlocked;
    
}

-(NSMutableArray *) getPeersBlocked {
    return peersBlocked;
}

-(BOOL) getHasNoPeers {
    return hasNoPeers;
}

-(NSMutableDictionary *) getPeerData {
    return peerData;
}

#pragma mark GKSessionDelegate Methods

// example code of implementing the didChangeState GKSession delegate method
// we originally kept track of peers manually, but this also contains code useful if you decide to set a maximum number of players
// implement the methods below to observe changes in count of players
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeInPeerCount:) name:@"NewPeerConnected" object:nil];
//    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeInPeerCount:) name:@"PeerDisconnected" object:nil];
- (void)session:(GKSession *)session peer:(NSString *)peerID didChangeState:(GKPeerConnectionState)state {
    
    if (state == GKPeerStateConnected) {
        hasNoPeers = NO;
        NSNotification *receivedDataNotice = [NSNotification notificationWithName:@"NewPeerConnected" object:self];
        [[NSNotificationCenter defaultCenter] postNotification:receivedDataNotice];
        connectionStateChangePeerID = peerID;
        //[peersInSession addObject:peerID];
    }
    
    else if (state == GKPeerStateDisconnected) {
        if([[self getPeersInSession] count] == 0){
            hasNoPeers = YES;
        }
        NSNotification *receivedDataNotice = [NSNotification notificationWithName:@"PeerDisconnected" object:self];
        [[NSNotificationCenter defaultCenter] postNotification:receivedDataNotice];
        connectionStateChangePeerID = peerID;
        //[peersInSession removeObject:peerID];
        //  if ([peersInSession count] < MAX_PLAYERS) [self.bluetoothSession setAvailable:YES];
    }
    
}


//Called when a client tries to connect to a server
- (void)session:(GKSession *)session didReceiveConnectionRequestFromPeer:(NSString *)peerID
{
    if(![peersBlocked containsObject:peerID]){
        NSError *acceptConnectionError;
        if(![self.bluetoothSession acceptConnectionFromPeer:peerID error:&acceptConnectionError])
            NSLog(@"Session Fail with Error: %@", [acceptConnectionError localizedDescription]);
    }
    else [session denyConnectionFromPeer:peerID];
    //     if ([[self getPeersInSession] count] == MAX_PLAYERS) [thisSession setAvailable:NO];
    //     if (![peersInSession containsObject:peerID]) { accept connection }
    //     else [self.bluetoothSession denyConnectionFromPeer:peerID];
}

- (void)session:(GKSession *)session didFailWithError:(NSError *)error
{
    NSLog(@"Session Fail with Error: %@", [error localizedDescription]);
}


//reattempts connection with peer 10 times. Note: the failedConnections count is not tied to an individual,
//so if it failed to connect to a peerA 9 times before connecting, it would only reattempt to connect to peerB once before doing nothing
//from then on
- (void)session:(GKSession *)session connectionWithPeerFailed:(NSString *)peerID withError:(NSError *)error
{
    NSLog(@"Connection with Peer Failed with Error: %@", [error localizedDescription]);
    if(failedConnections < 10){
        [bluetoothSession connectToPeer:peerID withTimeout:5.0];
        failedConnections++;
    }
}


@end
