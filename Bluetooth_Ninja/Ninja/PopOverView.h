//
//  PopOverView.h
//  Ninja
//
//  Created by Jacob Hanshaw on 11/2/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>

@interface PopOverView : UIView {
        UILabel     IBOutlet *groupNameLabel;
        UITextField IBOutlet *groupNameInput;
        UILabel     IBOutlet *nameLabel;
        UITextField IBOutlet *nameInput;
        UIButton    IBOutlet *startGroup;
}

@property (nonatomic) UILabel     IBOutlet *groupNameLabel;
@property (nonatomic) UITextField IBOutlet *groupNameInput;
@property (nonatomic) UILabel     IBOutlet *nameLabel;
@property (nonatomic) UITextField IBOutlet *nameInput;
@property (nonatomic) UIButton    IBOutlet *startGroup;

@end
