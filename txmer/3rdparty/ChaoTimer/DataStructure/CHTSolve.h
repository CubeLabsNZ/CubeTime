//
//  CHTSolve.h
//  ChaoTimer
//
//  Created by Jichao Li on 8/10/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHTScramble.h"
#import "CHTUtil.h"

typedef enum penaltyType {
    PENALTY_NO_PENALTY = 0,
    PENALTY_PLUS_2 = 1,
    PENALTY_DNF = 2
} PenaltyType;

@interface CHTSolve : NSObject <NSCoding>
@property (nonatomic) int index;
@property (nonatomic, strong) NSDate *timeStamp;
@property (nonatomic, strong) CHTScramble *scramble;
@property (nonatomic) int timeBeforePenalty;
@property (nonatomic) int timeAfterPenalty;
@property (nonatomic) PenaltyType penalty;

- (NSString *) toString;
- (NSString *) toStringWith2DecimalPlaces;
- (void) setTime: (int)newTimeBeforePenalty andPenalty: (PenaltyType)newPenalty;
- (NSString *) getTimeStampString;
+ (CHTSolve *) newSolveWithTime: (int)newTime andPenalty:(PenaltyType)newPenalty andScramble: (CHTScramble *)newScramble;
- (NSString *)getPenaltyAsString;
@end
