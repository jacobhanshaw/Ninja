//
//  NameInputView.m
//  BluetoothLobby
//
//  Created by Michael on 11/1/12.
//  Copyright (c) 2012 Michael. All rights reserved.
//

#import "NameInputView.h"

@implementation NameInputView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame andDefaultName:(NSString *)name
{
    self = [super initWithFrame:frame];
    if (self) {
        [self setBackgroundColor:[UIColor blueColor]];
        
        instrctions = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 400, 50)];
        [instrctions setBackgroundColor:[UIColor clearColor]];
        [instrctions setOpaque:FALSE];
        [instrctions setText:[NSString stringWithFormat:@"Enter name:"]];
        [self addSubview:instrctions];
        
        nameInput = [[UITextField alloc] initWithFrame:CGRectMake(0, 50, 150, 50)];
        nameInput.delegate = self;
        nameInput.enablesReturnKeyAutomatically = TRUE;
        nameInput.returnKeyType = UIReturnKeyJoin;
        [nameInput setText:name];
        [nameInput setBackgroundColor:[UIColor whiteColor]];
        [self addSubview:nameInput];
        
        enterLobby = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        [enterLobby setCenter:CGPointMake(200, 75)];
        [enterLobby addTarget:self action:@selector(joinLobby) forControlEvents:UIControlEventTouchUpInside];
        [self addSubview:enterLobby];
        
        // Initialization code
    }
    return self;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    [self joinLobby];
    return TRUE;
}

- (void)joinLobby
{
    [nameInput resignFirstResponder];
    [delegate nameSelected:nameInput.text];
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
