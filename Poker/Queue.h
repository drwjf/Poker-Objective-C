//
//  Queue.h
//  
//
//  Created by Admin on 07.08.15.
//
//

#import <Foundation/Foundation.h>

@interface Queue : NSObject

@property(nonatomic, strong)NSMutableArray *mutableArray;

- (id)nextObject;
- (void)addObject:(id)object;
- (BOOL)isQueueEmpty;

- (instancetype)init;

@end
