//
//  Yodo1Analytics.h
//
//  Created by yixian huang on 2017/7/26.
//
//  sdk version 1.0.11
//

#ifndef Yodo1Analytics_h
#define Yodo1Analytics_h
#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface Yodo1Analytics : NSObject

+ (id)instance;

- (void)initWithAppKey:(NSString*)appKey
              channelId:(NSString*)channelId;

- (void)releaseSDKVersion:(NSString*)version;

- (void)eventId:(NSString*)eventId
      eventData:(NSDictionary*)eventData;

- (void)setDebugMode:(BOOL)enableDebugMode;

- (BOOL)getDebug;

@end

NS_ASSUME_NONNULL_END
#endif /* Yodo1Analytics_h */
