//
//  Yodo1SplashManager.h
//  Yodo1SDK
//
//  Created by yanpeng on 2020/10/21.
//  Copyright © 2020 yixian huang. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "Yodo1SplashDelegate.h"

@interface Yodo1SplashManager : NSObject

+ (Yodo1SplashManager*)sharedInstance;
- (void)setDelegate:(id<Yodo1SplashDelegate>)delegate;
- (void)showSplash:(UIWindow *)window placement:(NSString *)placement_id;
//- (BOOL)isSplashAdReady;
@end

