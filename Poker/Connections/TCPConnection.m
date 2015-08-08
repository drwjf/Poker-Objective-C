//
//  TCPConnection.m
//  Poker
//
//  Created by Admin on 30.07.15.
//  Copyright (c) 2015 by.bsuir.eLearning. All rights reserved.
//

#import "TCPConnection.h"
#import "Queue.h"

@interface TCPConnection ()

@property(nonatomic, strong)Queue *queue;

@end


#define GET_INVITE_TO_THE_GAME 0
#define GET_ACCEPT 1
#define GET_INFO_ABOUT_GAMERS 3
#define GET_INFO_ABOUT_CARDS 4
#define GET_INFO_ABOUT_BETS   5

#define TIME_OUT 3
#define LONG_TIME_OUT 60

static const int ddLogLevel = LOG_LEVEL_INFO;


@implementation TCPConnection


static TCPConnection *singlTCPConnection = nil;

-(id)init{
    self = [super init];
    
    if(self) {
        _mainQueue = nil;
        _asyncSocket = nil;
        _isConnected = NO;
        _queue = [[Queue alloc] init];
    }
    return self;
}

+ (instancetype)sharedInstance {
    @synchronized(self) {
        if(singlTCPConnection == nil) {
            singlTCPConnection = [[TCPConnection alloc] init];
        }
    }
    return singlTCPConnection;
}


//-------------------SENDING--------------------------------------------

-(void)sendDataWithTag:(NSData *)data andTag:(int)tag {
    [_asyncSocket writeData:data withTimeout:1 tag:tag];
}

//---------------------------------------------------------------------


//-------------------RECEIVING-----------------------------------------
-(void)readDataWithTag:(int)tag {
   // NSLog(@"%@, tag : %d", THIS_METHOD, tag);
    NSMutableData *myData = [[NSMutableData alloc] init];
    
    
    if([self.queue isQueueEmpty])
        [_asyncSocket readDataWithTimeout:LONG_TIME_OUT buffer:myData bufferOffset:0 tag:tag];
    else
        [self returnDataWithTag:tag];
}

- (void)returnDataWithTag:(long)tag {
        self.downloadedData = [self.queue nextObject];
        switch (tag) {
            case GET_INVITE_TO_THE_GAME:
                [self.delegateForGamerVC parseResponseFromServer];
                break;
    
            case GET_INFO_ABOUT_GAMERS:
                [self.delegateForPlayGameVC parseGameInformationFromServer];
    
                //Gamers on the table are rendered. Geting info about cards.
                [self readDataWithTag:GET_INFO_ABOUT_CARDS];
                break;
            case GET_INFO_ABOUT_CARDS:
                [self.delegateForPlayGameVC parseGameInformationFromServer];
    
                [self readDataWithTag:GET_INFO_ABOUT_BETS];
                break;
    
            case GET_INFO_ABOUT_BETS:
                [self.delegateForPlayGameVC parseInformationAboutGamersBets];
                break;
                
            default:
                break;
        }
}


-(void)readDataWithTagLongTime:(int)tag andDurationWaiting:(int)duration {
    NSLog(@"%@, tag : %d", THIS_METHOD, tag);
    NSMutableData *myData = [[NSMutableData alloc] init];
    [_asyncSocket readDataWithTimeout:duration buffer:myData bufferOffset:0 tag:tag];
}
//----------------------------------------------------------------------


-(void)setParameters:(NSString*)ip andPort:(NSString*)myPort{
    _ipAdressTextField = ip;
    _portTextField = myPort;
}

-(void)connectToServer{
    
    _mainQueue = dispatch_get_main_queue();
    _asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:_mainQueue];
    
    uint16_t port = [_portTextField intValue];
    
    DDLogInfo(@"Connecting to \"%@\" on port %huu...", _ipAdressTextField, port);
    
    NSError *error = nil;
    if (![_asyncSocket connectToHost:_ipAdressTextField onPort:port error:&error])
    {
        DDLogError(@"Error connecting: %@", error);
    } else {
        DDLogError(@"Success connecting: %@", error);
    }
}

- (NSMutableArray*)arrayOfIndexesSeparateSymols:(NSString*)string {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    for (int i=0; i<[string length]; i++) {
        if([string characterAtIndex:i] == '\n')
            [array addObject:[NSNumber numberWithInt:i]];
    }
    return array;
}

- (void)splitDownloadedJSON:(NSData *)data {
    NSString *httpResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"%@", httpResponse);
    NSMutableArray *arrayOfIndexes = [self arrayOfIndexesSeparateSymols:httpResponse];
    
    for(int i=0, indexOfStartSymbol = 0; i < [arrayOfIndexes count]; i++)
    {
        NSNumber *numberOfSeparateSymbol = [arrayOfIndexes objectAtIndex:i];
        
        NSLog(@"firstSymbol  :%c, %i", [httpResponse characterAtIndex:indexOfStartSymbol], indexOfStartSymbol);
        NSLog(@"lastSymbol   :%c, %i", [httpResponse characterAtIndex:[numberOfSeparateSymbol intValue]], [numberOfSeparateSymbol intValue]);
        
        
        NSString *subString  = [httpResponse substringWithRange:NSMakeRange(indexOfStartSymbol, [numberOfSeparateSymbol intValue] - indexOfStartSymbol)];
        
        [self.queue addObject:[subString dataUsingEncoding:NSUTF8StringEncoding]];
        indexOfStartSymbol = [numberOfSeparateSymbol intValue];
        subString = nil;
    }
}




////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Socket Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// Setup our socket (GCDAsyncSocket).
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    DDLogInfo(@"method : %@", THIS_METHOD);
    DDLogInfo(@"socket:%p didConnectToHost:%@ port:%hu", sock, host, port);
    _isConnected = YES;
    [self.delegateForRootVC connected];
}

- (void)socketDidSecure:(GCDAsyncSocket *)sock
{
    DDLogInfo(@"socketDidSecure:%p", sock);
    _isConnected = YES;
    
    NSString *requestStr = [NSString stringWithFormat:@"GET / HTTP/1.1\r\nHost: %@\r\n\r\n", _ipAdressTextField];
    NSData *requestData = [requestStr dataUsingEncoding:NSUTF8StringEncoding];
    
    [sock writeData:requestData withTimeout:-1 tag:0];
    [sock readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1 tag:0];
}



- (void)socket:(GCDAsyncSocket *)sock didWriteDataWithTag:(long)tag
{
    switch (tag) {
        case GET_INVITE_TO_THE_GAME:
            [self readDataWithTag:GET_INVITE_TO_THE_GAME];
            break;
        case GET_ACCEPT: //If player added to game table.
            [self.delegateForGamerVC segueToGeneralViewController];
            
            break;
        default:
            break;
    }
    
    DDLogInfo(@"socket:%p didWriteDataWithTag:%ld", sock, tag);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    DDLogInfo(@"socket:%p didReadData:withTag:%ld", sock, tag);
    [self splitDownloadedJSON:data];
    [self returnDataWithTag:tag];
    
    NSString *httpResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    DDLogInfo(@"HTTP Response:\n%@!!", httpResponse);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    DDLogInfo(@"socketDidDisconnect:%p withError: %@", sock, err);
    _isConnected = NO;
    [self.delegateForRootVC returnOnPreviusView];
}




@end
