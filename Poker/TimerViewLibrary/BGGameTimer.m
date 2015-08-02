//
//  BGGameTimer.m
//  Boggle
//
//  Created by vladimir.trus@monterosa.co.uk on 17.02.15.
//  Copyright (c) 2015 Monterosa Productions Ltd. All rights reserved.
//

#import "BGGameTimer.h"

@implementation BGGameTimer

@synthesize timer;
@synthesize maxTimer;

- (void)drawRect:(CGRect)rect {
    
    [self setOpaque:NO];
    [self setBackgroundColor:[UIColor clearColor]];
    
    CGRect bounds = self.bounds;
    CGFloat radius = bounds.size.width * 0.5;
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    CGContextSaveGState(ctx);
    CGContextClearRect(ctx, bounds);
    
    float value = 0;
    value = self.timer/self.maxTimer;
    
    CGFloat starttime = 3*M_PI/2;
    CGFloat endtime = 3*M_PI_2 - 2 * M_PI * value;

    //draw arc
    CGPoint center = CGPointMake(radius,radius);
    UIBezierPath *arc = [UIBezierPath bezierPath]; //empty path
    [arc moveToPoint:center];
    CGPoint next;
    next.x = center.x + radius * cos(starttime);
    next.y = center.y + radius * sin(starttime);
    [arc addLineToPoint:next]; //go one end of arc
    [arc addArcWithCenter:center radius:radius startAngle:starttime endAngle:endtime clockwise:YES]; //add the arc
    [arc addLineToPoint:center]; //back to center
    
    //[DEFAULT_BACKGROUND_COLOR_FOR_GAME_VIEW_CONTROLLER set];
    [arc fill];
    
}

-(void)resetGameViewTimer {
    self.timer = 0;// self.maxTimer;
    [self setNeedsDisplay];
}

@end
