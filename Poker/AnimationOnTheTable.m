//
//  AnimationOnTheTable.m
//  Poker
//
//  Created by Admin on 05.05.15.
//  Copyright (c) 2015 by.bsuir.eLearning. All rights reserved.
//

#import "AnimationOnTheTable.h"
#import "ConnectionToServer.h"
#import "EAColourfulProgressView.h"
#import "screenshortViewController.h"
#import "SoundManager.h"

#define GET_ACCEPT 0
#define GET_STRING 1
#define GET_INT_VALUE 2
#define GET_GAMER_NAME    3
#define GET_GAMER_MONEY   4
#define GET_GAMER_LEVEL   5
#define GET_COUNT_GAMERS_ON_THE_TABLE  6
#define GET_GAME_STATUS 7
#define GET_CARD 8
#define GET_RATE_FROM_SERVER 9
#define GET_WINNERS_NAME 10
#define GET_BEST_CARD_COMBINATION 11
#define GET_WINNER_CADR 12

#define TIME_OUT 3
#define LONG_TIME_OUT 60

#define MAX_DURATION_OF_PARTY 1080


#define FIRST_PRIVATE_CARD 5
#define SECOND_PRIVATE_CARD 6

#define bigBlind 300

//--------------combination-------
#define StraightFlush  9;
#define FourofaKind = 8;
#define FullHouse = 7;
#define Flush = 6;
#define Straight = 5;
#define ThreeofaKind = 4;
#define TwoPair = 3;
#define Pair = 2;
#define HighCard = 1;
//--------------------------------





@interface AnimationOnTheTable () <UIAccelerometerDelegate>

@property(nonatomic)int countGamersOnTheTable;
@property(nonatomic,strong)NSString *receiveGamerName;
@property(nonatomic)int receiveGamerLevel;
@property(nonatomic)int receiveGamerMoney;
@property(nonatomic)BOOL isFirstTryToConnect;

@property(nonatomic,strong)NSMutableArray *arrayOfCardOnTheTable;

@property(nonatomic)BOOL isSendedRateToServer;
@property(nonatomic)int minRate;
@property(nonatomic)int amountRate;

@property(nonatomic)int firstWinnerPrivateCard;
@property(nonatomic)int secondWinnerPrivateCard;

@property(nonatomic)NSString *nameOfWinner;
@property(nonatomic,strong)NSMutableArray *arrayBestCard;
@property(nonatomic)BOOL isGameFinished;
@property(nonatomic)int sliderRate;
@property(nonatomic,strong)NSTimer *timer;
@property(nonatomic,strong)UIImage *buffImage;

@property (strong, nonatomic) IBOutlet UIButton *showBestCombinationButton;
@property (strong, nonatomic) IBOutlet UIButton *makeScreenshortButton;


@property(nonatomic, strong)NSArray *arrayOfCombination;

@property(nonatomic,strong)EAColourfulProgressView *currentProgressBar;

@property(nonatomic)int numberOfGeneralGamer;
@property(nonatomic)int numberOfCurrentGamer;
@property(nonatomic)int numberOfCurrentProgressView;
@property(nonatomic,strong)Gamer *genGamer;
@property(nonatomic)int bestPriority;
@property(nonatomic)BOOL isGameIsNotFinished;
@property(nonatomic)BOOL isBlind;
@property(nonatomic)BOOL isModalViewControllerShouldBeShowed;
@property(nonatomic)int countOfShowedCard;

-(void)showHideImage;

@end

@implementation AnimationOnTheTable

- (void)viewDidLoad {
    [super viewDidLoad];
    [self generalSettings];
    
    [self setGeneralGamerObject];

    [self hideAllGamers];
    [self setCornersParametersForView];

    [self getInfoAboutGamersOnTheTable];
}

-(void)generalSettings {
    
    _arrayOfCombination = @[@"High Card", @"Pair", @"Two Pair", @"ThreeofaKind", @"Straight", @"Flush", @"FullHouse", @"FourofaKind", @"StraightFlush"];
    [[UIAccelerometer sharedAccelerometer]setDelegate:self];
    
    
#if !(TARGET_IPHONE_SIMULATOR)
    [SoundManager sharedManager].allowsBackgroundMusic = YES;
    [[SoundManager sharedManager] prepareToPlay];
#endif
    
    
    
    _isModalViewControllerShouldBeShowed = NO;
    [self resetValueAllVariable];
    [self.rateSlider removeConstraints:self.rateSlider.constraints];
    [self.rateSlider setTranslatesAutoresizingMaskIntoConstraints:YES];
    self.rateSlider.transform = CGAffineTransformRotate(self.rateSlider.transform, 270.0/180*M_PI);
}

-(void)resetValueAllVariable {
    _numberOfCurrentGamer = 0;
    _bestPriority = -1;
    //---------set parameters
    ConnectionToServer *connection = [ConnectionToServer sharedInstance];
    _isGameFinished = NO;
    connection.delegate = self;
    _gamersArray = [NSMutableArray new];
    _arrayOfCardOnTheTable = [NSMutableArray new];
    _arrayBestCard = [NSMutableArray new];
    
    _isFirstTryToConnect = YES;
    _isSendedRateToServer = NO;
    _amountRate = 0;
    _numberOfCurrentGamer = 0;
    _countGamersOnTheTable = 0;
    _countOfShowedCard = 0;
    _currentProgressBar = nil;
    _isBlind = YES;
    
//    [_firstCard setImage:[UIImage imageNamed:@"shirt.jpg"]];
//    [_secondCard setImage:[UIImage imageNamed:@"shirt.jpg"]];
//    [_theardCard setImage:[UIImage imageNamed:@"shirt.jpg"]];
//    [_fourthCard setImage:[UIImage imageNamed:@"shirt.jpg"]];
//    [_fifeCard setImage:[UIImage imageNamed:@"shirt.jpg"]];
    
    _rateSlider.minimumValue = 300.0;
}

#define COUNT_GAMERS 10

-(void)setCornersParametersForView {
   
    UIView *view;
    
    for(int i=0; i < COUNT_GAMERS; i++) {
//        view = [_arrayOfMoneyLabel objectAtIndex:i];
//        [self roundCornerRadius:view];
//        
//        view = [_arrayOfNameLabel objectAtIndex:i];
//        [self roundCornerRadius:view];
//        
//        view = [_arrayOfImage objectAtIndex:i];
//        [self roundCornerRadius:view];
    }
    //-----------setting buttons corner radius !
    [_checkButton.layer setMasksToBounds:YES];
    [_checkButton.layer setCornerRadius:10];
    
    [_pasButton.layer setMasksToBounds:YES];
    [_pasButton.layer setCornerRadius:10];
    
    [_callButton.layer setMasksToBounds:YES];
    [_callButton.layer setCornerRadius:10];
    
    [_raiseBetButton.layer setMasksToBounds:YES];
    [_raiseBetButton.layer setCornerRadius:10];
    //-----------
    [_callButton.layer setMasksToBounds:YES];
    [_callButton.layer setCornerRadius:10];
    
    [_makeScreenshortButton.layer setMasksToBounds:YES];
    [_makeScreenshortButton.layer setCornerRadius:10];
    
    [_showBestCombinationButton.layer setMasksToBounds:YES];
    [_showBestCombinationButton.layer setCornerRadius:10];
    //-----------
    
}

-(void)roundCornerRadius:(UIView*)view {
    [view.layer setMasksToBounds:YES];
    [view.layer setCornerRadius:15];
}

-(void)playSound:(NSString*)file {

#if (TARGET_IPHONE_SIMULATOR)
    return;
#endif
    [[SoundManager sharedManager] playSound:file looping:NO];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    NSSet *allTouches = [event allTouches];
    UITouch *touch = [[allTouches allObjects] objectAtIndex:0];
    int selectedGamer = -1;
    int i = 0;
    
//    for(UIImageView *image in _arrayOfImage) {
//        if(touch.view == image) {
//            selectedGamer = i;
//            break;
//        }
//        i++;
//    }
    
    if(touch.view != _contentView) {
        [_contentView setAlpha:0.0];
    }
    
    if(selectedGamer != -1)
    [self renderingInfoAboutSelectedGamer:selectedGamer];
    
}

- (IBAction)makeScreenshotClick:(id)sender {
    if([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(self.view.bounds.size, NO, [UIScreen mainScreen].scale);
    } else {
        UIGraphicsBeginImageContext(self.view.bounds.size);
    }
    [self.view.layer renderInContext:UIGraphicsGetCurrentContext()];
    _buffImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    NSDictionary *userInfo = [NSDictionary dictionaryWithObject:_buffImage forKey:@"image"];
    [[NSNotificationCenter defaultCenter] postNotificationName:@"TestNotification" object:nil userInfo:userInfo];
    [_contentView setAlpha:1.0];
}




- (IBAction)changeRateSlider:(id)sender {
    _sliderRate = _rateSlider.value;
    NSString *string = [[NSString alloc] initWithFormat:@"%d $", _sliderRate];
        _rateLabel.text = string;
        [_rateLabel reloadInputViews];
    
}

-(NSString*)currentTime {
    NSDate *currentDate = [NSDate date];
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"HH:mm"];
    NSString *strDate = [dateFormatter stringFromDate:currentDate];
    
    return strDate;
}

-(void)setGeneralGamerObject {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    
    NSString *gamerMoney = [[NSString alloc] initWithFormat:@"%@",[userDefaults objectForKey:@"money"]];
    NSString *gamerLevel = [[NSString alloc] initWithFormat:@"%@", [userDefaults objectForKey:@"level"]];
    
    
    _genGamer = [[Gamer alloc] initWithInfo:[userDefaults objectForKey:@"name"] andMoney:[gamerMoney intValue] andLevel:[gamerLevel intValue]];
}

-(void)renderingInfoAboutSelectedGamer:(int)number {
    @synchronized(self) {
        Gamer *gamer;
        gamer = [_gamersArray objectAtIndex:number];
        NSString *gamerMoney = [[NSString alloc] initWithFormat:@"%i $", gamer.money];
        NSString *gamerLevel = [[NSString alloc]  initWithFormat:@"%i", gamer.level];
        
//        _selectedGamerName.text = gamer.name;
//        _selectedGamerMoney.text = gamerMoney;
//        _selectedGamerLevel.text = gamerLevel;

    }
}

-(NSString*)returnIntValueFromId:(NSString*)key {
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *outStr = [[NSString alloc] initWithFormat:@"%@", [userDefaults objectForKey:key]];
    
    return outStr;
}

-(void)hideAllGamers {
    UILabel *moneyLabel;
    UILabel *nameLabel;
    UILabel *rateLabel;
    UIImageView *image;
    EAColourfulProgressView *progress;
    
    for(int i=0; i < 10; i++) {
//        moneyLabel = [_arrayOfMoneyLabel objectAtIndex:i];
//        nameLabel = [_arrayOfNameLabel objectAtIndex:i];
//        rateLabel = [_arrayOfRates objectAtIndex:i];
//        image = [_arrayOfImage objectAtIndex:i];
        
        [moneyLabel setAlpha:0.0];
        [rateLabel setAlpha:0.0];
        [nameLabel setAlpha:0.0];
        [image setAlpha:0.0];
    }
    
//    for(UIImageView *image in _arrayImageOfPrivateCards) {
//        [image setAlpha:0.0];
//    }
//    
//    [self.firstCard setAlpha:0.0];
//    [self.secondCard setAlpha:0.0];
//    [self.theardCard setAlpha:0.0];
//    [self.fourthCard setAlpha:0.0];
//    [self.fifeCard setAlpha:0.0];
}

-(void)getInfoAboutGamersOnTheTable {
    ConnectionToServer * connection = [ConnectionToServer sharedInstance];
    [connection sendData:@"GIVE_ME_COUNT_PLAYERS_ON_THE_TABLE"];
    [connection readDataWithTagLongTime:GET_COUNT_GAMERS_ON_THE_TABLE andDurationWaiting:LONG_TIME_OUT*4];
}

- (IBAction)clickQual:(id)sender {
    if(_isSendedRateToServer && _minRate > 0) {
       // [self changeProgressView];
        [self viewWillDisappear:YES];
        
        [self playSound:@"Raise"];
        
        Gamer *gamer = [_gamersArray objectAtIndex:_numberOfGeneralGamer];
        if(_minRate < 0) _minRate *= -1;
        
        NSString *bind = [[NSString alloc] initWithFormat:@"%d", _minRate];
        _minRate -= gamer.rate;
        ConnectionToServer *connect = [ConnectionToServer sharedInstance];
        [connect sendData:bind];
        _isSendedRateToServer = !_isSendedRateToServer;
        [self updateGeneralGamerMoney];
        [self lockAllBetButtons];
        [connect readDataWithTagLongTime:GET_RATE_FROM_SERVER andDurationWaiting:LONG_TIME_OUT*4];
    }
}

- (IBAction)clickPas:(id)sender {
    if(_isSendedRateToServer) {
        [self stopCurrentProgressBar];
        [self passAction];
    }
}

-(void)passAction {
//
//    [self playSound:@"Pass"];
//    
//    ConnectionToServer *connect = [ConnectionToServer sharedInstance];
//    [connect sendData:@"-1"];
//    
//    UIImageView *imageGeneralGamer = [_arrayOfImage objectAtIndex:_numberOfGeneralGamer];
//    UILabel *moneyGeneralGamer = [_arrayOfMoneyLabel objectAtIndex:_numberOfGeneralGamer];
//    UILabel *nameLabel = [_arrayOfNameLabel objectAtIndex:_numberOfGeneralGamer];
//    
//    [imageGeneralGamer setAlpha:0.6];
//    [moneyGeneralGamer setAlpha:0.6];
//    [nameLabel setAlpha:0.6];
//    
//    Gamer *gamer = [_gamersArray objectAtIndex:_numberOfGeneralGamer];
//    gamer.isGamed = NO;
//    _amountRate += gamer.rate;
//    
//    [_rateAmountAllGamersLabel setText:[[NSString alloc] initWithFormat:@"%d$", _amountRate]];
//    [_rateAmountAllGamersLabel reloadInputViews];
//    
//    [_gamersArray replaceObjectAtIndex:_numberOfGeneralGamer withObject:gamer];
//    _rateGeneralGamerLabel.text = @"0 $";
//    [self lockAllBetButtons];
//    [connect readDataWithTagLongTime:GET_RATE_FROM_SERVER andDurationWaiting:LONG_TIME_OUT*4];
}

- (IBAction)clickCheck:(id)sender {
    if(_isSendedRateToServer) {
        Gamer *gamer = [_gamersArray objectAtIndex:_numberOfGeneralGamer];
        if((gamer.rate - _minRate) != 0) return;
        
        ConnectionToServer *connect = [ConnectionToServer sharedInstance];
        
            NSString *outStr = [[NSString alloc] initWithFormat:@"%d", _minRate];
            [connect sendData:outStr];
        
        NSString *outSt = [[NSString alloc] initWithFormat:@"%d $", _minRate];
        //[[_arrayOfRates objectAtIndex:_numberOfGeneralGamer] setText:outSt];
        _isSendedRateToServer = !_isSendedRateToServer;
        [self lockAllBetButtons];
        [self playSound:@"Check"];
        
        [connect readDataWithTagLongTime:GET_RATE_FROM_SERVER andDurationWaiting:LONG_TIME_OUT*4];
    }
}

- (IBAction)clickRaise:(id)sender {
    if(_isSendedRateToServer) {
        int temp = 0;

        Gamer *genGamer;
        genGamer = [_gamersArray objectAtIndex:_numberOfGeneralGamer];
        if(_sliderRate + genGamer.rate >= _minRate) {
            _minRate = _sliderRate;
            temp = genGamer.rate + _minRate;;
        }
        else
            return;
         [self playSound:@"Raise"];
        
        NSString *bind = [[NSString alloc] initWithFormat:@"%d", temp];
        
        
        ConnectionToServer *connect = [ConnectionToServer sharedInstance];
        [connect sendData:bind];
        _isSendedRateToServer = !_isSendedRateToServer;
        [self updateGeneralGamerMoney];
        [self lockAllBetButtons];
        [connect readDataWithTagLongTime:GET_RATE_FROM_SERVER andDurationWaiting:LONG_TIME_OUT*4];
        
        _rateSlider.maximumValue = 0;
        _rateSlider.minimumValue = 0;
        [_rateSlider reloadInputViews];
    }
}

-(void)stopCurrentProgressBar {
    if(_currentProgressBar != nil) {
        _currentProgressBar.currentValue = 60;
        [_timer invalidate];
        _timer = nil;
        [self viewWillDisappear:NO];
        [_currentProgressBar  setAlpha:0.0];
    }
}

-(void)startProgressBarAtNumber:(int)number {
   // _currentProgressBar = [_arrayOfProgressBar objectAtIndex:number];
    _numberOfCurrentProgressView = number;
    _currentProgressBar.currentValue = 60;
    [_currentProgressBar  setAlpha:1.0];
    [self viewWillAppearWithoutFirstStart:YES];
}

-(void)parseServerResponse:(NSString*)string {
    ConnectionToServer *connect = [ConnectionToServer sharedInstance];
    
    
    NSLog(@"Called parseServer ...");
    NSLog(@"received string : %@", connect.receiveString);
    char lastSymbol = [connect.receiveString characterAtIndex:[connect.receiveString length]-1];
    char prevLastSymbol =[connect.receiveString characterAtIndex:[connect.receiveString length]-2];
    char firstSymbol = [connect.receiveString characterAtIndex:0];
    [self lockAllBetButtons];
    
    if( !(lastSymbol == '?' && (prevLastSymbol >= '0' && prevLastSymbol <= '9')) )
    [self stopCurrentProgressBar];
    
    if(lastSymbol == '?' && (prevLastSymbol >= '0' && prevLastSymbol <= '9')) { //server send to client min. RATE
        NSString *subStr = [connect.receiveString substringToIndex:[connect.receiveString length]-1];
        _minRate = [subStr intValue];
        NSString *outStr = [[NSString alloc] initWithFormat:@"Check or raise ? minRate : %d", _minRate];
        [self playSound:@"Check"];
      //  _messageFromServerLabel.text = outStr;
        _isSendedRateToServer = !_isSendedRateToServer;
        [self unlockAllBetButton];
        
        _numberOfCurrentGamer = _numberOfGeneralGamer;
        //ПРОСТО ЖДЁМ ОТПРАВКИ СООБЩЕНИЯ СЕРВЕРУ(кнопки), О НАШИХ НАМЕРЕНИЯХ
    } else if(firstSymbol == '-') {
        _minRate = [connect.receiveString intValue];
    
        NSString *outStr = [[NSString alloc] initWithFormat:@"You made blind : %d $ Check or raise ?", _minRate];
    
//        Gamer *gamer = [_gamersArray objectAtIndex:_numberOfGeneralGamer];
//        gamer.rate = _minRate;
//        _minRate = 0;
//        [_gamersArray replaceObjectAtIndex:_numberOfGeneralGamer withObject:gamer];
        
//        _messageFromServerLabel.text = outStr;
//        [_messageFromServerLabel reloadInputViews];
        [self updateGeneralGamerMoney];
        [connect sendData:@"received"];
    
        [connect readDataWithTagLongTime:GET_RATE_FROM_SERVER andDurationWaiting:LONG_TIME_OUT*4];
       // _isSendedRateToServer = !_isSendedRateToServer;
    } else if([string isEqual:@"showAllCards"]) {
        [connect sendData:@"received"];
        [self collectBindAllGamers];
        
        if(_countOfShowedCard != 0 ) _countOfShowedCard++;
        
        for(int i=_countOfShowedCard; i<5; i++) [self showNextCard:i];
            
        connect.numberOfAttribut = 0;
        [connect readDataWithTagLongTime:GET_RATE_FROM_SERVER andDurationWaiting:LONG_TIME_OUT*4];
        return;
    } else if([string isEqual:@"showCard"]) {
        [connect sendData:@"received"];
        connect.numberOfAttribut = 0;
        connect.countOfGameCycl++;  //сервер сообщил, что все уже поменялись письками.
        
        
        if(connect.countOfGameCycl == 1) {
            [self playSound:@"ShowCard"];
            _countOfShowedCard += 2;
            for(int i=0; i<3; i++) [self showNextCard:i];
        }
        if(connect.countOfGameCycl == 2) { [self playSound:@"ShowCard"]; [self showNextCard:3];  _countOfShowedCard++; }
        if(connect.countOfGameCycl == 3) { [self playSound:@"ShowCard"];  [self showNextCard:4]; _countOfShowedCard++; }
        [self collectBindAllGamers];
        [connect readDataWithTagLongTime:GET_RATE_FROM_SERVER andDurationWaiting:LONG_TIME_OUT*4]; //Цикл завершился, ждём запроса от сервера о след. мин. ставке
    } else if([string isEqual:@"DATA_ABOUT_WINNER"]) {
        [connect sendData:@"received"];
        [self collectBindAllGamers];
        connect.numberOfAttribut = 0;
        [connect readDataWithTagLongTime:GET_WINNERS_NAME andDurationWaiting:LONG_TIME_OUT*4];
        return;
    } else if(firstSymbol == '!') {
        if([_contentView alpha] == 1.0) {
            [_contentView setAlpha:0.0];
            _isModalViewControllerShouldBeShowed = YES;
        }
        
        NSString *nameOfCurrentGamer = [connect.receiveString substringFromIndex:1];
        int i=0;
        for(Gamer *gamer in _gamersArray) {
            if([gamer.name isEqualToString:nameOfCurrentGamer]) break;
            i++;
        }
        [self startProgressBarAtNumber:i];
        [connect sendData:@"received"];
        [connect readDataWithTagLongTime:GET_RATE_FROM_SERVER andDurationWaiting:LONG_TIME_OUT*4];
    } else { // Definition, why is make rate !
        int i=0;
        
        for(i=0; i < [connect.receiveString length]; i++) {
            if([connect.receiveString characterAtIndex:i] == ':') break;
        }
        
        NSString *nameGamer = [connect.receiveString substringToIndex:i];
        NSString *rate = [connect.receiveString substringFromIndex:i+1];
        int valueRate = [rate intValue]; // rate some gamer.
        
        if(valueRate > _minRate)
            _minRate = valueRate; //update bind.
        
        int j=0;
        for(Gamer *gam in _gamersArray) {
            if([gam.name isEqualToString:nameGamer]) break;
            j++;
        }
        
        if(connect.countOfGameCycl == 0 && _minRate == bigBlind && _isBlind == YES) {
            _numberOfCurrentGamer = j;
            _numberOfCurrentGamer %= _countGamersOnTheTable;
            _isBlind = NO;
            [self startProgressBarAtNumber:_numberOfCurrentGamer];
        }
            Gamer *gamer = [_gamersArray objectAtIndex:j];
            int tmp = gamer.rate;
                if(valueRate != -1)
                        gamer.rate = valueRate;
                else {
//                    _amountRate += gamer.rate;
//                    _rateAmountAllGamersLabel.text = [[NSString alloc] initWithFormat:@"%d $", _amountRate];
//                    [_rateAmountAllGamersLabel reloadInputViews];
//                    gamer.rate = -1;
                }
                
                if(gamer.rate != -1) {
                    gamer.money -= gamer.rate;
                    gamer.money += tmp;
                    [_gamersArray replaceObjectAtIndex:j withObject:gamer];
                } else  {
                    gamer.isGamed = NO;
                    gamer.rate = 0;
                    [_gamersArray replaceObjectAtIndex:j withObject:gamer];
                }
                [self selectParam:j];
        [connect sendData:@"received"];
        
        
        
            [connect readDataWithTagLongTime:GET_RATE_FROM_SERVER andDurationWaiting:LONG_TIME_OUT*4];
    }
}

-(void)collectBindAllGamers {
    [self playSound:@"Collect"];
    
    NSLog(@"Called COLLECTOR BINDES ! ");
    Gamer *gamer;
    for(int i=0; i < [_gamersArray count]; i++) {
        gamer = [_gamersArray objectAtIndex:i];
        if(gamer.isGamed == YES)  {
            _amountRate += gamer.rate;
            gamer.rate = 0;
            [_gamersArray replaceObjectAtIndex:i withObject:gamer];
        }
    }
//    _rateAmountAllGamersLabel.text = [[NSString alloc] initWithFormat:@"%d $", _amountRate];
//    
//    _rateGeneralGamerLabel.text = @"0 $";
//    _rateSecondGamerLabel.text = @"0 $";
//    _rateTheardUserLabel.text = @"0 $";
//    _rateFourthGamerLabel.text = @"0 $";
//    _rateFifeGamerLabel.text = @"0 $";
//    _rateSixGamerLabel.text = @"0 $";
//    _rateSevenGamerLabel.text = @"0 $";
}

-(void)updateGeneralGamerMoney { //-1 используется для того, чтобы маневрированть: игрок получил деньги или отдал...
    @synchronized(self) {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSString *outStr = [[NSString alloc] initWithFormat:@"%@", [userDefaults objectForKey:@"money"]];
        if(_minRate < 0 && _isGameFinished  == NO)
            _minRate *= -1;
            
        int newMoney = [outStr intValue] - _minRate;
        
        Gamer *gamer;
        gamer = [_gamersArray objectAtIndex:_numberOfGeneralGamer];
        gamer.money = newMoney;
        gamer.rate += _minRate;
        [_gamersArray replaceObjectAtIndex:_numberOfGeneralGamer withObject:gamer];
        
        if(_isGameFinished == YES && gamer.rate < 0) gamer.rate *= -1;
        
        NSString *newRate = [[NSString alloc] initWithFormat:@"%d $", gamer.rate];
        
        [userDefaults setInteger:newMoney forKey:@"money"];
        outStr = [[NSString alloc] initWithFormat:@"%@ $", [userDefaults objectForKey:@"money"]];
        
////        UILabel *moneyLabel = [_arrayOfMoneyLabel objectAtIndex:_numberOfGeneralGamer];
////        UILabel *rateLabel = [_arrayOfRates objectAtIndex:_numberOfGeneralGamer];
//        
//        [rateLabel setText:newRate];
//        [rateLabel reloadInputViews];
//        [rateLabel setAlpha:1.0];
//        
//        [moneyLabel setText:outStr];
//        [moneyLabel reloadInputViews];
    }
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)showCardsOnTheTable {
//    [self playSound:@"Cards"];
//    [UIView animateWithDuration:3.0 delay:0.5 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:0 animations:^{
//        [self.firstCard setAlpha:0.1];
//        [self.secondCard setAlpha:0.1];
//        [self.theardCard setAlpha:0.1];
//        [self.fourthCard setAlpha:0.1];
//        [self.fifeCard setAlpha:0.1];
//        
//    } completion:^(BOOL finished) {
//        [UIView animateWithDuration:3.0 animations:^{
//            [self.firstCard setAlpha:1];
//            [self.secondCard setAlpha:1];
//            [self.theardCard setAlpha:1];
//            [self.fourthCard setAlpha:1];
//            [self.fifeCard setAlpha:1];
//        } completion:^(BOOL finished) {
//            
//        }];
//    }];
}

-(void)lockAllBetButtons {
    [_raiseBetButton setEnabled:NO];
    [_callButton setEnabled:NO];
    [_checkButton setEnabled:NO];
    [_pasButton setEnabled:NO];
    [_rateSlider setEnabled:NO];
}

-(void)unlockAllBetButton {
    [_raiseBetButton setEnabled:YES];
    [_callButton setEnabled:YES];
    [_checkButton setEnabled:YES];
    [_pasButton setEnabled:YES];
    [_rateSlider setEnabled:YES];
    
    long temp = 1000000000; //max moneyif
    Gamer *genGamer = [_gamersArray objectAtIndex:_numberOfGeneralGamer];
    
    
    for(Gamer *gamer in _gamersArray) {
        if(gamer.isGamed == NO) continue;
        if(gamer.money + gamer.rate < temp) {
            
                temp = gamer.money + gamer.rate - genGamer.rate;
        }
        
    }
    
    if(temp <= (genGamer.money + genGamer.rate))
        _rateSlider.maximumValue = temp;
    else
        _rateSlider.maximumValue = (genGamer.money + genGamer.rate);
}

- (IBAction)showCombinationClickButton:(id)sender {
    [self showHideImage];
}

-(void)showHideImage {
    float startApha = _combinationImage.alpha;
    float endAlpha;
    if(startApha == 0) endAlpha = 1;
    else endAlpha = 0;
    
    [UIView animateWithDuration:3.0 delay:3 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:0 animations:^{
        [_combinationImage setAlpha:startApha];
    } completion:^(BOOL finished) {
        [_combinationImage setAlpha:endAlpha];
    }];
}

-(void)changeProgressBar:(int)numberOfGeneralCard {
//    NSString *firstPicture = [[NSString alloc]initWithFormat:@"cards/%i.png", _firstPrivateCard];
//    NSLog(@"path to firstPicture : %@", firstPicture);
//    NSString *secondPicture = [[NSString alloc]initWithFormat:@"cards/%i.png", _secondPrivateCard];
//    NSLog(@"path to second picture : %@", secondPicture);
//            UIImageView *image1 = [_arrayImageOfPrivateCards objectAtIndex:numberOfGeneralCard];
//            UIImageView *image2 = [_arrayImageOfPrivateCards objectAtIndex:numberOfGeneralCard+1];
//    
//    [image1 setImage:[UIImage imageNamed:firstPicture]];
//    [image2 setImage:[UIImage imageNamed:secondPicture]];
//    
//    [UIView animateWithDuration:3.0 delay:0.5 usingSpringWithDamping:0.5 initialSpringVelocity:0.5 options:0 animations:^{
//        
//        [self.firstCard setAlpha:0.1];
//        [self.secondCard setAlpha:0.1];
//        [self.theardCard setAlpha:0.1];
//        [self.fourthCard setAlpha:0.1];
//        [self.fifeCard setAlpha:0.1];
//        image1.center = image1.center;
//        image2.center = image2.center;
//        
//    } completion:^(BOOL finished) {
//        [UIView animateWithDuration:1.0 animations:^{
//            [self.firstCard setAlpha:1];
//            [self.secondCard setAlpha:1];
//            [self.theardCard setAlpha:1];
//            [self.fourthCard setAlpha:1];
//            [self.fifeCard setAlpha:1];
//            [image1 setAlpha:1.0];
//            [image2 setAlpha:1.0];
//            
//            image1.center = image1.center;
//            image2.center = image2.center;
//        } completion:^(BOOL finished) {
//            
//       }];
//        
////        _firstPrivateCardImage.center = CGPointMake(470.0, 560.0);
////        _secondPrivateCardImage.center = CGPointMake(500.0, 560.0);
//    }];
    
    [self receiveRateFromServer];
}

-(void)receiveRateFromServer{
    ConnectionToServer *connect = [ConnectionToServer sharedInstance];
    connect.countOfGameCycl=0;
    connect.numberOfAttribut=0;
    [connect readDataWithTagLongTime:GET_RATE_FROM_SERVER andDurationWaiting:LONG_TIME_OUT*3];
}


-(BOOL)isRateSendToServer {
    @synchronized(self) {
        if(_isSendedRateToServer == YES) return YES;
        else return NO;
    }
}

-(void)gameEngine{
    [self changeProgressBar:_numberOfGeneralGamer*2];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/
#pragma mark ConnectionToServer Delegate Methods

-(void)addPlayer {
    //add player on the table
}

-(void)parseServerResponseAboutWinner {
    ConnectionToServer *connect = [ConnectionToServer sharedInstance];
    int i=0;
    
    for(i=0; i < [connect.receiveString length]; i++) {
        if([connect.receiveString characterAtIndex:i] == ':') break;
    }
    
    NSString *winnerName = [connect.receiveString substringFromIndex:i+1];
    NSString *tempString = [[NSString alloc] initWithFormat:@"%@\n[%@] %@ is winner !", _chatTextView.text, [self currentTime], winnerName];
    [_chatTextView setText:tempString];
//    [_messageFromServerLabel setText:tempString];
//    [_messageFromServerLabel reloadInputViews];
    [_chatTextView reloadInputViews];
    _nameOfWinner = winnerName;
    connect.numberOfAttribut = 0;
    [connect sendData:@"received"];
    NSLog(@"Called parse WINNER_GAMER !!!! ASK ABOUT BEST !!!");
    [connect readDataWithTagLongTime:GET_BEST_CARD_COMBINATION andDurationWaiting:LONG_TIME_OUT];
}

-(void)gettingBestCombination {
    ConnectionToServer *connect= [ConnectionToServer sharedInstance];
    int temp = connect.receivedIntValue;
    
    if(temp == 255) { //255 == -1(unsigned char)
        [self showOneWinnerWithoutCombination];
        return;
    }
    [connect sendData:@"received"];
    
    NSNumber *value = [[NSNumber alloc] initWithInt: temp];
    [_arrayBestCard addObject:value];
    connect.numberOfAttribut += 1;
    if(connect.numberOfAttribut < 5) [connect readDataWithTagLongTime:GET_BEST_CARD_COMBINATION andDurationWaiting:LONG_TIME_OUT];
    else {
        connect.numberOfAttribut = 0;
        [connect readDataWithTagLongTime:GET_WINNER_CADR andDurationWaiting:LONG_TIME_OUT];
    }
}

-(void)showOneWinnerWithoutCombination {
    int i=0;
    for(Gamer *gamer in _gamersArray) {
        if([gamer.name isEqualToString:_nameOfWinner]) {
            break;
        }
        i++;
    }
   // [_rateAmountAllGamersLabel setText:@"0 $"];
    [self modifyMoneyOfWinner:i];
    Gamer *gamer = [_gamersArray objectAtIndex:i];
    NSString *name = [[NSString alloc] initWithFormat:@"[%@] %@ is winn with unnamed cards !",[self currentTime], gamer.name];
    NSString *outStr = [[NSString alloc] initWithFormat:@"%@\n%@", [_chatTextView text], name];
    [_chatTextView setText:outStr];
    
    _timer = nil;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:15.0f
                                                  target:self
                                                selector:@selector(finishedGame)
                                                userInfo:nil
                                                 repeats:NO];
}

-(void)finishedGame{
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    NSString *outStr = [[NSString alloc] initWithFormat:@"%@", [userDefaults objectForKey:@"money"]];
    int temp = [outStr intValue];
    if(temp <=0) {[userDefaults setInteger:100000 forKey:@"money"];}
    
    
    [_arrayOfCardOnTheTable removeAllObjects];
    [_arrayBestCard removeAllObjects];
    [self stopCurrentProgressBar];
    ConnectionToServer *connect = [ConnectionToServer sharedInstance];
    connect.numberOfAttribut = 0;
    [_gamersArray removeAllObjects];
    [self hideAllGamers];
    
    [self resetValueAllVariable];
    [self getInfoAboutGamersOnTheTable];
}

-(Gamer*)showWinnersCard:(int)value andFirstCard:(NSString*)firstPicture andSecondCard:(NSString*)secondPicture andGamer:(Gamer*)gamer {
    UIImageView *image1;
    UIImageView *image2;
    
//    image1 = [_arrayImageOfPrivateCards objectAtIndex:value*2];
//    image2 = [_arrayImageOfPrivateCards objectAtIndex:value*2 + 1];
//    
    gamer.firstCard = image1;
    gamer.secondCard= image2;
    [image1 setAlpha:1.0];
    [image2 setAlpha:1.0];
    
    [image1 setImage:[UIImage imageNamed:firstPicture]];
    [image2 setImage:[UIImage imageNamed:secondPicture]];
    return gamer;
}

-(void)gettingWinnerGamerTwoCard {
    ConnectionToServer *connect= [ConnectionToServer sharedInstance];
    
//    if(connect.numberOfAttribut < 2)
//      [connect sendData:@"received"];
//    
//    if(connect.numberOfAttribut == 0) { _firstWinnerPrivateCard = connect.receivedIntValue; }
//    if(connect.numberOfAttribut == 1) { _secondWinnerPrivateCard = connect.receivedIntValue; }
//    if(connect.numberOfAttribut == 2) { _bestPriority = connect.receivedIntValue; NSLog(@"best priority : %d", _bestPriority); }
//    
//    connect.numberOfAttribut += 1;
//    if(connect.numberOfAttribut < 3) [connect readDataWithTagLongTime:GET_WINNER_CADR andDurationWaiting:LONG_TIME_OUT];
//    else {
//        connect.numberOfAttribut = 0;
//        
//         [_messageFromServerLabel setText:[_arrayOfCombination objectAtIndex:_bestPriority-1]]; //show name of best combination
//        
//         NSString *firstPicture = [[NSString alloc]initWithFormat:@"cards/%i.png", _firstWinnerPrivateCard];
//         NSString *secondPicture = [[NSString alloc] initWithFormat:@"cards/%i.png", _secondWinnerPrivateCard];
//        
//        Gamer *gamer;
//        int i = 0;
//        for(i=0; i < [_gamersArray count]; i++) {
//            gamer = [_gamersArray objectAtIndex:i];
//            if([gamer.name isEqualToString:_nameOfWinner]) {
//                gamer.firstPrivateCard = _firstWinnerPrivateCard;
//                gamer.secondPrivateCard = _secondWinnerPrivateCard;
//                gamer = [self showWinnersCard:i andFirstCard:firstPicture andSecondCard:secondPicture andGamer:gamer];
//                [_gamersArray replaceObjectAtIndex:i withObject:gamer];
//                break;
//            }
//        }
//        [self showBestCombination:i];
        /*need rendering scene, show alpha cards !!!!*/
//   }
}

-(void)showBestCombination:(int)number {
    BOOL flag = NO;
    int i = 0, j = 0;
    UIImageView *temp;
    NSNumber *number1, *number2;
    Gamer *gamer = [_gamersArray objectAtIndex:number];
   // NSArray *array = @[_firstCard, _secondCard, _theardCard, _fourthCard, _fifeCard];
    
    //проверка на затемнение карт на столе
    for (i=0; i < [_arrayOfCardOnTheTable count]; i++) {
        flag = NO;
        for(j=0; j < [_arrayBestCard count]; j++) {
            number1 = [_arrayOfCardOnTheTable objectAtIndex:i];
            number2 = [_arrayBestCard objectAtIndex:j];
            if([number1 intValue] == [number2 intValue]) flag = YES;
        }
        if(flag == NO) {
            NSLog(@"zatemnena : %d", [number1 intValue]);
           // temp = [array objectAtIndex:i];
            [temp setAlpha:0.6]; //Затемняем
        }
    }
    //проверяем карты у игрока на руках на затемнеие
    for(i=0;  i < 2; i++) {
        flag = NO;
        if(i==0) {
            for(j=0; j < [_arrayBestCard count]; j++) {
                number2 = [_arrayBestCard objectAtIndex:j];
                if(gamer.firstPrivateCard == [number2 intValue]) flag = YES;
            }
            if(flag == NO) {
                [gamer.firstCard setAlpha:0.6];
                NSLog(@"zatemnena : %d", gamer.firstPrivateCard);
            }
        }
        if(i==1) {
            for(j=0; j < [_arrayBestCard count]; j++) {
                number2 = [_arrayBestCard objectAtIndex:j];
                if(gamer.secondPrivateCard == [number2 intValue]) flag = YES;
            }
            if(flag == NO) {
                NSLog(@"zatemnena : %d", gamer.secondPrivateCard);
                [gamer.secondCard setAlpha:0.6];
            }
        }
    }
    _minRate = _amountRate;
    NSLog(@"number : %d  |   amount rate : %d", number, _amountRate);
//    [_rateAmountAllGamersLabel setText:@"0 $"];
//    [_rateAmountAllGamersLabel reloadInputViews];
    [self modifyMoneyOfWinner:number];
    _timer = nil;
    self.timer = [NSTimer scheduledTimerWithTimeInterval:15.0f
                                                  target:self
                                                selector:@selector(finishedGame)
                                                userInfo:nil
                                                 repeats:NO];
}

-(void)modifyMoneyOfWinner:(int)number {
    Gamer *gamer = [_gamersArray objectAtIndex:number];
    
    if(number == _numberOfGeneralGamer) {
        NSLog(@"Called modify general money");
        _minRate = _amountRate;
        if(_minRate>0) _minRate *= -1;
        _isGameFinished = YES;
        [self updateGeneralGamerMoney];
    }
    else {
        gamer.rate = _amountRate;
        gamer.money += _amountRate;
        [_gamersArray replaceObjectAtIndex:number withObject:gamer];
        [self selectParam:number];
    }
}

-(void)showNextCard:(int)numberInArray{
//    //NSArray *array = @[_firstCard, _secondCard, _theardCard, _fourthCard, _fifeCard];
//    UIImageView *point = [array objectAtIndex:numberInArray];
//    
//    NSString *firstPict = [[NSString alloc]initWithFormat:@"cards/%@.png", ([_arrayOfCardOnTheTable objectAtIndex:numberInArray])];
//    NSLog(@"карта : %@", firstPict);
//    
//    [UIView animateWithDuration:1.0 delay:0.01 usingSpringWithDamping:0.01 initialSpringVelocity:0.01 options:0 animations:^{
//        point.transform = CGAffineTransformMakeScale(1.0, 1.0);
//    } completion:^(BOOL finished) {
//        point.transform = CGAffineTransformMakeScale(0.01, 1.0);
//    }];
//    
//    [UIView animateWithDuration:1.0 animations:^{
//        //_firstCard.center = CGPointMake(0.0f, 0.0f);
//        point.transform = CGAffineTransformMakeScale(0.01, 1.0);
//    } completion:^(BOOL finished) {
//        [point setImage:[UIImage imageNamed:firstPict]];
//        point.transform = CGAffineTransformMakeScale(1.0, 1.0);
//    }];
}

-(void)getCards {
    
    ConnectionToServer *connection = [ConnectionToServer sharedInstance];
    connection.numberOfAttribut += 1;
    [connection sendData:@"received"];
    
    //if(connection.numberOfAttribut == -1) { [connection readDataWithTag:GET_CARD];  }
    
    NSLog(@"getting card %i : %i", connection.numberOfAttribut, connection.receivedIntValue);
    
    if(connection.numberOfAttribut < 5 && connection.numberOfAttribut >= 0) {
        NSNumber *value = [[NSNumber alloc] initWithInt:connection.receivedIntValue];
        NSLog(@"value == %@", value);
        [_arrayOfCardOnTheTable addObject:value];
        [connection readDataWithTag:GET_CARD];
    } else {
//        NSLog(@"value == %i", connection.receivedIntValue);
//        if(connection.numberOfAttribut == FIRST_PRIVATE_CARD) { _firstPrivateCard = connection.receivedIntValue; [connection readDataWithTag:GET_CARD]; }
//        else if(connection.numberOfAttribut == SECOND_PRIVATE_CARD)
//        {  _secondPrivateCard = connection.receivedIntValue; [self gameEngine]; return; }
//        else
//        { return; }

    }
}

-(void)waitingResponseFromServer {
    ConnectionToServer *connection = [ConnectionToServer sharedInstance];
    [connection sendData:@"received"];
    [connection readDataWithTagLongTime:GET_COUNT_GAMERS_ON_THE_TABLE andDurationWaiting:LONG_TIME_OUT];
}

-(void)waitingResponseFromServerAboutGameStatus {
    ConnectionToServer *connection = [ConnectionToServer sharedInstance];
    //[connection sendData:@"GIVE_ME_GAME_STATUS"];
    [connection readDataWithTagLongTime:GET_GAME_STATUS andDurationWaiting:MAX_DURATION_OF_PARTY];
}


//test method
-(void)updateInfo {

}

-(void)renderGamer:(UIImageView*)image andLabel1:(UILabel*)label1 andSecondLabel:(UILabel*)label2 andRate:(UILabel*)label3 andNumber:(int)number {
    Gamer *gamer;
    gamer = [_gamersArray objectAtIndex:number];
    NSString *gamerMoney = [[NSString alloc] initWithFormat:@"%i $", gamer.money];
    NSString *gamerRate = [[NSString alloc] initWithFormat:@"%d $", gamer.rate];
    
    label1.text = gamer.name;
    label2.text = gamerMoney;
    label3.text = gamerRate;
    
    [label1 reloadInputViews];
    [label2 reloadInputViews];
    [label3 reloadInputViews];
    
    if(gamer.isGamed == YES) {
        [image setAlpha:1.0];
        [label1 setAlpha:1.0];
        [label2 setAlpha:1.0];
        [label3 setAlpha:1.0];
    } else {
        [image setAlpha:0.6];
        [label1 setAlpha:0.6];
        [label2 setAlpha:0.6];
        [label3 setAlpha:0.6];
    }
}

-(void)selectParam:(int)value {
//    UILabel *gamerMoneyLabel = [_arrayOfMoneyLabel objectAtIndex:value];
//    UILabel *gamerNameLabel = [_arrayOfNameLabel objectAtIndex:value];
//    UILabel *gamerRate = [_arrayOfRates objectAtIndex:value];
//    UIImageView *image = [_arrayOfImage objectAtIndex:value];
//    
//    [self renderGamer:image andLabel1:gamerNameLabel andSecondLabel:gamerMoneyLabel andRate:gamerRate andNumber:value];
}

-(void)addPlayerToGameList:(NSString*)name andMoney:(int)money andLevel:(int)level {
//    Gamer *gamer = [[Gamer alloc] initWithInfo:name andMoney:money andLevel:level];
//    gamer.firstCard = [_arrayImageOfPrivateCards objectAtIndex:_numberOfCurrentGamer*2];
//    gamer.secondCard = [_arrayImageOfPrivateCards objectAtIndex:_numberOfCurrentGamer*2 + 1];
//    [_gamersArray addObject:gamer];
//    
//    if([gamer.name isEqualToString:_genGamer.name]) { //if this gamer am I ?
//        _numberOfGeneralGamer = _numberOfCurrentGamer;
//        
//        if(_bufferImage != nil) {
//            UIImageView *image = [_arrayOfImage objectAtIndex:_numberOfGeneralGamer];
//            [image setImage:_bufferImage];
//        }
    }
//    
//    NSString *outChatString = [[NSString alloc] initWithFormat:@"%@ joined to the game", gamer.name];
//    NSString *outStr = [[NSString alloc] initWithFormat:@"%@\n[%@] %@", _chatTextView.text, [self currentTime], outChatString];
//    
//    [_chatTextView setText:outStr];
//    
////    NSLog(@"count : %i", _countGamersOnTheTable);
////    NSLog(@"%@", gamer.name);
////    NSLog(@"%i", gamer.money);
////    NSLog(@"%i", gamer.level);
//    
//    UILabel *gamerMoneyLabel = [_arrayOfMoneyLabel objectAtIndex:_numberOfCurrentGamer];
//    UILabel *gamerNameLabel = [_arrayOfNameLabel objectAtIndex:_numberOfCurrentGamer];
//    UILabel *gamerRate = [_arrayOfRates objectAtIndex:_numberOfCurrentGamer];
//    UIImageView *image = [_arrayOfImage objectAtIndex:_numberOfCurrentGamer];
//    _numberOfCurrentGamer++;
//    [self renderGamer:image andLabel1:gamerNameLabel andSecondLabel:gamerMoneyLabel andRate:gamerRate andNumber:_numberOfCurrentGamer-1];
   // [self selectParam:_countGamersOnTheTable];


- (IBAction)SendMessagClick:(id)sender {
    NSString *string = [[NSString alloc] initWithFormat:@"%@\n[%@] %@", [_chatTextView text], [self currentTime],_inputTextFeld.text];
    [_inputTextFeld setText:@""];
    [_chatTextView setText:string];
}


-(void)returnOnPreviusView {
    ConnectionToServer *connect = [ConnectionToServer sharedInstance];
    if(connect.isConnected != YES && _isFirstTryToConnect == YES) {
        [connect connectToServer];
    }
    _isFirstTryToConnect = false;
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{
    if(self.isUseAccelerometer == YES && _isSendedRateToServer == YES && acceleration.z >= 3) {
            [self passAction];
    }
}

-(void)viewWillAppearWithoutFirstStart:(BOOL)animated {
//    [super viewWillAppear:animated]; IncoRRECT method !
//    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.5f
//                                                  target:self
//                                                selector:@selector(updateProgressView:)
//                                                userInfo:nil
//                                                 repeats:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self.timer invalidate];
     self.timer = nil;
    [super viewWillDisappear:animated];
    _currentProgressBar.currentValue = 60;
}


#pragma mark - Helpers

- (void)updateProgressView:(NSTimer *)timer
{
    NSInteger newCurrentValue;
    
    if (self.currentProgressBar.currentValue == 0 && (_currentProgressBar != nil)) {
        newCurrentValue = self.currentProgressBar.maximumValue;
        [timer invalidate];
        timer = nil;
        
        if(_numberOfCurrentProgressView == _numberOfGeneralGamer) {
            //[self viewWillDisappear:YES];
            _currentProgressBar.currentValue = _currentProgressBar.maximumValue;
            [self passAction];
            [self stopCurrentProgressBar];
            return;
        }
        _timer = nil;
        return;
    } else {
        newCurrentValue = self.currentProgressBar.currentValue - 1;
    }
    
    [self.currentProgressBar updateToCurrentValue:newCurrentValue animated:YES];
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    screenshortViewController *secVC = [segue destinationViewController];
    secVC.theImage = _buffImage;
}

@end