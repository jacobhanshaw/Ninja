//
//  NameInputView.h
//  BluetoothLobby
//
//  Created by Michael on 11/1/12.
//  Copyright (c) 2012 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NameInputProtocol.h"

@interface NameInputView : UIView <UITextFieldDelegate>

{
    UITextField *nameInput;
    UIButton *enterLobby;
    UILabel *instrctions;
}

@property (assign) id delegate;

- (id)initWithFrame:(CGRect)frame andDefaultName:(NSString *)name;
- (void)joinLobby;

@end
