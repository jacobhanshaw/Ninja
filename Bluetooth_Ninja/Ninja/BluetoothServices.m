//
//  BluetoothServices.m
//  
//
//  Created by Jacob Hanshaw on 10/26/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import "BluetoothServices.h"

@implementation BluetoothServices

@synthesize bluetoothSession, receiveData, peer, session, context;

+ (id)sharedBluetoothServices
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    
    
    myMode = GKSessionModeClient;
    peersInGroup = [[NSMutableArray alloc] init]; //Holds the list of available servers
    thisSession = [[GKSession alloc] initWithSessionID:ninjaSessionID displayName:myPeerID sessionMode:GKSessionModeClient];
    thisSession.delegate = self;
    [thisSession setDataReceiveHandler:self withContext:NULL];
    
    return _sharedObject;
}

- (void)sendData:(void *)data
{
    NSData *packet = [NSData dataWithBytes:data length:sizeof(unsigned char)];
    
    [session sendDataToAllPeers:packet withDataMode:GKSendDataReliable error:nil];
}

- (void)receiveData:(NSData *)data fromPeer:(NSString *)inputPeer inSession:(GKSession *)inputSession context:(void *)inputContext {

    self.receiveData = data;
    self.peer = inputPeer;
    self.session = inputSession;
    self.context = inputContext;
    
    //BluetoothObject *receivedInformation = [[BluetoothObject alloc] initWithReceiveData:data peer:peer session:inputSession context:context];
    
    NSNotification *receivedDataNotice = [NSNotification notificationWithName:@"NewDataReceived" object:self];
    [[NSNotificationCenter defaultCenter] postNotification:receivedDataNotice];
    
    
    //[[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(YOURMEHTODNAMEHERE) name:@"NewDataReceived" object:[BluetoothServices sharedBluetoothServices]];
    
}



@end
