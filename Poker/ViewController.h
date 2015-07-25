//
//  ViewController.h
//  Poker
//
//  Created by Admin on 20.04.15.
//  Copyright (c) 2015 by.bsuir.eLearning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GCDAsyncSocket.h"
#import <AVFoundation/AVFoundation.h>
#import "ConnectionToServer.h"

@interface ViewController : UIViewController <AVAudioPlayerDelegate, ConnectionToServerDelegate>

@property (strong, nonatomic) IBOutlet UIImageView *generalImage;
@property (strong, nonatomic) IBOutlet UITextField *ipAdressTextField;
@property (strong, nonatomic) IBOutlet UITextField *portTextField;
@property(nonatomic,strong)AVAudioPlayer *audioPlayer;

@end

