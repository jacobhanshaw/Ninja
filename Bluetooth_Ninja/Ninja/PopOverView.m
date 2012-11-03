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

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    return YES;
}

@end
