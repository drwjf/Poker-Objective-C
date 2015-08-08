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
- (BOOL)isObjectNSNumber:(id)object;
- (BOOL)isObjectNSString:(id)object;
@end

@implementation JSONParser

- (instancetype)init {
    self = [super init];

    return self;
}

- (NSData *)convertNSDictionaryToJSONdata:(NSDictionary*)data
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

- (NSDictionary *)convertJSONdataToNSDictionary:(NSData *)data {
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

- (BOOL)isObjectNSNumber:(id)object { return [object isKindOfClass:[NSNumber class]] ? YES : NO; }
- (BOOL)isObjectNSString:(id)object { return [object isKindOfClass:[NSString class]] ? YES : NO; }


- (NSNumber *)getNSNumberWithObject:(id)object
{
    if ([self isObjectNSNumber:object])
        return (NSNumber *)object;
    else {
        [NSException raise:@"object is not at NSNumber " format:@"object %@ is not a NSNumber", object];
        return nil;
    }
}

- (NSString *)getNSStringWithObject:(id)object
{
    if ([self isObjectNSString:object])
        return (NSString *)object;
    else {
        [NSException raise:@"object is not at NSString " format:@"object %@ is not a NSString", object];
        return nil;
    }
}

- (Gamer *)parseGamerJSONData:(NSDictionary *)dictionary
{
    return [Gamer alloc];
}

@end
