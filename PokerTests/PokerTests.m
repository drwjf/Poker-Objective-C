//
//  PokerTests.m
//  PokerTests
//
//  Created by Admin on 20.04.15.
//  Copyright (c) 2015 by.bsuir.eLearning. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <XCTest/XCTest.h>

@interface PokerTests : XCTestCase
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *arrayOfPlayersImages;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *arrayOfLabelsPlayersMoneys;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *arrayOfLabelsPlayersNames;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *arrayOfImagesCardsOnTheTable;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *arrayOfImagesPrivatePlayersCard;

@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *arrayOfLabelsGamerRates;

@property (nonatomic) int countOfPlayersOnTheTable;
@end

@implementation PokerTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    // This is an example of a functional test case.
    XCTAssert(YES, @"Pass");
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

- (NSString *)prepareGamerMoneyBeforeRendering:(NSNumber *)money {
    NSString *gamerMoney = [NSString stringWithFormat:@"%@", money];
    NSString *resultString = @"$";
    
    int countOfFirstNumbers = [gamerMoney length] % 3;
    
    resultString = [resultString stringByAppendingString:[gamerMoney substringWithRange:NSMakeRange(0, countOfFirstNumbers)]];
    
    for(int i=countOfFirstNumbers; i < [gamerMoney length]; i+=3) {
        NSString *partOfString = [NSString stringWithFormat:@" %@", [gamerMoney substringWithRange:NSMakeRange(i, 3)]];
        resultString = [resultString stringByAppendingString:partOfString];
    }
    return resultString;
}

- (void)renderingBlindsOfGamers:(NSDictionary *)dictionary {
    int numberOfGamerWithSmallBlind, numberOfGamerWithBigBlind;
    
    id firstBlind = dictionary[@"numberOfPlayerWithSmallBlind"];
    if(![firstBlind isKindOfClass:[NSNumber class]]) {NSLog(@"error of parser !"); return; }
    
    numberOfGamerWithSmallBlind = [firstBlind intValue];
    numberOfGamerWithBigBlind = (numberOfGamerWithSmallBlind + 1) % self.countOfPlayersOnTheTable;
    
    NSNumber *valueOfBigBlind = dictionary[@"betOfBigBlind"];
    NSNumber *valueOfSmallBlind = [NSNumber numberWithLongLong:[valueOfBigBlind longLongValue] / 2];
    
    
    UILabel *gamerWithBigBlindMoneyLabel = [self.arrayOfLabelsGamerRates objectAtIndex:numberOfGamerWithBigBlind];
    UILabel *gamerWithSmallBlindMoneyLabel = [self.arrayOfLabelsGamerRates objectAtIndex:numberOfGamerWithSmallBlind];
    
    NSString *betOfBigBlind = [self prepareGamerMoneyBeforeRendering:valueOfBigBlind];
    NSString *betOfSmallBlind = [self prepareGamerMoneyBeforeRendering:valueOfSmallBlind];
    
    [gamerWithBigBlindMoneyLabel setAttributedText:[self attributedStringForInfoAboutGamerInView:betOfBigBlind]];
    [gamerWithSmallBlindMoneyLabel setAttributedText:[self attributedStringForInfoAboutGamerInView:betOfSmallBlind]];
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        [self renderingBlindsOfGamers:[[NSDictionary alloc] init]];
    }];
}

@end
