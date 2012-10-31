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
#import "NetworkServerViewController.h"
#import "NetworkClientViewController.h"
#import "NewUIExampleViewController.h"
#import "ColorSelector.h"

@interface RootViewController : UIViewController{
    
    UIButton *host;
    UIButton *find;
    NetworkServerViewController *networkServerController;
    NetworkClientViewController *networkClientController;
    
}

@property(nonatomic) IBOutlet UIButton *host;
@property(nonatomic) IBOutlet UIButton *find;
@property(nonatomic) NetworkServerViewController *networkServerController;
@property(nonatomic) NetworkClientViewController *networkClientController;

+ (RootViewController *)sharedRootViewController;

@end
