//
//  BluetoothServices.h
//  
//
//  Created by Jacob Hanshaw on 10/26/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//
// IMPORTANT!
// Please see:
// http://developer.apple.com/library/ios/#documentation/GameKit/Reference/GKSession_Class/Reference/Reference.html#//apple_ref/doc/uid/TP40008258
// and
// http://developer.apple.com/library/ios/#DOCUMENTATION/GameKit/Reference/GKPeerPickerControllerDelegate_Protocol/Reference/Reference.html
// for Apple's documentation



#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

//#define definedSessionID @"ninja"

@interface BluetoothServices : NSObject <GKSessionDelegate, GKPeerPickerControllerDelegate> {
    
    GKSession *bluetoothSession; //the bluetooth connection session
    
    NSData * dataReceived;        //the data received
    NSString *originOfData;       //the sender of the notification
    GKSession *sessionReceived;   //the bluetooth session that is that has received data
    void *context;                //data associated with the session upon set-up
    
    NSMutableArray *peersInSession; //all other devices in the session
    NSMutableArray *peersInGroup;   //list of devices to send data toß
    
}

@property (nonatomic) GKSession *bluetoothSession;

@property (nonatomic) NSData * dataReceived;
@property (nonatomic) NSString *originOfData;
@property (nonatomic) GKSession *sessionReceived;
@property (nonatomic) void *context;

//@property (nonatomic) NSMutableArray *peersInSession;
@property (nonatomic) NSMutableArray *peersInGroup;


+ (BluetoothServices *)sharedBluetoothSession;

-(void) setUpWithSessionID:(NSString *)inputSessionID displayName:(NSString *)inputName sessionMode:(GKSessionMode)inputMode andContext:(void *)inputContext;

- (void) sendData:(void *)data toAll:(BOOL)shouldSendToAll;

-(NSMutableArray *) getPeersInSession;

@end
