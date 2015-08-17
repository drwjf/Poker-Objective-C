//
//  MessageFromGamersViewController.m
//  Poker
//
//  Created by Admin on 16.08.15.
//  Copyright (c) 2015 by.bsuir.eLearning. All rights reserved.
//

#import "MessageFromGamersViewController.h"

@interface MessageFromGamersViewController ()

@end

@implementation MessageFromGamersViewController

- (void)viewDidLoad {
    [super viewDidLoad];

}

- (void)addTextFiledAsSubview {
    UITextField *textFiled = [[UITextField alloc] initWithFrame:CGRectMake(self.view.frame.origin.x,
                                                                           self.view.frame.origin.y,
                                                                           self.view.frame.size.width,
                                                                           self.view.frame.size.height)];
    [textFiled setBackgroundColor:[UIColor colorWithRed:0.375 green:0.4 blue:0.8 alpha:1.0]];
    [textFiled setTextColor:[UIColor whiteColor]];
    [textFiled setTintColor:[UIColor whiteColor]];
    [textFiled setText:_message];
    [textFiled setEnabled:NO];
//    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(self.view.frame.origin.x, self.view.frame.origin.y, self.view.frame.size.width, self.view.frame.size.height)];
//    [label setBackgroundColor:[UIColor colorWithRed:0.375 green:0.6 blue:0.6 alpha:1.0]];
//    [label setTextColor:[UIColor whiteColor]];
//    [label setTintColor:[UIColor whiteColor]];
//    [label setText:_message];
//    
    
    
    [self.view addSubview:textFiled];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self addTextFiledAsSubview];
}

- (instancetype)initWithMessage:(NSString *)messsage {
    if(self = [super init]) {
        _message = messsage;
        
    }
    
    return self;
}


@end
