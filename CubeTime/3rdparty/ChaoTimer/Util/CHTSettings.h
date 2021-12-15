//
//  CHTSettings.h
//  ChaoTimer
//
//  Created by Jichao Li on 9/19/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CHTSettings : NSObject

+ (int) getFreezeTime;
+ (void) saveFreezeTime:(int)freezeTime;
+ (BOOL) boolForKey:(NSString *)key;
+ (int) intForKey: (NSString *)key;
+ (NSString *) stringForKey: (NSString *)key;
+ (NSObject *) objectForKey: (NSString *)key;
+ (BOOL) hasObjectForKey: (NSString *)key;
+ (void) saveBool:(BOOL)value forKey:(NSString *)key;
+ (void) saveInt:(int)value forKey:(NSString *)key;
+ (void) saveString:(NSString *)value forKey:(NSString *)key;
+ (void) saveObject:(NSObject *)value forKey:(NSString *)key;
+ (void) initUserDefaults;
@end
