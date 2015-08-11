//
//  PokerGameViewController.m
//  Poker
//
//  Created by Admin on 11.08.15.
//  Copyright (c) 2015 by.bsuir.eLearning. All rights reserved.
//

#import "PokerGameViewController.h"

@interface PokerGameViewController ()

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

@end

@implementation PokerGameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
