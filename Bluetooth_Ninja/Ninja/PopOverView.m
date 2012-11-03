//
//  PopOverView.m
//  Ninja
//
//  Created by Jacob Hanshaw on 11/2/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import "PopOverView.h"

@implementation PopOverView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setup];
    }
    return self;
}


- (void)setup {
    // probably requires custom animation, but can change self.modalTransitionStyle beforehand
    UIImageView *backgroundImage = [[UIImageView alloc] initWithImage:[self screenshot]];
    [self addSubview:backgroundImage];
    UIView *solidColorView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
    solidColorView.backgroundColor = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.5];
    [self addSubview:solidColorView];
    int tenPercentOfFrameWidth = self.frame.size.width/10;
    int tenPercentOfFrameHeight = self.frame.size.height/10;
    UIView *roundedRectView = [[UIView alloc] initWithFrame:CGRectMake((tenPercentOfFrameWidth/2), (tenPercentOfFrameHeight/2), (self.frame.size.width - tenPercentOfFrameWidth), (self.frame.size.height - tenPercentOfFrameHeight))];
    [roundedRectView.layer setCornerRadius:9.0];
    roundedRectView.layer.borderColor = [UIColor grayColor].CGColor;
    roundedRectView.layer.borderWidth = 3.0f;
    roundedRectView.backgroundColor = [UIColor blackColor];
    [self addSubview:roundedRectView];
    
    groupNameLabel.text = @"Group Name";
    groupNameLabel.frame = CGRectMake(self.frame.size.width/4, self.frame.size.height/4, self.frame.size.width/2, self.frame.size.height/4);
    [self addSubview:groupNameLabel];
    
    groupNameInput.placeholder = [[[[UIDevice currentDevice] name] componentsSeparatedByString:@"'"] objectAtIndex:0];
    groupNameInput.textAlignment = NSTextAlignmentCenter;
    groupNameInput.frame = CGRectMake(self.frame.size.width/4, self.frame.size.height/4, self.frame.size.width/2, self.frame.size.height/4);
    [self addSubview:groupNameInput];
    
    nameLabel.text = @"Your Name";
    nameLabel.frame = CGRectMake(self.frame.size.width/4, self.frame.size.height/4, self.frame.size.width/2, self.frame.size.height/4);
    [self addSubview:nameLabel];
    
    nameInput.placeholder = [[UIDevice currentDevice] name];
    nameInput.textAlignment = NSTextAlignmentCenter;
    nameInput.frame = CGRectMake(self.frame.size.width/4, self.frame.size.height/4, self.frame.size.width/2, self.frame.size.height/4);
    [self addSubview:nameInput];
}

- (UIImage*)screenshot
{
    // Create a graphics context with the target size
    // On iOS 4 and later, use UIGraphicsBeginImageContextWithOptions to take the scale into consideration
    // On iOS prior to 4, fall back to use UIGraphicsBeginImageContext
    CGSize imageSize = [[UIScreen mainScreen] bounds].size;
    if (NULL != UIGraphicsBeginImageContextWithOptions)
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, 0);
    else
        UIGraphicsBeginImageContext(imageSize);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Iterate over every window from back to front
    for (UIWindow *window in [[UIApplication sharedApplication] windows])
    {
        if (![window respondsToSelector:@selector(screen)] || [window screen] == [UIScreen mainScreen])
        {
            // -renderInContext: renders in the coordinate space of the layer,
            // so we must first apply the layer's geometry to the graphics context
            CGContextSaveGState(context);
            // Center the context around the window's anchor point
            CGContextTranslateCTM(context, [window center].x, [window center].y);
            // Apply the window's transform about the anchor point
            CGContextConcatCTM(context, [window transform]);
            // Offset by the portion of the bounds left of and above the anchor point
            CGContextTranslateCTM(context,
                                  -[window bounds].size.width * [[window layer] anchorPoint].x,
                                  -[window bounds].size.height * [[window layer] anchorPoint].y);
            
            // Render the layer hierarchy to the current context
            [[window layer] renderInContext:context];
            
            // Restore the context
            CGContextRestoreGState(context);
        }
    }
    
    // Retrieve the screenshot image
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    
    UIGraphicsEndImageContext();
    
    return image;
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    return YES;
}

@end
