//
//  CHTTheme.m
//  ChaoTimer
//
//  Created by Jichao Li on 9/30/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import "CHTTheme.h"

@implementation CHTTheme
@synthesize myTheme;
@synthesize textColor;
@synthesize backgroundColor;
@synthesize tabBarColor;
@synthesize navigationColor;

+ (CHTTheme *) initWithTheme: (Theme)theme {
    CHTTheme *timerTheme = [[CHTTheme alloc] init];
    timerTheme.myTheme = theme;
    timerTheme.navigationColor = [CHTTheme getColorFromTheme:theme];
    UIColor *lightBlackColor = [UIColor colorWithRed:20/255.0f green:20/255.0f blue:20/255.0f alpha:1];
    switch (theme) {
        case THEME_BLUE:
            timerTheme.textColor = [UIColor whiteColor];
            timerTheme.backgroundColor = lightBlackColor;
            timerTheme.tabBarColor = [UIColor blackColor];
            timerTheme.barItemColor = [UIColor yellowColor];
            break;
        case THEME_WHITE:
            timerTheme.textColor = [UIColor blackColor];
            timerTheme.backgroundColor = [UIColor whiteColor];
            timerTheme.tabBarColor = timerTheme.navigationColor;
            timerTheme.barItemColor = [UIColor colorWithRed:0/255.0f green:122/255.0f blue:255/255.0f alpha:1];
            break;
        case THEME_RED:
            timerTheme.textColor = [UIColor whiteColor];
            timerTheme.backgroundColor = lightBlackColor;
            timerTheme.tabBarColor = [UIColor blackColor];
            timerTheme.barItemColor = [UIColor yellowColor];
            break;
        case THEME_GREEN:
            timerTheme.textColor = [UIColor whiteColor];
            timerTheme.backgroundColor = lightBlackColor;
            timerTheme.tabBarColor = [UIColor blackColor];
            timerTheme.barItemColor = [UIColor yellowColor];
            break;
        case THEME_YELLOW:
            timerTheme.textColor = [UIColor whiteColor];
            timerTheme.backgroundColor = lightBlackColor;
            timerTheme.tabBarColor = [UIColor blackColor];
            timerTheme.barItemColor = [UIColor orangeColor];
            break;
        case THEME_BLACK:
            timerTheme.textColor = [UIColor whiteColor];
            timerTheme.backgroundColor = lightBlackColor;
            timerTheme.tabBarColor = [UIColor blackColor];
            timerTheme.barItemColor = [UIColor whiteColor];
            break;
        case THEME_PINK:
            timerTheme.textColor = [UIColor whiteColor];
            timerTheme.backgroundColor = lightBlackColor;
            timerTheme.tabBarColor = [UIColor blackColor];
            timerTheme.barItemColor = [UIColor yellowColor];
            break;
    }
    return timerTheme;

}

- (void) setNavigationControllerTheme{
    UIApplication *myApp = [UIApplication sharedApplication];
    if (myTheme == THEME_WHITE) {
        [myApp setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    } else {
        [myApp setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }
    [[UINavigationBar appearance] setTitleTextAttributes:@{
        NSFontAttributeName:[CHTTheme font:FONT_REGULAR iphoneSize:22.0f ipadSize:22.0f],
        NSForegroundColorAttributeName: self.textColor}];
    [[UINavigationBar appearance] setBarTintColor:self.navigationColor];
    [[UINavigationBar appearance] setTintColor:self.barItemColor];
    [[UIBarButtonItem appearance] setTitleTextAttributes:@{
      NSFontAttributeName:[CHTTheme font:FONT_REGULAR iphoneSize:17.0f ipadSize:17.0f]}
        forState:UIControlStateNormal];
    [[UITabBar appearance] setBarTintColor:self.tabBarColor];
}

- (void) setNavigationControllerTheme: (UINavigationController *)controller {
    UIApplication *myApp = [UIApplication sharedApplication];
    if (myTheme == THEME_WHITE) {
        NSLog(@"theme white");
        [myApp setStatusBarStyle:UIStatusBarStyleDefault animated:YES];
    } else {
        NSLog(@"theme others");
        [myApp setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
    }
    [controller.navigationBar setTitleTextAttributes:@{
            NSFontAttributeName:[CHTTheme font:FONT_REGULAR iphoneSize:22.0f ipadSize:22.0f],
            NSForegroundColorAttributeName: self.textColor}];
    [controller.navigationBar setBarTintColor:self.navigationColor];
    [controller.navigationBar setTintColor:self.barItemColor];
}

+ (NSString *) getThemeName: (Theme)theme {
    switch (theme) {
        case THEME_BLUE:
            return [CHTUtil getLocalizedString:@"theme blue"];
        case THEME_WHITE:
            return [CHTUtil getLocalizedString:@"theme white"];
        case THEME_RED:
            return [CHTUtil getLocalizedString:@"theme red"];
        case THEME_GREEN:
            return [CHTUtil getLocalizedString:@"theme green"];
        case THEME_YELLOW:
            return [CHTUtil getLocalizedString:@"theme yellow"];
        case THEME_BLACK:
            return [CHTUtil getLocalizedString:@"theme black"];
        case THEME_PINK:
            return [CHTUtil getLocalizedString:@"theme pink"];
    }
}

- (NSString *) getMyThemeName {
    return [CHTTheme getThemeName:myTheme];
}

- (void) save {
    [CHTSettings saveInt:myTheme forKey:@"timerTheme"];
}

+ (CHTTheme *) getTimerTheme {
    return [self initWithTheme:[CHTSettings intForKey:@"timerTheme"]];
    //return [self initWithTheme:THEME_YELLOW];
}

+ (NSMutableArray *) getAllTheme {
    return [[NSMutableArray alloc] initWithObjects:
            [NSNumber numberWithInt:THEME_BLUE],
            [NSNumber numberWithInt:THEME_WHITE],
            [NSNumber numberWithInt:THEME_RED],
            [NSNumber numberWithInt:THEME_GREEN],
            [NSNumber numberWithInt:THEME_YELLOW],
            [NSNumber numberWithInt:THEME_BLACK],
            [NSNumber numberWithInt:THEME_PINK], nil];
}

+ (UIColor *) getColorFromTheme: (Theme)theme {
    UIColor *color;
    switch (theme) {
        case THEME_BLUE:
            color = [UIColor colorWithRed:26/255.0f green:127/255.0f blue:191/255.0f alpha:1];
            break;
        case THEME_WHITE:
            color = [UIColor colorWithRed:247/255.0f green:247/255.0f blue:247/255.0f alpha:1];
            break;
        case THEME_RED:
            color = [UIColor colorWithRed:255/255.0f green:58/255.0f blue:45/255.0f alpha:1];
            break;
        case THEME_GREEN:
            color = [UIColor colorWithRed:76/255.0f green:217/255.0f blue:100/255.0f alpha:1];
            break;
        case THEME_YELLOW:
            color = [UIColor colorWithRed:255/255.0f green:204/255.0f blue:0/255.0f alpha:1];
            break;
        case THEME_BLACK:
            color = [UIColor blackColor];
            break;
        case THEME_PINK:
            color = [UIColor colorWithRed:255/255.0f green:73/255.0f blue:129/255.0f alpha:1];
            break;
        default:
            color = [UIColor colorWithRed:26/255.0f green:127/255.0f blue:191/255.0f alpha:1];
            break;
    }
    return color;
}

- (UIColor *)getTintColor{
    if (self.myTheme == THEME_WHITE) {
        return [UIColor lightGrayColor];
    } else {
        return [CHTTheme getColorFromTheme:myTheme];
    }
}

+ (UIFont *) font: (Font_Style)style iphoneSize:(CGFloat)iphoneSize ipadSize:(CGFloat)ipadSize
{
    if ([CHTUtil getDevice] == DEVICE_PHONE) {
        switch (style) {
            case FONT_BOLD:
                return [UIFont fontWithName:@"Avenir-Medium" size:iphoneSize];
            case FONT_LIGHT:
                return [UIFont fontWithName:@"Avenir-Light" size:iphoneSize];
            case FONT_REGULAR:
                return [UIFont fontWithName:@"Avenir-Book" size:iphoneSize];
        }
    }
    else {
        switch (style) {
            case FONT_BOLD:
                return [UIFont fontWithName:@"Avenir-Medium" size:ipadSize];
            case FONT_LIGHT:
                return [UIFont fontWithName:@"Avenir-Light" size:ipadSize];
            case FONT_REGULAR:
                return [UIFont fontWithName:@"Avenir-Book" size:ipadSize];
        }
    }
}
@end
