//
//  ConnectionToServer.h
//  Poker
//
//  Created by Admin on 03.05.15.
//  Copyright (c) 2015 by.bsuir.eLearning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GCDAsyncSocket.h"
#import "DDLog.h"
#import "DDTTYLogger.h"


@protocol ConnectionToServerDelegate

-(void)updateInfo;
-(void)accept;
-(void)updateInfoAboutPlayer;
-(void)returnOnPreviusView;
-(void)waitingResponseFromServer;
-(void)getCards;
-(void)waitingResponseFromServerAboutGameStatus;
-(void)parseServerResponse:(NSString*)string;
-(void)showNextCard:(int)numberInArray;
-(void)parseServerResponseAboutWinner;
-(void)gettingBestCombination;
-(void)gettingWinnerGamerTwoCard;

-(void)connected;
@end

@interface ConnectionToServer : NSObject


//------------------Technical feilds-------------------
@property(nonatomic,strong)dispatch_queue_t mainQueue;
@property(nonatomic,strong)GCDAsyncSocket *asyncSocket;
@property(nonatomic,strong)NSString *ipAdressTextField;
@property(nonatomic,strong)NSString *portTextField;
//-----------------------------------------------------

//-----------------Info about gamer--------------------
@property(nonatomic,strong)NSString *gameName;
@property(nonatomic)int gamerMoney;
@property(nonatomic)int gamerLevel;
//-----------------------------------------------------

@property(nonatomic,strong)NSString *receiveString;
@property(nonatomic)int receivedIntValue;
@property(nonatomic)int countGamers;
@property(nonatomic)int numberOfAttribut;
@property(nonatomic)int countOfGameCycl;


@property(nonatomic)BOOL isConnected;

//-----------------Delegates---------------------------
@property(nonatomic, assign) id<ConnectionToServerDelegate> delegate;
//-----------------------------------------------------


+(id) sharedInstance;

-(void)setParameters:(NSString*)ip andPort:(NSString*)myPort;
-(void)connectToServer;
-(void)sendData:(NSString*)data;
-(void)sendDataWithTag:(NSString*)data andTag:(int)tag;
-(void)sendSomeIntValue:(int)intValue;
//-(void)receiveDataWithCompletionBlock:(void (^)(NSString *name))copmpletionsBlock;
-(void)readDataWithTag:(int)tag;
-(void)readDataWithTagLongTime:(int)tag andDurationWaiting:(int)duration;

@end
