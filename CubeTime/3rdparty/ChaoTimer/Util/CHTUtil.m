//
//  CHTUtil.m
//  ChaoTimer
//
//  Created by Jichao Li on 8/12/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import "CHTUtil.h"
#import "CHTSettings.h"

@implementation CHTUtil

+ (NSString *)getLocalizedString: (NSString *)str{
    return NSLocalizedString(str, NULL);
}

+ (NSString *)convertTimeFromMsecondToString: (int)msecond {
    NSString *outputTimeString;
    if (msecond < 1000) {
        outputTimeString = [NSString stringWithFormat:@"0.%03d", msecond];
    } else if (msecond < 60000) {
        int second = msecond * 0.001;
        int msec = msecond % 1000;
        outputTimeString = [NSString stringWithFormat:@"%d.%03d", second, msec];
    } else if (msecond < 3600000) {
        int minute = msecond / 60000;
        int second = (msecond % 60000)/1000;
        int msec = msecond % 1000;
        outputTimeString = [NSString stringWithFormat:@"%d:%02d.%03d", minute, second, msec];
    } else {
        int hour = msecond / 3600000;
        int minute = (msecond % 360000) / 60000;
        int second = (msecond % 60000) / 1000;
        int msec = msecond % 1000;
        outputTimeString = [NSString stringWithFormat:@"%d:%02d:%02d.%03d", hour, minute, second, msec];
    }
    return outputTimeString;
}

+ (Device) getDevice {
    if (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone) {
        return DEVICE_PHONE;
    } else {
        return DEVICE_PAD;
    }
}

+ (NSString *)escapeString: (NSString *)string {
    NSString *fileName = [string copy];
    fileName = [fileName stringByReplacingOccurrencesOfString:@"/" withString:@"slash"];
    return fileName;
}

+ (CGFloat) getScreenWidth {
    CGFloat screenWidth;
    screenWidth = [UIScreen mainScreen].applicationFrame.size.width;
    NSLog(@"screen width = %f", screenWidth);
    if (screenWidth == 748.0f) {
        screenWidth = 1024.0f;
    }
    return screenWidth;
}


+ (CGFloat) heightOfContent: (NSString *)content font:(UIFont *)font
{
    NSAttributedString *attributedText = [[NSAttributedString alloc] initWithString:content attributes:@{
     NSFontAttributeName: font}];
    CGRect rect = [attributedText boundingRectWithSize:CGSizeMake( [self getScreenWidth] - 20, 44.0f * 7)options:NSStringDrawingUsesLineFragmentOrigin context:nil];
    return rect.size.height + 20;
}


+ (UIImage *)imageWithColor:(UIColor *)color
{
    CGRect rect = CGRectMake(0.0f, 0.0f, 30.0f, 30.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGContextSetFillColorWithColor(context, [color CGColor]);
    CGContextFillRect(context, rect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

+ (bool) versionUpdateds
{
    NSDictionary *infoDictionary = [[NSBundle mainBundle] infoDictionary];
    NSString *crtVersion = [infoDictionary objectForKey:@"CFBundleShortVersionString"];
    NSString *oldVersion = [CHTSettings stringForKey:@"appVersion"];
    NSLog(@"AppVersion old: %@, new: %@", oldVersion, crtVersion);
    if ([crtVersion isEqualToString:oldVersion]) {
        return false;
    } else {
        [CHTSettings saveString:crtVersion forKey:@"appVersion"];
        if ([[crtVersion substringToIndex:3] isEqualToString:[oldVersion substringToIndex:3]]) {
            return false;
        } else {
            return true;
        }
    }
}

@end
