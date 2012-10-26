//
//  AppModel.h
//  Ninja
//
//  Created by Jacob Hanshaw on 10/26/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AppModel : NSObject {
    BOOL isServer;
}

@property(readwrite) BOOL isServer;

+ (AppModel *)sharedAppModel;

@end
