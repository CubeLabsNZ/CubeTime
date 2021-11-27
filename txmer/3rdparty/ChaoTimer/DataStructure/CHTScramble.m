//
//  CHTScramble.m
//  ChaoTimer
//
//  Created by Jichao Li on 8/12/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import "CHTScramble.h"
#import "CHTScrambler.h"

@implementation CHTScramble

@synthesize scrType;
@synthesize scrSubType;
@synthesize scramble;

+(CHTScramble *) getNewScrambleByScrambler:(CHTScrambler *)scrambler type:(int)type subType:(int)subType {
    CHTScramble *newScramble = [[CHTScramble alloc] init];
    [newScramble setTypeAndSubTypeByType:type subset:subType];
    newScramble.scramble = [scrambler getScrStringByType:type subset:subType];
    return newScramble;
}

- (void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.scrType forKey:@"scrambleType"];
    [aCoder encodeObject:self.scrSubType forKey:@"scrambleSubType"];
    [aCoder encodeObject:self.scramble  forKey:@"scrambleString"];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self == [super init]) {
        self.scrType =[aDecoder decodeObjectForKey:@"scrambleType"];
        self.scrSubType = [aDecoder decodeObjectForKey:@"scrambleSubType"];
        self.scramble = [aDecoder decodeObjectForKey:@"scrambleString"];
    }
    return self;
}

- (void)setTypeAndSubTypeByType:(int)type subset:(int)subset {
    NSBundle *bundle = [NSBundle mainBundle];
    NSURL *plistURL = [bundle URLForResource:@"scrambleTypes" withExtension:@"plist"];
    NSDictionary *scrTypeDic = [NSDictionary dictionaryWithContentsOfURL:plistURL];
    NSArray *types = [CHTScrambler scrambleTypes];
    NSString *typeStr = [types objectAtIndex:type];
    NSArray *subsets = [scrTypeDic objectForKey:typeStr];
    NSString *subsetStr = [subsets objectAtIndex:subset];
    self.scrType = typeStr;
    self.scrSubType = subsetStr;
}

+ (NSString *)getScrambleTypeStringByType:(int)type language:(int)language{
    NSString *typeStr = @"speedsolving";
    if (language == 0) {
        switch (type) {
            case 0: // 2x2
                typeStr = @"2x2x2";
                break;
            case 1: // 3x3
                typeStr = @"3x3x3";
                break;
            case 2: // 4x4
                typeStr = @"4x4x4";
                break;
            case 3: // 5x5
                typeStr = @"5x5x5";
                break;
            case 4: // 6x6
                typeStr = @"6x6x6";
                break;
            case 5: // 7x7
                typeStr = @"7x7x7";
                break;
            case 6: // sq1
                typeStr = @"Square-1";
                break;
            case 7: // megaminx
                typeStr = @"Magaminx";
                break;
            case 8: // pyraminx
                typeStr = @"Pyraminx";
                break;
            case 9: // clock
                typeStr = @"Clock";
                break;
            case 10: // skewb
                typeStr = @"Skewb";
                break;
            case 11: // gear
                typeStr = @"Gear";
                break;
            case 12: // 33sub
                typeStr = @"3x3x3";
                break;
            default:
                break;
        }
    }else {
        switch (type) {
            case 0: // 2x2
                typeStr = @"二阶魔方";
                break;
            case 1: // 3x3
                typeStr = @"三阶魔方";
                break;
            case 2: // 4x4
                typeStr = @"四阶魔方";
                break;
            case 3: // 5x5
                typeStr = @"五阶魔方";
                break;
            case 4: // 6x6
                typeStr = @"六阶魔方";
                break;
            case 5: // 7x7
                typeStr = @"七阶魔方";
                break;
            case 6: // sq1
                typeStr = @"Square-1";
                break;
            case 7: // megaminx
                typeStr = @"五魔方";
                break;
            case 8: // pyraminx
                typeStr = @"金字塔";
                break;
            case 9: // clock
                typeStr = @"魔表";
                break;
            case 10: // skewb
                typeStr = @"Skewb";
                break;
            case 11: // gear
                typeStr = @"齿轮魔方";
                break;
            case 12: // 33sub
                typeStr = @"三阶魔方";
                break;
            default:
                typeStr = @"魔方";
                break;
        }
    }
    return typeStr;
}

@end
