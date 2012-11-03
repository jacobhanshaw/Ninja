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
        UILabel     *groupNameLabel;
        UITextField *groupNameInput;
        UILabel     *nameLabel;
        UITextField *nameInput;
        UIButton    *startGroup;
}

@end
