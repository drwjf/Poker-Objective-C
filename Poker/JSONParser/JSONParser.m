//
//  JSONParser.m
//  Poker
//
//  Created by Admin on 08.08.15.
//  Copyright (c) 2015 by.bsuir.eLearning. All rights reserved.
//

#import "JSONParser.h"
#import "Gamer.h"

@interface JSONParser ()

@end

@implementation JSONParser

- (instancetype)init {
    if(self = [super init]) {
        //do something ...
    }
    
    return self;
}

+ (NSData *)convertNSDictionaryToJSONdata:(NSDictionary*)data
{
    NSError *error = nil;
    
    if([NSJSONSerialization isValidJSONObject:data]) {
        
        NSData *json = [NSJSONSerialization dataWithJSONObject:data options:NSJSONWritingPrettyPrinted error:&error];
        if (json != nil && error == nil) {
            NSLog(@"JSON info : %@", [[NSString alloc] initWithData:json encoding:NSUTF8StringEncoding]);
            return json;
        }
    }
    return nil;
}

+ (NSDictionary *)convertJSONdataToNSDictionary:(NSData *)data {
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if(error) {
        NSLog(@"Error of NSJSONSerialization !");
        [NSException raise:@"Error of NSJSONSerialize" format:@"object is not json !"];
    }
    
    if([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = object;
        return dictionary;
    } else {
        return nil;
    }
}


+ (NSNumber *)getNSNumberWithObject:(id)object{
    if ([object isKindOfClass:[NSNumber class]])
        return (NSNumber *)object;
    else {
        [NSException raise:@"object is not at NSNumber " format:@"object %@ is not a NSNumber", object];
        return nil;
    }
}
+ (NSString *)getNSStringWithObject:(id)object{
    if ([object isKindOfClass:[NSString class]])
        return (NSString *)object;
    else {
        [NSException raise:@"object is not at NSString " format:@"object %@ is not a NSString", object];
        return nil;
    }
}
+ (NSDictionary *)getNSDictionaryWithObject:(id)object {
    if([object isKindOfClass:[NSDictionary class]]) {
        return (NSDictionary *)object;
    } else
        [NSException raise:@"Object is not a NSDictionary !" format:@"object %@ a NSDictionary", object];
        return nil;
}

+ (BOOL)getBOOLValueWithObject:(id)object {
    if ([object isKindOfClass:[NSNumber class]])
        return [(NSNumber *)object boolValue];
    else {
        [NSException raise:@"object is not at NSNumber " format:@"object %@ is not a NSNumber", object];
        return NO;
    }
}


- (Gamer *)parseGamerJSONData:(NSDictionary *)dictionary
{
    return [Gamer alloc];
}

@end
