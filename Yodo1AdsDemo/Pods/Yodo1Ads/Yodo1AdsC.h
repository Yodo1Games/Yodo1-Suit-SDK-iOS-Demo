//
//  Yodo1AdsC.h
//  Yodo1Ads
//
//  Created by yixian huang on 2017/9/13.
//  Copyright © 2017年 yixian huang. All rights reserved.
//
//

#ifndef Yodo1AdsC_h
#define Yodo1AdsC_h

typedef enum {
    Yodo1AdsCEventClose          = 0,   //Close
    Yodo1AdsCEventFinish         = 1,   //Finish playing
    Yodo1AdsCEventClick          = 2,   //Click ad
    Yodo1AdsCEventLoaded         = 3,   //Ad load finish
    Yodo1AdsCEventShowSuccess    = 4,   //Display success
    Yodo1AdsCEventShowFail       = 5,   //display fail
    Yodo1AdsCEventSkip           = 6,   //skip
    Yodo1AdsCEventLoadFail       = -1,  //Load of Error
}Yodo1AdsCEvent;

typedef enum {
    Yodo1AdsCBannerAdAlignLeft               = 1 << 0,
    Yodo1AdsCBannerAdAlignHorizontalCenter   = 1 << 1,
    Yodo1AdsCBannerAdAlignRight              = 1 << 2,
    Yodo1AdsCBannerAdAlignTop                = 1 << 3,
    Yodo1AdsCBannerAdAlignVerticalCenter     = 1 << 4,
    Yodo1AdsCBannerAdAlignBottom             = 1 << 5,
}Yodo1AdsCBannerAdAlign;

//Error Message
class Yodo1AdsCError{
public:
    int errorCode;
    const char * errorDescription;
};

typedef void (*Yodo1AdsEvent_Callback)(Yodo1AdsCEvent event,Yodo1AdsCError * error);
typedef void (*Yodo1RewardGame_Callback)(const char * reward,Yodo1AdsCError * error);

class Yodo1AdsC {
    
public:
    /**
     *  Init
     */
    static void InitWithAppKey(const char* appKey);
    
    /**
     *  Enable/Disable log
     */
    static void SetLogEnable(bool enable);
    
#pragma mark- YODO1_BANNER
    
    /**
     *  Set banner's align
     */
    static void SetBannerAlign(Yodo1AdsCBannerAdAlign align);
    
    /**
     *  Set banner's callback
     */
    static void SetBannerCallback(Yodo1AdsEvent_Callback callback);
    
    /**
     *  Set banner's offset
     */
    static void SetBannerOffset(float x,float y);
    
    /**
     *  Set the Banner Scale scaling factor x axis direction
     *  multiple sx,y axis direction multiple sy
     */
    static void SetBannerScale(float sx,float sy);
    
    /**
     * Check if banner ad is ready to show
     */
    static bool BannerIsReady();
    
    /**
     *  Show banner
     */
    static void ShowBanner();
    
    /**
     *  Show banner with placement_id
     */
    static void ShowBannerWithPlacement(const char* placement_id);
    
    /**
     *  Hide banner
     */
    static void HideBanner();
    
    /**
     *  Remove Banner from
     */
    static void RemoveBanner();
    
#pragma mark- YODO1_INTERSTITIAL
    
    /**
     *  Set interstitial's callback
     */
    static void SetInterstitialCallback(Yodo1AdsEvent_Callback callback);
    
    /**
     *  Check if interstitial is ready to show
     */
    static bool InterstitialIsReady();
    
    /**
     *  Show interstitial ad
     */
    static void ShowInterstitial();
    
    /**
     *  Show interstitial ad with placement_id
     */
    static void ShowInterstitialWithPlacement(const char* placement_id);
    
#pragma mark- YODO1_VIDEO
    
    /**
     *  Set video's callback
     */
    static void SetVideoCallback(Yodo1AdsEvent_Callback callback);
    
    /**
     *  Check if vedeo ad is ready to paly
     *
     *  @return YES/NO
     */
    static bool VideoIsReady();
    
    /**
     *  Show the video ad
     */
    static void ShowVideo();
    
    /**
     *  Show video ad with placement_id
     */
    static void ShowVideoWithPlacement(const char* placement_id);
    
    /**
     * This can be used by the integrating App to indicate if
     * the user falls in any of the GDPR applicable countries
     * (European Economic Area).
     * consent YES User consents (Behavioral and Contextual Ads).
     * NO if they are not.
     */
    static void SetUserConsent(BOOL consent);
    
    /**
     *  return YES
     *  Agrees to collect data. The default is to collect data
     */
    static bool IsUserConsent();
    
    /**
     * In the US, the Children’s Online Privacy Protection Act (COPPA) imposes
     * certain requirements on operators of online services that (a)
     * have actual knowledge that the connected user is a child under 13 years of age,
     * or (b) operate services (including apps) that are directed to children under 13.
     * isBelowConsentAge YES if the user is affected by COPPA, NO if they are not.
     */
    static void SetTagForUnderAgeOfConsent(BOOL isBelowConsentAge);
    
    /**
     *  return YES
     *  It means
     *  under the age of 16
     */
    static bool IsTagForUnderAgeOfConsent();
    
    /**
     * Set whether or not user has opted out of the sale of their
     * personal information.
     * doNotSell 'YES' if the user has opted out of the sale of
     * their personal information.
     */
    static void SetDoNotSell(BOOL doNotSell);
    
    /**
     *  return YES
     *  Indicates that the user has chosen not to
     * sell their personal information
     */
    static bool IsDoNotSell();
    
#pragma mark- YODO1_REWARDGAME
    /**
     *  Check reward game is enable or not
     *
     *  @return YES/NO
     */
    static bool RewardGameIsEnable();
    
    /**
     *  Show reward game
     */
    static void ShowRewardGame(Yodo1RewardGame_Callback callback);

#pragma mark- YODO1_SPLASH
    /**
     *  Set video's callback
     */
    static void SetSplashCallback(Yodo1AdsEvent_Callback callback);
    
    /**
     *  Show splash ad
     */
    static void ShowSplash();
    static void ShowSplashWithPlacement(const char* placement_id);
};

#endif /* Yodo1AdsC_h */
