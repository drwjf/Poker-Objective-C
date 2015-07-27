//
//  PlayGameViewController.m
//  Poker
//
//  Created by Admin on 25.07.15.
//  Copyright (c) 2015 by.bsuir.eLearning. All rights reserved.
//

#import "PlayGameViewController.h"
#import "EAColourfulProgressView.h"

@interface PlayGameViewController ()

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *arrayOfPlayersImages;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *arrayOfLabelsPlayersMoneys;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *arrayOfLabelsPlayersNames;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *arrayOfImagesCardsOnTheTable;

@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *arrayOfImagesPrivatePlayersCard;

@property (nonatomic) int countOfPlayersOnTheTable;



@end

@implementation PlayGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [self changeCornerRadiusOfPlayersViews:10];
    [self rotateRightPrivateCardOfPlayers:10];
    [self changeCornerRadiusOfCards:10];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}


- (void)clearTable
{
    //performance better, than if we use a (1)cycle.
    for(UILabel *nameLabel in self.arrayOfLabelsPlayersNames)   [nameLabel  setAlpha:0.0];
    for(UILabel *moneyLabel in self.arrayOfLabelsPlayersMoneys) [moneyLabel setAlpha:0.0];
    for(UIImageView *imageView in self.arrayOfPlayersImages)    [imageView  setAlpha:0.0];
    for(UIImageView *privateCardImage in self.arrayOfImagesPrivatePlayersCard) [privateCardImage setAlpha:0.0];
}

#define ANGLE_PI_devided_4 0.19625

- (void)rotateRightPrivateCardOfPlayers: (int)countOfPlayers
{
    UIImageView *card;
    
    for(int i=0; i<countOfPlayers; i++) {
        card = [_arrayOfImagesPrivatePlayersCard objectAtIndex:i*2];
        card.transform = CGAffineTransformRotate(card.transform, ANGLE_PI_devided_4);
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

- (void)parseMessageFromServer {
    
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
