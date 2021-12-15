//
//  CHTUtil.h
//  ChaoTimer
//
//  Created by Jichao Li on 8/12/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import <Foundation/Foundation.h>

#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>

typedef enum device {
    DEVICE_PHONE = 0,
    DEVICE_PAD = 1,
} Device;

@interface CHTUtil : NSObject

+ (NSString *)getLocalizedString: (NSString *)str;
+ (NSString *)convertTimeFromMsecondToString: (int)msecond;
+ (Device) getDevice;
+ (NSString *)escapeString: (NSString *)string;
+ (CGFloat) getScreenWidth;
+ (CGFloat) heightOfContent: (NSString *)content font:(UIFont *)font;
+ (UIImage *)imageWithColor:(UIColor *)color;
+ (bool) versionUpdateds;
@end
