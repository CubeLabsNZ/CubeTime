//
//  CHTOneStat.h
//  ChaoTimer
//
//  Created by Jichao Li on 10/4/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHTOneStat : NSObject
@property (nonatomic, strong) NSString *statType, *statValue;

+ (CHTOneStat *) initWithType: (NSString *)type Value: (NSString *)value;
@end
