//
//  OpenSuitShareBySinaWeibo.h
//  foundation
//
//  Created by Nyxon on 14-8-6.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenSuitSMConstant.h"

@interface OpenSuitShareBySinaWeibo : NSObject

+ (OpenSuitShareBySinaWeibo *)sharedInstance;

- (void)initSinaWeiboWithAppKey:(NSString *)appKey
                  universalLink:(NSString *)universalLink;

#pragma mark - sdk方式分享
- (void)shareWithContent:(SMContent *)content
                   scene:(Yodo1SNSType)snsType
         completionBlock:(SNSShareCompletionBlock)aCompletionBlock;

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
            options:(NSDictionary *)options;
@end
