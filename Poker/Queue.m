//
//  Queue.m
//  
//
//  Created by Admin on 07.08.15.
//
//

#import "Queue.h"

#define HEAD 0

@implementation Queue

- (id)nextObject {
    if (![self.mutableArray count]) return nil;
    
    id object = [self.mutableArray objectAtIndex:HEAD];
    [self.mutableArray removeObjectAtIndex:HEAD];
    
    return object;
}

- (void)addObject:(id)object {
    [self.mutableArray addObject:object];
}

- (instancetype)init {
    if(self = [super init]) {
        _mutableArray = [[NSMutableArray alloc] init];
        
    }
    
    return self;
}

- (BOOL)isQueueEmpty { return ![self.mutableArray count] ? YES : NO; }

@end
