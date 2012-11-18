//
//  IconQuestsButton.h
//  ARIS
//
//  Created by Jacob Hanshaw on 9/25/12.
//
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h> 

@interface ColorButton : UIButton{
    
    UIView *solidColorView;
    BOOL   hasTitle;
}

@property (nonatomic) UIView *solidColorView;

- (id)initWithFrame:(CGRect)inputFrame andImage:(UIColor *) inputColor;
- (id)initWithFrame:(CGRect)inputFrame andImage:(UIColor *) inputColor andTitle:(NSString *)inputTitle;

@end
