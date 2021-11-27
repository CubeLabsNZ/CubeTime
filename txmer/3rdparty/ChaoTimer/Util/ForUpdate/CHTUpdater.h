//
//  CHTUpdater.h
//  ChaoTimer
//
//  Created by Jichao Li on 10/7/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@class CHTSessionManager;
@interface CHTUpdater : NSObject
+ (CHTSessionManager *) updateFromOldVersion;
@end
