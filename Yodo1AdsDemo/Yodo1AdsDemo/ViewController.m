//
//  ViewController.m
//  Yodo1AdsDemo
//
//  Created by yixian huang on 2017/9/13.
//  Copyright © 2017年 yixian huang. All rights reserved.
//

#import "ViewController.h"
#import "Yd1OnlineParameter.h"
#import "Yodo1Tool+Commons.h"
#import "Yodo1Tool+Storage.h"
#import "Yd1UCenter.h"
#import "Yd1UCenterManager.h"
#import "ThinkingAnalyticsSDK.h"
#import "Yodo1Commons.h"
#import "Yd1UCenter.h"
#import "YD1AgePrivacyManager.h"
#import <Yodo1Manager.h>
#import <Yodo1AnalyticsManager.h>
#import "OpenSuitSNSManager.h"
#import <Yodo1Reachability.h>

@interface ViewController (){
    BOOL isOneTimes;
}

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    // purchase
    YD1LOG(@"deviceid :%@",Yd1OpsTools.keychainDeviceId);
    YD1LOG(@"uuid:%@",Yd1OpsTools.keychainUUID);
    
    [NSNotificationCenter.defaultCenter addObserver:self selector:@selector(onlineParameter:) name:kYodo1OnlineConfigFinishedNotification object:nil];
    YD1LOG(@"%@",[Yodo1Tool.shared cachedPath]);
    
    [Yd1OnlineParameter.shared initWithAppKey:@"16VNuBOVlX"//@"CbpEWM32D"//
                                    channelId:@"AppStore"];
    [Yd1OnlineParameter.shared cachedCompletionHandler:^{
        YD1LOG(@"Online Parameter is Success!");
        NSLog(@"%@",Yd1UCenterManager.shared);
    }];
    
    
    
    if ([Yodo1Reachability reachability].reachable) {
        NSLog(@"有网了");
    }else{
        NSLog(@"没有网络");
    }
    // Share
    [[OpenSuitSNSManager sharedInstance]initSNSPlugn:@{kOpenSuitQQAppId:@"1105116621",
                                               kOpenSuitQQUniversalLink:@"https://www.yodo1.com/qq_conn/1105116621",
                                               kOpenSuitWechatAppId:@"wx6f8e95d1933f4fcf",
                                               kOpenSuitWechatUniversalLink:@"https://www.yodo1.com/HL/",
                                               kOpenSuitSinaWeiboUniversalLink:@"xxxxxx",
                                               kOpenSuitSinaWeiboAppKey:@"707194890"}];
    
    
}

- (IBAction)ShowPrivacy:(id)sender {
    NSLog(@"[ Yodo1 ] Show Privacy");
    // test:@"16VNuBOVlX"
    [YD1AgePrivacyManager dialogShowUserConsentWithGameAppKey:@"Your AppKey" channelCode:@"appstore" viewController:self block:^(BOOL accept, BOOL child, int age) {

        NSLog(@"[ Yodo1 ] age:%d",age);
    }];
}
- (IBAction)Buy:(id)sender {
    NSLog(@"[ Yodo1 ] Buy");
    //    @"iap_cash_cow_sale"//@"iap_cash_cow" @"iap_cash_cow_combination"
    [Yd1UCenterManager.shared paymentWithUniformProductId:@"iap_cash_cow_sale"
                                                 extra:@""
                                                 callback:^(PaymentObject * _Nonnull payemntObject) {
        if (payemntObject.paymentState == PaymentSuccess) {
            YD1LOG(@"%@: 购买成功!",payemntObject.uniformProductId);
            Yd1UCenter.shared.itemInfo.orderId = payemntObject.orderId;
            Yd1UCenter.shared.itemInfo.extra = @"";
            [Yd1UCenter.shared clientCallback:Yd1UCenter.shared.itemInfo
                                     callbakc:^(BOOL success, NSString * _Nonnull error) {
                if (success) {
                    YD1LOG(@"上报成功");
                } else {
                    YD1LOG(@"上报失败");
                }
            }];
            //通知发货
            [Yd1UCenter.shared sendGoodsOver:payemntObject.orderId callback:^(BOOL success, NSString * _Nonnull error) {
                if (success) {
                    YD1LOG(@"发货成功！");
                }else{
                    YD1LOG(@"%@",error);
                }
                NSMutableDictionary* properties = [NSMutableDictionary dictionary];
                [properties setObject:success?@"成功":@"失败" forKey:@"status"];
                [properties addEntriesFromDictionary:Yd1UCenterManager.shared .superProperty];
                [properties addEntriesFromDictionary:Yd1UCenterManager.shared.itemProperty];
                YD1LOG(@"%@",properties);
                [ThinkingAnalyticsSDK.sharedInstance track:@"order_Item_Delivered" properties:properties];
            }];
            //同步信息
            [Yd1UCenter.shared clientNotifyForSyncUnityStatus:@[payemntObject.orderId]
                                                     callback:^(BOOL success, NSArray * _Nonnull notExistOrders, NSArray * _Nonnull notPayOrders, NSString * _Nonnull error) {
                if (success) {
                    YD1LOG(@"同步信息成功");
                } else {
                    YD1LOG(@"同步信息失败:%@",error);
                }
                YD1LOG(@"notExistOrders:%@,notPayOrders:%@",
                       notExistOrders,notPayOrders)
            }];
        } else {
            YD1LOG(@"%@: 购买失败! %@",payemntObject.uniformProductId,payemntObject.response);
            if ([payemntObject.channelOrderid length] > 0 && [payemntObject.orderId length] > 0) {
                Yd1UCenter.shared.itemInfo.channelCode = @"AppStore";
                Yd1UCenter.shared.itemInfo.channelOrderid = payemntObject.channelOrderid;
                Yd1UCenter.shared.itemInfo.orderId = payemntObject.orderId;
                Yd1UCenter.shared.itemInfo.statusCode = [NSString stringWithFormat:@"%d",PaymentSuccess];
                Yd1UCenter.shared.itemInfo.statusMsg = payemntObject.response;
                [Yd1UCenter.shared reportOrderStatus:Yd1UCenter.shared.itemInfo
                                            callbakc:^(BOOL success, NSString * _Nonnull error) {
                    if (success) {
                        YD1LOG(@"上报成功");
                    } else {
                        YD1LOG(@"上报失败");
                    }
                }];
            }
            
            NSMutableDictionary* properties = [NSMutableDictionary dictionary];
            [properties setObject:@-1 forKey:@"channelErrorCode"];
            [properties addEntriesFromDictionary:Yd1UCenterManager.shared .superProperty];
            [properties addEntriesFromDictionary:Yd1UCenterManager.shared.itemProperty];

            NSNumber* errorCode = [NSNumber numberWithInt:2004];//默认是未知失败
            if (payemntObject.error) {
                errorCode  = [NSNumber numberWithInteger:payemntObject.error.code];
            }
            [properties setObject:errorCode forKey:@"yodo1ErrorCode"];
            YD1LOG(@"%@",properties);
            [ThinkingAnalyticsSDK.sharedInstance track:@"order_Error_FromSDK" properties:properties];
        }
    }];
}
- (IBAction)AutoSus:(id)sender {
    NSLog(@"[ Yodo1 ] AutoSus");
    
    if (Yd1UCenterManager.shared.isLogined) {
        YD1LOG(@"device is logined!");
        YD1LOG(@"yid:%@",Yd1UCenterManager.shared.user.yid);
        YD1LOG(@"uid:%@",Yd1UCenterManager.shared.user.uid);
        YD1LOG(@"token:%@",Yd1UCenterManager.shared.user.token);
        YD1LOG(@"extra:%@",Yd1UCenterManager.shared.user.extra);
        YD1LOG(@"isnewuser:%d",Yd1UCenterManager.shared.user.isnewuser);
        YD1LOG(@"isRealName:%d",Yd1UCenterManager.shared.user.isRealName);
        YD1LOG(@"isnewyaccount:%d",Yd1UCenterManager.shared.user.isnewyaccount);
        
    }
    NSDictionary* extra = @{@"channelUserid":Yd1UCenterManager.shared.user.uid};
    NSString* extraString = [Yd1OpsTools stringWithJSONObject:extra error:nil];
    [Yd1UCenterManager.shared paymentWithUniformProductId:@"iap_unlock_area_olympus"
                                                    extra:extraString
                                                 callback:^(PaymentObject * _Nonnull payemntObject) {
        if (payemntObject.paymentState == PaymentSuccess) {
            YD1LOG(@"%@: 购买成功!",payemntObject.uniformProductId);
            Yd1UCenter.shared.itemInfo.orderId = payemntObject.orderId;
            Yd1UCenter.shared.itemInfo.extra = @"";
            [Yd1UCenter.shared clientCallback:Yd1UCenter.shared.itemInfo
                                     callbakc:^(BOOL success, NSString * _Nonnull error) {
                if (success) {
                    YD1LOG(@"上报成功");
                } else {
                    YD1LOG(@"上报失败");
                }
            }];
            //通知发货
            [Yd1UCenter.shared sendGoodsOver:payemntObject.orderId callback:^(BOOL success, NSString * _Nonnull error) {
                if (success) {
                    YD1LOG(@"发货成功！");
                }else{
                    YD1LOG(@"%@",error);
                }
            }];
            //同步信息
            [Yd1UCenter.shared clientNotifyForSyncUnityStatus:@[payemntObject.orderId]
                                                     callback:^(BOOL success, NSArray * _Nonnull notExistOrders, NSArray * _Nonnull notPayOrders, NSString * _Nonnull error) {
                if (success) {
                    YD1LOG(@"同步信息成功");
                } else {
                    YD1LOG(@"同步信息失败:%@",error);
                }
                YD1LOG(@"notExistOrders:%@,notPayOrders:%@",
                       notExistOrders,notPayOrders)
            }];
        } else {
            YD1LOG(@"%@: 购买失败! %@",payemntObject.uniformProductId,payemntObject.response);
            if ([payemntObject.channelOrderid length] > 0 && [payemntObject.orderId length] > 0) {
                Yd1UCenter.shared.itemInfo.channelCode = @"AppStore";
                Yd1UCenter.shared.itemInfo.channelOrderid = payemntObject.channelOrderid;
                Yd1UCenter.shared.itemInfo.orderId = payemntObject.orderId;
                Yd1UCenter.shared.itemInfo.statusCode = [NSString stringWithFormat:@"%d",PaymentSuccess];
                Yd1UCenter.shared.itemInfo.statusMsg = payemntObject.response;
                [Yd1UCenter.shared reportOrderStatus:Yd1UCenter.shared.itemInfo
                                            callbakc:^(BOOL success, NSString * _Nonnull error) {
                    if (success) {
                        YD1LOG(@"上报成功");
                    } else {
                        YD1LOG(@"上报失败");
                    }
                }];
            }
            //失败神策埋点
            NSMutableDictionary* properties = [NSMutableDictionary dictionary];
            [properties setObject:@-1 forKey:@"channelErrorCode"];
            [properties addEntriesFromDictionary:Yd1UCenterManager.shared .superProperty];
            [properties addEntriesFromDictionary:Yd1UCenterManager.shared.itemProperty];
            
            NSNumber* errorCode = [NSNumber numberWithInt:2004];//默认是未知失败
            if (payemntObject.error) {
                errorCode  = [NSNumber numberWithInteger:payemntObject.error.code];
            }
            [properties setObject:errorCode forKey:@"yodo1ErrorCode"];
            YD1LOG(@"%@",properties);
            [ThinkingAnalyticsSDK.sharedInstance track:@"order_Error_FromSDK" properties:properties];
        }
    }];
    [Yd1UCenterManager.shared productWithUniformProductId:@"iap_subscribe_cashcow" callback:^(NSArray<Product *> * _Nonnull productInfo) {
        for (NSDictionary* product in productInfo) {
            YD1LOG(@"channelProductId:%@",[product objectForKey:@"marketId"]);
            YD1LOG(@"uniformProductId:%@",[product objectForKey:@"productId"]);
            YD1LOG(@"productType:%d",[[product objectForKey:@"productType"]intValue]);
            YD1LOG(@"productName:%@",[product objectForKey:@"productName"]);
            YD1LOG(@"productDescription:%@",[product objectForKey:@"productDescription"]);
            YD1LOG(@"productPrice:%@",[product objectForKey:@"productPrice"]);
            YD1LOG(@"periodUnit:%@",[product objectForKey:@"periodUnit"]);
            YD1LOG(@"priceDisplay:%@",[product objectForKey:@"priceDisplay"]);
            YD1LOG(@"currency:%@",[product objectForKey:@"currency"]);
        }
    }];
}
- (IBAction)Restore:(id)sender {
    NSLog(@"[ Yodo1 ] Restore");
    
    [Yd1UCenterManager.shared restorePayment:^(NSArray * _Nonnull productIds, NSString * _Nonnull response) {
        for (NSDictionary* dic in productIds) {
            NSLog(@"%@",dic);
        }
    }];
    
    [Yd1UCenterManager.shared querySubscriptions:YES callback:^(NSArray * _Nonnull subscriptions, NSTimeInterval serverTime, BOOL success, NSString * _Nonnull error) {
        for (SubscriptionInfo* info in subscriptions) {
            NSLog(@"channelProductId:%@",info.channelProductId);
            NSLog(@"expiresTime:%f",info.expiresTime);
            NSLog(@"purchase_date_ms:%f",info.purchase_date_ms);
        }
    }];
}
- (IBAction)LossOrderId:(id)sender {
    NSLog(@"[ Yodo1 ] Loss OrderId");
    [Yd1UCenterManager.shared queryLossOrder:^(NSArray * _Nonnull productIds, NSString * _Nonnull response) {
        for (NSDictionary *dic in productIds) {
            NSLog(@"%@",dic);
        }
    }];
}
- (IBAction)SendCustomEvent:(id)sender {
    NSLog(@"[ Yodo1 ] Send Custom Event");
    
    //ThinkingData
    [[Yodo1AnalyticsManager sharedInstance]eventAnalytics:@"Yodo1TestIOS_2022_03_16"
                                                eventData:@{@"Counto":@"2120"}];
    //Appsflyer
    [[Yodo1AnalyticsManager sharedInstance]eventAdAnalyticsWithName:@"Yodo1TestIOS_2022_03_16"
                                                          eventData:@{@"Count":@"2120"}];
}
- (IBAction)SendBuyEvent:(id)sender {
    NSLog(@"[ Yodo1 ] Send Buy Event");
    
    // Appsflyer
    //[Yodo1AnalyticsManager sharedInstance] validateAndTrackInAppPurchase:<#(NSString *)#> price:<#(NSString *)#> currency:<#(NSString *)#> transactionId:<#(NSString *)#>
}
- (IBAction)Share:(id)sender {
    NSLog(@"[ Yodo1 ] Share");
    
    NSLog(@"展示UI");
    //分享sns
    [OpenSuitSNSManager sharedInstance].isLandscapeOrPortrait = NO;
    SMContent* content = [[SMContent alloc]init];
    content.image = [UIImage imageNamed:@"share_test_image.jpg"];
    content.title = @"测试";
    content.desc = @"亲爱的滑雪健将们大家好，欢迎进入游道易的滑雪世界。在体验滑雪的同时，不要忘了与其他玩家分享你的战绩。更会有神秘活动等着你哦！";
    content.url = @"https://itunes.apple.com/us/app/rodeo-stampede-sky-zoo-safari/id1047961826?l=zh&ls=1&mt=8";//@"https://www.facebook.com";//
    content.gameLogo = [UIImage imageNamed:@"sharelogo.png"];
    content.qrLogo = [UIImage imageNamed:@"AppIcon"];
    content.qrText = @"一起长按识别别\n二维码分享分享 \n 求挑战！求带走！\n 求挑战！求带走！";
    content.snsType = Yodo1SNSTypeAll;
    [[OpenSuitSNSManager sharedInstance] showSocial:content block:^(Yodo1SNSType snsType, Yodo1ShareContentState state, NSError *error) {

        if (state == Yodo1ShareContentStateSuccess) {
            NSLog(@"分享成功");
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"分享成功"
                                      message:nil
                                      delegate:self
                                      cancelButtonTitle:@"确定"
                                      otherButtonTitles:nil];
            [alertView show];
        }else{
            UIAlertView *alertView = [[UIAlertView alloc]
                                      initWithTitle:@"分享失败"
                                      message:nil
                                      delegate:self
                                      cancelButtonTitle:@"确定"
                                      otherButtonTitles:nil];
            [alertView show];
        }
        if (error) {
            NSLog(@"分享失败:%@",[error description]);
           

        }
    }];
}

- (void)onlineParameter:(NSNotification*)notifi {
    YD1LOG(@"%@",notifi.object);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
