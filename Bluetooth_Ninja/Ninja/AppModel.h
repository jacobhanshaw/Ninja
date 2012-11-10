//
//  AppModel.h
//  Ninja
//
//  Created by Jacob Hanshaw on 10/26/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import <Foundation/Foundation.h>

//#define SESSION_ID @"ninja" //PUT YOUR UNIQUE SESSION ID HERE

@interface AppModel : NSObject {
    BOOL isFirstUse;
    BOOL isServer;
    
    int originalPlayers;
    int livePlayers;
    
    BOOL playerHasDied;
}

@property(readwrite) BOOL isServer;
@property(readwrite) BOOL isFirstUse;
@property(readwrite) int originalPlayers;
@property(readwrite) int livePlayers;
@property(readwrite) BOOL playerHasDied;

+ (AppModel *)sharedAppModel;

@end
