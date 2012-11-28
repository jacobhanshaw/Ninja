//
//  CellData.m
//  Bluetooth API
//
//  Created by Michael on 11/9/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import "PeerData.h"

@implementation PeerData

@synthesize colorSelection, name, score, iconLevel, peerID;

- (id)initWithColor:(enum colors)_color name:(NSString *)_name peerID:(NSString *)_peerID score:(int)_score andIcon:(enum icons)_iconLevel
{
    self = [super init];
    if (self) {
        
        colorSelection = _color;
        name = _name;
        peerID = _peerID;
        score = _score;
        iconLevel = _iconLevel;
    }
    
    return self;
}

- (id)initWithCoder:(NSCoder *)decoder {
    if (self = [super init]) {
        self.colorSelection = [decoder decodeIntForKey:@"colorSelection"];
        self.name = [decoder decodeObjectForKey:@"name"];
        self.peerID = [decoder decodeObjectForKey:@"peerID"];
        self.score = [decoder decodeIntForKey:@"score"];
        self.iconLevel = [decoder decodeIntForKey:@"iconLevel"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)encoder {
    [encoder encodeInt:colorSelection forKey:@"colorSelection"];
    [encoder encodeObject:name forKey:@"name"];
    [encoder encodeObject:peerID forKey:@"peerID"];
    [encoder encodeInt:score forKey:@"score"];
    [encoder encodeInt:iconLevel forKey:@"iconLevel"];
}

@end