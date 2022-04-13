//
//  Yodo1SplashDelegate.h
//  Yodo1SDK
//
//  Created by yanpeng on 2020/10/21.
//  Copyright © 2020 yixian huang. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol Yodo1SplashDelegate <NSObject>

@optional

/**
 Called after an splash has been loaded
 */
- (void)splashDidLoad;

/**
 Called after an splash has attempted to load but failed.
 
 @param error The reason for the error
 */
- (void)splashDidFailToLoadWithError:(NSError *)error;

/**
 Called after an splash has been displayed on the screen.
 */
- (void)splashDidShow;

/**
 Called after an splash has been dismissed.
 */
- (void)splashDidClose;

/**
 Called after an splash has been skipped.
 */
- (void)splashDidSkip;

/**
 Called after an splash has been clicked.
 */
- (void)splashDidClick;

@end

