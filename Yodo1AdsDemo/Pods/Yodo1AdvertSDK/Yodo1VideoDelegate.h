//
//  Yodo1VideoDelegate.h
//
//  Created by yixian huang on 2017/8/14.
//
//

#ifndef Yodo1VideoDelegate_h
#define Yodo1VideoDelegate_h

#import <Foundation/Foundation.h>

@protocol Yodo1VideoDelegate <NSObject>

@optional

/**
 *  Called when the ad display success
 *
 */
- (void)onVideoShowSuccess;

/**
 *  Called when the ad failed to display for some reason
 *
 *  @param error       - error object that describes the exact error encountered when showing the ad.
 */
- (void)onVideoShowFailed:(nonnull NSError *)error;

/**
 *  Called when the ad is clicked
 *
 */
- (void)onVideoClicked;

/**
 *  Called when the ad has been dismissed from being displayed, and control will return to your app
 *
 *  @param finished   - BOOL describing whether the ad has converted
 */
- (void)onVideoClosed:(BOOL)finished;

@end

#endif /* Yodo1VideoDelegate_h */
