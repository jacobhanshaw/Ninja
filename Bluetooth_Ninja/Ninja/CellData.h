//
//  CellData.h
//  Bluetooth API
//
//  Created by Michael on 11/9/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import <Foundation/Foundation.h>

enum icons {
    LOW,
    MEDIUM,
    HIGH,
    CROWN
}icons;

enum colors {
    RED,
    ORANGE,
    YELLOW,
    GREEN,
    CYAN,
    BLUE,
    PURPLE,
    MAGENTA
}colors;

@interface CellData : NSObject

{
    NSString *name;
    int score;
    enum icons iconLevel;
    enum colors colorSelection;
}

@property (nonatomic) NSString *name;
@property (assign) int score;
@property (assign) enum icons iconLevel;
@property (assign) enum colors colorSelection;

- (id)initWithColor:(enum colors)_color name:(NSString *)_name score:(int)_score andIcon:(enum icons)_iconLevel;

@end
