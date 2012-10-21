//
//  TablePopUp.m
//  Ninja
//
//  Created by Jacob Hanshaw on 10/20/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import "TablePopUp.h"

@implementation TablePopUp

@synthesize serverTable, serversArray;

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.serverTable = [[UITableView alloc] init];
        self.serverTable.frame = CGRectMake(10, 10, self.frame.size.width-20, self.frame.size.height - 60);
        self.frame = frame;
        
        UIButton *refreshButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
        refreshButton.frame = CGRectMake(20, self.frame.size.height + 10, self.frame.size.width-40, 40);
        
        [refreshButton addTarget:self action:@selector(startSelected:) forControlEvents:UIControlEventTouchUpInside];
        [refreshButton setTitle:@"Refresh" forState:UIControlStateNormal];
        [self addSubview:refreshButton];
        [refreshButton setNeedsDisplay];
    }
    return self;
}

-(void) refresh:(id)sender{
    //call out to update data used to populate table then
    [serverTable reloadData];
}

#pragma mark PickerViewDelegate selectors

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
	return  [self.serversArray count]; //number of servers
}


// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
	static NSString *CellIdentifier = @"Cell";
	
    
	UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
	if(cell == nil) cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:nil];
    
    cell.textLabel.text = [self.serversArray objectAtIndex:indexPath.row];
    cell.textLabel.backgroundColor = [UIColor clearColor];
    cell.detailTextLabel.backgroundColor = [UIColor clearColor];
    
    if (indexPath.row % 2 == 0){
        cell.contentView.backgroundColor = [UIColor colorWithRed:233.0/255.0
                                                           green:233.0/255.0
                                                            blue:233.0/255.0
                                                           alpha:1.0];
    }
    
    else {
        cell.contentView.backgroundColor = [UIColor colorWithRed:200.0/255.0
                                                           green:200.0/255.0
                                                            blue:200.0/255.0
                                                           alpha:1.0];
    }
	return cell;
}



// Customize the height of each row
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
	return 60;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
	//use indexPath.row to know index of server selected
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
