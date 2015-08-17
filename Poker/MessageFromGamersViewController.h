//
//  MessageFromGamersViewController.h
//  Poker
//
//  Created by Admin on 16.08.15.
//  Copyright (c) 2015 by.bsuir.eLearning. All rights reserved.
//

#import "ViewController.h"

@interface MessageFromGamersViewController : ViewController

@property(strong, nonatomic) NSString *message;

- (instancetype)initWithMessage:(NSString *)messsage;

@end
