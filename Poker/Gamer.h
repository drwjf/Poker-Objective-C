//
//  Gamer.h
//  Poker
//
//  Created by Admin on 06.05.15.
//  Copyright (c) 2015 by.bsuir.eLearning. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface Gamer : NSObject

@property(nonatomic)int firstPrivateCard;
@property(nonatomic)int secondPrivateCard;

@property(nonatomic,strong)NSString* name;
@property(nonatomic)int level;
@property(nonatomic, strong)NSNumber *money;

@property(nonatomic,strong)NSString *ipAddress;
@property(nonatomic)int port;

@property(nonatomic)long rate;
@property(nonatomic)BOOL isGamed;



- (instancetype)initWithInfo:(NSString*)name andMoney:(NSNumber *)money andLevel:(int)level;
- (void)setFurtherNetInformation:(NSString *)ipAddress andPort:(int)port;
- (void)setPrivateCards:(int)firstCard andSecondCard:(int)secondCard;

@end
