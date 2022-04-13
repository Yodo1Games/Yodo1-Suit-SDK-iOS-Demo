//
//  Yodo1RewardGameViewController.h
//
//  Created by yanpeng on 2020/7/22.
//  Copyright © 2020 yanpeng. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface Yodo1RewardGameViewController : UIViewController

+(void)presentRewardGame:(UIViewController *)viewController reward:(void(^)(NSString * reward, NSError * error))reward;
@end

