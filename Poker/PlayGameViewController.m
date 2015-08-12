//
//  PlayGameViewController.m
//  Poker
//
//  Created by Admin on 25.07.15.
//  Copyright (c) 2015 by.bsuir.eLearning. All rights reserved.
//

#import "PlayGameViewController.h"
#import "EAColourfulProgressView.h"
#import "Gamer.h"
#import "JSONParser.h"

//---tags----
#define GET_INFO_ABOUT_GAMERS 3
#define GET_INFO_ABOUT_BETS   5
#define DATA_ABOUT_BETS 7
//---tags----

@interface PlayGameViewController ()

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *arrayOfPlayersImages;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *arrayOfLabelsPlayersMoneys;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *arrayOfLabelsPlayersNames;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *arrayOfImagesCardsOnTheTable;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *arrayOfImagesPrivatePlayersCard;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *arrayOfLabelsGamerRates;

@property (strong, nonatomic) IBOutletCollection(EAColourfulProgressView) NSArray *arrayOfGamersProgressView;

@property(nonatomic, weak)EAColourfulProgressView *currentProgressView;
@property (weak, nonatomic) IBOutlet UILabel *generalBankLabel;



@property(nonatomic, strong) NSMutableArray *arrayOfPlayersOnTheTable;
@property(nonatomic, strong) NSMutableArray *arrayOfCardsOnTheTable;
@property(nonatomic, strong) NSTimer *timer;

@property (nonatomic) int countOfPlayersOnTheTable;
@property (nonatomic) int numberOfMeInGamersList;
@property (nonatomic) int numberOfCurrentProgressView;
@property (nonatomic) int openedCardsOnTheTable;

@property (nonatomic) BOOL isCheckFold;
@property (nonatomic) BOOL isCallAny;
@property (nonatomic) BOOL isCheck;
@property (nonatomic) BOOL isFold;
@property (nonatomic) BOOL isMyHandRightNow;

@property (nonatomic,strong) NSNumber *currentMinBet;
@property (nonatomic, strong)NSNumber *moneyOnTheTable;

@property (strong, nonatomic) IBOutlet UIButton *foldButton;
@property (strong, nonatomic) IBOutlet UIButton *checkButton;
@property (strong, nonatomic) IBOutlet UIButton *CheckFoldButton;
@property (strong, nonatomic) IBOutlet UIButton *callButton;
@property (strong, nonatomic) IBOutlet UIButton *raiseButton;
@property (strong, nonatomic) IBOutlet UIButton *callAnyButton;

@property (strong, nonatomic) IBOutlet UIButton *makeScreenshortButton;
@property (strong, nonatomic) IBOutlet UIButton *showCombinationButton;

@property (strong, nonatomic) IBOutlet UILabel *messageFromServerLabel;

@end

@implementation PlayGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self lockTheBetButtons];
    [self prepareBeforeGameProcess];
    [self readInformationAboutGamersOnTheTable];
    
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [self setDefaultGamerMoney];
}
- (void)setDefaultGamerMoney {
    Gamer *gamer = [self.arrayOfPlayersOnTheTable objectAtIndex:_numberOfMeInGamersList];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:gamer.money forKey:@"money"];
}

- (long)differenceCurrentGamerRateAndMinBet {
    Gamer *generalGamer = [self.arrayOfPlayersOnTheTable objectAtIndex:self.numberOfMeInGamersList];
    long diff = [self.currentMinBet longValue] - generalGamer.rate;
    
    return diff;
}

#define BET_CHECK 0
#define BET_FOLD -1

- (IBAction)gamerHandAction:(UIButton *)sender {
    NSData *jsonData = nil;
    long currentBet = 0;
    
    if([sender isEqual:_foldButton]) {
         currentBet = BET_FOLD;
         jsonData = [self createJSONGamerAnswerWithBet:[NSNumber numberWithLong:currentBet]];
    } else
    if([sender isEqual:_checkButton]) {
         currentBet = BET_CHECK;
         jsonData = [self createJSONGamerAnswerWithBet:[NSNumber numberWithLong:currentBet]];
    } else
    if ([sender isEqual:_callButton]) {
        currentBet = [self differenceCurrentGamerRateAndMinBet];
        jsonData = [self createJSONGamerAnswerWithBet:[NSNumber numberWithLong:currentBet]];
    } else
    if ([sender isEqual:_raiseButton]) {
        currentBet = [self.currentMinBet longValue] * 2;
        jsonData = [self createJSONGamerAnswerWithBet:[NSNumber numberWithLong:currentBet]];
    }
    
    if([self shouldIMakeTheBet])  {
        [self sendInfoAboutBet:jsonData];
        [self stopCurrentProgressView];
        [self updateGamerBetAndMoneyOnTheTable:_numberOfMeInGamersList andValue:[NSNumber numberWithLong:currentBet]];
        _isMyHandRightNow = NO;
        [self setViewUnvisible:_messageFromServerLabel];
        [self lockTheBetButtons];
    }
    
}


- (IBAction)callAnyAction:(UIButton *)sender {
    _isCallAny = !_isCallAny;
    //[self setImageForButton:sender andCheck:_isCallAny];
    [self unsetImageForButton:sender];
}

- (IBAction)checkFoldAction:(UIButton *)sender {
    _isCheckFold = !_isCheckFold;
    [self setImageForButton:sender andCheck:_isCheckFold];
}

- (void)unsetImageForButton:(UIButton *)button {
    [button setImage:[UIImage imageNamed:@""] forState:UIControlStateNormal];
    [button reloadInputViews];
}
- (void)setImageForButton:(UIButton *)button andCheck:(BOOL)isChecked {
    if(isChecked)
        [button setImage:[UIImage imageNamed:@"OSX-Checkbox-ON"] forState:UIControlStateNormal];
     else
        [button setImage:[UIImage imageNamed:@"OSX-Checkbox-OFF"] forState:UIControlStateNormal];
    
    [button reloadInputViews];
}
- (NSData *)createJSONGamerAnswerWithBet:(NSNumber *)bet {
    NSDictionary *dictionary = @{
                                 @"title" : @"CurrentBetOfGamer",
                                 @"numberOfCurrentGamer" : [NSNumber numberWithInt:self.numberOfMeInGamersList],
                                 @"betOfPlayer" : bet
                                 };
    
    return [JSONParser convertNSDictionaryToJSONdata:dictionary];
}


- (void)sendInfoAboutBet:(NSData*)data {
    TCPConnection *connection = [TCPConnection sharedInstance];
    [connection sendDataWithTag:data andTag:DATA_ABOUT_BETS];
}
- (void)readInformationAboutGamersOnTheTable {
    TCPConnection *connection = [TCPConnection sharedInstance];
    connection.delegateForPlayGameVC = self;
    [connection readDataWithTag:GET_INFO_ABOUT_GAMERS];
}
- (void)readInformationAboutGamerBets {
    TCPConnection *connection = [TCPConnection sharedInstance];
    [connection readDataWithTag:GET_INFO_ABOUT_BETS];
}

- (void)prepareBeforeGameProcess {
    [self clearTable];
    [self changeCornerRadiusOfBetButtons];
    _countOfPlayersOnTheTable = 0;
    _isMyHandRightNow = NO;
    _moneyOnTheTable = [NSNumber numberWithLong:0];
}
- (void)clearTable
{
    //performance better, than if we use a (1)cycle.
    for(UILabel *nameLabel in self.arrayOfLabelsPlayersNames)   [self setViewUnvisible:nameLabel];
    for(UILabel *moneyLabel in self.arrayOfLabelsPlayersMoneys) [self setViewUnvisible:moneyLabel];
    for(UIImageView *imageView in self.arrayOfPlayersImages)    [self setViewUnvisible:imageView];
    for(UIImageView *privateCardImage in self.arrayOfImagesPrivatePlayersCard) [self setViewUnvisible:privateCardImage];
    for(UIView *progressView in self.arrayOfGamersProgressView) [self setViewUnvisible:progressView];
    for(UILabel *rateLabel in self.arrayOfLabelsGamerRates)     [self setViewUnvisible:rateLabel];
    
    [self setViewUnvisible:_messageFromServerLabel];
}
- (void)lockTheBetButtons
{
    [self.foldButton setEnabled:NO];
    [self.CheckFoldButton setEnabled:NO];
    [self.checkButton setEnabled:NO];
    [self.raiseButton setEnabled:NO];
    [self.callAnyButton setEnabled:NO];
    [self.callButton setEnabled:NO];
    [self.raiseButton setEnabled:NO];
}
- (void)unlockTheBetButtons
{
    [self.foldButton setEnabled:YES];
    [self.CheckFoldButton setEnabled:YES];
    [self.checkButton setEnabled:YES];
    [self.raiseButton setEnabled:YES];
    [self.callAnyButton setEnabled:YES];
    [self.callButton setEnabled:YES];
    [self.raiseButton setEnabled:YES];
}


- (void)rotateRightPrivateCardOfPlayers: (int)countOfPlayers
{
    UIImageView *card;
    
    for(int i=0; i<countOfPlayers; i++) {
        card = [_arrayOfImagesPrivatePlayersCard objectAtIndex:i*2];
        card.transform = CGAffineTransformRotate(card.transform, M_PI_4/4);
    }
}

- (void)setCornerRadius:(UIView *)view andRadius:(int)radius
{
    [view.layer setMasksToBounds:YES];
    [view.layer setCornerRadius:radius];
}

#define CORNER_RADIUS_OF_PLAYER_ICON 10

- (void)changeCornerRadiusOfPlayersViews:(int)count
{
    UIView *playersNameLabel, *playersMoneyLabel, *playersImage;
    
    for(int i=0; i<count; i++) {
        playersImage       = [self.arrayOfPlayersImages       objectAtIndex:i];
        playersNameLabel   = [self.arrayOfLabelsPlayersNames  objectAtIndex:i];
        playersMoneyLabel  = [self.arrayOfLabelsPlayersMoneys objectAtIndex:i];
        
        [self setCornerRadius:playersImage       andRadius:CORNER_RADIUS_OF_PLAYER_ICON];
        [self setCornerRadius:playersNameLabel   andRadius:CORNER_RADIUS_OF_PLAYER_ICON];
        [self setCornerRadius:playersMoneyLabel  andRadius:CORNER_RADIUS_OF_PLAYER_ICON];
    }
}

#define CORNER_RADIUS_CARD 4

- (void)changeCornerRadiusOfCards: (int)countOfPlayers
{
    for(UIImageView *cardOnTheTable in self.arrayOfImagesCardsOnTheTable)
        [self setCornerRadius:cardOnTheTable andRadius:CORNER_RADIUS_CARD];
    
    for (int i=0; i < countOfPlayers * 2; i += 2) {
        [self setCornerRadius:[self.arrayOfImagesPrivatePlayersCard objectAtIndex:i] andRadius:CORNER_RADIUS_CARD];
        [self setCornerRadius:[self.arrayOfImagesPrivatePlayersCard objectAtIndex:i+1] andRadius:CORNER_RADIUS_CARD];
    }
    [self setCornerRadius:_messageFromServerLabel andRadius:CORNER_RADIUS_CARD];
}

- (void)changeCornerRadiusOfBetButtons {
    [self setCornerRadius:self.foldButton andRadius:CORNER_RADIUS_CARD];
    [self setCornerRadius:self.raiseButton andRadius:CORNER_RADIUS_CARD];
    [self setCornerRadius:self.callButton andRadius:CORNER_RADIUS_CARD];
    [self setCornerRadius:self.callAnyButton andRadius:CORNER_RADIUS_CARD];
    [self setCornerRadius:self.checkButton andRadius:CORNER_RADIUS_CARD];
    [self setCornerRadius:self.CheckFoldButton andRadius:CORNER_RADIUS_CARD];
    
    [self setCornerRadius:self.makeScreenshortButton andRadius:CORNER_RADIUS_CARD];
    [self setCornerRadius:self.showCombinationButton andRadius:CORNER_RADIUS_CARD];
}

- (NSDictionary *)downloadedJSONData {
    TCPConnection *connection = [TCPConnection sharedInstance];
    NSDictionary *dictionary =  [JSONParser convertJSONdataToNSDictionary:connection.downloadedData];
    
    return dictionary;
}

- (void)parseGameInformationFromServer {
    NSDictionary *dictionary = [self downloadedJSONData];
    
    NSString *titleOfJsonData = [JSONParser getNSStringWithObject:dictionary[@"title"]];
    
        if([titleOfJsonData isEqualToString:@"InformationAboutGamers"])
          dispatch_async(dispatch_get_main_queue(), ^{
            [self parseInformationAboutGamers:dictionary];
          });
    
        if([titleOfJsonData isEqualToString:@"InformationAboutCards"])
          dispatch_async(dispatch_get_main_queue(), ^{
                [self parseInformationAboutGameCards:dictionary];
          });
}

- (void)parseInformationAboutGamersBets {
    NSDictionary *dictionary = [self downloadedJSONData];
    
    NSString *titleOfJsonData = [JSONParser getNSStringWithObject:dictionary[@"title"]];
    [self stopCurrentProgressView];
    [self lockTheBetButtons];
    
    if([titleOfJsonData isEqualToString:@"InformationAboutBlinds"]) {
                [self renderingBlindsOfGamers: dictionary[@"blinds"]];
    } else if ([titleOfJsonData isEqualToString:@"OpenCardsOnTheTable"]) {
        BOOL isAllCards = [JSONParser getBOOLValueWithObject:dictionary[@"allCards"]];
        [self openCardsOnTheTable:isAllCards];
        [self collectionsOfGamersBets];
    } else if([titleOfJsonData isEqualToString:@"InfoAboutWinner"]) { //current GAMER OR HIM BET
        NSDictionary *info = [JSONParser getNSDictionaryWithObject:dictionary[@"information"]];
        [self parseInfoAboutWinner:info];
    } else {
        [self parseAndRenderInfoAboutCurrentGamer:dictionary andTitle:titleOfJsonData];
    }
    [self readInformationAboutGamerBets];
}

- (void)parseInfoAboutWinner:(NSDictionary *)dictionary {
    NSMutableArray *arrayOfBestCard = [[NSMutableArray alloc] init];
    
    NSNumber *numberOfBestGamer = [JSONParser getNSNumberWithObject:dictionary[@"numberOfWinner"]];
    
    for(int i=0; i < 5; i++) {
        NSString *key = [NSString stringWithFormat:@"bestCard %i", i+1];
        NSNumber *card = [JSONParser getNSNumberWithObject:dictionary[key]];
        [arrayOfBestCard addObject:card];
    }
    
    Gamer *gamerWinner = [self.arrayOfPlayersOnTheTable objectAtIndex:[numberOfBestGamer intValue]];
    gamerWinner.firstPrivateCard  = (int)[[JSONParser getNSNumberWithObject:dictionary[@"firstPrivateCard"]] longValue];
    gamerWinner.secondPrivateCard = (int)[[JSONParser getNSNumberWithObject:dictionary[@"secondPrivateCard"]] longValue];
    
    [self renderingWinnersCombination:arrayOfBestCard andNumberOfWinner:[numberOfBestGamer intValue]];
}

- (void)renderingWinnersCombination:(NSMutableArray *)winnerCombination andNumberOfWinner:(int)number {
    Gamer *winner = [self.arrayOfPlayersOnTheTable objectAtIndex:number];
    
    UIImageView *firstPrivateCardOfWinnerImageView = [self.arrayOfImagesPrivatePlayersCard objectAtIndex:2 * number];
    UIImageView *secondPrivateCardOfWinnerImageView = [self.arrayOfImagesPrivatePlayersCard objectAtIndex:2 * number + 1];

    [firstPrivateCardOfWinnerImageView  setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%i", winner.firstPrivateCard]]];
    [secondPrivateCardOfWinnerImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%i", winner.secondPrivateCard]]];
    
    for(int i=0; i < 5; i++) {
        NSNumber *cardOnTheTable = [self.arrayOfCardsOnTheTable objectAtIndex:i];
        BOOL isWinnerCard = NO;
        for(NSNumber *bestCard in winnerCombination) {
            if([cardOnTheTable isEqual:bestCard])  {
                isWinnerCard = YES;
                break;
            }
        }
        if(!isWinnerCard)  [[self.arrayOfImagesCardsOnTheTable  objectAtIndex:i] setAlpha:0.5];
        isWinnerCard = NO;
    }
    
    for(int i=0; i < 2; i++) {
        NSNumber *firstPrivateCardOfWinner = [NSNumber numberWithInt:winner.firstPrivateCard];
        NSNumber *secondPrivateCardOfWinner = [NSNumber numberWithInt:winner.firstPrivateCard];
        BOOL isFirstPrivateCardBest = NO;
        BOOL isSecondPrivateCardBest = NO;
        
        for(NSNumber *bestCard in winnerCombination) {
            if([firstPrivateCardOfWinner isEqual:bestCard]) isFirstPrivateCardBest = YES;
            if([secondPrivateCardOfWinner isEqual:bestCard]) isSecondPrivateCardBest = YES;
        }
        if(!isFirstPrivateCardBest)  [firstPrivateCardOfWinnerImageView setAlpha:0.5];
        if(!isSecondPrivateCardBest) [secondPrivateCardOfWinnerImageView setAlpha:0.5];
    }
}

- (void)renderingBlindsOfGamers:(NSDictionary *)dictionary {
    int numberOfGamerWithSmallBlind, numberOfGamerWithBigBlind;
    
    numberOfGamerWithSmallBlind = [[JSONParser getNSNumberWithObject:dictionary[@"numberOfPlayerWithSmallBlind"]] intValue];
    numberOfGamerWithBigBlind = (numberOfGamerWithSmallBlind + 1) % _countOfPlayersOnTheTable;
    
    NSNumber *valueOfBigBlind = [JSONParser getNSNumberWithObject:dictionary[@"betOfBigBlind"]];
    NSNumber *valueOfSmallBlind = [NSNumber numberWithLongLong:[valueOfBigBlind longLongValue] / 2];
    
    [self updateGamerBetAndMoneyOnTheTable:numberOfGamerWithBigBlind andValue:valueOfBigBlind];
    [self updateGamerBetAndMoneyOnTheTable:numberOfGamerWithSmallBlind andValue:valueOfSmallBlind];
}

- (int)numberOfGamerWithName:(NSString *)gamerName {
    int i=0;
    for(Gamer *gamer in self.arrayOfPlayersOnTheTable) {
        if([gamer.name isEqualToString:gamerName]) return i;
        i++;
    }
    
    return -1;
}

- (BOOL)isCurrentGamerMe:(NSString *)gamerName { return ([gamerName hash] == self.hashValueOfGamerName) ? YES : NO; }
- (BOOL)shouldIMakeTheBet { return (_numberOfMeInGamersList == _numberOfCurrentProgressView) ? YES : NO; }

- (void)parseInformationAboutGamers:(NSDictionary *)dictionary {
    self.countOfPlayersOnTheTable = [[JSONParser getNSNumberWithObject:dictionary[@"countOfGamers"]] intValue];
    
    for (int i=0; i<self.countOfPlayersOnTheTable; i++) {
        NSString *gamerOfNumber = [NSString stringWithFormat:@"gamer%i", i+1];
        
        NSDictionary *generalInfoAboutGamer = [JSONParser getNSDictionaryWithObject:dictionary[gamerOfNumber]];
        [self addPlayerOnTheTable:generalInfoAboutGamer];
        if([self isCurrentGamerMe:generalInfoAboutGamer[@"name"]]) self.numberOfMeInGamersList = i;
    }
    
    [self renderingPlayersOnTheTable];
    [self changeCornerRadiusOfCards:self.countOfPlayersOnTheTable];
    [self changeCornerRadiusOfPlayersViews:self.countOfPlayersOnTheTable];
    [self rotateRightPrivateCardOfPlayers:self.countOfPlayersOnTheTable];
    //Information about gamers is rendered.

}

#define COUNT_CARDS_ON_THE_TABLE 5
#define COUNT_OPENED_CARDS_ON_FIRST_FLOP 3
#define COUNT_OPENED_CARDS_ON_ANOTHERE_FLOPS 1

- (void)openCardsOnTheTable:(BOOL)isAllCards {
    int countOfCardNeedOpen = _openedCardsOnTheTable ? COUNT_OPENED_CARDS_ON_ANOTHERE_FLOPS : COUNT_OPENED_CARDS_ON_FIRST_FLOP;
    
    if(isAllCards) countOfCardNeedOpen = COUNT_CARDS_ON_THE_TABLE - _openedCardsOnTheTable;
    
    for(int i=_openedCardsOnTheTable; i < _openedCardsOnTheTable + countOfCardNeedOpen; i++)
    {
        [self rotateCardOnTheTableAtIndex:i andImage:[self.arrayOfImagesCardsOnTheTable objectAtIndex:i]];
    }
    _openedCardsOnTheTable += countOfCardNeedOpen;
}
- (void)rotateCardOnTheTableAtIndex:(int)numberInArray andImage:(UIImageView *)image {
    NSString *pictureOfCard = [[NSString alloc]initWithFormat:@"%@", [self.arrayOfCardsOnTheTable objectAtIndex:numberInArray]];
    
        [UIView animateWithDuration:2.0 animations:^{
            image.transform = CGAffineTransformMakeScale(0.01, 1.0);
        } completion:^(BOOL finished) {
            image.transform = CGAffineTransformMakeScale(1.0, 1.0);
            [image setImage:[UIImage imageNamed:pictureOfCard]];
        }];

   // NSLog(@"card :  !!! --->>>   %@   | %i", pictureOfCard, numberInArray);
}


- (void)parseInformationAboutGameCards:(NSDictionary *)dictionary {
   NSDictionary *dictionaryWithInfoAboutCards = [JSONParser getNSDictionaryWithObject:dictionary[@"cards"]];
    if(!_arrayOfCardsOnTheTable) _arrayOfCardsOnTheTable = [[NSMutableArray alloc] init];
    
    NSNumber *card;
    NSString *keyWord;

    for (int i=0; i<5; i++) {
        keyWord = [NSString stringWithFormat:@"cardOfNumber_%i", (i+1)];
        card = [JSONParser getNSNumberWithObject:dictionaryWithInfoAboutCards[keyWord]];
        
        [_arrayOfCardsOnTheTable addObject:card];
        NSLog(@" -> card : %@", card);
    }
    NSNumber *firstPrivateCard  = [JSONParser getNSNumberWithObject:dictionaryWithInfoAboutCards[@"firstPrivateCard"]];
    NSNumber *secondPrivateCard = [JSONParser getNSNumberWithObject:dictionaryWithInfoAboutCards[@"secondPrivateCard"]];
    
    [self setPrivateCardsForGeneralGamer:firstPrivateCard andSecondPrivateCard:secondPrivateCard];
    [self renderingPrivateCardsOfGeneralGamer];
   // [self openCardsOnTheTable:YES];
}


- (void)parseAndRenderInfoAboutCurrentGamer:(NSDictionary *)dictionary andTitle:(NSString *)title{
    if([title isEqualToString:@"InformationAboutCurrentGamer"]) {
        
        NSNumber *numberOfCurrentGamer = [JSONParser getNSNumberWithObject:dictionary[@"numberOfCurrentGamer"]];
        if([numberOfCurrentGamer intValue] == _numberOfMeInGamersList) _isMyHandRightNow = YES;
        
        [self startProgressViewAtIndex:[numberOfCurrentGamer intValue]];
        
        if([self shouldIMakeTheBet]) {
            self.currentMinBet = [JSONParser getNSNumberWithObject:dictionary[@"minBet"]];
            [self unlockTheBetButtons];
            [self updateMessageFromServerLabel];
        }
        
    } else if([title isEqualToString:@"CurrentBetOfGamer"]) {
        
        [self stopCurrentProgressView];
        NSNumber *betOfGamer = [JSONParser getNSNumberWithObject:dictionary[@"betOfPlayer"]];
        NSNumber *numberOfPlayer = [JSONParser getNSNumberWithObject:dictionary[@"numberOfCurrentGamer"]];
        
        [self updateGamerBetAndMoneyOnTheTable:[numberOfPlayer intValue] andValue:betOfGamer];
        //[self lockTheBetButtons];
    }
}


- (void)updateGamerBetAndMoneyOnTheTable:(int)indexOfGamer andValue:(NSNumber *)currentBet {
   long bet = [currentBet longValue];
    
    if(bet >= 0) {
        UILabel *betLabel = [self.arrayOfLabelsGamerRates objectAtIndex:indexOfGamer];
        UILabel *moneyLabel = [self.arrayOfLabelsPlayersMoneys objectAtIndex:indexOfGamer];
        
        Gamer *gamer = [self.arrayOfPlayersOnTheTable objectAtIndex:indexOfGamer];
        gamer.rate  += bet;
        gamer.money = [NSNumber numberWithLong:[gamer.money longValue] - bet];
        
        NSString *moneyOfGamerString = [self prepareGamerMoneyBeforeRendering:gamer.money];
        NSString *betOfGamerString = [self prepareGamerMoneyBeforeRendering:[NSNumber numberWithLong:gamer.rate]];
    
        [betLabel setAttributedText:[self attributedStringForInfoAboutGamerInView:betOfGamerString]];
        [moneyLabel setAttributedText:[self attributedStringForInfoAboutGamerInView:moneyOfGamerString]];
        
        [self setViewVisible:betLabel];
    } else
        [self setFoldForGamerAtIndex:indexOfGamer];
}


- (void)collectionsOfGamersBets {
    long bets = 0;
    for(Gamer *gamer in self.arrayOfPlayersOnTheTable) {
        bets += gamer.rate;
        gamer.rate = 0;
    }
    
    _moneyOnTheTable = [NSNumber numberWithLong:bets + [_moneyOnTheTable longValue]];
    NSString *bankOnTheTable = [self prepareGamerMoneyBeforeRendering:_moneyOnTheTable];
    [self.generalBankLabel setAttributedText:[self attributedStringForInfoAboutGamerInView:bankOnTheTable]];
    
    [self hideAllGamersBets];
}

- (void)hideAllGamersBets { for(UILabel *rate in self.arrayOfLabelsGamerRates) [self setViewUnvisible:rate]; }

- (void)setFoldForGamerAtIndex:(int)index
{
    [[self.arrayOfPlayersImages objectAtIndex:index] setAlpha:0.5];
    [[self.arrayOfLabelsPlayersMoneys objectAtIndex:index] setAlpha:0.5];
    [[self.arrayOfLabelsPlayersNames objectAtIndex:index] setAlpha:0.5];
}

- (void)updateMessageFromServerLabel {
    Gamer *generalGamer = [self.arrayOfPlayersOnTheTable objectAtIndex:self.numberOfMeInGamersList];
    
    NSString *message;
    if(generalGamer.rate == [self.currentMinBet intValue])
        message = [NSString stringWithFormat:@"CHECK $%@ or RAISE ?", _currentMinBet];
    else
        message = [NSString stringWithFormat:@"CALL $%@ or RAISE", _currentMinBet];
    
    [self.messageFromServerLabel setText:message];
    [self setViewVisible:_messageFromServerLabel];
}

#define DEFAULT_TEXT_LENGTH_GAMERS_ICON_VIEW 9
#define DEFAULT_TEXT_SIZE_GAMER_ICON_VIEW 17

#define LENGTH_DISCHARGE_THOUSANDS 3

- (int)sizeForAttributedTextGamerIconView:(NSString *)string {
    int length = (int)[string length];
    int needSize = (DEFAULT_TEXT_SIZE_GAMER_ICON_VIEW - (length - DEFAULT_TEXT_LENGTH_GAMERS_ICON_VIEW));
    
    return needSize > DEFAULT_TEXT_SIZE_GAMER_ICON_VIEW ? DEFAULT_TEXT_SIZE_GAMER_ICON_VIEW : needSize;
}
- (NSAttributedString *)attributedStringForInfoAboutGamerInView:(NSString *)string {
    int size = [self sizeForAttributedTextGamerIconView:string];
    
    NSAttributedString *attribString = [[NSAttributedString alloc] initWithString:string attributes:@{
            NSFontAttributeName : [UIFont systemFontOfSize: size],
    }];
    
    return attribString;
}
- (NSString *)prepareGamerMoneyBeforeRendering:(NSNumber *)money {
    NSString *gamerMoney = [NSString stringWithFormat:@"%@", money];
    NSString *resultString = @"$";
    
    int countOfFirstNumbers = [gamerMoney length] % LENGTH_DISCHARGE_THOUSANDS;
    
    resultString = [resultString stringByAppendingString:[gamerMoney substringWithRange:NSMakeRange(0, countOfFirstNumbers)]];
    
    for(int i=countOfFirstNumbers; i < [gamerMoney length]; i+=LENGTH_DISCHARGE_THOUSANDS) {
        NSString *partOfString = [NSString stringWithFormat:@" %@", [gamerMoney substringWithRange:NSMakeRange(i, LENGTH_DISCHARGE_THOUSANDS)]];
        resultString = [resultString stringByAppendingString:partOfString];
    }
    return resultString;
}

- (void)renderingPlayersOnTheTable {
    int numberOfPlayer = 0;
    for(Gamer *gamer in self.arrayOfPlayersOnTheTable) {
        UILabel *gamerName = [self.arrayOfLabelsPlayersNames objectAtIndex:numberOfPlayer];
        UILabel *gamerMoney = [self.arrayOfLabelsPlayersMoneys objectAtIndex:numberOfPlayer];
        UIImageView *gamerImage = [self.arrayOfPlayersImages objectAtIndex:numberOfPlayer];
        
        NSString *gamerMoneyText = [self prepareGamerMoneyBeforeRendering:gamer.money];
        
        [gamerMoney setAttributedText:[self attributedStringForInfoAboutGamerInView:gamerMoneyText]];
        [gamerName setAttributedText:[self attributedStringForInfoAboutGamerInView:gamer.name]];
        
        [self setViewVisible:gamerName];
        [self setViewVisible:gamerMoney];
        [self setViewVisible:gamerImage];
        
        numberOfPlayer++;
    }
}

- (void)setViewVisible:(UIView *)view   { [view setAlpha:1.0]; }
- (void)setViewUnvisible:(UIView *)view { [view setAlpha:0.0]; }

- (void)renderingPrivateCardsOfGeneralGamer {
    Gamer *generalGamer = [self.arrayOfPlayersOnTheTable objectAtIndex:self.numberOfMeInGamersList];
    
    UIImageView *firstPrivateCardImage = [self.arrayOfImagesPrivatePlayersCard objectAtIndex:self.numberOfMeInGamersList * 2];
    UIImageView *secondPrivateCardImage = [self.arrayOfImagesPrivatePlayersCard objectAtIndex:self.numberOfMeInGamersList * 2 + 1];
    
    NSString *imageNameOfFirstPrivateCard =  [NSString stringWithFormat:@"%i", generalGamer.firstPrivateCard];
    NSString *imageNameOfSecondPrivateCard = [NSString stringWithFormat:@"%i", generalGamer.secondPrivateCard];
    
    
    [firstPrivateCardImage setImage:[UIImage imageNamed:imageNameOfFirstPrivateCard]];
    [secondPrivateCardImage setImage:[UIImage imageNamed:imageNameOfSecondPrivateCard]];
    
    [self setVisibleCardsAllGamers];
}

- (void)setVisibleCardsAllGamers {
    for(int i=0; i<self.countOfPlayersOnTheTable * 2; i++)
        [[self.arrayOfImagesPrivatePlayersCard objectAtIndex:i] setAlpha:1.0];
}

- (void)addPlayerOnTheTable:(NSDictionary *)generalInfoAboutGamer
{
    
    if(!self.arrayOfPlayersOnTheTable)
        self.arrayOfPlayersOnTheTable = [[NSMutableArray alloc] init];
    
    NSDictionary *netInfoAboutGamer = [JSONParser getNSDictionaryWithObject:generalInfoAboutGamer[@"netInformation"]];
    
    NSString *gamerName =  [JSONParser getNSStringWithObject:generalInfoAboutGamer[@"name"]];
    NSNumber *gamerMoney = [JSONParser getNSNumberWithObject:generalInfoAboutGamer[@"money"]];
    NSNumber *gamerLevel = [JSONParser getNSNumberWithObject:generalInfoAboutGamer[@"level"]];
    
    NSString *IpAddressOfGamer =[JSONParser getNSStringWithObject:netInfoAboutGamer[@"ipAddress"]];
    NSNumber *portOfGamer =     [JSONParser getNSNumberWithObject:netInfoAboutGamer[@"port"]];
    
    Gamer *gamer = [[Gamer alloc] initWithInfo:gamerName andMoney:gamerMoney andLevel:[gamerLevel intValue]];
    [gamer setFurtherNetInformation:IpAddressOfGamer andPort:[portOfGamer intValue]];
    
    [self.arrayOfPlayersOnTheTable addObject:gamer];
}


- (void)setPrivateCardsForGeneralGamer:(NSNumber *)firstPrivateCard andSecondPrivateCard:(NSNumber *)secondPrivateCard {
    Gamer *generalGamer = [self.arrayOfPlayersOnTheTable objectAtIndex:self.numberOfMeInGamersList];
    [generalGamer setPrivateCards:[firstPrivateCard intValue] andSecondCard:[secondPrivateCard intValue]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)updateProgressView:(NSTimer *)timer
{
    NSInteger newCurrentValue;
    
    if (self.currentProgressView.currentValue == 0) {
        newCurrentValue = self.currentProgressView.maximumValue;
        [timer invalidate];
        timer = nil;
        [self hideCurrentProgressView];
        if([self shouldIMakeTheBet]) //[self passHand];
        return;
    } else {
        newCurrentValue = self.currentProgressView.currentValue - 1;
    }
    
    [self.currentProgressView updateToCurrentValue:newCurrentValue animated:YES];
}

- (void)startProgressViewAtIndex:(int)index {
    self.currentProgressView = [self.arrayOfGamersProgressView objectAtIndex:index];
    _numberOfCurrentProgressView = index;
    [self showCurrentProgressView];
    [self setTimerA];
}
- (void)stopCurrentProgressView   {
    if (!self.timer) return;
    
    _currentProgressView.currentValue = _currentProgressView.maximumValue;
    [self.timer invalidate];
     self.timer = nil;
    
    [self hideCurrentProgressView];
}
- (void)hideCurrentProgressView {  [self.currentProgressView setAlpha:0.0];  }
- (void)showCurrentProgressView {  [self.currentProgressView setAlpha:1.0];  }
- (void)setTimerA {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1.0f
                                                 target:self
                                               selector:@selector(updateProgressView:)
                                               userInfo:nil
                                                repeats:YES];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
