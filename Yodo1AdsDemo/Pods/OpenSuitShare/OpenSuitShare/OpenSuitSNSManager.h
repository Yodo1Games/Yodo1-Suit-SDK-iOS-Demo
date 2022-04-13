//
//  Yodo1SNS.h
//  localization_sdk
//
//  Created by huafei qu on 13-5-4.
//  Copyright (c) 2015年 yodo1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "OpenSuitSMConstant.h"

FOUNDATION_EXPORT NSString * _Nonnull const kOpenSuitQQAppId;
FOUNDATION_EXPORT NSString * _Nonnull const kOpenSuitQQUniversalLink;
FOUNDATION_EXPORT NSString * _Nonnull const kOpenSuitWechatAppId;
FOUNDATION_EXPORT NSString * _Nonnull const kOpenSuitWechatUniversalLink;
FOUNDATION_EXPORT NSString * _Nonnull const kOpenSuitSinaWeiboAppKey;
FOUNDATION_EXPORT NSString * _Nonnull const kOpenSuitSinaWeiboUniversalLink;
FOUNDATION_EXPORT NSString * _Nonnull const kOpenSuitTwitterConsumerKey;
FOUNDATION_EXPORT NSString * _Nonnull const kOpenSuitTwitterConsumerSecret;

@interface OpenSuitSNSManager: NSObject

@property(nonatomic,assign) BOOL isYodo1Shared;/*当前正在分享的是不是Yodo1的分享，区别于别的平台，比如KTPlay*/
@property(nonatomic,assign) BOOL isLandscapeOrPortrait;/*支持横竖屏切换，默认NO*/

+ (OpenSuitSNSManager*)sharedInstance;

/**
 初始化qq,微信
 
 @param shareAppIds appId字典
 如：@{kOpenSuitQQAppId:@"qqAppId",kOpenSuitWechatAppId:@"wechatAppId"}
 */
- (void)initSNSPlugn:(NSDictionary*)shareAppIds;

- (void)showSocial:(SMContent *)content
             block:(SNSShareCompletionBlock)completionBlock;

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary *)options;

// Still need this for iOS8
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(nullable NSString *)sourceApplication
         annotation:(nonnull id)annotation;
/**
 *  检查是否安装新浪，微信，QQ客户端,facebook,twitter 服务是否有效
 *
 *  @param snsType Yodo1SNSType
 *
 *  @return YES安装了客户端或服务有效 可以分享！
 */
- (BOOL)isInstalledWithType:(Yodo1SNSType)snsType;

@end
