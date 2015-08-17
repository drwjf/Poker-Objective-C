//
//  UDPConnection.h
//  Poker
//
//  Created by Admin on 30.07.15.
//  Copyright (c) 2015 by.bsuir.eLearning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncUdpSocket.h"


@protocol UDPConnectionDelegates
@required
- (void)updateUIWithMessageFromGamer:(NSDictionary *)dictionary;
@end

@interface UDPConnection : NSObject <GCDAsyncUdpSocketDelegate>



@property(assign, nonatomic) id<UDPConnectionDelegates> delegate;
@property(strong, nonatomic)GCDAsyncUdpSocket *asyncSocket;


+ (id)sharedInstance;
- (void)sendDataWithTag:(NSData *)jsonData andIP:(NSString *)host andUdpPort:(uint16_t)port;
- (void)bindSocket;
- (uint16_t)getLocalUDPport;

@end
