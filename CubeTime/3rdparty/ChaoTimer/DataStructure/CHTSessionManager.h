//
//  CHTSessionManager.h
//  ChaoTimer
//
//  Created by Jichao Li on 10/2/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHTSession.h"
#import "CHTUpdater.h"

@interface CHTSessionManager : NSObject <NSCoding>
@property (nonatomic, strong) NSMutableArray *sessionArray;
@property (nonatomic, strong) NSMutableArray *stickySessionArray;
@property (nonatomic, strong) NSString *currentSessionName;

+ (CHTSession *) loadSessionWithName: (NSString *)name;
- (CHTSession *) loadCurrentSession;
- (void) addSession:(NSString *)addName;
- (void) removeStickySessionAtIndex:(int) index;
- (void) removeNormalSessionAtIndex:(int) index;
- (NSUInteger) stickySessionNum;
- (NSUInteger) normalSessionNum;
- (NSString *) getStickySessionAt: (int)position;
- (NSString *) getNormalSessionAt: (int)position;
- (BOOL) hasSession:(NSString *)sessionName;
- (void) renameSession:(NSString *)oldName to:(NSString *) newName;
- (void) moveObjectFrom:(NSIndexPath *)from toIndexPath:(NSIndexPath *)to;
+ (void)saveSession: (CHTSession *)session;
- (void)save;
+ (CHTSessionManager *)load;

@end
