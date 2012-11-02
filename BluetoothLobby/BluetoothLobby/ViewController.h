//
//  ViewController.h
//  BluetoothLobby
//
//  Created by Michael on 11/1/12.
//  Copyright (c) 2012 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NameInputView.h"
#import "NameInputProtocol.h"

#import "LobbyView.h"
#import "LobbyProtocol.h"
#import "NameEntryViewController.h"


@interface ViewController : UIViewController <NameInputProtocol, LobbyProtocol>

{
    NameEntryViewController *testController;
    
    NameInputView *nameView;
    LobbyView *lobbyView;
    
    NSMutableArray *peers, *groups;
    NSString *names[10];
    int namesCreated;
}

- (void)nameSelected:(NSString *)finalName;

@end
