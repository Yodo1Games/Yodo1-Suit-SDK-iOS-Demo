//
//  OpenSuitShareByFacebook.h
//  foundation
//
//  Created by Nyxon on 14-8-6.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenSuitSMConstant.h"

@interface OpenSuitShareByFacebook : NSObject

+ (OpenSuitShareByFacebook *)sharedInstance;

- (void)initFacebookWithAppId:(NSString *)appId;

#pragma mark - sdk方式分享
- (void)shareWithContent:(SMContent *)content
                   scene:(Yodo1SNSType)snsType
         completionBlock:(SNSShareCompletionBlock)aCompletionBlock;

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary *)options;

// Still need this for iOS8
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(nullable NSString *)sourceApplication
         annotation:(nonnull id)annotation;

- (BOOL)isInstallFacebook;

@end
