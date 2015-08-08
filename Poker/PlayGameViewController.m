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



@property(nonatomic, strong) NSMutableArray *arrayOfPlayersOnTheTable;
@property(nonatomic, strong) NSMutableArray *arrayOfCardsOnTheTable;
@property(nonatomic, strong) NSTimer *timer;

@property (nonatomic) int countOfPlayersOnTheTable;
@property (nonatomic) int numberOfMeInGamersList;
@property (nonatomic) int numberOfCurrentProgressView;

@property (nonatomic,strong) NSNumber *currentMinBet;

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




- (IBAction)raiseAction:(id)sender {
   // [self raiseHand];
}




- (IBAction)callAction:(id)sender {
    //[self callHand];
}


- (IBAction)checkAction:(id)sender {
    
}



- (IBAction)foldAction:(id)sender {
   // [self passHand];
}

//- (void)passHand {
//    NSDictionary *data = @{
//                           @"title" : @"CurrentBetOfGamer",
//                           @"numberOfPlayer"  : [NSNumber numberWithInt:self.numberOfMeInGamersList],
//                           @"betOfPlayer" : [NSNumber numberWithInt:-1],
//                        };
//    [self sendInfoAboutBet:[self createJSONDataFromData:data]];
//}
//
//- (void)callHand {
//        NSDictionary *data = @{
//                               @"title" : @"CurrentBetOfGamer",
//                               @"numberOfPlayer"  : [NSNumber numberWithInt:self.numberOfMeInGamersList],
//                               @"betOfPlayer" : self.currentMinBet,
//                               };
//        [self sendInfoAboutBet:[self createJSONDataFromData:data]];
//
//}
//
//- (void)raiseHand {
//    NSNumber *raisedBet = [NSNumber numberWithInt:[self.currentMinBet intValue] * 2];
//    NSDictionary *data = @{
//                           @"title" : @"CurrentBetOfGamer",
//                           @"numberOfPlayer"  : [NSNumber numberWithInt:self.numberOfMeInGamersList],
//                           @"betOfPlayer" : raisedBet,
//                           };
//    [self sendInfoAboutBet:[self createJSONDataFromData:data]];
//    
//}
//
//
//
//
//- (void)sendInfoAboutBet:(NSData*)data {
//    TCPConnection *connection = [TCPConnection sharedInstance];
//    [connection sendDataWithTag:data andTag:DATA_ABOUT_BETS];
//}
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
    
    self.countOfPlayersOnTheTable = 0;
}
- (void)clearTable
{
    //performance better, than if we use a (1)cycle.
    for(UILabel *nameLabel in self.arrayOfLabelsPlayersNames)   [nameLabel  setAlpha:0.0];
    for(UILabel *moneyLabel in self.arrayOfLabelsPlayersMoneys) [moneyLabel setAlpha:0.0];
    for(UIImageView *imageView in self.arrayOfPlayersImages)    [imageView  setAlpha:0.0];
    for(UIImageView *privateCardImage in self.arrayOfImagesPrivatePlayersCard) [privateCardImage setAlpha:0.0];
    for(UIView *progressView in self.arrayOfGamersProgressView) [progressView setAlpha:0.0];
    for(UILabel *rateLabel in self.arrayOfLabelsGamerRates) [rateLabel setAlpha:0.0];
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

- (NSDictionary *)convertToJSON:(NSData *)data {
    NSError *error = nil;
    id object = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    if(error) {
        NSLog(@"Error of NSJSONSerialization !");
    }
    
    if([object isKindOfClass:[NSDictionary class]]) {
        NSDictionary *dictionary = object;
        return dictionary;
    } else { return nil; }
}


- (NSDictionary *)downloadedJSONData {
    TCPConnection *connection = [TCPConnection sharedInstance];
    NSDictionary *dictionary = [NSDictionary dictionaryWithDictionary:[self convertToJSON:connection.downloadedData]];
    
    return (dictionary) ? dictionary : nil;
}

- (void)parseGameInformationFromServer {
    NSDictionary *dictionary = [self downloadedJSONData];
    
    if(!dictionary) {
        NSLog(@"Downloaded data isn't a JSON !");
        return; }
    
    NSString *titleOfJsonData = dictionary[@"title"];
    
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
    if(!dictionary) {
        NSLog(@"Downloaded data isn't a JSON !");
        return; }
    
    NSString *titleOfJsonData = dictionary[@"title"];
    [self stopCurrentProgressView];
    
    if([titleOfJsonData isEqualToString:@"InformationAboutBlinds"]) {
                [self renderingBlindsOfGamers: dictionary[@"blinds"]];
                [self readInformationAboutGamerBets];
    } else {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self parseAndRenderInfoAboutCurrentGamer:dictionary andTitle:titleOfJsonData];
        });
    }
}

- (void)renderingBlindsOfGamers:(NSDictionary *)dictionary {
    int numberOfGamerWithSmallBlind, numberOfGamerWithBigBlind;
    
    id firstBlind = dictionary[@"numberOfPlayerWithSmallBlind"];
    if(![firstBlind isKindOfClass:[NSNumber class]]) {NSLog(@"error of parser !"); return; }
    
    numberOfGamerWithSmallBlind = [firstBlind intValue];
    numberOfGamerWithBigBlind = (numberOfGamerWithSmallBlind + 1) % self.countOfPlayersOnTheTable;
    
    NSNumber *valueOfBigBlind = dictionary[@"betOfBigBlind"];
    NSNumber *valueOfSmallBlind = [NSNumber numberWithLongLong:[valueOfBigBlind longLongValue] / 2];
    
    
    UILabel *gamerWithBigBlindMoneyLabel = [self.arrayOfLabelsGamerRates objectAtIndex:numberOfGamerWithBigBlind];
    UILabel *gamerWithSmallBlindMoneyLabel = [self.arrayOfLabelsGamerRates objectAtIndex:numberOfGamerWithSmallBlind];

    NSString *betOfBigBlind = [self prepareGamerMoneyBeforeRendering:valueOfBigBlind];
    NSString *betOfSmallBlind = [self prepareGamerMoneyBeforeRendering:valueOfSmallBlind];
    
    [gamerWithBigBlindMoneyLabel setAttributedText:[self attributedStringForInfoAboutGamerInView:betOfBigBlind]];
    [gamerWithSmallBlindMoneyLabel setAttributedText:[self attributedStringForInfoAboutGamerInView:betOfSmallBlind]];
    
    [self setViewVisible:gamerWithBigBlindMoneyLabel];
    [self setViewVisible:gamerWithSmallBlindMoneyLabel];
    [gamerWithBigBlindMoneyLabel setAlpha:1.0];
    NSLog(@"@DSFDSFDSFSSDF");
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
- (BOOL)shouldIMakeTheBet { return (self.numberOfMeInGamersList == self.numberOfCurrentProgressView) ? YES : NO; }

- (void)parseInformationAboutGamers:(NSDictionary *)dictionary {
  
    id data = dictionary[@"countOfGamers"];
    if([data isKindOfClass:[NSNumber class]]) {
        self.countOfPlayersOnTheTable =[(NSNumber *)data intValue];
    }
    
    for (int i=0; i<self.countOfPlayersOnTheTable; i++) {
        NSString *gamerOfNumber = [NSString stringWithFormat:@"gamer%i", i+1];
        NSDictionary *generalInfoAboutGamer = [NSDictionary dictionaryWithDictionary:dictionary[gamerOfNumber]];
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

- (void)parseInformationAboutGameCards:(NSDictionary *)dictionary {
    NSDictionary *dictionaryWithInfoAboutCards = [NSDictionary dictionaryWithDictionary:dictionary[@"cards"]];
    
    NSNumber *card;
    NSString *keyWord;
    
    for (int i=0; i<COUNT_CARDS_ON_THE_TABLE; i++) {
        keyWord = [NSString stringWithFormat:@"cardOfNumber_%i", (i+1)];
        card = dictionaryWithInfoAboutCards[keyWord];
        
        [self.arrayOfCardsOnTheTable addObject:card];
    }
    NSNumber *firstPrivateCard = dictionaryWithInfoAboutCards[@"firstPrivateCard"];
    NSNumber *secondPrivateCard = dictionaryWithInfoAboutCards[@"secondPrivateCard"];
    
    [self setPrivateCardsForGeneralGamer:firstPrivateCard andSecondPrivateCard:secondPrivateCard];
    [self renderingPrivateCardsOfGeneralGamer];
}


- (void)parseAndRenderInfoAboutCurrentGamer:(NSDictionary *)dictionary andTitle:(NSString *)title{
    if([title isEqualToString:@"InformationAboutCurrentGamer"]) {
        id data = dictionary[@"numberOfCurrentGamer"];
        if(![data isKindOfClass:[NSNumber class]]) { NSLog(@"error of parser"); return; }
        
        NSNumber *numberOfCurrentGamer = (NSNumber *)data;
        [self startProgressViewAtIndex:[numberOfCurrentGamer intValue]];
        
        if([self shouldIMakeTheBet]) {
            self.currentMinBet = dictionary[@"minBet"];
            [self unlockTheBetButtons];
        } else;
            //[self readInformationAboutGamerBets];
    } else if([title isEqualToString:@"CurrentBetOfGamer"]) {
        [self stopCurrentProgressView];
        NSNumber *betOfGamer = [dictionary objectForKey:@"betOfPlayer"];
        NSNumber *numberOfPlayer = [dictionary objectForKey:@"numberOfPlayer"];
        
        UILabel *currentBetLabel = [self.arrayOfLabelsGamerRates objectAtIndex:[numberOfPlayer intValue]];
        [currentBetLabel setText:[NSString stringWithFormat:@"$%@", betOfGamer]];
        [self setViewVisible:currentBetLabel];
        //[self readInformationAboutGamerBets];
    }
}



- (void)updateMessageFromServerLabel {
    Gamer *generalGamer = [self.arrayOfPlayersOnTheTable objectAtIndex:self.numberOfMeInGamersList];
    
    NSString *message;
    if(generalGamer.rate == [self.currentMinBet intValue])
        message = [NSString stringWithFormat:@"CHECK or RAISE ?"];
    else
        message = [NSString stringWithFormat:@"CALL $%@ or RAISE", self.currentMinBet];
    
    [self.messageFromServerLabel setText:message];
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

- (void)setViewVisible:(UIView*)view { [view setAlpha:1.0]; }

- (void)renderingPrivateCardsOfGeneralGamer {
    Gamer *generalGamer = [self.arrayOfPlayersOnTheTable objectAtIndex:self.numberOfMeInGamersList];
    
    UIImageView *firstPrivateCardImage = [self.arrayOfImagesPrivatePlayersCard objectAtIndex:self.numberOfMeInGamersList * 2];
    UIImageView *secondPrivateCardImage = [self.arrayOfImagesPrivatePlayersCard objectAtIndex:self.numberOfMeInGamersList * 2 + 1];
    
    NSString *imageNameOfFirstPrivateCard = [NSString stringWithFormat:@"%i", generalGamer.firstPrivateCard];
    NSString *imageNameOfSecondPrivateCard = [NSString stringWithFormat:@"%i", generalGamer.secondPrivateCard];
    
    
    [firstPrivateCardImage setImage:[UIImage imageNamed:imageNameOfFirstPrivateCard]];
    [secondPrivateCardImage setImage:[UIImage imageNamed:imageNameOfSecondPrivateCard]];
    
    [self setVisibleCardsAllGamers];
}

- (void)setVisibleCardsAllGamers {
    for(int i=0; i<self.countOfPlayersOnTheTable * 2; i++)
        [[self.arrayOfImagesPrivatePlayersCard objectAtIndex:i] setAlpha:1.0];
}

- (void)animationHandingOutCardsToGeneralGamer:(UIImageView *)firstCard andSecondCard:(UIImageView *)secondCard {
    UIImageView *gamerImage = [self.arrayOfPlayersImages objectAtIndex:self.numberOfMeInGamersList];
    
    //self.view.frame.origin.x
    CGPoint pointOfFirstCard = CGPointMake(gamerImage.frame.origin.x, gamerImage.frame.origin.y);
    CGPoint pointOfSecondCard = CGPointMake(gamerImage.frame.origin.x + 20, gamerImage.frame.origin.y);
    [firstCard setCenter:CGPointMake(100, 50)];
    [secondCard setCenter:CGPointMake(120, 50)];
    
    [firstCard setAlpha:1.0];
    [secondCard setAlpha:1.0];
    
           [UIView animateWithDuration:1.0 delay:0.0 usingSpringWithDamping:1.5 initialSpringVelocity:0.5 options:0 animations:^{
            
            } completion:^(BOOL finished) {
                
            }];
}


- (void)addPlayerOnTheTable:(NSDictionary *)generalInfoAboutGamer
{
    
    if(!self.arrayOfPlayersOnTheTable)
        self.arrayOfPlayersOnTheTable = [[NSMutableArray alloc] init];
    
    NSDictionary *netInfoAboutGamer = [NSDictionary dictionaryWithDictionary:generalInfoAboutGamer[@"netInformation"]];
    
    NSString *gamerName = generalInfoAboutGamer[@"name"];
    NSNumber *gamerMoney = generalInfoAboutGamer[@"money"];
    NSNumber *gamerLevel = generalInfoAboutGamer[@"name"];
    
    NSString *IpAddressOfGamer = netInfoAboutGamer[@"ipAddress"];
    NSNumber *portOfGamer = netInfoAboutGamer[@"port"];
    
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
    [self showCurrentProgressView];
    [self setTimerA];
}
- (void)stopCurrentProgressView   {
    if (!self.timer) return;
        
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
