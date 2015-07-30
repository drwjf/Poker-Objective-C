//
//  GamerDataViewController.h
//  Poker
//
//  Created by Admin on 22.04.15.
//  Copyright (c) 2015 by.bsuir.eLearning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <MessageUI/MessageUI.h>
#import <MessageUI/MFMailComposeViewController.h>
#import "TCPConnection.h"

@interface GamerDataViewController : UIViewController <AVAudioPlayerDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, MFMailComposeViewControllerDelegate, ConnectionToServerDelegateForGamerDataVC>

@property (strong, nonatomic) IBOutlet UITextField *gamerName;

@property (strong, nonatomic) IBOutlet UIImageView *imageOfGamer;

@property (strong, nonatomic) IBOutlet UILabel *gamerMoneyLabel;
@property (strong, nonatomic) IBOutlet UILabel *gamersLevel;

@property (strong, nonatomic) IBOutlet UIButton *playButton;
@property (strong, nonatomic) IBOutlet UITextView *rulesOfPokerTextView;
@property (strong, nonatomic) IBOutlet UILabel *enableAccelerometerLabel;
@property (strong, nonatomic) IBOutlet UISwitch *enableAcceslerometerSwitcher;

@property (strong, nonatomic) IBOutlet UIButton *sendMessageButton;


@property(nonatomic,strong)AVAudioPlayer *audioPlayer;

@end
