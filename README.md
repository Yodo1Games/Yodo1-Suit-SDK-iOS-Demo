# Yodo1-Suit-SDK-iOS-Demo

## Overview

### Please check the [documentation](https://github.com/Yodo1Games/Suit-Document/blob/master/README.md) to get started on integration.

## Demo App
To get started with the demo app, follow the instructions below:

### 1. If you have CocoaPods(1.8.0 and above) installed, please ignore this step. Otherwise, to install CocoaPods, use the following command.

```
/bin/bash -c "$(curl -fsSL https://gist.githubusercontent.com/nicky9112/0bf903795f77c5052ff12c92e629f975/raw/a8783d03c96b8d1d50f92977bfa0112711fbc57a/install-cocoapods.sh)"
```

### 2. Execute the following command in Terminal.

```ruby
pod install --repo-update
```

### 3. Change `Bundle Identifier` to your game's `Bundle Identifier`

### 4. Change the AppKey value in `AppDelegate.m` file with the AppId

``` obj-c
SDKConfig *config = [[SDKConfig alloc]init];
config.appKey = @"Your AppKey";
[Yodo1Manager initSDKWithConfig:config];
```
### 5. Change AppsFlyerDevKey, AppleAppId, ThinkingAppId values in `Info.plist`.

``` xml
<key>AnalyticsInfo</key> 
<dict>  
    	<key>ThinkingAppId</key> 
    	<string>[ThinkingData AppId]</string> 
    	<key>AppleAppId</key> 
    	<string>[Apple AppId]</string> 
    	<key>AppsFlyerDevKey</key> 
    	<string>[AppsFlyer DevKey]</string> 
</dict>
```

### 6. Change `Yodo1ProductInfo.plist` to purchase point

``` xml
<key>custom name</key> 
<dict> 
        <key>ProductName</key> 
        <string>product name</string> 
        <key>ChannelProductId</key> 
        <string>product id</string> 
        <key>ProductDescription</key> 
        <string>product description</string> 
        <key>PriceDisplay</key> 
        <string>displayed price</string> 
        <key>ProductPrice</key> 
        <string>product price</string> 
        <key>Currency</key> 
        <string>currency</string> 
        <key>ProductType</key> 
        <string>1(0:not consumable, 1:consumable, 2:auto subscribe, 3:non-auto subscription)</string> 
        <key>PeriodUnit</key> 
        <string>Period Unit</string> 
</dict>
```
