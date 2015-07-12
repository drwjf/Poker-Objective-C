//
//  ConnectionToServer.m
//  Poker
//
//  Created by Admin on 03.05.15.
//  Copyright (c) 2015 by.bsuir.eLearning. All rights reserved.
//

#import "ConnectionToServer.h"

#define GET_ACCEPT 0
#define GET_STRING 1
#define GET_INT_VALUE 2
#define GET_GAMER_NAME    3
#define GET_GAMER_MONEY   4
#define GET_GAMER_LEVEL   5
#define GET_COUNT_GAMERS  6


//#define GET_REQUEST_FROM_SERVER 7
#define GET_GAME_STATUS 7
#define GET_CARD 8
#define GET_RATE_FROM_SERVER 9
#define GET_WINNERS_NAME 10
#define GET_BEST_CARD_COMBINATION 11
#define GET_WINNER_CADR 12


#define TIME_OUT 3
#define LONG_TIME_OUT 60

#define DID_WRITE_RESPONSE 101

#define MAX_DURATION_OF_PARTY 1080

@implementation ConnectionToServer


static const int ddLogLevel = LOG_LEVEL_INFO;

static ConnectionToServer *mySinglConnection = nil;

-(id)init{
    self = [super init];
    
    if(self) {
        _mainQueue = nil;
        _asyncSocket = nil;
        _isConnected = NO;
        _countGamers = 0;
        _numberOfAttribut = 0;
    }
    return self;
}

+(ConnectionToServer*)sharedInstance {
    @synchronized(self) {
        if(mySinglConnection == nil) {
            mySinglConnection = [[ConnectionToServer alloc] init];
        }
    }
    return mySinglConnection;
}


//-------------------SENDING--------------------------------------------
-(void)sendData:(NSString*)data {
    NSData *myData = [data dataUsingEncoding:NSUTF8StringEncoding];
    [_asyncSocket writeData:myData withTimeout:1 tag:10];
}

-(void)sendDataWithTag:(NSString*)data andTag:(int)tag {
    NSData *myData = [data dataUsingEncoding:NSUTF8StringEncoding];
    [_asyncSocket writeData:myData withTimeout:1 tag:tag];
}



-(void)sendSomeIntValue:(int)intValue {
    int value = intValue;
    NSData *myData = [NSData dataWithBytes:&value length:sizeof(value)];
    [_asyncSocket writeData:myData withTimeout:-1 tag:10];
}

//---------------------------------------------------------------------


//-------------------RECEIVING-----------------------------------------
-(void)readDataWithTag:(int)tag {
        NSLog(@"%@, tag : %d", THIS_METHOD, tag);
        NSMutableData *myData = [[NSMutableData alloc] init];
        [_asyncSocket readDataWithTimeout:TIME_OUT buffer:myData bufferOffset:0 tag:tag];
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


////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark Socket Delegate
////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////


// Setup our socket (GCDAsyncSocket).
- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
    DDLogInfo(@"method : %@", THIS_METHOD);
    DDLogInfo(@"socket:%p didConnectToHost:%@ port:%hu", sock, host, port);
    _isConnected = YES;
    [self.delegate connected];
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
    if(tag == DID_WRITE_RESPONSE) {
        [self readDataWithTagLongTime:GET_ACCEPT andDurationWaiting:LONG_TIME_OUT];
    }
    
    DDLogInfo(@"socket:%p didWriteDataWithTag:%ld", sock, tag);
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{
    
    DDLogInfo(@"socket:%p didReadData:withTag:%ld", sock, tag);
    
    if(tag == GET_ACCEPT || tag == GET_STRING || tag == GET_GAME_STATUS || tag == GET_RATE_FROM_SERVER || tag == GET_GAMER_NAME || tag == GET_WINNERS_NAME || tag == GET_GAMER_MONEY) {
        _receiveString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        switch (tag) {
            case GET_ACCEPT:
                [self.delegate accept];
                break;
                
            case GET_STRING:
                [self.delegate updateInfo];
                break;
                
            case GET_GAMER_MONEY:
                _gamerMoney = [_receiveString intValue];
                [self.delegate updateInfo];
                break;
                
            case GET_WINNERS_NAME:
                NSLog(@"GET_WINNERS_NAME Called");
                [self.delegate parseServerResponseAboutWinner];
                break;
                
            case GET_GAME_STATUS: //IF COUNT GAMERS ON THE TABLE 10, we should wait(0); DON'T MADE IN SERVER !!!!!!!!!//////////////////////////
                            if([_receiveString isEqualToString:@"GAME_IS_STARTED"])
                            {
                                NSLog(@"server : gamer is started");
                                _numberOfAttribut = -1;
                                [self.delegate getCards];
                            }
                
                            if([_receiveString isEqualToString:@"PLEASE_WAIT"]) { NSLog(@"server : please wait");  [self.delegate waitingResponseFromServerAboutGameStatus];  }
                break; ////////////////////////////////////////////////////////////////////////////////////////////////////////////////////////
                
            case GET_RATE_FROM_SERVER:
                if(_countOfGameCycl < 5) {
                    _numberOfAttribut++;
                    _numberOfAttribut = _numberOfAttribut % _countGamers;
                    [self.delegate parseServerResponse:_receiveString];
                } 
                break;
            case GET_GAMER_NAME:
                        _gameName = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                        [self.delegate updateInfo];
                break;
                
            default:
                break;
        }
    }
    if(tag == GET_INT_VALUE || tag == GET_COUNT_GAMERS || tag == GET_GAMER_LEVEL || tag == GET_CARD || tag == GET_BEST_CARD_COMBINATION || tag == GET_WINNER_CADR) {

       const uint8_t *bytes = [data bytes]; // pointer to the bytes in data
        int value = bytes[0]; // first byte
        _receivedIntValue = value;
        switch (tag) {
            case GET_COUNT_GAMERS:
                _countGamers = _receivedIntValue;
                            if(_countGamers > 0) [self.delegate updateInfo];
                            else [self.delegate waitingResponseFromServer];
                break;
                
            case GET_GAMER_LEVEL:
                _gamerLevel = _receivedIntValue;
                 [self.delegate updateInfo];
                break;
                
            case GET_CARD:
                [self.delegate getCards];
                break;
                
            case GET_WINNER_CADR:
                [self.delegate gettingWinnerGamerTwoCard];
                break;
                
            case GET_BEST_CARD_COMBINATION:
                [self.delegate gettingBestCombination];
                break;
                
            case GET_INT_VALUE:
                [self.delegate updateInfo];
                break;
                
            default:
                break;
        }
        
    }
    
    NSString *httpResponse = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
    DDLogInfo(@"HTTP Response:\n%@", httpResponse);
}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
    DDLogInfo(@"socketDidDisconnect:%p withError: %@", sock, err);
    _isConnected = NO;
    [self.delegate returnOnPreviusView];
}



@end
