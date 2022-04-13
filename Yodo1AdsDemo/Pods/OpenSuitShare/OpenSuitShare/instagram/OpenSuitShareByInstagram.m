//
//  OpenSuitShareByInstagram.m
//  foundation
//
//  Created by Nyxon on 14-8-6.
//  Copyright (c) 2014年 yodo1. All rights reserved.
//

#import "OpenSuitShareByInstagram.h"
#import "OpenSuitSNSManager.h"

@interface OpenSuitShareByInstagram ()<UIDocumentInteractionControllerDelegate>
{
    Yodo1SNSType _snsType;
    SNSShareCompletionBlock completionBlock;
    BOOL bSendSuccess;
    
}

@property (nonatomic, retain) UIDocumentInteractionController *documentController;

@end

@implementation OpenSuitShareByInstagram

+ (OpenSuitShareByInstagram *)sharedInstance
{
    static OpenSuitShareByInstagram *sharedInstance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[OpenSuitShareByInstagram alloc] init];
    });
    return sharedInstance;
}

- (void)dealloc {
    
}

- (BOOL)isInstalledIntagram {
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    if([[UIApplication sharedApplication] canOpenURL:instagramURL]) {
        return YES;
    }
    return YES;
}

- (void)shareWithContent:(SMContent *)content
                   scene:(Yodo1SNSType)snsType
         completionBlock:(SNSShareCompletionBlock)aCompletionBlock
{
    completionBlock = [aCompletionBlock copy];
    _snsType = snsType;
    if (self == nil) {
        if(completionBlock){
            NSDictionary *errorDict = @{NSLocalizedDescriptionKey : @"没有初始化",
                                        NSLocalizedFailureReasonErrorKey : @"",
                                        NSLocalizedRecoverySuggestionErrorKey : @""};
            NSError *error = [NSError errorWithDomain:@"com.yodo1.SNSShare" code:-1 userInfo:errorDict];
            completionBlock(snsType,Yodo1ShareContentStateUnInstalled,error);
        }
        completionBlock = nil;
        return;
    }
    
    if (![self isInstalledIntagram]) {
        if(completionBlock){
            NSDictionary *errorDict = @{NSLocalizedDescriptionKey : @"客户端没有安装",
                                        NSLocalizedFailureReasonErrorKey : @"",
                                        NSLocalizedRecoverySuggestionErrorKey : @""};
            NSError *error = [NSError errorWithDomain:@"com.yodo1.SNSShare" code:-1 userInfo:errorDict];
            completionBlock(snsType,Yodo1ShareContentStateUnInstalled,error);
        }
        completionBlock = nil;
        return;
    }
    bSendSuccess = NO;
    NSString *status = content.desc;
    UIImage* img = content.image;

    NSString *documentDirectory=[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *saveImagePath=[documentDirectory stringByAppendingPathComponent:@"image.ig"];
    NSData *imgData=UIImagePNGRepresentation(img);
    [imgData writeToFile:saveImagePath atomically:YES];
    NSURL *imageURL=[NSURL fileURLWithPath:saveImagePath];
    
    self.documentController=[[UIDocumentInteractionController alloc]init];
    self.documentController = [UIDocumentInteractionController interactionControllerWithURL:imageURL];
    self.documentController.delegate = self;
    if (status) {
        self.documentController.annotation = [NSDictionary dictionaryWithObjectsAndKeys:@"describe",status,nil];
    }
    self.documentController.UTI = @"com.instagram.photo";
    UIViewController *vc = [UIApplication sharedApplication].keyWindow.rootViewController;
    [self.documentController presentOpenInMenuFromRect:CGRectMake(1, 1, 1, 1) inView:vc.view animated:YES];
}

- (void)documentInteractionControllerWillPresentOpenInMenu:(UIDocumentInteractionController *)controller {

}

- (void)documentInteractionControllerDidDismissOpenInMenu:(UIDocumentInteractionController *)controller {
  if(completionBlock){
    if (bSendSuccess) {
        completionBlock(_snsType,Yodo1ShareContentStateSuccess,nil);
    }else{
        completionBlock(_snsType,Yodo1ShareContentStateFail,nil);
    }
  }
}

- (void)documentInteractionController:(UIDocumentInteractionController *)controller
        willBeginSendingToApplication:(nullable NSString *)application {
    bSendSuccess = YES;
}
- (void)documentInteractionController:(UIDocumentInteractionController *)controller
           didEndSendingToApplication:(nullable NSString *)application {

}

@end
