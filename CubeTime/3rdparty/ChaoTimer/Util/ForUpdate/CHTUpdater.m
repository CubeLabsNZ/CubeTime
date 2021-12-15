//
//  CHTUpdater.m
//  ChaoTimer
//
//  Created by Jichao Li on 10/7/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import "CHTUpdater.h"
#import "RubiksTimerDataProcessing.h"
#import "RubiksTimerTimeObj.h"
#import "CHTSessionManager.h"

@implementation CHTUpdater

+ (CHTSessionManager *) updateFromOldVersion {
    CHTSessionManager *sessionManager;
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *sessionManagerFileName = [[path objectAtIndex:0] stringByAppendingPathComponent:@"sessions"];
    NSData *data = [[NSData alloc] initWithContentsOfFile:sessionManagerFileName];
    if (data) {
        NSKeyedUnarchiver *unarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:data];
        [unarchiver setClass:[CHTSessionManager class] forClassName:@"RubiksTimerSessionManager"];
        sessionManager = [unarchiver decodeObjectForKey:@"sessionManager"];
        [unarchiver finishDecoding];
        for (NSString *session in sessionManager.sessionArray) {
            NSLog(@"get old session: %@", session);
            [self updateSession:session];
        }
        for (NSString *session in sessionManager.stickySessionArray) {
            NSLog(@"get old session: %@", session);
            [self updateSession:session];
        }
        //delete old sessionManager
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:sessionManagerFileName error:nil];
    } else {
        sessionManager = [[CHTSessionManager alloc] init];
        CHTSession *defaultSession = [CHTSession initWithDefault];
        [CHTSessionManager saveSession:defaultSession];
    }
    [sessionManager save];
    return sessionManager;
}

+ (NSString *)escapeStringOldVersion: (NSString *)string {
    NSString *fileName = [string copy];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"nijixuchao"];
    return fileName;
}

+ (void) updateSession: (NSString *)oldSessionName {
    NSArray *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *sessionFileName = [[path objectAtIndex:0] stringByAppendingPathComponent:[@"timeProcess_" stringByAppendingString:[CHTUpdater escapeStringOldVersion:oldSessionName]]];
    NSData *sessionData = [[NSData alloc] initWithContentsOfFile:sessionFileName];
    if (sessionData) {
        NSKeyedUnarchiver *sessionUnarchiver = [[NSKeyedUnarchiver alloc] initForReadingWithData:sessionData];
        RubiksTimerDataProcessing *oldSession =[sessionUnarchiver decodeObjectForKey:oldSessionName];
        [sessionUnarchiver finishDecoding];
        CHTSession *newSession = [CHTSession initWithName:oldSession.sessionName];
        NSMutableArray* newTimeArray = [[NSMutableArray alloc] init];
        for (RubiksTimerTimeObj *oldTime in oldSession.timeStoredArray) {
            int timeValue = oldTime.timeValueBeforePenalty;
            int panelty = oldTime.penalty;
            CHTScramble *newScramble = [[CHTScramble alloc] init];
            newScramble.scrType = oldTime.type;
            newScramble.scrSubType = @"";
            newScramble.scramble = oldTime.scramble;
            CHTSolve *newSolve = [CHTSolve newSolveWithTime:timeValue andPenalty:panelty andScramble:newScramble];
            [newTimeArray addObject:newSolve];
        }
        [newSession setSolves:newTimeArray];
        //newSession.currentType = oldSession.CurrentType;
        [CHTSessionManager saveSession:newSession];
        //delete old session
        NSFileManager *fileManager = [NSFileManager defaultManager];
        [fileManager removeItemAtPath:sessionFileName error:nil];
    }
}

@end
