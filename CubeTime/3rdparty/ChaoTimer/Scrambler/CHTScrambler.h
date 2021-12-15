//
//  CHTScrambler.h
//  ChaoTimer
//
//  Created by Jichao Li on 10/6/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHTScrambler : NSObject

- (NSString *)getScrStringByType: (int)type subset: (int)subset;
- (void) initSq1;
+ (NSArray *) scrambleTypes;

@end
