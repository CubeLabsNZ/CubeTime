//
//  CHTSession.m
//  ChaoTimer
//
//  Created by Jichao Li on 8/10/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import "CHTSession.h"

@interface CHTSession()
@property (nonatomic, strong) NSMutableArray *timeArray;
@end

@implementation CHTSession
@synthesize timeArray = _timeArray;
@synthesize currentType = _currentType;
@synthesize currentSubType = _currentSubType;
@synthesize sessionName = _sessionName;

- (NSString *) sessionName {
    if (!_sessionName) {
        _sessionName = @"main session";
    }
    return _sessionName;
}

- (NSMutableArray *)timeArray  {
    if (!_timeArray) {
        _timeArray = [[NSMutableArray alloc] init];
    }
    return _timeArray;
}

+ (CHTSession *) initWithDefault{
    return [self initWithName:@"main session"];
}

+ (CHTSession *) initWithName:(NSString *)name{
    CHTSession *session = [[CHTSession alloc] init];
    session.sessionName = name;
    session.currentType = 1;
    session.currentSubType = 0;
    return session;
}

- (int)numberOfSolves {
    return self.timeArray.count;
}

- (void)addSolve:(int)time withPenalty:(PenaltyType)penalty scramble:(CHTScramble *)scramble {
    CHTSolve *newSolve = [CHTSolve newSolveWithTime:time andPenalty:penalty andScramble:scramble];
    newSolve.index = self.numberOfSolves;
    [self.timeArray addObject:newSolve];
}

- (CHTSolve *)bestSolveOf: (NSMutableArray *)array {
    CHTSolve *min = (CHTSolve *)(array.lastObject);
    for (id solve in self.timeArray) {
        if (((CHTSolve *)solve).timeAfterPenalty < min.timeAfterPenalty) {
            min = (CHTSolve *)solve;
        }
    }
    return min;
}

- (CHTSolve *)worstSolveOf: (NSMutableArray *)array {
    CHTSolve *max = (CHTSolve *)(array.lastObject);
    for (id solve in self.timeArray) {
        if (((CHTSolve *)solve).timeAfterPenalty > max.timeAfterPenalty) {
            max = (CHTSolve *)solve;
        }
    }
    return max;
}

- (void)addPenaltyToLastSolve: (PenaltyType)penalty {
    if (self.numberOfSolves > 0) {
        [((CHTSolve *)self.timeArray.lastObject) setPenalty:penalty];
    }
}

- (void)deleteLastSolve {
    if (self.numberOfSolves > 0) {
        [self.timeArray removeLastObject];
    }
}

- (CHTSolve *)lastSolve {
    return self.timeArray.lastObject;
}

- (CHTSolve *)bestSolve {
    return [self bestSolveOf:self.timeArray];
}

- (CHTSolve *)worstSolve {
    return [self worstSolveOf:self.timeArray];
}

- (CHTSolve *)bestAvgOf: (int)num {
    int bestavg = INFINITY;
    if ((self.numberOfSolves >= num) && (self.numberOfSolves >=3)) {
        for (int i = 0; i <= (self.numberOfSolves - num); i++) {
            int avg = 0;
            int sum = 0;
            int max = 0;
            int min = INFINITY;
            int DNFs = 0;
            for (int j = 0; j < num; j++) {
                int thisTime = ((CHTSolve *)[self.timeArray objectAtIndex:(i+j)]).timeAfterPenalty;
                PenaltyType p = ((CHTSolve *)[self.timeArray objectAtIndex:(i+j)]).penalty;
                if (p == PENALTY_DNF) {
                    DNFs++;
                }
                sum = sum + thisTime;
                if (thisTime > max) {
                    max = thisTime;
                }
                if (thisTime < min) {
                    min = thisTime;
                }
            }
            if (DNFs > 1) {
                avg = INFINITY;
            } else {
                sum = sum - min - max;
                avg = sum / (num - 2);
            }
            if (bestavg > avg) {
                bestavg = avg;
            }
        }
    }
    // why if (bestavg == INFINITY) not right?
    if (bestavg == 2147483647) {
        bestavg = -1;
    }
    PenaltyType newPenalty = PENALTY_NO_PENALTY;
    if(bestavg == -1) {
        newPenalty = PENALTY_DNF;
    }
    return [CHTSolve newSolveWithTime:bestavg andPenalty:newPenalty andScramble:nil];
}

- (CHTSolve *)currentAvgOf: (int)num {
    int avg = 0;
    if ((self.numberOfSolves >= num) && (self.numberOfSolves >=3)) {
        int sum = 0;
        int max = 0;
        int min = INFINITY;
        int DNFs = 0;
        for (int i = (self.timeArray.count - num); i < self.timeArray.count; i++) {
            int thisTime = ((CHTSolve *)[self.timeArray objectAtIndex:i]).timeAfterPenalty;
            PenaltyType p =  ((CHTSolve *)[self.timeArray objectAtIndex:i]).penalty;
            if (p == PENALTY_DNF) {
                DNFs++;
            }
            sum = sum + thisTime;
            if (thisTime > max) {
                max = thisTime;
            }
            if (thisTime < min) {
                min = thisTime;
            }
        }
        if (DNFs > 1) {
            avg = -1;
        }
        else {
            sum = sum - min - max;
            avg = sum / (num - 2);
        }
    }
    PenaltyType newPenalty = PENALTY_NO_PENALTY;
    if(avg == -1) {
        newPenalty = PENALTY_DNF;
    }
    return [CHTSolve newSolveWithTime:avg andPenalty:newPenalty andScramble:nil];
}

- (CHTSolve *)sessionAvg {
    int avg = 0;
    if (self.numberOfSolves >= 3) {
        int sum = 0;
        int DNFs = 0;
        for (id times in self.timeArray) {
            int thisTime = ((CHTSolve *)times).timeAfterPenalty;
            PenaltyType p = ((CHTSolve *)times).penalty;
            sum = sum + thisTime;
            if (p == PENALTY_DNF) {
                DNFs++;
            }
        }
        if (DNFs > 1) {
            avg = -1;
        } else {
            sum = sum - [self bestSolve].timeAfterPenalty -[self worstSolve].timeAfterPenalty;
            avg = sum / (self.numberOfSolves - 2);
        }
    }
    PenaltyType newPenalty = PENALTY_NO_PENALTY;
    if(avg == -1) {
        newPenalty = PENALTY_DNF;
    }
    return [CHTSolve newSolveWithTime:avg andPenalty:newPenalty andScramble:nil];
}

- (CHTSolve *)sessionMean {
    int mean = 0;
    if (self.numberOfSolves > 0) {
        int sum = 0;
        int DNFs = 0;
        for (id times in self.timeArray) {
            int thisTime = ((CHTSolve *)times).timeAfterPenalty;
            PenaltyType p = ((CHTSolve *)times).penalty;
            if (p == PENALTY_DNF) {
                DNFs++;
            } else {
                sum = sum + thisTime;
            }
        }
        if (self.numberOfSolves > DNFs) {
            mean = sum / (self.numberOfSolves - DNFs);
        }
        else {
            mean = -1;
        }
    }
    PenaltyType newPenalty = PENALTY_NO_PENALTY;
    if(mean == -1) {
        newPenalty = PENALTY_DNF;
    }
    return [CHTSolve newSolveWithTime:mean andPenalty:newPenalty andScramble:nil];
}

- (NSMutableArray *) getBest: (int)solves {
    NSMutableArray *array = [[NSMutableArray alloc] init];
    int bestavg = INFINITY;
    int index = 0;
    if ((self.numberOfSolves >= solves) && (self.numberOfSolves >=3)) {
        for (int i = 0; i <= (self.numberOfSolves - solves); i++) {
            int avg = 0;
            int sum = 0;
            int max = 0;
            int min = INFINITY;
            int DNFs = 0;
            for (int j = 0; j < solves; j++) {
                int thisTime = ((CHTSolve *)[self.timeArray objectAtIndex:(i+j)]).timeAfterPenalty;
                PenaltyType p = ((CHTSolve *)[self.timeArray objectAtIndex:(i+j)]).penalty;
                if (p == PENALTY_DNF) {
                    DNFs++;
                }
                sum = sum + thisTime;
                if (thisTime > max) {
                    max = thisTime;
                }
                if (thisTime < min) {
                    min = thisTime;
                }
            }
            if (DNFs > 1) {
                avg = INFINITY;
            } else {
                sum = sum - min - max;
                avg = sum / (solves - 2);
            }
            if (bestavg > avg) {
                bestavg = avg;
                index = i;
            }
        }
    }
    for (int i = index; i < (index + solves); i++) {
        [array addObject:[self.timeArray objectAtIndex:i]];
    }
    return array;
}

- (NSMutableArray *) getCurrent: (int)solves{
    NSMutableArray *array = [[NSMutableArray alloc] init];
    if ((self.numberOfSolves >= solves) && (self.numberOfSolves >=3)) {
        for (int i = (self.timeArray.count - solves); i < self.timeArray.count; i++) {
            [array addObject:[self.timeArray objectAtIndex:i]];
        }
    }
    return array;
}

- (NSMutableArray *) getAllSolves {
    return [self.timeArray mutableCopy];
}

- (NSString *)numberOfSolvesToString {
    int num = self.numberOfSolves;
    return [NSString stringWithFormat:@"%d", num];
}

- (NSString *)toString: (BOOL)containIndividualTime {
    NSString *str = [[CHTUtil getLocalizedString:@"Number of solves: "] stringByAppendingFormat:@"%d\n", self.numberOfSolves];
    if (self.numberOfSolves > 0) {
        NSString *bestTime = [[[CHTUtil getLocalizedString:@"Best Time: "] stringByAppendingString:[[self bestSolve] toString]] stringByAppendingFormat:@"\n"];
        NSString *worstTime = [[[CHTUtil getLocalizedString:@"Worst Time: "] stringByAppendingString:[[self worstSolve] toString]] stringByAppendingFormat:@"\n"];
        str = [[str stringByAppendingString:bestTime] stringByAppendingString:worstTime];
        if (!containIndividualTime) {
            if (self.numberOfSolves >= 5) {
                NSString *ca5 = [[[CHTUtil getLocalizedString:@"Current Avg5: "] stringByAppendingString:[[self currentAvgOf:5] toString]]stringByAppendingFormat:@"\n"];
                NSString *ba5 = [[[CHTUtil getLocalizedString:@"Best Avg5: "] stringByAppendingString:[[self bestAvgOf:5] toString]]stringByAppendingFormat:@"\n"];
                str = [[str stringByAppendingString:ca5] stringByAppendingString:ba5];
            }
            if (self.numberOfSolves >= 12) {
                NSString *ca12 = [[[CHTUtil getLocalizedString:@"Current Avg12: "] stringByAppendingString:[[self currentAvgOf:12] toString]]stringByAppendingFormat:@"\n"];
                NSString *ba12 = [[[CHTUtil getLocalizedString:@"Best Avg12: "] stringByAppendingString:[[self bestAvgOf:12] toString]]stringByAppendingFormat:@"\n"];
                str = [[str stringByAppendingString:ca12] stringByAppendingString:ba12];
            }
            if (self.numberOfSolves >= 100) {
                NSString *ca100 = [[[CHTUtil getLocalizedString:@"Current Avg100: "] stringByAppendingString:[[self currentAvgOf:100] toString]]stringByAppendingFormat:@"\n"];
                NSString *ba100 = [[[CHTUtil getLocalizedString:@"Best Avg100: "] stringByAppendingString:[[self bestAvgOf:100] toString]]stringByAppendingFormat:@"\n"];
                str = [[str stringByAppendingString:ca100] stringByAppendingString:ba100];
            }
        }
        NSString *sessionAvg = [[[CHTUtil getLocalizedString:@"Session Avg: "] stringByAppendingString:[[self sessionAvg] toString]]stringByAppendingFormat:@"\n"];
        NSString *sessionMean = [[[CHTUtil getLocalizedString:@"Session Mean: "] stringByAppendingString:[[self sessionMean] toString]]stringByAppendingFormat:@"\n"];
        str = [[str stringByAppendingString:sessionAvg] stringByAppendingString:sessionMean];
        if (containIndividualTime) {
            BOOL notHasBest = YES;
            BOOL notHasWorst = YES;
            NSString *timesList = @"";
            CHTSolve *tempBest = self.timeArray.lastObject;
            CHTSolve *tempWorst = self.timeArray.lastObject;
            for (id aTime in self.timeArray) {
                if (((CHTSolve *)aTime).timeAfterPenalty > tempWorst.timeAfterPenalty) {
                    tempWorst = (CHTSolve *)aTime;
                }
                if (((CHTSolve *)aTime).timeAfterPenalty < tempBest.timeAfterPenalty) {
                    tempBest = (CHTSolve *)aTime;
                }
            }
            for (id aTime in self.timeArray) {
                NSString *appendTime = [aTime toString];
                if ([aTime isEqual:tempBest] && notHasBest) {
                    appendTime = [NSString stringWithFormat:@"(%@)", appendTime];
                    notHasBest = NO;
                } else if ([aTime isEqual:tempWorst] && notHasWorst) {
                    appendTime = [NSString stringWithFormat:@"(%@)", appendTime];
                    notHasWorst = NO;
                }
                timesList = [[timesList stringByAppendingString:appendTime] stringByAppendingString:@", "];
            }
            timesList = [timesList substringToIndex:(timesList.length - 2)];
            NSString *individualTimes = [[[CHTUtil getLocalizedString:@"Individual Times: "] stringByAppendingFormat:@"\n"] stringByAppendingString:timesList];
            str = [[str stringByAppendingString:individualTimes] stringByAppendingFormat:@"\n"];
        }
    }
    if ([self.sessionName isEqualToString:@"main session"]) {
        str = [[[CHTUtil getLocalizedString:self.sessionName] stringByAppendingString:@"\n\n" ] stringByAppendingString:str];
    } else {
        str = [[self.sessionName stringByAppendingString:@"\n\n" ] stringByAppendingString:str];
    }
    return str;
}

- (void)removeSolveAtIndex: (int)index {
    if (self.numberOfSolves > index) {
        [self.timeArray removeObjectAtIndex:index];
    }
}

- (void)removeSolve: (CHTSolve *)aSolve {
    [self.timeArray removeObject:aSolve];
}

- (void)clear {
    [self.timeArray removeAllObjects];
}

- (void)setSolves: (NSMutableArray *)solves {
    self.timeArray = solves;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.timeArray forKey:@"timeArray"];
    [aCoder encodeInt:self.currentType forKey:@"currentType"];
    [aCoder encodeInt:self.currentSubType forKey:@"currentSubType"];
    [aCoder encodeObject:self.sessionName forKey:@"sessionName"];
    
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self == [super init]) {
        self.timeArray = [aDecoder decodeObjectForKey:@"timeArray"];
        self.currentType = [aDecoder decodeIntForKey:@"currentType"];
        self.currentSubType = [aDecoder decodeIntForKey:@"currentSubType"];
        self.sessionName = [aDecoder decodeObjectForKey:@"sessionName"];
    }
    return self;
}
@end
