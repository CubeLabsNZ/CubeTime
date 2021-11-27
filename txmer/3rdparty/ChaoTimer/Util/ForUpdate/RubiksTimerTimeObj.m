//
//  RubiksTimerTimeObj.m
//  RubiksTimer
//
//  Created by Jichao Li on 5/22/12.
//  Copyright (c) 2012 Sufflok University. All rights reserved.
//

#import "RubiksTimerTimeObj.h"
#import "RubiksTimerDataProcessing.h"

@interface RubiksTimerTimeObj ()

@end

@implementation RubiksTimerTimeObj
@synthesize timeValueBeforePenalty;
@synthesize timeValueAfterPenalty;
@synthesize penalty;
@synthesize scramble;
@synthesize index;
@synthesize type;


- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:[NSNumber numberWithInt:timeValueBeforePenalty] forKey:@"timeBeforePenalty"];
    [aCoder encodeObject:[NSNumber numberWithInt:timeValueAfterPenalty] forKey:@"timeAfterPenalty"];
    [aCoder encodeObject:[NSNumber numberWithInt:penalty] forKey:@"timePenalty"];
    [aCoder encodeObject:scramble forKey:@"solveScramble"];
    [aCoder encodeObject:type forKey:@"solveType"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self == [super init]) {
        self.timeValueBeforePenalty = [[aDecoder decodeObjectForKey:@"timeBeforePenalty"] intValue];
        self.timeValueAfterPenalty = [[aDecoder decodeObjectForKey:@"timeAfterPenalty"] intValue];
        self.penalty = [[aDecoder decodeObjectForKey:@"timePenalty"] intValue];
        self.scramble = [aDecoder decodeObjectForKey:@"solveScramble"];
        self.type =  [aDecoder decodeObjectForKey:@"solveType"];
    }
    return self;
}

@end
