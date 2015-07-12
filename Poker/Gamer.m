//
//  Gamer.m
//  Poker
//
//  Created by Admin on 06.05.15.
//  Copyright (c) 2015 by.bsuir.eLearning. All rights reserved.
//

#import "Gamer.h"

@implementation Gamer

-(id)initWithInfo:(NSString*)name andMoney:(int)money andLevel:(int)level{
    self = [super init];
    
    
    if(self) {
        _name = name;
        _money = money;
        _level = level;
        _image = @"defaultImage.jpg";
        _rate = 0;
        _isGamed = YES;
    }
    
    return self;
}

-(void)setPrivateCards:(int)firstCard andSecondCard:(int)secondCard{
    _firstPrivateCard = firstCard;
    _secondPrivateCard = secondCard;
}


@end
