//
//  TestViewController.m
//  Ninja
//
//  Created by Michael on 11/2/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()

@end

@implementation TestViewController

@synthesize screenTitle, peerTable, leave, start, refreshIcon, refreshIndicator;
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        host2 = false;
        NSLog(@"init");
        refreshIndicator.hidesWhenStopped = TRUE;
    }
    return self;
}

- (void)startViewWith:(BOOL)host
{
    if (host) {
        [screenTitle setText:@"Members:"];
        [leave setTitle:@"Main Menu" forState:UIControlStateNormal];
        [start setTitle:@"Start" forState:UIControlStateNormal];
    }
    else {
        [screenTitle setText:@"Groups:"];
        [start setHidden:TRUE];
        [leave setTitle:@"Main Menu" forState:UIControlStateNormal];
    }
    
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(refresh) userInfo:nil repeats:TRUE];
    [self refresh];
    
}

- (void)refresh
{
    NSLog(@"refresh");
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    host2 = !host2;
    [self startViewWith:host2];
}

- (void)updatePeersList:(NSArray *)peersList
{
    if (![tableViewInfo isEqualToArray:peersList]) {
        NSMutableArray *deletePaths = [[NSMutableArray alloc] init];
        NSMutableArray *insertPaths = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < [tableViewInfo count]; i++) {
            if (![peersList containsObject:[tableViewInfo objectAtIndex:i]]) {
                [deletePaths addObject:[NSIndexPath indexPathForRow:i inSection:1]];
            }
        }
        
        for (int i = 0; i < [peersList count]; i++) {
            if (![tableViewInfo containsObject:[peersList objectAtIndex:i]]) {
                [insertPaths addObject:[NSIndexPath indexPathForRow:i inSection:1]];
            }
        }
        
        tableViewInfo = [NSArray arrayWithArray:peersList];
        
        [peerTable beginUpdates];
        [peerTable deleteRowsAtIndexPaths:deletePaths withRowAnimation:UITableViewRowAnimationFade];
        [peerTable insertRowsAtIndexPaths:insertPaths withRowAnimation:UITableViewRowAnimationFade];
        [peerTable endUpdates];
    }

}

//TableView delegate

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *returnCell;
    if ((returnCell = [peerTable dequeueReusableCellWithIdentifier:@"group"]) == NULL) {
        returnCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"group"];
    }
    
    switch (indexPath.section) {
        case 0:
            returnCell.textLabel.text = tableViewInfo[indexPath.row];
            break;
            
        default:
            returnCell.textLabel.text = @"if you're reading this, something has gone horribly wrong";
            break;
    }
    
    return returnCell;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return [tableViewInfo count];
            break;
            
        default:
            return 0;
            break;
    }
}

//End table view delegate

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
