//
//  AnimationOnTheTable.h
//  Poker
//
//  Created by Admin on 05.05.15.
//  Copyright (c) 2015 by.bsuir.eLearning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Gamer.h"
#import <AVFoundation/AVFoundation.h>

@interface AnimationOnTheTable : UIViewController
@property (strong, nonatomic) IBOutlet UIImageView *backgroundImage;
@property(nonatomic)BOOL isUseAccelerometer;
@property(nonatomic,strong)UIImage *bufferImage;


@property (strong, nonatomic) IBOutlet UIImageView *firstCard;
@property (strong, nonatomic) IBOutlet UIImageView *secondCard;
@property (strong, nonatomic) IBOutlet UIImageView *theardCard;
@property (strong, nonatomic) IBOutlet UIImageView *fourthCard;
@property (strong, nonatomic) IBOutlet UIImageView *fifeCard;


@property (weak, nonatomic) IBOutlet UIView *contentView;


@property (strong, nonatomic) IBOutlet UIImageView *firstGamerImage;
@property (strong, nonatomic) IBOutlet UILabel *firstGamerNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *firstGamerMoneyLabel;


@property (strong, nonatomic) IBOutlet UIImageView *secondGamerImage;
@property (strong, nonatomic) IBOutlet UILabel *secondGamerNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *secondGamerMoneyLabel;

@property (strong, nonatomic) IBOutlet UIImageView *theardGamerImage;
@property (strong, nonatomic) IBOutlet UILabel *theardGamerNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *theardGamerMoneyLabel;

@property (strong, nonatomic) IBOutlet UIImageView *fourthGamerImage;
@property (strong, nonatomic) IBOutlet UILabel *fourthGamerNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *forthGamerMoneyLabel;

@property (strong, nonatomic) IBOutlet UIImageView *fifeGamerImage;
@property (strong, nonatomic) IBOutlet UILabel *fifeGamerNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *fifeGamerMoneyLabel;

@property (strong, nonatomic) IBOutlet UIImageView *sixGamerImage;
@property (strong, nonatomic) IBOutlet UILabel *sixGamerNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *sixGamerMoneyLabel;

@property (strong, nonatomic) IBOutlet UIImageView *sevenGamerImage;
@property (strong, nonatomic) IBOutlet UILabel *sevenGamerNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *sevenGamerMoneyLabel;

@property (strong, nonatomic) IBOutlet UIImageView *eightGamerImage;
@property (strong, nonatomic) IBOutlet UILabel *eightGamerNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *eightGamerMoneyLabel;

@property (strong, nonatomic) IBOutlet UIImageView *nineGamerImage;
@property (strong, nonatomic) IBOutlet UILabel *nineGamerNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *nineGamerMoneyLabel;

@property (strong, nonatomic) IBOutlet UIImageView *tenGamerImage;
@property (strong, nonatomic) IBOutlet UILabel *tenGamerNameLabel;
@property (strong, nonatomic) IBOutlet UILabel *tenGamerMoneyLabel;

@property (strong, nonatomic) IBOutlet UIButton *raiseButton;
@property (strong, nonatomic) IBOutlet UIButton *checkButton;
@property (strong, nonatomic) IBOutlet UIButton *pasButton;
@property (strong, nonatomic) IBOutlet UIButton *qualButton;

@property (strong, nonatomic) IBOutlet UIButton *showCombinationButton;
@property (strong, nonatomic) IBOutlet UIImageView *combinationImage;


@property (strong, nonatomic) IBOutlet UITextView *chatTextView;
@property (strong, nonatomic) IBOutlet UITextField *inputTextFeld;
@property (strong, nonatomic) IBOutlet UIButton *sendMessageToChatButton;

//---------------selected gamer info--------------------
@property (strong, nonatomic) IBOutlet UIImageView *selectedGamerImage;
@property (strong, nonatomic) IBOutlet UILabel *selectedGamerName;
@property (strong, nonatomic) IBOutlet UILabel *selectedGamerMoney;
@property (strong, nonatomic) IBOutlet UILabel *selectedGamerLevel;

@property (strong, nonatomic) IBOutlet UIButton *sendMessageToSelectedGamerButton;
@property (strong, nonatomic) IBOutlet UIButton *addToFriendsButton;
@property (strong, nonatomic) IBOutlet UIButton *quitButton;

//------------------------------------------------------

@property (strong, nonatomic) IBOutlet UILabel *rateLabel;
@property (strong, nonatomic) IBOutlet UISlider *rateSlider;

//---------------image of card Ganeral Gamer-------------------------------
@property (strong, nonatomic) IBOutlet UIImageView *firstPrivateCardImage;
@property (strong, nonatomic) IBOutlet UIImageView *secondPrivateCardImage;
//---------------/---------------/---------------/---------------/---------------
@property (strong, nonatomic) IBOutlet UIImageView *firstPrivateCardSecondGamerImage;
@property (strong, nonatomic) IBOutlet UIImageView *secondPrivateCardSecondGamerImage;

@property (strong, nonatomic) IBOutlet UIImageView *firstPrivateCardTheardGamerImage;
@property (strong, nonatomic) IBOutlet UIImageView *secondPrivateCardTheardGamerImage;

@property (strong, nonatomic) IBOutlet UIImageView *firstPrivateCardFourthGamerImage;
@property (strong, nonatomic) IBOutlet UIImageView *secondPrivateCardFourthGamerImage;
//need make for 10 gamers !!!
///-----------------------------------------------------------------

@property (strong, nonatomic) IBOutlet UILabel *messageFromServerLabel;



@property(nonatomic,strong)Gamer *user1;
@property(nonatomic,strong)Gamer *user2;
@property(nonatomic,strong)Gamer *user3;
@property(nonatomic,strong)Gamer *user4;
@property(nonatomic,strong)Gamer *user5;
@property(nonatomic,strong)Gamer *user6;
@property(nonatomic,strong)Gamer *user7;
@property(nonatomic,strong)Gamer *user8;
@property(nonatomic,strong)Gamer *user9;


@property (strong, nonatomic) IBOutlet UILabel *rateGeneralGamerLabel;
@property (strong, nonatomic) IBOutlet UILabel *rateSecondGamerLabel;
@property (strong, nonatomic) IBOutlet UILabel *rateTheardUserLabel;
@property (strong, nonatomic) IBOutlet UILabel *rateFourthGamerLabel;
@property (strong, nonatomic) IBOutlet UILabel *rateFifeGamerLabel;
@property (strong, nonatomic) IBOutlet UILabel *rateSixGamerLabel;
@property (strong, nonatomic) IBOutlet UILabel *rateSevenGamerLabel;
@property (strong, nonatomic) IBOutlet UILabel *rateEightGamerLabel;
@property (strong, nonatomic) IBOutlet UILabel *rateNineGamerLabel;
@property (strong, nonatomic) IBOutlet UILabel *rateTenGamerLabel;
@property (strong, nonatomic) IBOutlet UILabel *rateAmountAllGamersLabel;


@property(nonatomic,strong)NSMutableArray *gamersArray;
@property(nonatomic)int countVizualizedGamers;


@end
