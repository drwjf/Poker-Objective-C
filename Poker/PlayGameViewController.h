//
//  PlayGameViewController.h
//  Poker
//
//  Created by Admin on 25.07.15.
//  Copyright (c) 2015 by.bsuir.eLearning. All rights reserved.
//

#import "ViewController.h"
#import "PlayGameViewController.h"

@interface PlayGameViewController : ViewController <ConnectionToServerDelegateForPlayGameVC>


@property (nonatomic) BOOL isUseAccelerometer;

@end
