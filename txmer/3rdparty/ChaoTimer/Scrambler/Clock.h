//
//  Clock.h
//  DCTimer scramblers
//
//  Created by MeigenChou on 13-3-2.
//  Copyright (c) 2013年 MeigenChou. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Clock : NSObject

- (NSString *) scramble;
- (NSString *) scrambleOld:(bool) concise;
- (NSString *)scrambleEpo;

@end
