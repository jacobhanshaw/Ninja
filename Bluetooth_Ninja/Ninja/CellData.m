//
//  CellData.m
//  Bluetooth API
//
//  Created by Michael on 11/9/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import "CellData.h"

@implementation CellData

@synthesize colorSelection, name, score, iconLevel;

- (id)initWithColor:(enum colors)_color name:(NSString *)_name score:(int)_score andIcon:(enum icons)_iconLevel
{
    self = [super init];
    if (self) {
        
        colorSelection = _color;
        name = _name;
        score = _score;
        iconLevel = _iconLevel;
    }
    
    return self;
}

@end
