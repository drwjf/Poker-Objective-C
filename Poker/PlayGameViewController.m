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

@property (nonatomic) int countOfPlayersOnTheTable;



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

- (void)parseMessageFromServer {
    
}

- (void)parseInformationAboutGamers {
    TCPConnection *connection = [TCPConnection sharedInstance];
    NSDictionary *dictionary = [NSDictionary dictionaryWithDictionary:[self convertToJSON:connection.downloadedData]];
    
    if(!dictionary) {
        NSLog(@"Downloaded data isn't a JSON !");
        return;
    }
  //  NSString *title = [NSString stringWithString:dictionary[@"title"]];
    NSString *infoAboutAmountGamer = dictionary[@"countOfGamers"];
    
    self.countOfPlayersOnTheTable =[infoAboutAmountGamer intValue];
    
    
    for (int i=0; i<self.countOfPlayersOnTheTable; i++) {
        NSString *gamerOfNumber = [NSString stringWithFormat:@"gamer%i", i+1];
        NSDictionary *generalInfoAboutGamer = [NSDictionary dictionaryWithDictionary:dictionary[gamerOfNumber]];
        [self addPlayerOnTheTable:generalInfoAboutGamer];
    }
    
    [self changeCornerRadiusOfCards:self.countOfPlayersOnTheTable];
    [self changeCornerRadiusOfPlayersViews:self.countOfPlayersOnTheTable];
    [self renderingPlayersOnTheTable];
}

- (void)renderingPlayersOnTheTable {
    int numberOfPlayer = 0;
    for(Gamer *gamer in self.arrayOfPlayersOnTheTable) {
        UILabel *gamerName = [self.arrayOfLabelsPlayersNames objectAtIndex:numberOfPlayer];
        UILabel *gamerMoney = [self.arrayOfLabelsPlayersMoneys objectAtIndex:numberOfPlayer];
        UIImageView *gamerImage = [self.arrayOfPlayersImages objectAtIndex:numberOfPlayer];
        
        gamerName.text = gamer.name;
        gamerMoney.text = [NSString stringWithFormat:@"$%i", gamer.money];
        
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
    NSString *gamerMoney = generalInfoAboutGamer[@"money"];
    NSString *gamerLevel = generalInfoAboutGamer[@"name"];
    NSString *IpAddressOfGamer = netInfoAboutGamer[@"ipAddress"];
    NSString *portOfGamer = netInfoAboutGamer[@"port"];
    
    Gamer *gamer = [[Gamer alloc] initWithInfo:gamerName andMoney:[gamerMoney intValue] andLevel:[gamerLevel intValue]];
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
