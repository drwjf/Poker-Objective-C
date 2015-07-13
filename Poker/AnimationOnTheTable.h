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

@property (weak, nonatomic) IBOutlet UIView *contentView;

@property (strong, nonatomic) IBOutlet UIButton *raiseBetButton;
@property (strong, nonatomic) IBOutlet UIButton *checkButton;
@property (strong, nonatomic) IBOutlet UIButton *pasButton;
@property (strong, nonatomic) IBOutlet UIButton *callButton;

@property (strong, nonatomic) IBOutlet UIButton *showCombinationButton;
@property (strong, nonatomic) IBOutlet UIImageView *combinationImage;


@property (strong, nonatomic) IBOutlet UITextView *chatTextView;
@property (strong, nonatomic) IBOutlet UITextField *inputTextFeld;
@property (strong, nonatomic) IBOutlet UIButton *sendMessageToChatButton;

@property (strong, nonatomic) IBOutlet UILabel *rateLabel;
@property (strong, nonatomic) IBOutlet UISlider *rateSlider;

@property(nonatomic,strong)NSMutableArray *gamersArray;
@property(nonatomic)int countVizualizedGamers;

@end
