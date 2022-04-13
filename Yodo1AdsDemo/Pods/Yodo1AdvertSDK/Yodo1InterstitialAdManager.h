//
//  Yodo1InterstitialAdManager.h
//  localization_sdk_sample
//
//  Created by shon wang on 13-8-13.
//  Copyright (c) 2013年 游道易. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@protocol InterstitialAdDelegate <NSObject>

@optional

/**
 Called after an interstitial has been loaded
 */
- (void)interstitialDidLoad;

/**
 Called after an interstitial has attempted to load but failed.
 
 @param error The reason for the error
 */
- (void)interstitialDidFailToLoadWithError:(NSError *)error;

/**
 Called after an interstitial has been opened.
 */
- (void)interstitialDidOpen;

/**
 Called after an interstitial has been dismissed.
 */
- (void)interstitialDidClose;

/**
 Called after an interstitial has been displayed on the screen.
 */
- (void)interstitialDidShow;

/**
 Called after an interstitial has attempted to show but failed.
 
 @param error The reason for the error
 */
- (void)interstitialDidFailToShowWithError:(NSError *)error;

/**
 Called after an interstitial has been clicked.
 */
- (void)didClickInterstitial;


@end


@interface Yodo1InterstitialAdManager: NSObject

///Yodo1InterstitialAdManager单例
+ (Yodo1InterstitialAdManager*)sharedInstance;

///初始化插屏sdk
- (void)initInterstitalSDK:(id<InterstitialAdDelegate>)delegate;

///显示插屏广告
- (void)showAd:(UIViewController*)viewcontroller placement:(NSString *)placement_id;

///插屏广告是否已经准备好
- (BOOL)interstitialAdReady;

@end
