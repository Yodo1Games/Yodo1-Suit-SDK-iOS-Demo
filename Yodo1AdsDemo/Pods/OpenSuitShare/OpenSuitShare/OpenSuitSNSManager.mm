//
//  Yodo1SNS.m
//  localization_sdk
//
//  Created by huafei qu on 13-5-4.
//  Copyright (c) 2015年 yodo1. All rights reserved.
//

#import "OpenSuitSNSManager.h"
#import "OpenSuitShareUI.h"

#import <Social/Social.h>
#import "OpenSuitShareByWeChat.h"
#import "OpenSuitShareByQQ.h"
#import "OpenSuitShareBySinaWeibo.h"
#import "OpenSuitShareByFacebook.h"
//#import "ShareByTwitter.h"
#import "OpenSuitShareByInstagram.h"

#import "Yodo1Commons.h"
#import "Yodo1UnityTool.h"
#import "Yodo1Reachability.h"
#import "Yodo1Model.h"

#import <TencentOpenAPI/QQApiInterface.h>
#import "WXApi.h"
#import "WeiboSDK.h"

NSString * const kOpenSuitQQAppId                  = @"QQAppId";
NSString * const kOpenSuitQQUniversalLink          = @"QQUniversalLink";
NSString * const kOpenSuitWechatAppId              = @"WechatAppId";
NSString * const kOpenSuitWechatUniversalLink      = @"WechatUniversalLink";
NSString * const kOpenSuitSinaWeiboAppKey          = @"SinaAppId";
NSString * const kOpenSuitSinaWeiboUniversalLink   = @"SinaUniversalLink";
NSString * const kOpenSuitTwitterConsumerKey       = @"TwitterConsumerKey";
NSString * const kOpenSuitTwitterConsumerSecret    = @"TwitterConsumerSecret";

@interface Yodo1SMContent : NSObject
@property (nonatomic,assign) NSInteger snsType;     //对单个平台分享模式有效
@property (nonatomic,strong) NSString *title;       //仅对qq和微信有效
@property (nonatomic,strong) NSString *desc;        //分享描述
@property (nonatomic,strong) NSString *image;       //分享图片
@property (nonatomic,strong) NSString *url;         //分享URL
@property (nonatomic,strong) NSString *gameLogo;   //game of Logo
@property (nonatomic,assign) float gameLogoX;      //game of logo X偏移量
@property (nonatomic,strong) NSString *qrLogo;      //二维码logo
@property (nonatomic,strong) NSString *qrText;      //二维码右边的文本
@property (nonatomic,assign) float qrTextX;         //文字X偏移量
@property (nonatomic,assign) float qrImageX;        //二维码偏移量
@end

@implementation Yodo1SMContent
@end

@interface OpenSuitSNSManager()
{
    BOOL isShow;
}

@property (nonatomic, copy) SNSShareCompletionBlock completionBlock;
@property (nonatomic, strong) NSString *wechatAppKey;
@property (nonatomic, strong) NSString *wechatUniversalLink;
@property (nonatomic, strong) NSString *qqAppId;
@property (nonatomic, strong) NSString *qqUniversalLink;
@property (nonatomic, strong) NSString *sinaWeiboAppKey;
@property (nonatomic, strong) NSString *sinaWeiboUniversalLink;
@property (nonatomic, strong) NSString *twitterConsumerKey;
@property (nonatomic, strong) NSString *twitterConsumerSecret;

- (void)showSocial:(SMContent *)content
           snsType:(Yodo1SNSType)snsType;

- (NSArray*)snsTypesWithContent:(SMContent *)content;

@end

@implementation OpenSuitSNSManager
@synthesize isYodo1Shared;
@synthesize isLandscapeOrPortrait;

static OpenSuitSNSManager* sDefaultInstance;

+ (OpenSuitSNSManager*)sharedInstance {
    if(sDefaultInstance == nil){
        sDefaultInstance = [[OpenSuitSNSManager alloc] init];
    }
    return sDefaultInstance;
}

- (void)dealloc {
    
}

- (void)initSNSPlugn:(NSDictionary *)shareAppIds {
    if (shareAppIds == nil || [shareAppIds count] < 1) {
        NSAssert(YES, @"qq or wechat not setAppid");
    }
    if ([[shareAppIds allKeys]containsObject:kOpenSuitWechatAppId] &&
        [[shareAppIds allKeys]containsObject:kOpenSuitWechatUniversalLink]) {
        self.wechatAppKey = [shareAppIds objectForKey:kOpenSuitWechatAppId];
        self.wechatUniversalLink = [shareAppIds objectForKey:kOpenSuitWechatUniversalLink];
        [[OpenSuitShareByWeChat sharedInstance] initWeixinWithAppKey:self.wechatAppKey universalLink:self.wechatUniversalLink];
    } else {
#ifdef DEBUG
        NSLog(@"微信分享没设置");
#endif
    }
    if ([[shareAppIds allKeys]containsObject:kOpenSuitQQAppId] &&
        [[shareAppIds allKeys]containsObject:kOpenSuitQQUniversalLink]) {
        self.qqAppId = [shareAppIds objectForKey:kOpenSuitQQAppId];
        self.qqUniversalLink = [shareAppIds objectForKey:kOpenSuitQQUniversalLink];
        [[OpenSuitShareByQQ sharedInstance] initQQWithAppId:self.qqAppId
                                      universalLink:self.qqUniversalLink];
    } else {
#ifdef DEBUG
        NSLog(@"QQ分享没设置");
#endif
    }
    
    if ([[shareAppIds allKeys]containsObject:kOpenSuitSinaWeiboAppKey] &&
        [[shareAppIds allKeys]containsObject:kOpenSuitSinaWeiboUniversalLink]) {
        self.sinaWeiboAppKey = [shareAppIds objectForKey:kOpenSuitSinaWeiboAppKey];
        self.sinaWeiboUniversalLink = [shareAppIds objectForKey:kOpenSuitSinaWeiboUniversalLink];
        [[OpenSuitShareBySinaWeibo sharedInstance] initSinaWeiboWithAppKey:self.sinaWeiboAppKey
                                                     universalLink:self.sinaWeiboUniversalLink];
    } else {
#ifdef DEBUG
        NSLog(@"新浪微博分享没设置");
#endif
    }
//    if ([[shareAppIds allKeys]containsObject:kOpenSuitTwitterConsumerKey]&&[[shareAppIds allKeys]containsObject:kOpenSuitTwitterConsumerSecret]) {
//        self.twitterConsumerKey = [shareAppIds objectForKey:kOpenSuitTwitterConsumerKey];
//        self.twitterConsumerSecret = [shareAppIds objectForKey:kOpenSuitTwitterConsumerSecret];
//        [[ShareByTwitter sharedInstance] initTwitterWithConsumerKey:self.twitterConsumerKey secret:self.twitterConsumerSecret];
//    } else {
//#ifdef DEBUG
//        NSLog(@"Twitter分享没设置");
//#endif
//    }
    
    [[OpenSuitShareByFacebook sharedInstance] initFacebookWithAppId:nil];
}

- (NSArray*)snsTypesWithContent:(SMContent *)content
{
    NSMutableArray* snsTypes = [NSMutableArray array];
    Yodo1SNSType snsType = content.snsType;
    if ((snsType & Yodo1SNSTypeTencentQQ) && [self isInstalledWithType:Yodo1SNSTypeTencentQQ]) {
        [snsTypes addObject:@(Yodo1SNSTypeTencentQQ)];
    }
    
    if ((snsType & Yodo1SNSTypeWeixinMoments) && [self isInstalledWithType:Yodo1SNSTypeWeixinMoments]) {
        [snsTypes addObject:@(Yodo1SNSTypeWeixinMoments)];
    }
    if ((snsType & Yodo1SNSTypeWeixinContacts) && [self isInstalledWithType:Yodo1SNSTypeWeixinContacts]) {
        [snsTypes addObject:@(Yodo1SNSTypeWeixinContacts)];
    }
    if ((snsType & Yodo1SNSTypeSinaWeibo) && [self isInstalledWithType:Yodo1SNSTypeSinaWeibo]) {
        [snsTypes addObject:@(Yodo1SNSTypeSinaWeibo)];
    }
    if ((snsType & Yodo1SNSTypeFacebook) && [self isInstalledWithType:Yodo1SNSTypeFacebook]) {
        [snsTypes addObject:@(Yodo1SNSTypeFacebook)];
    }
    if ((snsType & Yodo1SNSTypeTwitter) && [self isInstalledWithType:Yodo1SNSTypeTwitter]) {
        [snsTypes addObject:@(Yodo1SNSTypeTwitter)];
    }
    if ((snsType & Yodo1SNSTypeInstagram) && [self isInstalledWithType:Yodo1SNSTypeInstagram]) {
        [snsTypes addObject:@(Yodo1SNSTypeInstagram)];
    }
    
    if (snsType & Yodo1SNSTypeAll) {
        if ([self isInstalledWithType:Yodo1SNSTypeTencentQQ]) {
            [snsTypes addObject:@(Yodo1SNSTypeTencentQQ)];
        }
        if ([self isInstalledWithType:Yodo1SNSTypeWeixinMoments]) {
            [snsTypes addObject:@(Yodo1SNSTypeWeixinMoments)];
        }
        if ([self isInstalledWithType:Yodo1SNSTypeWeixinContacts]) {
            [snsTypes addObject:@(Yodo1SNSTypeWeixinContacts)];
        }
        if ([self isInstalledWithType:Yodo1SNSTypeSinaWeibo]) {
            [snsTypes addObject:@(Yodo1SNSTypeSinaWeibo)];
        }
        if ([self isInstalledWithType:Yodo1SNSTypeFacebook]) {
            [snsTypes addObject:@(Yodo1SNSTypeFacebook)];
        }
        if ([self isInstalledWithType:Yodo1SNSTypeTwitter]) {
            [snsTypes addObject:@(Yodo1SNSTypeTwitter)];
        }
        if ([self isInstalledWithType:Yodo1SNSTypeInstagram]) {
            [snsTypes addObject:@(Yodo1SNSTypeInstagram)];
        }
    }
    return snsTypes;
}

- (void)showSocial:(SMContent *)content
             block:(SNSShareCompletionBlock)completionBlock
{
    [OpenSuitShareUI sharedInstance].isLandscapeOrPortrait = self.isLandscapeOrPortrait;
    
    self.completionBlock = completionBlock;
    
    if(![Yodo1Reachability reachability].reachable){
        if (self.completionBlock) {
            NSError *error = [NSError errorWithDomain:@"com.yodo1.SNSShare" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"网络连接错误或无网络"}];
            self.completionBlock(Yodo1SNSTypeNone,Yodo1ShareContentStateFail,error);
        }
        return;
    }
    
    NSArray* snsTypes = [self snsTypesWithContent:content];
    
    if ([snsTypes count] == 1){
        self.isYodo1Shared = YES;
        Yodo1SNSType type = (Yodo1SNSType)[[snsTypes firstObject]integerValue];
        [self showSocial:content snsType:type];
    }else {
        self.isYodo1Shared = YES;
        [[OpenSuitShareUI sharedInstance]showShareWithTypes:snsTypes
                                                   block:^(Yodo1SNSType snsType) {
                                                       [self showSocial:content snsType:snsType];
                                                   }];
    }
    
}

- (void)showSocial:(SMContent *)content
           snsType:(Yodo1SNSType)snsType
{
    switch (snsType) {
        case Yodo1SNSTypeTencentQQ:
        {
            if (![self isInstalledWithType:Yodo1SNSTypeTencentQQ]) {
                if (self.completionBlock) {
                    NSError *error = [NSError errorWithDomain:@"com.yodo1.SNSShare" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"客户端没有安装或登录"}];
                    self.completionBlock(Yodo1SNSTypeTencentQQ,Yodo1ShareContentStateUnInstalled,error);
                    self.isYodo1Shared = NO;
                }
                return;
            }
            [[OpenSuitShareByQQ sharedInstance]shareWithContent:content
                                                  scene:Yodo1SNSTypeTencentQQ                                                                                           completionBlock:^(Yodo1SNSType snsType, Yodo1ShareContentState resultCode, NSError *error) {
                                                      if (self.completionBlock) {
                                                          self.completionBlock(Yodo1SNSTypeTencentQQ,resultCode,error);
                                                          self.isYodo1Shared = NO;
                                                      }
                                                  }];
        }
            break;
        case Yodo1SNSTypeWeixinMoments:
        {
            if (![self isInstalledWithType:Yodo1SNSTypeWeixinMoments]) {
                if (self.completionBlock) {
                    NSError *error = [NSError errorWithDomain:@"com.yodo1.SNSShare" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"客户端没有安装或登录"}];
                    self.completionBlock(Yodo1SNSTypeWeixinMoments,Yodo1ShareContentStateUnInstalled,error);
                    self.isYodo1Shared = NO;
                }
                return;
            }
            [[OpenSuitShareByWeChat sharedInstance]shareWithContent:content
                                                      scene:Yodo1SNSTypeWeixinMoments
                                            completionBlock:^(Yodo1SNSType snsType, Yodo1ShareContentState resultCode, NSError *error) {
                                                if (self.completionBlock) {
                                                    self.completionBlock(Yodo1SNSTypeWeixinMoments,resultCode,error);
                                                    self.isYodo1Shared = NO;
                                                }
                                            }];
            
        }
            break;
            
        case Yodo1SNSTypeWeixinContacts:
        {
            if (![self isInstalledWithType:Yodo1SNSTypeWeixinContacts]) {
                if (self.completionBlock) {
                    NSError *error = [NSError errorWithDomain:@"com.yodo1.SNSShare" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"客户端没有安装或登录"}];
                    self.completionBlock(Yodo1SNSTypeWeixinContacts,Yodo1ShareContentStateUnInstalled,error);
                    self.isYodo1Shared = NO;
                }
                return;
            }
            [[OpenSuitShareByWeChat sharedInstance]shareWithContent:content
                                                      scene:Yodo1SNSTypeWeixinContacts
                                            completionBlock:^(Yodo1SNSType snsType, Yodo1ShareContentState resultCode, NSError *error) {
                                                if (self.completionBlock) {
                                                    self.completionBlock(Yodo1SNSTypeWeixinContacts,resultCode,error);
                                                    self.isYodo1Shared = NO;
                                                }
                                            }];
        }
            break;
            
        case Yodo1SNSTypeSinaWeibo:
        {
            if (![self isInstalledWithType:Yodo1SNSTypeSinaWeibo]) {
                if (self.completionBlock) {
                    NSError *error = [NSError errorWithDomain:@"com.yodo1.SNSShare" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"客户端没有安装或登录"}];
                    self.completionBlock(Yodo1SNSTypeSinaWeibo,Yodo1ShareContentStateUnInstalled,error);
                    self.isYodo1Shared = NO;
                }
                return;
            }
            [[OpenSuitShareBySinaWeibo sharedInstance]shareWithContent:content
                                                      scene:Yodo1SNSTypeSinaWeibo
                                            completionBlock:^(Yodo1SNSType snsType, Yodo1ShareContentState resultCode, NSError *error) {
                                                if (self.completionBlock) {
                                                    self.completionBlock(Yodo1SNSTypeSinaWeibo,resultCode,error);
                                                    self.isYodo1Shared = NO;
                                                }
                                            }];
        }
            break;
            
        case Yodo1SNSTypeFacebook:
        {
            if (![self isInstalledWithType:Yodo1SNSTypeFacebook]) {
                if (self.completionBlock) {
                    NSError *error = [NSError errorWithDomain:@"com.yodo1.SNSShare" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"客户端没有安装或登录"}];
                    self.completionBlock(Yodo1SNSTypeFacebook,Yodo1ShareContentStateUnInstalled,error);
                    self.isYodo1Shared = NO;
                }
                return;
            }
            if (@available(iOS 11.0,*)) {
                [[OpenSuitShareByFacebook sharedInstance]shareWithContent:content
                                                            scene:Yodo1SNSTypeFacebook
                                                  completionBlock:^(Yodo1SNSType snsType, Yodo1ShareContentState resultCode, NSError *error) {
                                                      if (self.completionBlock) {
                                                          self.completionBlock(Yodo1SNSTypeFacebook,resultCode,error);
                                                          self.isYodo1Shared = NO;
                                                      }
                                                  }];
            }else{
                SLComposeViewController *slVc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook];
                
                if (content.desc) {
                    [slVc setInitialText:content.desc];
                }
                if (content.image) {
                    [slVc addImage:content.image];
                }
                if (content.url) {
                    [slVc addURL:[NSURL URLWithString:content.url]];
                }
                
                slVc.completionHandler = ^(SLComposeViewControllerResult result){
                    switch (result) {
                        case SLComposeViewControllerResultDone:
                            if (self.completionBlock) {
                                self.completionBlock(Yodo1SNSTypeFacebook,Yodo1ShareContentStateSuccess,nil);
                                self.isYodo1Shared = NO;
                            }
                            break;
                        case SLComposeViewControllerResultCancelled:
                            if (self.completionBlock) {
                                self.completionBlock(Yodo1SNSTypeFacebook,Yodo1ShareContentStateCancel,nil);
                                self.isYodo1Shared = NO;
                            }
                            break;
                    }
                };
                [[Yodo1Commons getRootViewController] presentViewController:slVc animated:YES completion:nil];
            }
        }
            break;
        case Yodo1SNSTypeTwitter:
        {
//            if (![self isInstalledWithType:Yodo1SNSTypeTwitter]) {
//                if (self.completionBlock) {
//                    NSError *error = [NSError errorWithDomain:@"com.yodo1.SNSShare" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"客户端没有安装或登录"}];
//                    self.completionBlock(Yodo1SNSTypeTwitter,Yodo1ShareContentStateUnInstalled,error);
//                    self.isYodo1Shared = NO;
//                }
//                return;
//            }
//            if (@available(iOS 11.0,*)) {
//                [[ShareByTwitter sharedInstance]shareWithContent:content
//                                                           scene:Yodo1SNSTypeTwitter
//                                                 completionBlock:^(Yodo1SNSType snsType, Yodo1ShareContentState resultCode, NSError *error) {
//                                                     if (self.completionBlock) {
//                                                         self.completionBlock(Yodo1SNSTypeTwitter,resultCode,error);
//                                                         self.isYodo1Shared = NO;
//                                                     }
//                                                 }];
//            } else {
//                SLComposeViewController *slVc = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
//                if (content.desc) {
//                    [slVc setInitialText:content.desc];
//                }
//                if (content.image) {
//                    [slVc addImage:content.image];
//                }
//                if (content.url) {
//                    [slVc addURL:[NSURL URLWithString:content.url]];
//                }
//
//                slVc.completionHandler = ^(SLComposeViewControllerResult result){
//                    switch (result) {
//                        case SLComposeViewControllerResultDone:
//                            if (self.completionBlock) {
//                                self.completionBlock(Yodo1SNSTypeTwitter,Yodo1ShareContentStateSuccess,nil);
//                                self.isYodo1Shared = NO;
//                            }
//                            break;
//                        case SLComposeViewControllerResultCancelled:
//                            if (self.completionBlock) {
//                                self.completionBlock(Yodo1SNSTypeTwitter,Yodo1ShareContentStateCancel,nil);
//                                self.isYodo1Shared = NO;
//                            }
//                            break;
//                    }
//                };
//                [[Yodo1Commons getRootViewController] presentViewController:slVc animated:YES completion:nil];
//            }
        }
            break;
        case Yodo1SNSTypeInstagram:
        {
            if (![self isInstalledWithType:Yodo1SNSTypeInstagram]) {
                if (self.completionBlock) {
                    NSError *error = [NSError errorWithDomain:@"com.yodo1.SNSShare" code:-1 userInfo:@{NSLocalizedDescriptionKey:@"客户端没有安装或登录"}];
                    self.completionBlock(Yodo1SNSTypeTwitter,Yodo1ShareContentStateUnInstalled,error);
                    self.isYodo1Shared = NO;
                }
                return;
            }
            [[OpenSuitShareByInstagram sharedInstance]shareWithContent:content
                                                         scene:Yodo1SNSTypeInstagram
                                               completionBlock:^(Yodo1SNSType snsType, Yodo1ShareContentState resultCode, NSError *error) {
                                                   if (self.completionBlock) {
                                                       self.completionBlock(Yodo1SNSTypeInstagram,resultCode,error);
                                                       self.isYodo1Shared = NO;
                                                   }
            }];
        }
            break;
        case Yodo1SNSTypeNone:
        {
            if (self.completionBlock) {
                NSDictionary *errorDict = @{NSLocalizedDescriptionKey : @"未选择平台分享",
                                            NSLocalizedFailureReasonErrorKey : @"",
                                            NSLocalizedRecoverySuggestionErrorKey : @""};
                
                NSError *error = [NSError errorWithDomain:@"SNSShare" code:-1 userInfo:errorDict];
                self.completionBlock(Yodo1SNSTypeNone,Yodo1ShareContentStateCancel,error);
                self.isYodo1Shared = NO;
            }
            
        }
            break;
        case Yodo1SNSTypeAll:
        {
        }
            break;
    }
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary *)options
{
    //TencentQQ
    NSRange r = [url.absoluteString rangeOfString:self.qqAppId];
    if (r.location != NSNotFound) {
        return [[OpenSuitShareByQQ sharedInstance] application:application openURL:url options:options];
    }
    //Weixin
    r = [url.absoluteString rangeOfString:self.wechatAppKey];
    if (r.location != NSNotFound) {
        return [[OpenSuitShareByWeChat sharedInstance] application:application openURL:url options:options];
    }
    
    //SinaWeibo
    r = [url.absoluteString rangeOfString:self.sinaWeiboAppKey];
    if (r.location != NSNotFound) {
        return [[OpenSuitShareBySinaWeibo sharedInstance] application:application openURL:url options:options];
    }
    
    //Twitter
//    r = [url.absoluteString rangeOfString:self.twitterConsumerKey];
//    if (r.location != NSNotFound) {
//        return [[ShareByTwitter sharedInstance] application:application openURL:url options:options];
//    }
    //Facebook
    r = [url.absoluteString rangeOfString:@"fb"];
    if (r.location != NSNotFound) {
        return [[OpenSuitShareByFacebook sharedInstance] application:application openURL:url options:options];
    }
    return NO;
}

// Still need this for iOS8
- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(nullable NSString *)sourceApplication
         annotation:(nonnull id)annotation {
    //Facebook
    NSRange r = [url.absoluteString rangeOfString:@"fb"];
    if (r.location != NSNotFound) {
        return [[OpenSuitShareByFacebook sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
    }
    return NO;
}

- (BOOL)isInstalledWithType:(Yodo1SNSType)snsType
{
    BOOL isQQInstalled = [QQApiInterface isQQInstalled];
    
    BOOL isSinaWeiboInstalled = [WeiboSDK isWeiboAppInstalled];
    
    BOOL isWeChatInstalled = [WXApi isWXAppInstalled];
    
    BOOL isFacebookAvailable = NO;
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeFacebook]
        && (([SLComposeViewController composeViewControllerForServiceType:SLServiceTypeFacebook]) != nil)) {
        isFacebookAvailable = YES;
    }
    
    BOOL isTwitterAvailable = NO;
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter]
        && (([SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter]) != nil)) {
        isTwitterAvailable = YES;
    }
    
    if (snsType == Yodo1SNSTypeSinaWeibo) {
        return isSinaWeiboInstalled;
    }
    else if (snsType == Yodo1SNSTypeTencentQQ) {
        return isQQInstalled;
    }
    else if (snsType == Yodo1SNSTypeWeixinMoments||snsType == Yodo1SNSTypeWeixinContacts) {
        return isWeChatInstalled;
    }
    else if (snsType == Yodo1SNSTypeFacebook) {
        if (@available(iOS 11.0,*)) {
            return [[OpenSuitShareByFacebook sharedInstance] isInstallFacebook];
        } else {
            return isFacebookAvailable;
        }
    }
//    else if (snsType == Yodo1SNSTypeTwitter) {
//        if (@available(iOS 11.0,*)) {
//            return [[ShareByTwitter sharedInstance] isInstalledTwitter];
//        } else {
//            return isTwitterAvailable;
//        }
//    }else if (snsType == Yodo1SNSTypeInstagram) {
//        return [[OpenSuitShareByInstagram sharedInstance] isInstalledIntagram];
//    }
    return NO;
}

#ifdef __cplusplus

extern "C" {

    void UnityPostStatus(char* paramJson,char* gameObjectName, char* methodName)
    {
        NSString* ocGameObjName = Yodo1CreateNSString(gameObjectName);
        NSString* ocMethodName = Yodo1CreateNSString(methodName);
        NSString* _paramJson = Yodo1CreateNSString(paramJson);
        
        Yodo1SMContent* smContent = [Yodo1SMContent yodo1_modelWithJSON:_paramJson];
        
        UIImage* image = [UIImage imageNamed:smContent.image];
        if(image==nil){
            image = [UIImage imageWithContentsOfFile:smContent.image];
        }
        
        UIImage* qrLogo = [UIImage imageNamed:smContent.qrLogo];
        if(qrLogo==nil){
            qrLogo = [UIImage imageWithContentsOfFile:smContent.qrLogo];
        }
        
        UIImage* gameLogo = [UIImage imageNamed:smContent.gameLogo];
        if(gameLogo==nil){
            gameLogo = [UIImage imageWithContentsOfFile:smContent.gameLogo];
        }
        
        SMContent* content = [[SMContent alloc]init];
        content.image = image;
        content.title = smContent.title;
        content.desc = smContent.desc;
        content.url = smContent.url;
        content.gameLogo = gameLogo;
        content.qrLogo = qrLogo;
        content.qrText = smContent.qrText;
        content.qrTextX = smContent.qrTextX;
        content.qrImageX = smContent.qrImageX;
        content.gameLogoX = smContent.gameLogoX;
        Yodo1SNSType snsType = (Yodo1SNSType)smContent.snsType;
        content.snsType = snsType;
        
        [[OpenSuitSNSManager sharedInstance]showSocial:content
                                         block:^(Yodo1SNSType snsType, Yodo1ShareContentState state, NSError *error) {
                                             if(ocGameObjName && ocMethodName){
                                                 NSMutableDictionary* dict = [NSMutableDictionary dictionary];
                                                 NSString* msg = @"";
                                                 [dict setObject:[NSNumber numberWithInt:4001] forKey:@"resulType"];
                                                 [dict setObject:[NSNumber numberWithInt:(state == Yodo1ShareContentStateSuccess?1:0)] forKey:@"code"];
                                                 [dict setObject:[NSNumber numberWithInteger:snsType] forKey:@"snsType"];
                                                 if(error){
                                                     msg = [NSString stringWithFormat:@"%@",error];
                                                 }
                                                 [dict setObject:msg forKey:@"msg"];
                                                 NSError* parseJSONError = nil;
                                                 msg = [Yodo1Commons stringWithJSONObject:dict error:&parseJSONError];
                                                 if(parseJSONError){
                                                     msg =  [Yodo1Commons stringWithJSONObject:dict error:&parseJSONError];
                                                 }
                                                 
                                                 UnitySendMessage([ocGameObjName cStringUsingEncoding:NSUTF8StringEncoding],
                                                                  [ocMethodName cStringUsingEncoding:NSUTF8StringEncoding],
                                                                  [msg cStringUsingEncoding:NSUTF8StringEncoding] );
                                             }
                                             
                                         }];
    }
    
    bool UnityCheckSNSInstalledWithType(int type)
    {
        Yodo1SNSType kType = (Yodo1SNSType)type;
        if([[OpenSuitSNSManager sharedInstance] isInstalledWithType:kType]){
            return true;
        }
        return false;
    }
}
#endif

@end
