//
//  RubiksTimerDataProcessing.h
//  RubiksTimer
//
//  Created by Jichao Li on 5/21/12.
//  Copyright (c) 2012 Sufflok University. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RubiksTimerTimeObj.h"

@interface RubiksTimerDataProcessing : NSObject <NSCoding>

@property (nonatomic, strong) NSMutableArray *timeStoredArray;
@property (readonly) int numberOfSolves;
@property (nonatomic, strong) NSString *CurrentType;
@property (nonatomic, strong) NSString *sessionName;

@end