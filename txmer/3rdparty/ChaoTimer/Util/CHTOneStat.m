//
//  CHTOneStat.m
//  ChaoTimer
//
//  Created by Jichao Li on 10/4/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import "CHTOneStat.h"

@implementation CHTOneStat
@synthesize statType, statValue;

+ (CHTOneStat *) initWithType: (NSString *)type Value: (NSString *)value {
    CHTOneStat *oneStat = [[CHTOneStat alloc] init];
    oneStat.statType = type;
    oneStat.statValue = value;
    return oneStat;
}
@end
