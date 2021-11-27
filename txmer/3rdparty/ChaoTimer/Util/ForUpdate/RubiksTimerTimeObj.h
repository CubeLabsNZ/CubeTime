//
//  RubiksTimerTimeObj.h
//  RubiksTimer
//
//  Created by Jichao Li on 5/22/12.
//  Copyright (c) 2012 Sufflok University. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RubiksTimerTimeObj : NSObject <NSCoding>
@property int index;
@property int timeValueBeforePenalty; //ms
@property int timeValueAfterPenalty; //ms
@property int penalty; //0 for no penalty; 1 for +2; 2 for DNF;
@property NSString *scramble;
@property NSString *type;
@end
