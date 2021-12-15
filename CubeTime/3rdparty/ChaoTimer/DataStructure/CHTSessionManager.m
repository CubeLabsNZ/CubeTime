//
//  CHTSessionManager.m
//  ChaoTimer
//
//  Created by Jichao Li on 10/2/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import "CHTSessionManager.h"

#define KEY_SESSION_MANAGER @"sessionManager"
#define KEY_SESSION_ARRAY @"sessionArray"
#define KEY_STICKY_SESSION_ARRAY @"stickySessionArray"
#define KEY_CURRENT_SESSION_NAME @"currentSessionName"
#define KEY_SESSION @"CHTSession"
#define FILE_NAME @"CHTSessionManager"
#define FILE_SESSION_PREFIX @"CHTSession_"

@implementation CHTSessionManager
@synthesize sessionArray = _sessionArray;
@synthesize stickySessionArray = _stickySessionArray;
@synthesize currentSessionName = _currentSessionName;

- (NSMutableArray *)stickySessionArray {
    if (!_stickySessionArray) {
        NSLog(@"no sticky sessionArray");
        _stickySessionArray = [[NSMutableArray alloc] init];
        [_stickySessionArray addObject:@"main session"];
    }
    return _stickySessionArray;
}

- (NSMutableArray *)sessionArray {
    if (!_sessionArray) {
        NSLog(@"no sessionArray");
        _sessionArray = [[NSMutableArray alloc] init];
    }
    return _sessionArray;
}

- (NSString *)currentSessionName {
    if (!_currentSessionName) {
        NSLog(@"no currentSession");
        _currentSessionName = @"main session";
    }
    return _currentSessionName;
}

+ (CHTSession *) loadSessionWithName: (NSString *)name {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fileName = [[path objectAtIndex:0] stringByAppendingPathComponent:[FILE_SESSION_PREFIX stringByAppendingString:[CHTUtil escapeString:name]]];
    CHTSession *session;
    NSData *data = [[NSData alloc] initWithContentsOfFile:fileName];
    if (data) {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        @try {
            session = [unarchiver decodeObjectForKey:KEY_SESSION];
        }
        @catch (NSException * e) {
            session = [CHTSession initWithDefault];
            NSLog(@"Exception: %@", e);
        }
        @finally {
            [unarchiver finishDecoding];
        }
        NSLog(@"Load session: %@", session.sessionName);
        return session;
    }
    else {
        NSLog(@"Session named %@ not exit", name);
        session = [CHTSession initWithName:name];
        return session;
    }
}


- (CHTSession *) loadCurrentSession {
    NSLog(@"currentSessionName: %@", self.currentSessionName);
    return [CHTSessionManager loadSessionWithName:self.currentSessionName];
}

- (void) addSession:(NSString *)addName {
    [self.sessionArray insertObject:addName atIndex:0];
    self.currentSessionName = addName;
}

- (void) removeSession:(NSString *)removeName {
    if([self.stickySessionArray indexOfObject:removeName] != NSNotFound) {
        [self.stickySessionArray removeObject:removeName];
    } else
        [self.sessionArray removeObject:removeName];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fileName = [[path objectAtIndex:0] stringByAppendingPathComponent:[FILE_SESSION_PREFIX stringByAppendingString:removeName]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:fileName error:nil];
    
}

- (void) removeStickySessionAtIndex:(int) index{
    NSString *removeName = [self.stickySessionArray objectAtIndex:index];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fileName = [[path objectAtIndex:0] stringByAppendingPathComponent:[FILE_SESSION_PREFIX stringByAppendingString:removeName]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:fileName error:nil];
    [self.stickySessionArray removeObjectAtIndex:index];
}

- (void) removeNormalSessionAtIndex:(int) index{
    NSString *removeName = [self.sessionArray objectAtIndex:index];
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fileName = [[path objectAtIndex:0] stringByAppendingPathComponent:[FILE_SESSION_PREFIX stringByAppendingString:removeName]];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    [fileManager removeItemAtPath:fileName error:nil];
    [self.sessionArray removeObjectAtIndex:index];
}

- (NSUInteger) stickySessionNum {
    NSLog(@"stickysession num %d", self.stickySessionArray.count);
    return self.stickySessionArray.count;
}

- (NSUInteger) normalSessionNum {
    NSLog(@"normalsession num %d", self.sessionArray.count);
    return self.sessionArray.count;
}

- (NSString *) getStickySessionAt: (int)position{
    return [self.stickySessionArray objectAtIndex:position];
}

- (NSString *) getNormalSessionAt: (int)position{
    return [self.sessionArray objectAtIndex:position];
}

- (BOOL) hasSession:(NSString *)sessionName {
    if ([self.sessionArray indexOfObject:sessionName] != NSNotFound) {
        return YES;
    }
    if ([self.stickySessionArray indexOfObject:sessionName] != NSNotFound) {
        return YES;
    }
    return NO;
}

- (void) renameSession:(NSString *)oldName to:(NSString *) newName {
    if ([self.stickySessionArray indexOfObject:oldName]!= NSNotFound) {
        [self.stickySessionArray setObject:newName atIndexedSubscript:[self.stickySessionArray indexOfObject:oldName]];
        CHTSession *session = [CHTSessionManager loadSessionWithName:oldName];
        session.sessionName = newName;
        [CHTSessionManager saveSession:session];
        if ([self.currentSessionName isEqualToString:oldName]) {
            self.currentSessionName = newName;
        }
    } else if ([self.sessionArray indexOfObject:oldName]!= NSNotFound) {
        [self.sessionArray setObject:newName atIndexedSubscript:[self.sessionArray indexOfObject:oldName]];
        CHTSession *session = [CHTSessionManager loadSessionWithName:oldName];
        session.sessionName = newName;
        [CHTSessionManager saveSession:session];
        if ([self.currentSessionName isEqualToString:oldName]) {
            self.currentSessionName = newName;
        }
    } else
        return;
}

- (void)moveObjectFrom:(NSIndexPath *)from toIndexPath:(NSIndexPath *)to {
    if (from.section == to.section && from.section == 1) {
        if (from.row != to.row) {
            id obj = [self.sessionArray objectAtIndex:from.row];
            [self.sessionArray removeObjectAtIndex:from.row];
            if (to.row >= [self.sessionArray count]) {
                [self.sessionArray addObject:obj];
            } else {
                [self.sessionArray insertObject:obj atIndex:to.row];
            }
        }
    } else if (from.section == to.section && from.section == 0) {
        if (from.row != 0 && to.row != 0) {
            if (from.row != to.row) {
                id obj = [self.stickySessionArray objectAtIndex:from.row];
                [self.stickySessionArray removeObjectAtIndex:from.row];
                if (to.row >= [self.stickySessionArray count]) {
                    [self.stickySessionArray addObject:obj];
                } else {
                    [self.stickySessionArray insertObject:obj atIndex:to.row];
                }
            }
        }
    } else if (from.section != to.section) {
        if (from.section == 0) {
            if (from.row != 0) {
                id obj = [self.stickySessionArray objectAtIndex:from.row];
                [self.stickySessionArray removeObjectAtIndex:from.row];
                if (to.row >= [self.sessionArray count]) {
                    [self.sessionArray addObject:obj];
                } else {
                    [self.sessionArray insertObject:obj atIndex:to.row];
                }
            }
        } else if (to.section == 0) {
            if (to.row != 0) {
                id obj = [self.sessionArray objectAtIndex:from.row];
                [self.sessionArray removeObjectAtIndex:from.row];
                if (to.row >= [self.stickySessionArray count]) {
                    [self.stickySessionArray addObject:obj];
                } else {
                    [self.stickySessionArray insertObject:obj atIndex:to.row];
                }
            }
        }
    }
}

- (void)moveObjectFromIndex:(NSUInteger)from toIndex:(NSUInteger)to
{
    if (to != from) {
        id obj = [self.sessionArray objectAtIndex:from];
        [self.sessionArray removeObjectAtIndex:from];
        if (to >= [self.sessionArray count]) {
            [self.sessionArray addObject:obj];
        } else {
            [self.sessionArray insertObject:obj atIndex:to];
        }
    }
}

-(void)encodeWithCoder:(NSCoder *)aCoder {
    [aCoder encodeObject:self.sessionArray forKey:KEY_SESSION_ARRAY];
    [aCoder encodeObject:self.stickySessionArray forKey:KEY_STICKY_SESSION_ARRAY];
    [aCoder encodeObject:self.currentSessionName forKey:KEY_CURRENT_SESSION_NAME];
}

- (id)initWithCoder:(NSCoder *)aDecoder {
    if (self == [super init]) {
        self.sessionArray = [aDecoder decodeObjectForKey:KEY_SESSION_ARRAY];
        self.stickySessionArray = [aDecoder decodeObjectForKey:KEY_STICKY_SESSION_ARRAY];
        self.currentSessionName = [aDecoder decodeObjectForKey:KEY_CURRENT_SESSION_NAME];
    }
    return self;
}

- (void)save {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fileName = [[path objectAtIndex:0] stringByAppendingPathComponent:FILE_NAME];
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:self forKey:KEY_SESSION_MANAGER];
    [archiver finishEncoding];
    
    if ([data writeToFile:fileName atomically:YES]) {
        NSLog(@"save sessionManager");
    } else {
        NSLog(@"app not save");
    }

}

+ (void)saveSession: (CHTSession *)session {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fileName = [[path objectAtIndex:0] stringByAppendingPathComponent:[FILE_SESSION_PREFIX stringByAppendingString:[CHTUtil escapeString:session.sessionName]]];
    NSMutableData *data = [[NSMutableData alloc] init];
    NSKeyedArchiver *archiver = [[NSKeyedArchiver alloc] initForWritingWithMutableData:data];
    [archiver encodeObject:session forKey:KEY_SESSION];
    [archiver finishEncoding];
    
    if ([data writeToFile:fileName atomically:YES]) {
        NSLog(@"Save session: %@", session.sessionName);
    }
}

+ (CHTSessionManager *)load {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *fileName = [[path objectAtIndex:0] stringByAppendingPathComponent:FILE_NAME];
    CHTSessionManager *sessionManager;
    NSData *data = [[NSData alloc] initWithContentsOfFile:fileName];
    if (data) {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        sessionManager = [unarchiver decodeObjectForKey:KEY_SESSION_MANAGER];
        [unarchiver finishDecoding];
        NSLog(@"Get sessionManager, current: %@", sessionManager.currentSessionName);
        return sessionManager;
    }
    else {
        NSLog(@"sessionManager not exit");
        sessionManager = [CHTUpdater updateFromOldVersion];
        return sessionManager;
    }
}



@end
