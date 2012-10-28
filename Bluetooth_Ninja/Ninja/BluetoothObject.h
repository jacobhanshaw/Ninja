//
//  BluetoothObject.h
//  Ninja
//
//  Created by Jacob Hanshaw on 10/27/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@interface BluetoothObject : NSObject  <GKSessionDelegate>  {
    NSData * receiveData;
    NSString *peer;
    GKSession *session;
    void *context;
}

@property (nonatomic) NSData * receiveData;
@property (nonatomic) NSString *peer;
@property (nonatomic) GKSession *session;
@property (nonatomic) void *context;

- (BluetoothObject *) initWithReceiveData:(NSData *)data peer:(NSString *)inputPeer session:(GKSession *)inputSession context:(void *)inputContext;

@end
