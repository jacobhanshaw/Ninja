//
//  RootViewController.m
//  ProjectReality
//
//  Created by Jacob Hanshaw on 10/19/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import "RootViewController.h"


@implementation RootViewController

@synthesize startGame;

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
    
    [self.startGame setTitle:@"Start Game" forState:UIControlStateNormal];
    [self.startGame addTarget:self action:@selector(startGameSelected:) forControlEvents:UIControlEventTouchUpInside];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


-(void) startGameSelected:(id)sender{
    /*
    NetworkClientViewController *networkClientControllerA = [[NetworkClientViewController alloc] init];
    self.networkClientController = networkClientControllerA;
    [self presentViewController:self.networkClientController animated:YES completion:nil];
     */
    //ColorSelector *tempColor = [[ColorSelector alloc] initWithFrame:self.view.frame];
    //[self.view addSubview:tempColor];
    NewUIExampleViewController *test = [[NewUIExampleViewController alloc] init];
    [self presentViewController:test animated:YES completion:nil];
}


@end
