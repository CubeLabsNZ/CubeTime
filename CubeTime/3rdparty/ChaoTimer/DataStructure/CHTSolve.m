//
//  CHTSolve.m
//  ChaoTimer
//
//  Created by Jichao Li on 8/10/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import "CHTSolve.h"

@interface CHTSolve()

@end

@implementation CHTSolve

@synthesize index;
@synthesize timeStamp;
@synthesize scramble;
@synthesize timeBeforePenalty;
@synthesize timeAfterPenalty;
@synthesize penalty;

- (int) timeAfterPenalty{
    int time = self.timeBeforePenalty;
    if (self.penalty == PENALTY_PLUS_2) {
        time = self.timeBeforePenalty + 2000;
    } else if (self.penalty == PENALTY_DNF) {
        time = INFINITY;
    }
    return time;
}

- (NSString *) toString {
    NSString *str = [CHTUtil convertTimeFromMsecondToString:self.timeAfterPenalty];
    if (penalty == PENALTY_PLUS_2) {
        str = [str stringByAppendingString:@"+"];
    } else if (penalty == PENALTY_DNF) {
        str = @"DNF";
    } 
    return str;
}

- (NSString *) toStringWith2DecimalPlaces {
    NSString *str = [self toString];
    return [str substringToIndex:(str.length - 1)];
    
}

- (NSString *) getTimeStampString {
    NSString *dateString = [NSDateFormatter localizedStringFromDate:self.timeStamp dateStyle:NSDateFormatterMediumStyle timeStyle:NSDateFormatterMediumStyle];
    return dateString;
    
}

- (void) setTime: (int)newTimeBeforePenalty andPenalty: (PenaltyType)newPenalty {
    self.timeStamp = [NSDate date];
    self.timeBeforePenalty = newTimeBeforePenalty;
    self.penalty = newPenalty;
    self.scramble = [[CHTScramble alloc] init];
}

+ (CHTSolve *) newSolveWithTime: (int)newTime andPenalty:(PenaltyType)newPenalty andScramble: (CHTScramble *)newScramble {
    CHTSolve *newSolve = [[CHTSolve alloc] init];
    [newSolve setTime:newTime andPenalty:newPenalty];
    [newSolve setScramble:newScramble];
    return newSolve;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:timeStamp forKey:@"timeStamp"];
    [aCoder encodeInt:timeBeforePenalty forKey:@"timeBeforePenalty"];
    [aCoder encodeInt:penalty forKey:@"timePenalty"];
    [aCoder encodeObject:scramble forKey:@"solveScramble"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self == [super init]) {
        self.timeStamp = [aDecoder decodeObjectForKey:@"timeStamp"];
        self.timeBeforePenalty = [aDecoder decodeIntForKey:@"timeBeforePenalty"];
        self.penalty = [aDecoder decodeIntForKey:@"timePenalty"];
        self.scramble = [aDecoder decodeObjectForKey:@"solveScramble"];
    }
    return self;
}

- (NSString *)getPenaltyAsString {
    switch (self.penalty) {
        case PENALTY_NO_PENALTY:
            return @"No Penalty";
        case PENALTY_PLUS_2:
            return @"+2";
        case PENALTY_DNF:
            return @"DNF";
        default:
            break;
    }
}

@end
