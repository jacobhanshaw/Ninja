//
//  ColorSelector.m
//  Ninja
//
//  Created by Michael on 10/20/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import "ColorSelector.h"

@implementation ColorSelector

- (id)initWithFrame:(CGRect)frame// withOwner:(id) theOwner
{
    self = [super initWithFrame:frame];
    
    //owner = theOwner;
    
    UIButton *startButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    startButton.frame = CGRectMake(40, 400, 240, 60);
    
    [startButton addTarget:self.superview action:@selector(startSelected:) forControlEvents:UIControlEventTouchUpInside];
    [startButton setTitle:@"Start Game" forState:UIControlStateNormal];
    [self addSubview:startButton];
    [startButton setNeedsDisplay];
    
    [self createIcons];
    
    return self;
}

-(void) createIcons{
    for(int i = 0; i < 8; i++){
        int xMargin = truncf((self.frame.size.width - ICONSPERROW * ICONWIDTH)/(ICONSPERROW +1));
        int yMargin = xMargin;
        int row = (i/ICONSPERROW);
        int xOrigin = (i % ICONSPERROW) * (xMargin + ICONWIDTH) + xMargin;
        int yOrigin = row * (yMargin + ICONHEIGHT) + yMargin;
        
        float hue;
        
        switch(i){
            case 0: hue = 0;
                break;
            case 1: hue = 38;
                break;
            case 2: hue = 60;
                break;
            case 3: hue = 105;
                break;
            case 4: hue = 175;
                break;
            case 5: hue = 224;
                break;
            case 6: hue = 275;
                break;
            case 7: hue = 320;
                break;
        }
        
        hue = hue/360;
        
        UIColor *iconColor = [[UIColor alloc] initWithHue:hue saturation: 1 brightness:1 alpha:1];
        
        ColorButton *colorButton = [[ColorButton alloc] initWithFrame:CGRectMake(xOrigin, yOrigin, ICONWIDTH, ICONHEIGHT) andImage:iconColor andTitle:@"Untaken"];
        colorButton.solidColorView.layer.cornerRadius = 9.0;
        colorButton.solidColorView.layer.masksToBounds = YES;
        colorButton.tag = i;
        [colorButton addTarget:self.superview action:@selector(colorSelected:) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:colorButton];
        [colorButton setNeedsDisplay];
    }
}

-(void) colorSelected:(id)sender{
    
}

-(void) startSelected:(id)sender{
    //    UIButton *button = (UIButton*)sender;
    
}


@end
