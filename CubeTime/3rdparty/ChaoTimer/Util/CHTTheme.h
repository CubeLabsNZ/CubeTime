//
//  CHTTheme.h
//  ChaoTimer
//
//  Created by Jichao Li on 9/30/13.
//  Copyright (c) 2013 Jichao Li. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CHTUtil.h"
#import "CHTSettings.h"

typedef enum theme {
    THEME_BLUE = 0,
    THEME_WHITE = 1,
    THEME_RED = 2,
    THEME_GREEN = 3,
    THEME_YELLOW = 4,
    THEME_BLACK = 5,
    THEME_PINK = 6,
} Theme;

typedef enum font_style {
    FONT_BOLD = 0,
    FONT_LIGHT = 1,
    FONT_REGULAR = 2,
} Font_Style;

@interface CHTTheme : NSObject
@property (nonatomic) Theme myTheme;
@property (nonatomic) UIColor *textColor;
@property (nonatomic) UIColor *backgroundColor;
@property (nonatomic) UIColor *tabBarColor;
@property (nonatomic) UIColor *navigationColor;
@property (nonatomic) UIColor *barItemColor;

+ (CHTTheme *) initWithTheme: (Theme)theme;
- (void) setNavigationControllerTheme;
- (void) setNavigationControllerTheme: (UINavigationController *)controller;
+ (NSString *) getThemeName: (Theme)theme;
- (NSString *) getMyThemeName;
- (void) save;
+ (CHTTheme *) getTimerTheme;
+ (NSMutableArray *) getAllTheme;
+ (UIColor *) getColorFromTheme: (Theme)theme;
- (UIColor *) getTintColor;
+ (UIFont *) font: (Font_Style)style iphoneSize:(CGFloat)iphoneSize ipadSize:(CGFloat)ipadSize;
@end
