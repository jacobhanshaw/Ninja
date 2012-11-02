//
//  LobbyView.m
//  BluetoothLobby
//
//  Created by Michael on 11/1/12.
//  Copyright (c) 2012 Michael. All rights reserved.
//

#import "LobbyView.h"

@implementation LobbyView

@synthesize delegate;

- (id)initWithFrame:(CGRect)frame andName:(NSString *)_name
{
    self = [super initWithFrame:frame];
    if (self) {
        peers = [NSArray array];//WithObjects:test2 count:5];
        groups = [NSArray array];//]WithObjects:test count:1];
        
        obscurer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.frame.size.width, self.frame.size.height)];
        [obscurer setBackgroundColor:[UIColor blackColor]];
        [obscurer setAlpha:0.75];
        name = _name;
        [self setBackgroundColor:[UIColor grayColor]];
        header = [[UILabel alloc] initWithFrame:CGRectMake(10, 10, 400, 20)];
        header.text = [NSString stringWithFormat:@"In Lobby As: %@", name];
        header.opaque = FALSE;
        header.backgroundColor = [UIColor clearColor];
        [self addSubview:header];
        
        lobbyInfo = [[UITableView alloc] initWithFrame:CGRectMake(10, 40, self.frame.size.width - 20, self.frame.size.height - 80) style:UITableViewStyleGrouped];
        lobbyInfo.delegate = self;
        lobbyInfo.dataSource = self;
        [self addSubview:lobbyInfo];
        
        autoSearchSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(170, 410, 0, 0)];
        autoSearchSwitch.on = FALSE;
        [autoSearchSwitch addTarget:self action:@selector(toggleAutoSearch) forControlEvents:UIControlEventValueChanged];
        [autoSearchSwitch sendActionsForControlEvents:UIControlEventValueChanged];
        [self addSubview:autoSearchSwitch];
        
        searching = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        searching.color = [UIColor magentaColor];
        searching.center = CGPointMake(285, 425);
        searching.hidesWhenStopped = FALSE;
        [self addSubview:searching];
        
        autoResfresh = [[UILabel alloc] initWithFrame:CGRectMake(20, 400, 150, 40)];
        [autoResfresh setBackgroundColor:[UIColor clearColor]];
        [autoResfresh setOpaque:FALSE];
        [autoResfresh setText:@"Automatic Search"];
        [self addSubview:autoResfresh];
        
        [self addSubview:obscurer];
        // Initialization code
    }
    return self;
}

- (void)toggleAutoSearch
{
    if (autoSearchSwitch.on) {
        [self search];
        searchTimer = [NSTimer scheduledTimerWithTimeInterval:0.1 target:self selector:@selector(search) userInfo:nil repeats:TRUE];
        [searching startAnimating];
    }
    else {
        [searching stopAnimating];
        [searchTimer invalidate];
        
    }
}

- (void)search
{
    [delegate refreshLobby];
}

- (void)setName:(NSString *)_name
{
    name = _name;
    header.text = [NSString stringWithFormat:@"In Lobby As: %@", name];
    [UIView animateWithDuration:0.5 animations:^(void) {
        [obscurer setAlpha:0.0];
    } completion:^(BOOL finished) {
    [obscurer setHidden:TRUE];
    }];
    [autoSearchSwitch setOn:TRUE animated:TRUE];
    [self toggleAutoSearch];
}

- (void)updateLobbyWithGroups:(NSArray *)_groups andPeers:(NSArray *)_peers
{
    
    
    if (![groups isEqualToArray:_groups]) {
        //NSLog(@"edit groups");
        NSMutableArray *deletePaths = [[NSMutableArray alloc] init];
        NSMutableArray *insertPaths = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < [groups count]; i++) {
            if (![_groups containsObject:[groups objectAtIndex:i]]) {
                [deletePaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
        }
        
        for (int i = 0; i < [_groups count]; i++) {
            if (![groups containsObject:[_groups objectAtIndex:i]]) {
                [insertPaths addObject:[NSIndexPath indexPathForRow:i inSection:0]];
            }
        }
        
        groups = [NSArray arrayWithArray:_groups];
        
        [lobbyInfo beginUpdates];
        [lobbyInfo deleteRowsAtIndexPaths:deletePaths withRowAnimation:UITableViewRowAnimationFade];
        [lobbyInfo insertRowsAtIndexPaths:insertPaths withRowAnimation:UITableViewRowAnimationFade];
        [lobbyInfo endUpdates];
    }
    if (![peers isEqualToArray:_peers]) {
        //NSLog(@"edit peers");
        NSMutableArray *deletePaths = [[NSMutableArray alloc] init];
        NSMutableArray *insertPaths = [[NSMutableArray alloc] init];
        
        for (int i = 0; i < [peers count]; i++) {
            if (![_peers containsObject:[peers objectAtIndex:i]]) {
                [deletePaths addObject:[NSIndexPath indexPathForRow:i inSection:1]];
            }
        }
        
        for (int i = 0; i < [_peers count]; i++) {
            if (![peers containsObject:[_peers objectAtIndex:i]]) {
                [insertPaths addObject:[NSIndexPath indexPathForRow:i inSection:1]];
            }
        }
        
        peers = [NSArray arrayWithArray:_peers];
        
        [lobbyInfo beginUpdates];
        [lobbyInfo deleteRowsAtIndexPaths:deletePaths withRowAnimation:UITableViewRowAnimationFade];
        [lobbyInfo insertRowsAtIndexPaths:insertPaths withRowAnimation:UITableViewRowAnimationFade];
        [lobbyInfo endUpdates];    }
    [lobbyInfo reloadSectionIndexTitles];
    
   /* NSLog(@"lobbygroups");
    for (NSString *s in groups) {
        NSLog(@"%@\n",s);
    }
    
    NSLog(@"lobbypeers");
    for (NSString *s in peers) {
        NSLog(@"%@\n",s);
    }*/
}



//TableView delegate methods

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (autoSearchSwitch.on) {
        [autoSearchSwitch setOn:FALSE animated:TRUE];
        [self toggleAutoSearch];
    }
    
    [obscurer setHidden:FALSE];
    [UIView animateWithDuration:0.5 animations:^(void) {
        [obscurer setAlpha:0.750];
    } completion:^(BOOL finished) {
        
    }];}

//DataSource delegate methods

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *returnCell;
    if ((returnCell = [lobbyInfo dequeueReusableCellWithIdentifier:@"group"]) == NULL) {
        returnCell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"group"];
    }
    
    switch (indexPath.section) {
        case 0:
            returnCell.textLabel.text = groups[indexPath.row];
            break;
            
        case 1:
            returnCell.textLabel.text = peers[indexPath.row];
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
            return [groups count];
            break;
            
        case 1:
            return [peers count];
            break;
            
        default:
            return 0;
            break;
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Groups:";
            /*if ([groups count] == 1) {
                return @"1 Group Available:";
            }
            return [NSString stringWithFormat:@"%i Groups Available:", [groups count]];*/
            break;
            
        case 1:
            return @"People in Lobby";
            /*if ([peers count] == 1){
                return @"1 Other Person in Lobby:";
            }
            return [NSString stringWithFormat:@"%i Other People in Lobby:", [peers count]];*/
            break;
            
        default:
            return NULL;
            break;
    }
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
