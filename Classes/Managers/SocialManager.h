//
//  SocialManager.h
//  Tahady
//
//  Created by Wael on 2/9/14.
//  Copyright (c) 2014 AlphaApps. All rights reserved.
//

#import <FBSDKShareKit/FBSDKShareKit.h>
#import <Social/Social.h>
#import "Media.h"

@interface SocialManager : NSObject <UIAlertViewDelegate, FBSDKSharingDelegate>
{
    UIDocumentInteractionController *docFile;
}

+ (SocialManager*)sharedManager;
// Login check
- (NSString*)getCurrentFacebookToken;
- (void)facebookLogin:(void (^)(NSDictionary* responseObject))facebookLoginSuccess failure:(void (^)(NSError *error))facebookLoginFailure;
- (void)facebookLogout;
// Sharing media
- (void)facebookShareMedia:(Media*)media withParent:(UIViewController*)viewController;
- (void)twitterShareMedia:(Media*)media withParent:(UIViewController*)viewController;
- (void)instagramShareMedia:(Media*)media success:(void (^)())instagramShareMediaSuccess failure:(void (^)(NSError *error, int errorCode))instagramShareMediaFailure;

// temp
- (void)saveMediaToPhotoLibrary:(Media*)media success:(void (^)())saveMediaToPhotoLibrarySuccess failure:(void (^)(NSError *error))saveMediaToPhotoLibraryFailure;

@end
