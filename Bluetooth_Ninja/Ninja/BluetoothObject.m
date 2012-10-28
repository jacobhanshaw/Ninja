//
//  BluetoothObject.m
//  Ninja
//
//  Created by Jacob Hanshaw on 10/27/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import "BluetoothObject.h"

@implementation BluetoothObject

@synthesize receiveData, peer, session, context;

- (BluetoothObject *) initWithReceiveData:(NSData *)data peer:(NSString *)inputPeer session:(GKSession *)inputSession context:(void *)inputContext  {
    if (self = [super init]) {
		self.receiveData = data;
        self.peer = inputPeer;
        self.session = inputSession;
        self.context = inputContext;
    }
    return self;
}


@end
