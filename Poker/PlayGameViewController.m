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

//---tags----

@interface PlayGameViewController ()

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *arrayOfPlayersImages;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *arrayOfLabelsPlayersMoneys;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *arrayOfLabelsPlayersNames;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *arrayOfImagesCardsOnTheTable;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *arrayOfImagesPrivatePlayersCard;

@property(nonatomic, strong) NSMutableArray *arrayOfPlayersOnTheTable;
@property(nonatomic, strong) NSMutableArray *arrayOfCardsOnTheTable;

@property (nonatomic) int countOfPlayersOnTheTable;
@property (nonatomic) int numberOfMeInGamersList;



@end

@implementation PlayGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];

//    [self changeCornerRadiusOfPlayersViews:10];
//    [self rotateRightPrivateCardOfPlayers:10];
//    [self changeCornerRadiusOfCards:10];
    [self readInformationAboutGamersOnTheTable];
}

- (void)readInformationAboutGamersOnTheTable {
    TCPConnection *connection = [TCPConnection sharedInstance];
    connection.delegateForPlayGameVC = self;
    [connection readDataWithTag:GET_INFO_ABOUT_GAMERS];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self prepareBeforeGameProcess];
}

- (void)prepareBeforeGameProcess {
    [self clearTable];
    self.countOfPlayersOnTheTable = 0;
}



- (void)clearTable
{
    //performance better, than if we use a (1)cycle.
    for(UILabel *nameLabel in self.arrayOfLabelsPlayersNames)   [nameLabel  setAlpha:0.0];
    for(UILabel *moneyLabel in self.arrayOfLabelsPlayersMoneys) [moneyLabel setAlpha:0.0];
    for(UIImageView *imageView in self.arrayOfPlayersImages)    [imageView  setAlpha:0.0];
    for(UIImageView *privateCardImage in self.arrayOfImagesPrivatePlayersCard) [privateCardImage setAlpha:0.0];
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

- (void)parseGameInformationFromServer {
    TCPConnection *connection = [TCPConnection sharedInstance];
    
    NSDictionary *dictionary = [NSDictionary dictionaryWithDictionary:[self convertToJSON:connection.downloadedData]];
    if(!dictionary) {  NSLog(@"Downloaded data isn't a JSON !"); return; }
    
    NSString *titleOfJsonData = dictionary[@"title"];
    
        if([titleOfJsonData isEqualToString:@"InformationAboutGamers"])
          dispatch_async(dispatch_get_main_queue(), ^{
            [self parseInformationAboutGamers:dictionary];
          });
    
        if([titleOfJsonData isEqualToString:@"InformationAboutCards"])
          dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
                [self parseInformationAboutGameCards:dictionary];
          });
    
    
    
}

-(BOOL)isCurrentGamerMe:(NSString *)gamerName { return ([gamerName hash] == self.hashValueOfGamerName) ? YES : NO; }

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
    //Information about gamers is rendered.

}

#define COUNT_CARDS_ON_THE_TABLE 5

- (void)parseInformationAboutGameCards:(NSDictionary *)dictionary {
    NSNumber *card;
    NSString *keyWord;
    
    for (int i=0; i<COUNT_CARDS_ON_THE_TABLE; i++) {
        keyWord = [NSString stringWithFormat:@"cardOfNumber_%i", i+1];
        card = dictionary[keyWord];
        
        [self.arrayOfCardsOnTheTable addObject:card];
    }
    NSNumber *firstPrivateCard = dictionary[@"firstPrivateCard"];
    NSNumber *secondPrivateCard = dictionary[@"secondPrivateCard"];
    
    
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
- (NSString *)prepareGamerMoneyBeforeRendering:(int)money {
    NSString *gamerMoney = [NSString stringWithFormat:@"%i", money];
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
        
        [gamerName  setAlpha:1.0];
        [gamerMoney setAlpha:1.0];
        [gamerImage setAlpha:1.0];
        
        numberOfPlayer++;
    }
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


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
