//
//  TablePopUp.h
//  Ninja
//
//  Created by Jacob Hanshaw on 10/20/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TablePopUp : UIView {
    UITableView *serverTable;
    NSMutableArray *serversArray;
}

@property(nonatomic) UITableView *serverTable;
@property(nonatomic) NSMutableArray *serversArray;

@end
