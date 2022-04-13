//
//  Yodo1BannerAdManager.h
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "Yodo1BannerDelegate.h"

typedef enum {
    BannerAlignLeft               = 1 << 0,
    BannerAlignHorizontalCenter   = 1 << 1,
    BannerAlignRight              = 1 << 2,
    BannerAlignTop                = 1 << 3,
    BannerAlignVerticalCenter     = 1 << 4,
    BannerAlignBottom             = 1 << 5,
}BannerAlign;

@interface Yodo1BannerManager: NSObject

///Yodo1BannerAdManager单例
+ (Yodo1BannerManager*)sharedInstance;

///初始化Banner sdk
- (void)initBannerSDK:(id<Yodo1BannerDelegate>)delegate;

///设置广告显示位置 @param align banner广告位置
- (void)setBannerAlign:(BannerAlign)align
        viewcontroller:(UIViewController *)viewcontroller;

///设置Banner偏移
- (void)setBannerOffset:(CGPoint)point;

///设置Banner Scale缩放倍数 x轴方向倍数sx,  y轴方向倍数sy
- (void)setBannerScale:(CGFloat)sx sy:(CGFloat)sy;

///显示Banner广告
- (void)showBanner:(NSString *)placement_id;

///隐藏广告:不移除
- (void)hideBanner;

///移除广告
- (void)removeBanner;

///是否有广告准备好
- (BOOL)bannerAdReady;

@end
