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
#import "NewUIExampleViewController.h"
#import "ColorSelector.h"

@interface RootViewController : UIViewController{
    
    UIButton *startGame;
    
}

@property(nonatomic) IBOutlet UIButton *startGame;

+ (RootViewController *)sharedRootViewController;

@end
