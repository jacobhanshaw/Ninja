//
//  RootViewController.m
//  ProjectReality
//
//  Created by Jacob Hanshaw on 10/19/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import "RootViewController.h"


@implementation RootViewController

@synthesize host, find, networkServerController, networkClientController;

+ (id)sharedRootViewController
{
    static dispatch_once_t pred = 0;
    __strong static id _sharedObject = nil;
    dispatch_once(&pred, ^{
        _sharedObject = [[self alloc] initWithFrame:[UIScreen mainScreen].bounds];//[UIScreen mainScreen].bounds]; // or some other init method
    });
    return _sharedObject;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super init];
    if (self) {
        self.view.frame = frame;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [[UIApplication sharedApplication] setStatusBarHidden:YES withAnimation:UIStatusBarAnimationNone];
    
    [self.host setTitle:@"Start Group" forState:UIControlStateNormal];
    [self.host addTarget:self action:@selector(hostButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.find setTitle:@"Join Group" forState:UIControlStateNormal];
    [self.find addTarget:self action:@selector(findButtonSelected:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) hostButtonSelected:(id)sender{
    [AppModel sharedAppModel].isServer = YES;
    NetworkServerViewController *networkServerControllerA = [[NetworkServerViewController alloc] init];
    self.networkServerController = networkServerControllerA;
    [self presentViewController:self.networkServerController animated:YES completion:nil];
}

-(void) findButtonSelected:(id)sender{
    [AppModel sharedAppModel].isServer = NO;
    
    NetworkClientViewController *networkClientControllerA = [[NetworkClientViewController alloc] init];
    self.networkClientController = networkClientControllerA;
    [self presentViewController:self.networkClientController animated:YES completion:nil];
     /*
    ColorSelector *tempColor = [[ColorSelector alloc] initWithFrame:self.view.frame];
    [self.view addSubview:tempColor]; */
}


@end
