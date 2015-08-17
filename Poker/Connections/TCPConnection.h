//
//  TCPConnection.h
//  Poker
//
//  Created by Admin on 30.07.15.
//  Copyright (c) 2015 by.bsuir.eLearning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "DDLog.h"
#import "DDTTYLogger.h"




@protocol ConnectionToServerDelegateForPlayGameVC
- (void)parseInformationAboutGamersBets;
- (void)parseGameInformationFromServer;
- (void)connected;
@end

@protocol ConnectionToServerDelegateForGamerDataVC
- (void)parseResponseFromServer;
- (void)segueToGeneralViewController;
@end

@protocol ConnectionToServerDelegateForRootVC
- (void)connected;
- (void)returnOnPreviusView;
@end

@interface TCPConnection : NSObject


//------------------Technical feilds-------------------
@property(nonatomic,strong)dispatch_queue_t mainQueue;
@property(nonatomic,strong)GCDAsyncSocket *asyncSocket;
@property(nonatomic,strong)NSString *ipAdressTextField;
@property(nonatomic,strong)NSString *portTextField;
//-----------------------------------------------------

@property(nonatomic,strong) NSData *downloadedData;


@property(nonatomic)BOOL isConnected;

//-----------------Delegates---------------------------
@property(nonatomic, assign) id<ConnectionToServerDelegateForPlayGameVC> delegateForPlayGameVC;
@property(nonatomic, assign) id<ConnectionToServerDelegateForGamerDataVC> delegateForGamerVC;
@property(nonatomic, assign) id<ConnectionToServerDelegateForRootVC> delegateForRootVC;
//-----------------------------------------------------


+ (id) sharedInstance;

-(void)setParameters:(NSString*)ip andPort:(NSString*)myPort;
-(void)connectToServer;
-(void)sendDataWithTag:(NSData *)data andTag:(int)tag;
-(void)readDataWithTag:(int)tag;
-(void)readDataWithTagLongTime:(int)tag andDurationWaiting:(int)duration;


@end
