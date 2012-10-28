//
//  BluetoothServices.m
//  
//
//  Created by Jacob Hanshaw on 10/26/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import "BluetoothServices.h"

@implementation BluetoothServices

@synthesize bluetoothSession, sessionID, name, mode, dataReceived, originOfData, sessionReceived, context, peersInGroup, peersInSession;

+ (id)sharedBluetoothServices
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] init]; // or some other init method
    });
    
    return _sharedObject;
}


-(void) setUpWithSessionID:(NSString *)inputSessionID displayName:(NSString *)inputName sessionMode:(GKSessionMode)inputMode andContext:(void *)inputContext {
    
    self.mode = inputMode;
    self.sessionID = inputSessionID;
    self.name = inputName;
    
    peersInSession = [[NSMutableArray alloc] init];
    self.peersInGroup = [[NSMutableArray alloc] init];
    
    self.bluetoothSession = [[GKSession alloc] initWithSessionID:self.sessionID displayName:self.name sessionMode:self.mode];
    self.bluetoothSession.delegate = self;
    [self.bluetoothSession setDataReceiveHandler:self withContext:inputContext];
    
    [self.bluetoothSession setAvailable:TRUE]; //don't forget to set to false later
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
/*
-(NSMutableArray *) getPeersInSession{
    return peersInSession;
}*/

@end
