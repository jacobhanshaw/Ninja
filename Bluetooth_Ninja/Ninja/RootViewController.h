//
//  RootViewController.h
//  ProjectReality
//
//  Created by Jacob Hanshaw on 10/19/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppModel.h"
#import "GameViewController.h"
#import "ColorSelector.h"
#import "NetworkingViewController.h"
#import "NetworkingViewControllerDelegate.h"

@interface RootViewController : UIViewController <NetworkingViewControllerDelegate> {
    
    NetworkingViewController *test;
    UIButton *startGame;
    
}

@property(nonatomic) IBOutlet UIButton *startGame;

+ (RootViewController *)sharedRootViewController;

@end
