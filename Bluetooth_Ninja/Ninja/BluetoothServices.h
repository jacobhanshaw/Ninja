//
//  BluetoothServices.h
//  
//
//  Created by Jacob Hanshaw on 10/26/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>
#import "BluetoothObject.h"

#define SESSION_ID @"ninja" //PUT YOUR UNIQUE SESSION ID HERE
#define MAX_PLAYERS 7

@interface BluetoothServices : NSObject <GKSessionDelegate> {
    
    GKSession *bluetoothSession; //the bluetooth connection session
    
    NSData * receiveData; //the data received
    NSString *peer;       //the sender of the notification
    GKSession *session;   //the bluetooth session that is that has received data
    void *context;        //NEEDS MORE DOCUMENTATION
    
    
    UILabel *clientInstructions;
    
    NSString *myPeerID; //Created here
    NSMutableArray *peersInGroup; //Created in subclass
    GKSessionMode myMode; //Created in subclass
    
}

@property (nonatomic) GKSession *bluetoothSession;

@property (nonatomic) NSData * receiveData;
@property (nonatomic) NSString *peer;
@property (nonatomic) GKSession *session;
@property (nonatomic) void *context;

+ (BluetoothServices *)sharedBluetoothServices;

- (void)sendData:(void *)data;

@end
