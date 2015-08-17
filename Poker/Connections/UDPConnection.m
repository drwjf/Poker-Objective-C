//
//  UDPConnection.m
//  Poker
//
//  Created by Admin on 30.07.15.
//  Copyright (c) 2015 by.bsuir.eLearning. All rights reserved.
//

#import "UDPConnection.h"
#import "GCDAsyncUdpSocket.h"
#import "JSONParser.h"

#define MESSAGE_TO_GAMER 0

@implementation UDPConnection 

static UDPConnection *singlUPDConnection = nil;


#pragma mark - Instance methods

- (instancetype)init {
    if(self = [super init]) {
        _asyncSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        _asyncSocket.delegate = self;
    }
    
    return self;
}

+ (id)sharedInstance {
    @synchronized(self) {
        if(singlUPDConnection == nil) {
            singlUPDConnection = [[UDPConnection alloc] init];
        }
    }
    
    return singlUPDConnection;
}

#pragma makr - Send & Read data methods

#define DEFAULT_TIME_INTERVAL 3.0

- (void)sendDataWithTag:(NSData *)jsonData andIP:(NSString *)host andUdpPort:(uint16_t)port {
    [_asyncSocket sendData:jsonData toHost:host port:port withTimeout:-1 tag:0];
}

- (void)bindSocket {
    NSError *error = nil;
    if (![_asyncSocket bindToPort:0 error:&error])
    {
        NSLog(@"error binding !");
        return;
    }
    if (![_asyncSocket beginReceiving:&error])
    {
        NSLog(@"error receiving");
        return;
    }
    
}


- (uint16_t)getLocalUDPport {
    return [_asyncSocket localPort];
}

#pragma mark - GCDAsyncUdpSocket delegates

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didConnectToAddress:(NSData *)address {
    NSLog(@"socket did connect to address ");
   
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotConnect:(NSError *)error {
    NSLog(@"Did not connect");
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didSendDataWithTag:(long)tag {
    NSLog(@"data is sended !");
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didNotSendDataWithTag:(long)tag dueToError:(NSError *)error {
    NSLog(@"data is NOT sended error : %@", error);
}


- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data
      fromAddress:(NSData *)address
withFilterContext:(id)filterContext {
    
    NSLog(@"did receive data");
    [self.delegate updateUIWithMessageFromGamer:[JSONParser convertJSONdataToNSDictionary:data]];
}


- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error {
    NSLog(@"error : %@", error);
}


@end
