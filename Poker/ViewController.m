//
//  ViewController.m
//  Poker
//
//  Created by Admin on 20.04.15.
//  Copyright (c) 2015 by.bsuir.eLearning. All rights reserved.
//

#import "ViewController.h"
#import "GamerDataViewController.h"
#import "SoundManager.h"

@interface ViewController () 

@property(nonatomic,strong)UIAlertView *myAlert;
-(void)initAlertWithError;
-(void)initAlertWithSuccess;

@property(nonatomic)BOOL firstStart;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    _myAlert = nil;
    _firstStart = YES;
    //to do there
    
#if !(TARGET_IPHONE_SIMULATOR)
    [[UIAccelerometer sharedAccelerometer]setDelegate:self];
    
    [SoundManager sharedManager].allowsBackgroundMusic = YES;
    [[SoundManager sharedManager] prepareToPlay];
    [[SoundManager sharedManager] playSound:@"JamesBond" looping:NO];
#endif
}

- (IBAction)connectClickButton:(id)sender {
 
    ConnectionToServer *connection = [ConnectionToServer sharedInstance];
    [connection setParameters:_ipAdressTextField.text andPort:_portTextField.text];
    connection.delegate=self;
    [connection connectToServer];
}


#pragma mark Connected
-(void)connected {
        [self.audioPlayer stop];
        [self performSegueWithIdentifier:@"MySegue" sender:self];
}


-(void)returnOnPreviusView {
    [self initAlertWithError];
    [_myAlert show];
}

-(void)initAlertWithError{
    _myAlert = [[UIAlertView alloc] initWithTitle:@"Error :("
                                          message:@"Check connection to WiFi and repeat again"
                                         delegate:self
                                cancelButtonTitle:@"OK"
                                otherButtonTitles:nil];
}

-(void)initAlertWithSuccess{
    _myAlert =[[UIAlertView alloc] initWithTitle:@"Success ! ;)"
                                         message:@"Right now you go to next page."
                                        delegate:self
                               cancelButtonTitle:@"OK"
                               otherButtonTitles:nil];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
