//
//  CHTScramble.h
//  ChaoTimer
//
//  Created by Jichao Li on 8/12/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import <Foundation/Foundation.h>
@class CHTScrambler;
@interface CHTScramble : NSObject <NSCoding>
@property (nonatomic, strong) NSString *scrType;
@property (nonatomic, strong) NSString *scrSubType;
@property (nonatomic, strong) NSString *scramble;

+(CHTScramble *) getNewScrambleByScrambler:(CHTScrambler *)scrambler type:(int)type subType:(int)subType;
+ (NSString *)getScrambleTypeStringByType:(int)type language:(int)language;
@end
