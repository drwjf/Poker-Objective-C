//
//  Stack.h
//  Poker
//
//  Created by Admin on 06.08.15.
//  Copyright (c) 2015 by.bsuir.eLearning. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Stack : NSObject

@property(nonatomic, strong)NSMutableArray *mutableArray;

- (void)push:(id)data;
- (id)pope;
- (BOOL)isEmpty;
- (void)clearStack;

- (instancetype)init;


@end
