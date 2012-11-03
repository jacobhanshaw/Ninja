//
//  NetworkingViewController.m
//  Ninja
//
//  Created by Michael on 11/2/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import "NetworkingViewController.h"

@interface NetworkingViewController ()

@end

@implementation NetworkingViewController

@synthesize startView, startGroupButton, joinGroupButton, editProfileButton;
@synthesize semiTransparentOverlay, hostPopOver, clientPopOver;
@synthesize groupNameInput, groupNameLabel, nameInputHost, nameLabelHost, nameInputClient, nameLabelClient, hostGo;
@synthesize clientGo, screenTitle, peerTable, leave, start, refreshIcon, refreshIndicator; //Peer table view
@synthesize delegate;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
        refreshIndicator.hidesWhenStopped = TRUE;
        
        [self.view addSubview:startView];
        [self.view addSubview:semiTransparentOverlay];
        [self.view addSubview:clientPopOver];
        [self.view addSubview:hostPopOver];
        
        [clientPopOver.layer setCornerRadius:9.0];
        [hostPopOver.layer setCornerRadius: 9.0];
        
    }
    return self;
}

-(void) viewWillAppear:(BOOL)animated {
    [startView setHidden:NO];
    [semiTransparentOverlay setHidden:YES];
    [clientPopOver setHidden:YES];
    [hostPopOver setHidden:YES];
    
    [startGroupButton addTarget:self action:@selector(startGroupSelected:) forControlEvents:UIControlEventTouchUpInside];
    [joinGroupButton addTarget:self action:@selector(joinGroupSelected:) forControlEvents:UIControlEventTouchUpInside];
    [editProfileButton addTarget:self action:@selector(editProfileSelected:) forControlEvents:UIControlEventTouchUpInside];
}

#pragma mark Button Methods

- (void)startGroupSelected:(id)sender{
    [startView setHidden:YES];
    [semiTransparentOverlay setHidden:NO];
    [hostPopOver setHidden:NO];
    [self showPopOver:YES];
}

- (void)joinGroupSelected:(id)sender{
    [startView setHidden:YES];
    [semiTransparentOverlay setHidden:NO];
    [clientPopOver setHidden:NO];
    [self showPopOver:NO];
}

- (void)editProfileSelected:(id)sender{
    
}

- (void)showPopOver:(BOOL)host
{
    if (host) {
        nameInputHost.placeholder = [[UIDevice currentDevice] name];
        nameInputHost.textAlignment = NSTextAlignmentCenter;
        groupNameInput.placeholder = [[[[UIDevice currentDevice] name] componentsSeparatedByString:@"'"] objectAtIndex:0];
        groupNameInput.textAlignment = NSTextAlignmentCenter;
        [screenTitle setText:@"Members:"];
        [leave setTitle:@"Main Menu" forState:UIControlStateNormal];
        [start setTitle:@"Start" forState:UIControlStateNormal];
    }
    else {
        nameInputClient.placeholder = [[UIDevice currentDevice] name];
        nameInputClient.textAlignment = NSTextAlignmentCenter;
        [screenTitle setText:@"Groups:"];
        [start setHidden:TRUE];
        [leave setTitle:@"Main Menu" forState:UIControlStateNormal];
    }
    
    refreshTimer = [NSTimer scheduledTimerWithTimeInterval:5.0 target:self selector:@selector(refresh) userInfo:nil repeats:TRUE];
    [self refresh];
    
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField{
    
    [textField resignFirstResponder];
    
    return YES;
}


- (void)refresh
{
    NSLog(@"refresh");
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
