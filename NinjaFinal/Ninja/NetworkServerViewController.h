//
//  NetworkServerViewController.h
//  Ninja
//
//  Created by Transition on 10/20/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import "NetworkingViewController.h"

@interface NetworkServerViewController : NetworkingViewController

{
    UILabel *membersInGame;
    int members;

}


-(void) colorSelected:(id)sender;
- (void)initiateGameStart;
- (void)playerLost;//:(int)index;

@end
