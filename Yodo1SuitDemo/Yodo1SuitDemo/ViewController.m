//
//  ViewController.m
//  Yodo1SuitDemo
//
//  Created by yixian huang on 2017/9/13.
//  Copyright © 2017年 yixian huang. All rights reserved.
//

#import "ViewController.h"
#import "Yodo1Tool+Commons.h"
#import "Yodo1Tool+Storage.h"
#import "Yd1UCenter.h"
#import "Yd1UCenterManager.h"
#import <Yodo1AnalyticsManager.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    YD1LOG(@"deviceid :%@",Yd1OpsTools.keychainDeviceId);
    YD1LOG(@"uuid:%@",Yd1OpsTools.keychainUUID);
}

- (IBAction)Buy:(id)sender {
    NSLog(@"[ Yodo1 ] Purchase");
    
    // consumption:@"com.yodo1.consumption.example"
    // subscription:@"com.yodo1.subscription.example"
    [Yd1UCenterManager.shared paymentWithUniformProductId:@"com.yodo1.consumption.example"
                                                 extra:@""
                                                 callback:^(PaymentObject * _Nonnull payemntObject) {
        if (payemntObject.paymentState == PaymentSuccess) {
            YD1LOG(@"%@: Purchase success.",payemntObject.uniformProductId);
            Yd1UCenter.shared.itemInfo.orderId = payemntObject.orderId;
            Yd1UCenter.shared.itemInfo.extra = @"";
            
            //If the game has a shipping function, please call our shipping interface after your successful delivery, otherwise, call our shipping interface directly after the successful payment.
            //Purchase success and Send goods.
            [Yd1UCenter.shared sendGoodsOver:payemntObject.orderId callback:^(BOOL success, NSString * _Nonnull error) {
                if (success) {
                    YD1LOG(@"Send goods success.");
                }else{
                    YD1LOG(@"%@",error);
                }
            }];
            
        } else {
            YD1LOG(@"%@: Purchase failed.\n%@",payemntObject.uniformProductId,payemntObject.response);
        }
    }];
}

- (IBAction)Restore:(id)sender {
    NSLog(@"[ Yodo1 ] Restore Purchase.");
    
    [Yd1UCenterManager.shared restorePayment:^(NSArray * _Nonnull productIds, NSString * _Nonnull response) {
        for (NSDictionary* dic in productIds) {
            NSLog(@"%@",dic);
        }
    }];
}
- (IBAction)LossOrderId:(id)sender {
    NSLog(@"[ Yodo1 ] Query Loss Orderid.");
    [Yd1UCenterManager.shared queryLossOrder:^(NSArray * _Nonnull productIds, NSString * _Nonnull response) {
        for (NSDictionary *dic in productIds) {
            NSLog(@"%@",dic);
        }
    }];
}
- (IBAction)QuerySub:(id)sender {
    NSLog(@"[ Yodo1 ] Query subscription items.");
    
    // The API for querying and subscribing products is checked with the Apple API. The number of requests per day is limited. In order to ensure that this function can be used normally, please make reasonable arrangements to call the API for querying and subscribing.
    /*
    [Yd1UCenter.shared querySubscriptions:<#(nonnull YD1ItemInfo *)#> callback:^(BOOL success, NSString * _Nullable response, NSError * _Nullable error) {
        
    }];
     */
}

- (IBAction)SendCustomEvent:(id)sender {
    NSLog(@"[ Yodo1 ] Send Custom Event");
    
    //ThinkingData
    [[Yodo1AnalyticsManager sharedInstance]eventAnalytics:@"Yodo1TestIOS_2022_04_16"
                                                eventData:@{@"Counto":@"2120"}];
    //Appsflyer
    [[Yodo1AnalyticsManager sharedInstance]eventAdAnalyticsWithName:@"Yodo1TestIOS_2022_04_16"
                                                          eventData:@{@"Count":@"2120"}];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
