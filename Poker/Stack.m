//
//  Stack.m
//  Poker
//
//  Created by Admin on 06.08.15.
//  Copyright (c) 2015 by.bsuir.eLearning. All rights reserved.
//

#import "Stack.h"

@interface Stack ()

@end


@implementation Stack

- (void)push:(id)data { [self.mutableArray addObject:data]; }

- (NSData *)pope {
    if(![self.mutableArray count]) return nil;
    
    id data = [self.mutableArray lastObject];
    [self.mutableArray removeLastObject];
    
    return data;
}

- (BOOL)isEmpty { return ![self.mutableArray count]  ?  YES : NO; }

- (void)clearStack { self.mutableArray = nil; }

- (instancetype)init {
    if(self = [super init]) {
        self.mutableArray = [[NSMutableArray alloc] init];
    }
    
    return self;
}

@end
