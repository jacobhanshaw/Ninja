//
//  BluetoothServices.h
//  
//
//  Created by Jacob Hanshaw on 10/26/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//
// IMPORTANT!
// Please see:
// http://developer.apple.com/library/ios/#documentation/GameKit/Reference/GKSession_Class/Reference/Reference.html#//apple_ref/doc/uid/TP40008258 ,
//http://developer.apple.com/library/ios/#documentation/GameKit/Reference/GKSession_Class/Reference/Reference.html ,
// and
// http://developer.apple.com/library/ios/#DOCUMENTATION/GameKit/Reference/GKPeerPickerControllerDelegate_Protocol/Reference/Reference.html
// for Apple's documentation



#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

#define MAX_PLAYERS 8             //currently not used. Use if you want a max number of players.

@interface BluetoothServices : NSObject <GKSessionDelegate, GKPeerPickerControllerDelegate> {
    
    GKSession *bluetoothSession; //the bluetooth connection session
    
    NSData * dataReceived;        //the data received
    NSString *originOfData;       //the sender of the notification
    GKSession *sessionReceived;   //the bluetooth session that is that has received data
    void *context;                //data associated with the session upon set-up
    
    NSMutableArray *peersInSession; //all other devices in the session
    NSMutableArray *peersInGroup;   //list of devices to send data to
    NSMutableArray *peersBlocked;   //list of devices blocked from joining the session
    
    NSString *groupName;            //name of group
    NSString *personalName;         //name of individual (peer)
    
    NSString *connectionStateChangePeerID; //id of peer that last had a change of connection state
    
    BOOL hasNoPeers;                //Boolean to notice if this session is no longer connected to any peers
    
    int failedConnections;          //variable keeping track of the number of failed connections to prevent an infinite loop
                                    //could be more robust as it is not based on the number of failed connections to an certain peer
                                    //but rather the number of failed connections overall
    
}

@property (nonatomic) GKSession *bluetoothSession;

@property (nonatomic) NSData * dataReceived;
@property (nonatomic) NSString *originOfData;
@property (nonatomic) GKSession *sessionReceived;
@property (nonatomic) void *context;

@property (nonatomic) NSMutableArray *peersInGroup;


+ (BluetoothServices *)sharedBluetoothSession;

-(void) invalidateSession;

-(void) setUpWithSessionID:(NSString *)inputSessionID displayName:(NSString *)inputName sessionMode:(GKSessionMode)inputMode andContext:(void *)inputContext;

- (void) sendData:(NSData *)data toAll:(BOOL)shouldSendToAll; //peersInGroup is used as the list of peers to send data to, it toAll is NO
                                                              //so set peersInGroup (using some subset of peersInSession) before calling
                                                              //this function

-(void) setGroupName:(NSString *)newGroupName;
-(NSString *) getGroupName;

-(void) setPersonalName:(NSString *)newPersonalName;
-(NSString *) getPersonalName;

-(NSArray *) getPeersInSession; //connected peerIDs
-(NSArray *) getAvailablePeers; //available peerIDs

-(void) setPeersBlocked:(NSMutableArray *)newPeersBlocked;
-(NSMutableArray *) getPeersBlocked;

-(BOOL) getHasNoPeers;

@end
