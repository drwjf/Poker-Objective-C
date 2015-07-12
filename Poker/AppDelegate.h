//
//  AppDelegate.h
//  Poker
//
//  Created by Admin on 20.04.15.
//  Copyright (c) 2015 by.bsuir.eLearning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ViewController.h"


@class GCDAsyncSocket;

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property(nonatomic,strong)dispatch_queue_t mainQueue;
@property(nonatomic,strong)GCDAsyncSocket *asyncSocket;

@property (strong, nonatomic) UIWindow *window;
@property(nonatomic,strong)ViewController *viewController;


@end

