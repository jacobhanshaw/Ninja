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
// for Apple's documentation

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@interface BluetoothServices : NSObject <GKSessionDelegate> {
    
    GKSession *bluetoothSession; //the bluetooth connection session
    
    NSString *sessionID;         //unique string identifying session
    NSString *name;              //unique string identifying the individual device within the session
    GKSessionMode mode;          //GKSessionModeServer, GKSessionModeClient, or GKSessionModePeer
                                 //which makes this device a server, client, or both
    
    NSData * dataReceived;        //the data received
    NSString *originOfData;       //the sender of the notification
    GKSession *sessionReceived;   //the bluetooth session that is that has received data
    void *context;                //data associated with the session upon set-up
    
    NSMutableArray *peersInSession; //all other devices in the session
    NSMutableArray *peersInGroup;   //list of devices to send data to
    
    
    
  //  UILabel *clientInstructions;
    
  //  NSString *myPeerID; //Created here
  //  NSMutableArray *peersInGroup; //Created in subclass
   // GKSessionMode myMode; //Created in subclass
    
}

@property (nonatomic) GKSession *bluetoothSession;

@property (nonatomic) NSString *sessionID;
@property (nonatomic) NSString *name;
@property (nonatomic) GKSessionMode mode;

@property (nonatomic) NSData * dataReceived;
@property (nonatomic) NSString *originOfData;
@property (nonatomic) GKSession *sessionReceived;
@property (nonatomic) void *context;

@property (nonatomic) NSMutableArray *peersInSession;
@property (nonatomic) NSMutableArray *peersInGroup;


+ (BluetoothServices *)sharedBluetoothServices;

-(void) setUpWithSessionID:(NSString *)inputSessionID displayName:(NSString *)inputName sessionMode:(GKSessionMode)inputMode andContext:(void *)inputContext;

- (void) sendData:(void *)data toAll:(BOOL)shouldSendToAll;

//-(NSMutableArray *) getPeersInSession;

@end
