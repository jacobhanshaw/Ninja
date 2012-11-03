//
//  LobbyView.h
//  BluetoothLobby
//
//  Created by Michael on 11/1/12.
//  Copyright (c) 2012 Michael. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LobbyView : UIView <UITableViewDataSource, UITableViewDelegate>

{
    UILabel *header;
    NSString *name;
    
    UILabel *autoResfresh;
    
    NSArray *groups;
    NSArray *peers;
    
    UITableView *lobbyInfo;
    
    UIView *obscurer;
    
    UIActivityIndicatorView *searching;
    UISwitch *autoSearchSwitch;
    NSTimer *searchTimer;
}

@property (assign) id delegate;

- (id)initWithFrame:(CGRect)frame andName:(NSString *)_name;
- (void)setName:(NSString *)_name;

- (void)updateLobbyWithGroups:(NSArray *)_groups andPeers:(NSArray *)_peers;
- (void)search;
- (void)toggleAutoSearch;
@end
