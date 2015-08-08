//
//  JSONParser.h
//  Poker
//
//  Created by Admin on 08.08.15.
//  Copyright (c) 2015 by.bsuir.eLearning. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface JSONParser : NSObject

- (instancetype)init;

+ (NSData *)convertNSDictionaryToJSONdata:(NSDictionary*)data;
+ (NSDictionary *)convertJSONdataToNSDictionary:(NSData *)data;

+ (NSNumber *)getNSNumberWithObject:(id)object;
+ (NSString *)getNSStringWithObject:(id)object;
+ (NSDictionary *)getNSDictionaryWithObject:(id)object;
+ (BOOL)getBOOLValueWithObject:(id)object;

@end
