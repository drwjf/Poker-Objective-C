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
@property (strong, nonatomic) NSTimer *gameViewTimer;


- (void)redrawGameTimerView:(NSTimer *)timer;

@end

@implementation ViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    
    _ipAdressTextField.text = @"192.168.1.6";
    _portTextField.text = @"9999";
    
    
    
    
    
#if !(TARGET_IPHONE_SIMULATOR)
    [SoundManager sharedManager].allowsBackgroundMusic = YES;
    [[SoundManager sharedManager] prepareToPlay];
    [[SoundManager sharedManager] playSound:@"JamesBond" looping:NO];
#endif
}

-(void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
}


- (IBAction)connectClickButton:(id)sender {
 
    ConnectionToServer *connection = [ConnectionToServer sharedInstance];
    [connection setParameters:_ipAdressTextField.text andPort:_portTextField.text];
    connection.delegateForRootVC = self;
    [connection connectToServer];
}


#pragma mark Connected
-(void)connected {
        [self.audioPlayer stop];
        [self performSegueWithIdentifier:@"segueToGamerDataVC" sender:self];
}


-(void)returnOnPreviusView {
    [[self alertWithError] show];
}

- (UIAlertView *)alertWithError{
    return([[UIAlertView alloc] initWithTitle:@"Error :("
                                          message:@"Check connection to WiFi and repeat again"
                                         delegate:self
                                cancelButtonTitle:@"OK"
                                otherButtonTitles:nil]);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
