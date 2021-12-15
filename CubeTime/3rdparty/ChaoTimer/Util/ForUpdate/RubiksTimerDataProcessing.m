//
//  RubiksTimerDataProcessing.m
//  RubiksTimer
//
//  Created by Jichao Li on 5/21/12.
//  Copyright (c) 2012 Sufflok University. All rights reserved.
//

#import "RubiksTimerDataProcessing.h"
#import "RubiksTimerTimeObj.h"
#import "stdio.h"

@interface RubiksTimerDataProcessing ()
@end

@implementation RubiksTimerDataProcessing
@synthesize timeStoredArray = _timeStoredArray;
@synthesize CurrentType = _CurrentType;
@synthesize sessionName = _sessionName;

- (NSString *) CurrentType {
    if (!_CurrentType) {
        _CurrentType = @"3x3random state";
    }
    return _CurrentType;
}

- (NSString *) sessionName {
    if (!_sessionName) {
        _sessionName = @"main session";
    }
    return _sessionName;
}

- (NSMutableArray *)timeStoredArray  {
    if (!_timeStoredArray) {
        _timeStoredArray = [[NSMutableArray alloc] init];
    }
    return _timeStoredArray;
}


- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.timeStoredArray forKey:@"timeArray"];
    [aCoder encodeObject:self.CurrentType forKey:@"currentType"];
    [aCoder encodeObject:self.sessionName forKey:@"sessionName"];

}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self == [super init]) {
        self.timeStoredArray = [aDecoder decodeObjectForKey:@"timeArray"];
        self.CurrentType = [aDecoder decodeObjectForKey:@"currentType"];
        self.sessionName = [aDecoder decodeObjectForKey:@"sessionName"];
    }
    return self;
}

@end
