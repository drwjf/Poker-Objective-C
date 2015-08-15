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
#import "SoundManager.h"

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

@property (nonatomic, strong) NSArray *arrayOfCheckedBetButtons;

@property (nonatomic,strong) NSNumber *currentMinBet;
@property (nonatomic, strong)NSNumber *moneyOnTheTable;

@property (strong, nonatomic) IBOutlet UIButton *foldButton;
@property (strong, nonatomic) IBOutlet UIButton *checkButton;
@property (strong, nonatomic) IBOutlet UIButton *CheckFoldButton;
@property (strong, nonatomic) IBOutlet UIButton *callButton;
@property (strong, nonatomic) IBOutlet UIButton *raiseButton;
@property (strong, nonatomic) IBOutlet UIButton *callAnyButton;
@property (strong, nonatomic) IBOutlet UISlider *raiseRateSlider;
@property (strong, nonatomic) IBOutlet UILabel *currentPossibleBetLabel;


@property (strong, nonatomic) IBOutlet UIButton *makeScreenshortButton;
@property (strong, nonatomic) IBOutlet UIButton *showCombinationButton;

@property (strong, nonatomic) IBOutlet UILabel *messageFromServerLabel;
@property (strong, nonatomic) IBOutlet UITextView *consoleTextField;
@property (weak, nonatomic) IBOutlet UIButton *sendMessageButton;

@end

@implementation PlayGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _arrayOfCheckedBetButtons = [NSArray arrayWithObjects:_callAnyButton, _CheckFoldButton, _foldButton, _checkButton, nil];
    
    
    [self setViewUnvisible:_raiseRateSlider];
    [self setViewUnvisible:_currentPossibleBetLabel];
    [self changeCornerRadiusOfBetButtons];
    [self prepareBeforeGameProcess];
    [self readInformationAboutGamersOnTheTable];
}


- (void)setDefaultGamerMoney {
    Gamer *gamer = [self.arrayOfPlayersOnTheTable objectAtIndex:_numberOfMeInGamersList];
    
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:gamer.money forKey:@"money"];
    [userDefaults synchronize];
}
- (long)differenceCurrentGamerRateAndMinBet {
    Gamer *generalGamer = [self.arrayOfPlayersOnTheTable objectAtIndex:self.numberOfMeInGamersList];
    long diff = [self.currentMinBet longValue] - generalGamer.rate;
    
    return diff;
}

#pragma mark - Make bet IBAction methods

#define BET_CHECK 0
#define BET_FOLD -1

- (IBAction)gamerHandAction:(UIButton *)sender {
    NSData *jsonData = nil;
    long currentBet = 0;
    NSString *currentSound;

    if([sender isEqual:_foldButton])   {
        if(![self shouldIMakeTheBet])  { [self checkUncheckForButton:sender]; return; }
        
         currentBet = BET_FOLD;
         jsonData = [self createJSONGamerAnswerWithBet:[NSNumber numberWithLong:BET_FOLD]];
         currentSound = @"Pass.caf";
    } else
    if([sender isEqual:_checkButton])  {
        if(![self shouldIMakeTheBet])  { [self checkUncheckForButton:sender]; return; }
        
        currentBet = BET_CHECK;
         jsonData = [self createJSONGamerAnswerWithBet:[NSNumber numberWithLong:BET_CHECK]];
         currentSound = @"Check.caf";
    } else
    if ([sender isEqual:_callButton]) {
        currentBet = [self differenceCurrentGamerRateAndMinBet];
        currentSound = @"Raise.caf";
        
        jsonData = [self createJSONGamerAnswerWithBet:[NSNumber numberWithLong:currentBet]];
    } else
    if ([sender isEqual:_raiseButton]) {
        currentBet = [self.currentMinBet longValue] * 2;
        currentSound = @"Raise.caf";
        
        if(![self doIHaveSoMoneyInWallet:currentBet]) return; //I haven't got so much money to raise X2.
        
        jsonData = [self createJSONGamerAnswerWithBet:[NSNumber numberWithLong:currentBet]];
    }
    
    if([self shouldIMakeTheBet])  {
        [self makeBetAndUpdateDataWithView:jsonData andBet:currentBet];
        [self playSound:currentSound];
    }
}
- (IBAction)checkFold_CallAny_Action:(UIButton *)sender {
    [self checkUncheckForButton:sender];
}
- (IBAction)raiseRateWithSliderAction:(UIButton *)sender {
    [self setViewVisible:_raiseRateSlider];
    [self setViewVisible:_currentPossibleBetLabel];
    
    [_raiseRateSlider setMinimumValue:[self.currentMinBet longValue]];
    [_raiseRateSlider setMaximumValue:[[self getMyMoneyInMyWallet] longValue]];
}
- (IBAction)changePossibleRateAction:(UISlider *)sender {
    NSString *betOfGamerString = [self prepareGamerMoneyBeforeRendering:[NSNumber numberWithFloat:sender.value]];
    
    [_currentPossibleBetLabel setAttributedText:[self attributedStringForInfoAboutGamerInView:betOfGamerString]];
}
- (IBAction)touchDragExit:(UISlider *)sender {
    long value = (long)sender.value;
    
    NSNumber *bet =  [NSNumber numberWithLong:value];
    [self makeBetAndUpdateDataWithView:[self createJSONGamerAnswerWithBet:bet] andBet:[bet longValue]];
    
    [self setViewUnvisible:_raiseRateSlider];
    [self setViewUnvisible:_currentPossibleBetLabel];
 
}


- (void)checkUncheckForButton:(UIButton *)sender {
    sender.tag = !sender.tag;
    [self setImageForButton:sender andCheck:sender.tag];
    [self resetCheckForAllBetButtonsExcept:sender];
}
- (void)resetCheckForAllBetButtonsExcept:(UIButton *)sender {
    for(UIButton *button in self.arrayOfCheckedBetButtons) {
        if(![sender isEqual:button]) {
            button.tag = 0;
            [self setImageForButton:button andCheck:NO];
        }
    }
}


- (void)makeBetAndUpdateDataWithView:(NSData *)jsonData andBet:(long)bet {
    [self sendInfoAboutBet:jsonData];
    [self stopCurrentProgressView];
    [self updateGamerBetAndMoneyOnTheTable:_numberOfMeInGamersList andValue:[NSNumber numberWithLong:bet] andIsBank:NO];
    [self setViewUnvisible:_messageFromServerLabel];
    [self resetCheckForAllBetButtonsExcept:nil];
    [self lockNeedButtonsPrematureMakingBet];
}


- (BOOL)doIHaveSoMoneyInWallet:(long)summ {
    Gamer *gamer = [self.arrayOfPlayersOnTheTable objectAtIndex:_numberOfMeInGamersList];
    
    return ([gamer.money longValue] >= summ) ? YES : NO;
}



- (void)lockNeesBetButtonsBeforeMakingBet {
    BOOL check = [_currentMinBet longValue] == BET_CHECK;
    
    [_checkButton setEnabled:check];
        
    [_callButton setEnabled:YES];
    [_foldButton setEnabled:YES];
    [_raiseButton setEnabled:YES];
    
    [self.CheckFoldButton setEnabled:NO];
    [self.callAnyButton setEnabled:NO];
}
- (void)lockNeedButtonsPrematureMakingBet {
    [_callAnyButton setEnabled:YES];
    [_CheckFoldButton setEnabled:YES];
    [_checkButton setEnabled:YES];
    [_foldButton setEnabled:YES];
    
    [_callButton setEnabled:NO];
    [_raiseButton setEnabled:NO];
}


- (BOOL)makePrematureBet {
    BOOL flag = NO;
    
    for(UIButton *betButton in self.arrayOfCheckedBetButtons) {
        if(!betButton.tag) continue;
        
        if([betButton isEqual:_CheckFoldButton]  || [betButton isEqual:_checkButton]) {
            if([_currentMinBet longValue] == BET_CHECK) {
                [self gamerHandAction:_checkButton]; flag = YES;
            } else if (![betButton isEqual:_checkButton]) {
                [self gamerHandAction:_foldButton];  flag = YES;
            }
        } else if([betButton isEqual:_foldButton]) {
            [self gamerHandAction:_foldButton];  flag = YES;
        } else { [self gamerHandAction:_callButton];   flag = YES; }
    }
    
    return flag;
}

- (NSNumber *)getMyMoneyInMyWallet {
    Gamer *gamer = [self.arrayOfPlayersOnTheTable objectAtIndex:_numberOfMeInGamersList];
    return gamer.money;
}


- (NSArray *)arrayOfCheckedBetButtons {
    if (_arrayOfCheckedBetButtons) _arrayOfCheckedBetButtons = [NSArray arrayWithObjects:_callAnyButton, _CheckFoldButton, _foldButton, _checkButton, nil];
    
    return _arrayOfCheckedBetButtons;
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


#pragma mark - Methods for sending data with tag

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

#pragma mark - Render scene methods in start of round

- (void)prepareBeforeGameProcess {
    [self clearTable];
    [self resetValueOfGenralVariable];
    [self resetCheckForAllBetButtonsExcept:nil];
}

- (void)resetValueOfGenralVariable {
    _countOfPlayersOnTheTable = 0;
    _moneyOnTheTable = [NSNumber numberWithLong:0];
    _countOfPlayersOnTheTable = 0;
    _openedCardsOnTheTable = 0;
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
    
    [self resetImageOfCardsOnTheTable];
}

- (void)resetImageOfCardsOnTheTable {
    for (UIImageView *image in self.arrayOfImagesCardsOnTheTable) {
        [self setViewUnvisible:image];
        [image setImage:[UIImage imageNamed:@"shirt"]];
    }
    
    for(UIImageView *imageOfPrivateCard in self.arrayOfImagesPrivatePlayersCard)
        [imageOfPrivateCard setImage:[UIImage imageNamed:@"shirt"]];
    
}

- (void)rotateRightPrivateCardOfPlayers: (int)countOfPlayers
{
    UIImageView *card;
    
    for(int i=0; i<countOfPlayers; i++) {
        card = [_arrayOfImagesPrivatePlayersCard objectAtIndex:i*2];
        card.transform = CGAffineTransformRotate(card.transform, M_PI_4/4);
    }
}

#pragma mark - Methods fr changing corner radius of views'

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

#define CORNER_RADIUS_CARD 6

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
    
    [self setCornerRadius:_sendMessageButton andRadius:CORNER_RADIUS_CARD];
    
    //rotate sliderRate
        [self.raiseRateSlider removeConstraints:self.raiseRateSlider.constraints];
        [self.raiseRateSlider setTranslatesAutoresizingMaskIntoConstraints:YES];
    self.raiseRateSlider.transform = CGAffineTransformRotate(self.raiseRateSlider.transform, 270.0/180*M_PI);
    
    [self setCornerRadius:_raiseRateSlider andRadius:CORNER_RADIUS_CARD * 2];
    [self setCornerRadius:_currentPossibleBetLabel andRadius:CORNER_RADIUS_CARD * 2];
}

- (NSDictionary *)downloadedJSONData {
    TCPConnection *connection = [TCPConnection sharedInstance];
    NSDictionary *dictionary =  [JSONParser convertJSONdataToNSDictionary:connection.downloadedData];
    
    return dictionary;
}

#pragma mark - Parse JSONData from server DELEGATES

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
    
    if([titleOfJsonData isEqualToString:@"InformationAboutBlinds"]) {
                [self renderingBlindsOfGamers: dictionary[@"blinds"]];
    } else if ([titleOfJsonData isEqualToString:@"OpenCardsOnTheTable"]){
        BOOL isAllCards = [JSONParser getBOOLValueWithObject:dictionary[@"allCards"]];
        [self collectionsOfGamersBets];
        [self openCardsOnTheTable:isAllCards];
    } else if([titleOfJsonData isEqualToString:@"InfoAboutWinner"]) { //current GAMER OR HIM BET
            NSDictionary *info = [JSONParser getNSDictionaryWithObject:dictionary[@"information"]];
            [self parseInfoAboutWinner:info];
            return;
    } else if([titleOfJsonData isEqualToString:@"InfoAboutLastGamer"]) {
        [self parseInfoAboutWinnerWithUnnamedCards:dictionary];
        return;
    } else {
        [self parseAndRenderInfoAboutCurrentGamer:dictionary andTitle:titleOfJsonData];
    }
    [self readInformationAboutGamerBets];
}

- (void)parseInfoAboutWinner:(NSDictionary *)dictionary {
    NSMutableArray *arrayOfBestCard = [[NSMutableArray alloc] init];
    
    NSNumber *numberOfBestGamer = [JSONParser getNSNumberWithObject:dictionary[@"numberOfWinner"]];
    NSNumber *priority = [JSONParser getNSNumberWithObject:dictionary[@"priority"]];
    
    for(int i=0; i < 5; i++) {
        NSString *key = [NSString stringWithFormat:@"bestCard %i", i+1];
        NSNumber *card = [JSONParser getNSNumberWithObject:dictionary[key]];
        [arrayOfBestCard addObject:card];
    }
    
    Gamer *gamerWinner = [self.arrayOfPlayersOnTheTable objectAtIndex:[numberOfBestGamer intValue]];
    gamerWinner.firstPrivateCard  = (int)[[JSONParser getNSNumberWithObject:dictionary[@"firstPrivateCard"]] longValue];
    gamerWinner.secondPrivateCard = (int)[[JSONParser getNSNumberWithObject:dictionary[@"secondPrivateCard"]] longValue];
    
    [self renderingWinnersCombination:arrayOfBestCard andNumberOfWinner:[numberOfBestGamer intValue] andPriorityOfCombination:[priority intValue]];
    
}
- (void)parseInfoAboutWinnerWithUnnamedCards:(NSDictionary *)dictionary {
    NSNumber *numberOfGamer = [JSONParser getNSNumberWithObject:dictionary[@"numberOfWinner"]];
    int index = [numberOfGamer intValue];
    [self setAlphaForAllGamersIconsExceptWinner:index];
    [self collectionsOfGamersBets];
    
    Gamer *gamer = [self.arrayOfPlayersOnTheTable objectAtIndex:index];
    [self addMessageToConsole:[NSString stringWithFormat:@"%@ wins with unnamed cards.", gamer.name]];
    [self updateGamerBetAndMoneyOnTheTable:index andValue:_moneyOnTheTable andIsBank:YES];
    
    [self waitAfterRaund];
}


- (void)setAlphaForAllGamersIconsExceptWinner:(int)indexOfWinner {
    for(int i=0; i < [self.arrayOfPlayersOnTheTable count]; i++) {
        
        if(i != indexOfWinner) {
            [[self.arrayOfLabelsPlayersMoneys objectAtIndex:i] setAlpha:0.5];
            [[self.arrayOfLabelsPlayersNames objectAtIndex:i] setAlpha:0.5];
            [[self.arrayOfPlayersImages objectAtIndex:i] setAlpha:0.5];
            [[self.arrayOfLabelsGamerRates objectAtIndex:i] setAlpha:0.5];
            
            
            [[self.arrayOfImagesPrivatePlayersCard objectAtIndex:i*2] setAlpha:0.5];
            [[self.arrayOfImagesPrivatePlayersCard objectAtIndex:i*2 + 1] setAlpha:0.5];
        }
    }
    
}

- (void)renderingBlindsOfGamers:(NSDictionary *)dictionary {
    int numberOfGamerWithSmallBlind, numberOfGamerWithBigBlind;
    
    numberOfGamerWithSmallBlind = [[JSONParser getNSNumberWithObject:dictionary[@"numberOfPlayerWithSmallBlind"]] intValue];
    numberOfGamerWithBigBlind = (numberOfGamerWithSmallBlind + 1) % _countOfPlayersOnTheTable;
    
    NSNumber *valueOfBigBlind = [JSONParser getNSNumberWithObject:dictionary[@"betOfBigBlind"]];
    NSNumber *valueOfSmallBlind = [NSNumber numberWithLongLong:[valueOfBigBlind longLongValue] / 2];
    
    [self updateGamerBetAndMoneyOnTheTable:numberOfGamerWithBigBlind andValue:valueOfBigBlind andIsBank:NO];
    [self updateGamerBetAndMoneyOnTheTable:numberOfGamerWithSmallBlind andValue:valueOfSmallBlind andIsBank:NO];
    
    [self showFirstThreeCardOnTheFlop];
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


#define MIN_COUNT_OF_GAMERS 2

- (void)parseInformationAboutGamers:(NSDictionary *)dictionary {
    int count = [[JSONParser getNSNumberWithObject:dictionary[@"countOfGamers"]] intValue];
    _countOfPlayersOnTheTable = count ? count : MIN_COUNT_OF_GAMERS;
    
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

- (void)renderingWinnersCombination:(NSMutableArray *)winnerCombination
                  andNumberOfWinner:(int)number
           andPriorityOfCombination:(int)priority
{
    
    Gamer *winner = [self.arrayOfPlayersOnTheTable objectAtIndex:number];
    
    UIImageView *firstPrivateCardOfWinnerImageView = [self.arrayOfImagesPrivatePlayersCard objectAtIndex:2 * number];
    UIImageView *secondPrivateCardOfWinnerImageView = [self.arrayOfImagesPrivatePlayersCard objectAtIndex:2 * number + 1];
    
    [firstPrivateCardOfWinnerImageView  setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%i", winner.firstPrivateCard]]];
    [secondPrivateCardOfWinnerImageView setImage:[UIImage imageNamed:[NSString stringWithFormat:@"%i", winner.secondPrivateCard]]];
    
    for(int i=0; i < COUNT_CARDS_ON_THE_TABLE; i++) {
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
    
    const int countOfPrivateCardOfGamer = 2;
    for(int i=0; i < countOfPrivateCardOfGamer; i++) {
        NSNumber *firstPrivateCardOfWinner = [NSNumber numberWithInt:winner.firstPrivateCard];
        NSNumber *secondPrivateCardOfWinner = [NSNumber numberWithInt:winner.secondPrivateCard];
        BOOL isFirstPrivateCardBest = NO;
        BOOL isSecondPrivateCardBest = NO;
        
        for(NSNumber *bestCard in winnerCombination) {
            if([firstPrivateCardOfWinner isEqual:bestCard]) isFirstPrivateCardBest = YES;
            if([secondPrivateCardOfWinner isEqual:bestCard]) isSecondPrivateCardBest = YES;
        }
        if(!isFirstPrivateCardBest)  [firstPrivateCardOfWinnerImageView setAlpha:0.5];
        if(!isSecondPrivateCardBest) [secondPrivateCardOfWinnerImageView setAlpha:0.5];
    }
    [self createMessageInConsoleAboutWinner:winnerCombination andPriorityOfCombination:priority andNumberOfWinner:number];
    [self setAlphaForAllGamersIconsExceptWinner:number];
    
    [self collectionsOfGamersBets];
    [self updateGamerBetAndMoneyOnTheTable:number andValue:_moneyOnTheTable andIsBank:YES];
    [self waitAfterRaund];
}

- (void)waitAfterRaund {
    
    [self playSound:@"winnerMusic.caf"];
    [NSTimer scheduledTimerWithTimeInterval:15.0 target:self selector:@selector(updateValueAfterRound) userInfo:nil repeats:NO];
}

- (void)updateValueAfterRound {
    [self.arrayOfPlayersOnTheTable removeAllObjects];
    [self.arrayOfCardsOnTheTable removeAllObjects];
    [self prepareBeforeGameProcess];
    [self readInformationAboutGamersOnTheTable];
}

#pragma mark - Something wrong !

#define CARD_OF_ONE_SUIT 13

- (void)createMessageInConsoleAboutWinner:(NSMutableArray *)array
                 andPriorityOfCombination:(int)priority
                        andNumberOfWinner:(int)index
{
    Gamer *gamer = [self.arrayOfPlayersOnTheTable objectAtIndex:index];
    
    NSMutableString *bestCombinationOfCard = [NSMutableString string];
    
    for(NSNumber *bestCard in array) {
        NSString *currentCardString = [self rankAndSuitForCard:[bestCard intValue]];
        [bestCombinationOfCard appendFormat:@"%@ ", currentCardString];
    }
    
    NSString *messageToConsole = [NSString stringWithFormat:@"%@ wins with %@ : %@", gamer.name, [self combinationAtPriority:priority], bestCombinationOfCard];
    
    [self addMessageToConsole:messageToConsole];
}

- (void)addMessageToConsole:(NSString *)message
{
    NSString *outMessage = [NSString stringWithFormat:@"%@\n[%@] %@", _consoleTextField.text,  [self currentTime], message];
    [_consoleTextField setText:outMessage];
}

- (void)openCardsOnTheTable:(BOOL)isAllCards {
    int countOfCardNeedOpen = _openedCardsOnTheTable ? COUNT_OPENED_CARDS_ON_ANOTHERE_FLOPS : COUNT_OPENED_CARDS_ON_FIRST_FLOP;
    
    if(isAllCards) countOfCardNeedOpen = COUNT_CARDS_ON_THE_TABLE - _openedCardsOnTheTable;
    
    for(int i=_openedCardsOnTheTable; i < _openedCardsOnTheTable + countOfCardNeedOpen; i++)
    {
        [self playSound:@"ShowCard.caf"];
        [self rotateCardOnTheTableAtIndex:i andImage:[self.arrayOfImagesCardsOnTheTable objectAtIndex:i]];
    }
    _openedCardsOnTheTable += countOfCardNeedOpen;
}

- (void)rotateCardOnTheTableAtIndex:(int)numberInArray andImage:(UIImageView *)image {
    NSString *pictureOfCard = [[NSString alloc]initWithFormat:@"%@", [self.arrayOfCardsOnTheTable objectAtIndex:numberInArray]];
    
    [UIView animateWithDuration:1.0 animations:^{
        [self setViewVisible:image];
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 animations:^{
            image.transform = CGAffineTransformMakeScale(0.01, 1.0);
        } completion:^(BOOL finished) {
            image.transform = CGAffineTransformMakeScale(1.0, 1.0);
            [image setImage:[UIImage imageNamed:pictureOfCard]];
        }];
    }];
}

- (void)showFirstThreeCardOnTheFlop {
    for(int i=0; i < 3; i++) {
        UIImageView *card = [self.arrayOfImagesCardsOnTheTable objectAtIndex:i];
        [self playSound:@"ShowCard.caf"];
        
        [UIView animateWithDuration:1.0 animations:^{
            [self setViewVisible:card];
        } completion:^(BOOL finished) {
            //[self startProgressViewAtIndex:_numberOfCurrentProgressView];
        }];
    }
    
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
    }
    NSNumber *firstPrivateCard  = [JSONParser getNSNumberWithObject:dictionaryWithInfoAboutCards[@"firstPrivateCard"]];
    NSNumber *secondPrivateCard = [JSONParser getNSNumberWithObject:dictionaryWithInfoAboutCards[@"secondPrivateCard"]];
    
    [self setPrivateCardsForGeneralGamer:firstPrivateCard andSecondPrivateCard:secondPrivateCard];
    [self renderingPrivateCardsOfGeneralGamer];
   // [self openCardsOnTheTable:YES];
}

- (void)parseAndRenderInfoAboutCurrentGamer:(NSDictionary *)dictionary andTitle:(NSString *)title{
    [self setViewUnvisible:_messageFromServerLabel];
    
    if([title isEqualToString:@"InformationAboutCurrentGamer"]) {
        NSNumber *numberOfCurrentGamer = [JSONParser getNSNumberWithObject:dictionary[@"numberOfCurrentGamer"]];

        [self startProgressViewAtIndex:[numberOfCurrentGamer intValue]];
        
        if([self shouldIMakeTheBet]) {
            self.currentMinBet = [JSONParser getNSNumberWithObject:dictionary[@"minBet"]];
            if([self makePrematureBet]) return; //If gamer maked premature bet
            
            [self lockNeesBetButtonsBeforeMakingBet];
            [self updateMessageFromServerLabel];
        } else
            [self lockNeedButtonsPrematureMakingBet];
    } else if([title isEqualToString:@"CurrentBetOfGamer"]) {
        
        [self stopCurrentProgressView];
        NSNumber *betOfGamer = [JSONParser getNSNumberWithObject:dictionary[@"betOfPlayer"]];
        NSNumber *numberOfPlayer = [JSONParser getNSNumberWithObject:dictionary[@"numberOfCurrentGamer"]];
        
        [self updateGamerBetAndMoneyOnTheTable:[numberOfPlayer intValue] andValue:betOfGamer andIsBank:NO];
    }
}


- (void)updateGamerBetAndMoneyOnTheTable:(int)indexOfGamer andValue:(NSNumber *)currentBet andIsBank:(BOOL)isBank {
   long bet = [currentBet longValue];
    UILabel *betLabel = [self.arrayOfLabelsGamerRates objectAtIndex:indexOfGamer];
    
    if(bet >= 0) {
        UILabel *moneyLabel = [self.arrayOfLabelsPlayersMoneys objectAtIndex:indexOfGamer];
        
        
        Gamer *gamer = [self.arrayOfPlayersOnTheTable objectAtIndex:indexOfGamer];
        gamer.rate  += bet;
        
        if(isBank)  { bet *= -1; _generalBankLabel.text = @""; }  //If Gamer wins money
        
        gamer.money = [NSNumber numberWithLong:[gamer.money longValue] - bet];
        
        NSString *moneyOfGamerString = [self prepareGamerMoneyBeforeRendering:gamer.money];
        NSString *betOfGamerString = [self prepareGamerMoneyBeforeRendering:[NSNumber numberWithLong:gamer.rate]];
    
        if(bet != 0 || isBank)
            [betLabel setAttributedText:[self attributedStringForInfoAboutGamerInView:betOfGamerString]];
        else [betLabel setText:@"check"];
        [moneyLabel setAttributedText:[self attributedStringForInfoAboutGamerInView:moneyOfGamerString]];
        
        [self setViewVisible:betLabel];
    } else {
        [self setFoldForGamerAtIndex:indexOfGamer];
        [betLabel setText:@"fold"];
    }
    
    [self setDefaultGamerMoney];
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
    
    [self playSound:@"Collect.caf"];
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
        message = @"CHECK or RAISE ?";
    else
        message = @"CALL or RAISE";
    
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
    
    [self addMessageToConsole:[NSString stringWithFormat:@"%@ joined to the game !", gamer.name]];
}


- (void)setPrivateCardsForGeneralGamer:(NSNumber *)firstPrivateCard andSecondPrivateCard:(NSNumber *)secondPrivateCard {
    Gamer *generalGamer = [self.arrayOfPlayersOnTheTable objectAtIndex:self.numberOfMeInGamersList];
    [generalGamer setPrivateCards:[firstPrivateCard intValue] andSecondCard:[secondPrivateCard intValue]];
}

#pragma mark - Get currentTime(format: HH:mm)

-(NSString*)currentTime {
    NSDate *currentDate = [NSDate date];

    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *strDate = [dateFormatter stringFromDate:currentDate];

    return strDate;
}

#pragma mark - Custom ProgressView methods

- (void)updateProgressView:(NSTimer *)timer
{
    NSInteger newCurrentValue;
    
    if (self.currentProgressView.currentValue == 0) {
        newCurrentValue = self.currentProgressView.maximumValue;
        [timer invalidate];
        timer = nil;
        [self hideCurrentProgressView];
        
        if([self shouldIMakeTheBet]) [self gamerHandAction:_foldButton];
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
    self.timer = [NSTimer scheduledTimerWithTimeInterval:2.0f
                                                 target:self
                                               selector:@selector(updateProgressView:)
                                               userInfo:nil
                                                repeats:YES];
}


#pragma mark - Methods for getting card and best combination

- (NSString *)combinationAtPriority:(int)priority {
    NSArray *arrayOfCombination  = @[@"HighCard", @"Pair", @"Two Pair", @"Threeofa Kind", @"Straight", @"Flush", @"Full House",@"Fourofa Kind", @"Straight  Flush"];
    
    if(priority <= [arrayOfCombination count])
        return [arrayOfCombination objectAtIndex:priority-1];
    return nil;
}

- (NSString *)rankAndSuitForCard:(int)card {
    NSArray *arrayOfRank = @[@"2", @"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"J",@"Q",@"K", @"A"];
    NSArray *arrayOfSuit = @[@"♣️", @"♠️", @"♦️", @"♥️"];
    
    int suit = card/CARD_OF_ONE_SUIT;
    int rank = card%CARD_OF_ONE_SUIT;
    
    if(suit < [arrayOfSuit count])
        return [NSString stringWithFormat:@"%@%@", [arrayOfRank objectAtIndex:rank], [arrayOfSuit objectAtIndex:suit]];
    
    return nil;
}


#pragma mark - Play sound method

-(void)playSound:(NSString*)file {
#if (TARGET_IPHONE_SIMULATOR)
    return;
#else
    [[SoundManager sharedManager] playSound:file looping:NO];
#endif
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
