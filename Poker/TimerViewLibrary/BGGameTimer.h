//
//  BGGameTimer.h
//  Boggle
//
//  Created by vladimir.trus@monterosa.co.uk on 17.02.15.
//  Copyright (c) 2015 Monterosa Productions Ltd. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface BGGameTimer : UIView

@property (nonatomic, readwrite) CGFloat maxTimer;
@property (nonatomic, readwrite) CGFloat timer;

-(void)resetGameViewTimer;

@end
