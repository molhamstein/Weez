//
//  SocialManager.m
//  Tahady
//
//  Created by Wael on 2/9/14.
//  Copyright (c) 2014 AlphaApps. All rights reserved.
//

#import "SocialManager.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "AppManager.h"
#import "ConnectionManager.h"
#import "AppDelegate.h"
#import "UIImageView+WebCache.h"
#import <AssetsLibrary/AssetsLibrary.h>
@import Photos;

// Social manager
static SocialManager* m_pgSocialManager = nil;

@implementation SocialManager

#pragma mark -
#pragma mark Singilton Init Methods
// Shared social singleton.
+ (SocialManager*)sharedManager
{
    if(!m_pgSocialManager)
        m_pgSocialManager = [[SocialManager alloc] init];
    return m_pgSocialManager;
}

// Alloc shared social singleton.
+ (id)alloc
{
	@synchronized( self )
    {
		NSAssert(m_pgSocialManager == nil, @"Attempted to allocate a second instance of a singleton.");
		return [super alloc];
	}
	return nil;
}

// Init the manager
- (id)init
{
	if ( self = [super init] )
    {
	}
	return self;
}

#pragma mark -
#pragma mark Facebook Login
// Get current Facebook token
- (NSString*)getCurrentFacebookToken
{
    FBSDKAccessToken *token = [FBSDKAccessToken currentAccessToken];
    return token.tokenString;
}

// Facebook login process and return the authData on success
- (void)facebookLogin:(void (^)(NSDictionary* responseObject))facebookLoginSuccess failure:(void (^)(NSError *error))facebookLoginFailure
{
    FBSDKLoginManager *fbManager = [[FBSDKLoginManager alloc] init];
    [fbManager setLoginBehavior:FBSDKLoginBehaviorSystemAccount];
    [fbManager logOut];
    [fbManager logInWithReadPermissions:@[@"public_profile", @"user_friends", @"email"] fromViewController:nil handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
    {
        // global error
        if (error)
        {
            NSLog(@"Process error");
            NSString *alertTitle = [[AppManager sharedManager] getLocalizedString:@"FACEBOOK_ERROR_TITLE1"];
            NSString *alertText = [[AppManager sharedManager] getLocalizedString:@"FACEBOOK_ERROR_MSG1"];
            [self showMessage:alertText withTitle:alertTitle];
            facebookLoginFailure(error);
        }
        // login cancelled
        else if (result.isCancelled)
        {
            NSLog(@"Cancelled");
            NSString *alertTitle = [[AppManager sharedManager] getLocalizedString:@"FACEBOOK_ERROR_TITLE2"];
            NSString *alertText = [[AppManager sharedManager] getLocalizedString:@"FACEBOOK_ERROR_MSG2"];
            [self showMessage:alertText withTitle:alertTitle];
            facebookLoginFailure(nil);
        }
        else// success
        {
            NSLog(@"Logged in");
            // get user data
            FBSDKAccessToken *token = result.token;
            NSString *userToken = token.tokenString;
            NSString *userID = token.userID;
            NSDictionary *resultDic = @{@"token":userToken, @"fbid":userID};
            facebookLoginSuccess(resultDic);
        }
    }];
}

// Login with publish permissions
- (void)facebookPublishPermissions:(void (^)())facebookPublishPermissionsSuccess failure:(void (^)(NSError *error))facebookPublishPermissionsFailure
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    // login with publish permissions
    [login logInWithPublishPermissions:@[@"publish_actions"] fromViewController:nil handler:^(FBSDKLoginManagerLoginResult *result, NSError *error)
    {
        // global error
        if (error)
        {
            NSLog(@"Process error");
            NSString *alertTitle = [[AppManager sharedManager] getLocalizedString:@"FACEBOOK_ERROR_TITLE1"];
            NSString *alertText = [[AppManager sharedManager] getLocalizedString:@"FACEBOOK_ERROR_MSG3"];
            [self showMessage:alertText withTitle:alertTitle];
            facebookPublishPermissionsFailure(error);
        }
        // publish cancelled
        else if (result.isCancelled)
        {
            NSLog(@"Cancelled");
            NSString *alertTitle = [[AppManager sharedManager] getLocalizedString:@"FACEBOOK_ERROR_TITLE3"];
            NSString *alertText = [[AppManager sharedManager] getLocalizedString:@"FACEBOOK_ERROR_MSG4"];
            [self showMessage:alertText withTitle:alertTitle];
            facebookPublishPermissionsFailure(error);
        }
        else// success
        {
            NSLog(@"Logged in");
            // success permissions
            facebookPublishPermissionsSuccess();
        }
    }];
}


// Show message
- (void)showMessage:(NSString *)text withTitle:(NSString *)title
{
    [[[UIAlertView alloc] initWithTitle:title message:text delegate:nil
                        cancelButtonTitle:[[AppManager sharedManager] getLocalizedString:@"FACEBOOK_ERROR_ACTION"]
                        otherButtonTitles:nil] show];
}

// Logout from facebook
- (void)facebookLogout
{
    FBSDKLoginManager *login = [[FBSDKLoginManager alloc] init];
    [login logOut];
}

#pragma mark -
#pragma mark Share
// Facebook share photo
- (void)facebookShareMedia:(Media*)media withParent:(UIViewController*)viewController
{
    FBSDKShareLinkContent *content = [[FBSDKShareLinkContent alloc] init];
    content.contentURL = [NSURL URLWithString:media.mediaLink];
    [self facebookPublishContent:viewController withContent:content];
}

// Facebook publish content
- (void)facebookPublishContent:(UIViewController*)viewController withContent:(id<FBSDKSharingContent>)content
{
    // publish content
    if ([[FBSDKAccessToken currentAccessToken] hasGranted:@"publish_actions"])
    {
        // show dialog
        [FBSDKShareDialog showFromViewController:viewController withContent:content delegate:self];
    }
    else// grant publish actions
    {
        // askd for permissions
        [[SocialManager sharedManager] facebookPublishPermissions:^
        {
            // show dialog
            [FBSDKShareDialog showFromViewController:viewController withContent:content delegate:self];
        }
        failure:^(NSError *error)
        {
        }];
    }
}

#pragma mark -
#pragma mark - FBSDKSharingDelegate
// Share completed
- (void)sharer:(id<FBSDKSharing>)sharer didCompleteWithResults:(NSDictionary *)results
{
    NSLog(@"Facebook sharing completed: %@", results);
    // show notification success
    [[AppManager sharedManager] showNotification:@"TIMELINE_SHARE_SUCCESS" withType:kNotificationTypeSuccess];
}

// Share failed
- (void)sharer:(id<FBSDKSharing>)sharer didFailWithError:(NSError *)error
{
    NSLog(@"Facebook sharing failed: %@", error);
    // show notification error
    [[AppManager sharedManager] showNotification:@"TIMELINE_SHARE_FAILED" withType:kNotificationTypeFailed];
}

// Share canceled
- (void)sharerDidCancel:(id<FBSDKSharing>)sharer
{
    NSLog(@"Facebook sharing cancelled.");
}

#pragma mark -
#pragma mark Twitter & Instagram Share
// Twitter share media
- (void)twitterShareMedia:(Media*)media withParent:(UIViewController*)viewController
{
    // twitter available
    if ([SLComposeViewController isAvailableForServiceType:SLServiceTypeTwitter])
    {
        SLComposeViewController *tweet = [SLComposeViewController composeViewControllerForServiceType:SLServiceTypeTwitter];
        NSString *tweetText = media.mediaLink;
        [tweet setInitialText:tweetText];
        [tweet setCompletionHandler:^(SLComposeViewControllerResult result)
        {
            if (result == SLComposeViewControllerResultCancelled)
            {
                NSLog(@"The user cancelled.");
            }
            else if (result == SLComposeViewControllerResultDone)
            {
                NSLog(@"The user sent the tweet");
                // show notification success
                [[AppManager sharedManager] showNotification:@"TIMELINE_SHARE_SUCCESS" withType:kNotificationTypeSuccess];
            }
        }];
        [viewController presentViewController:tweet animated:YES completion:nil];
    }
    else// No twitter account
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[[AppManager sharedManager] getLocalizedString:@"TWITTER_ALERT_TITLE"]
                                                        message:[[AppManager sharedManager] getLocalizedString:@"TWITTER_ALERT_MSG"]
                                                        delegate:nil
                                                        cancelButtonTitle:[[AppManager sharedManager] getLocalizedString:@"TWITTER_ALERT_ACTION"]
                                                        otherButtonTitles:nil];
        [alert show];
    }
}

// Instagram share media
- (void)instagramShareMedia:(Media*)media success:(void (^)())instagramShareMediaSuccess failure:(void (^)(NSError *error, int errorCode))instagramShareMediaFailure
{
    NSURL *instagramURL = [NSURL URLWithString:@"instagram://app"];
    // can open instagram
    if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
    {
        // check if downloaded before
        if ([media fetchLocalURL] == nil)
        {
            // download media video
            [[ConnectionManager sharedManager] downloadVideoFromURL:media.mediaLink progress:^(CGFloat progress)
            {
            }
            success:^(NSURL *filePath)
            {
                // save media to photo library and share with instagram
                [[SocialManager sharedManager] saveMediaToPhotoLibrary:media success:^
                {
                    instagramShareMediaSuccess();
                }
                failure:^(NSError *error)
                {
                    instagramShareMediaFailure(nil, 1);
                }];
            }
            failure:^(NSError *error)
            {
                instagramShareMediaFailure(nil, 0);
            }];
        }
        else// fetch media locally
        {
            // save media to photo library and share with instagram
            [[SocialManager sharedManager] saveMediaToPhotoLibrary:media success:^
            {
                instagramShareMediaSuccess();
            }
            failure:^(NSError *error)
            {
                instagramShareMediaFailure(nil, 1);
            }];
        }
    }
    else// failed to open
    {
        // instagram not installed
        UIAlertView * alert = [[UIAlertView alloc] initWithTitle:[[AppManager sharedManager] getLocalizedString:@"INSTAGRAM_ALERT_TITLE"]
                                                         message:[[AppManager sharedManager] getLocalizedString:@"INSTAGRAM_ALERT_MSG"]
                                                         delegate:nil
                                                         cancelButtonTitle:[[AppManager sharedManager] getLocalizedString:@"TWITTER_ALERT_ACTION"]
                                                         otherButtonTitles:nil];
        [alert show];
        instagramShareMediaFailure(nil, 2);
    }
}

// Save media to photo library
- (void)saveMediaToPhotoLibrary:(Media*)media success:(void (^)())saveMediaToPhotoLibrarySuccess failure:(void (^)(NSError *error))saveMediaToPhotoLibraryFailure
{
    // get local file path
    NSURL *filePath = [media fetchLocalURL];
    ALAssetsLibrary *library = [[ALAssetsLibrary alloc] init];
    // video case
    if (media.mediaType == kMediaTypeVideo)
    {
        // save media to photos album folder
        [library writeVideoAtPathToSavedPhotosAlbum:filePath completionBlock:^(NSURL *assetURL, NSError *error)
        {
            // error wrting media to photo library
            if (error != nil)
            {
                saveMediaToPhotoLibraryFailure(nil);
            }
            else // fetch saved asset to load the local identifier
            {
                // fetch saved asset to load the local identifier
                PHFetchResult *asset = [PHAsset fetchAssetsWithALAssetURLs:@[assetURL] options:nil];
                // assets found
                if ((asset != nil) && ([asset count] > 0))
                {
                    [asset enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                    {
                        // object found, pass local media identifier to instagram
                        PHAsset *pObj = (PHAsset*)obj;
                        NSURL *instagramURL = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://library?LocalIdentifier=%@", pObj.localIdentifier]];
                        if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
                            [[UIApplication sharedApplication] openURL:instagramURL];
                        saveMediaToPhotoLibrarySuccess();
                    }];
                }
                else// not found
                    saveMediaToPhotoLibraryFailure(nil);
            }
        }];
    }
    // image case
    else if (media.mediaType == kMediaTypeImage)
    {
        NSData *imageData = [NSData dataWithContentsOfURL:filePath];
        // save media to photos album folder
        [library writeImageDataToSavedPhotosAlbum:imageData metadata:nil completionBlock:^(NSURL *assetURL, NSError *error)
        {
            // error wrting media to photo library
            if (error != nil)
            {
                saveMediaToPhotoLibraryFailure(nil);
            }
            // asset saved successfully
            else if (assetURL != nil)
            {
                // fetch saved asset to load the local identifier
                PHFetchResult *asset = [PHAsset fetchAssetsWithALAssetURLs:@[assetURL] options:nil];
                // assets found
                if ((asset != nil) && ([asset count] > 0))
                {
                    [asset enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop)
                    {
                        // object found, pass local media identifier to instagram
                        PHAsset *pObj = (PHAsset*)obj;
                        NSURL *instagramURL = [NSURL URLWithString:[NSString stringWithFormat:@"instagram://library?LocalIdentifier=%@", pObj.localIdentifier]];
                        if ([[UIApplication sharedApplication] canOpenURL:instagramURL])
                            [[UIApplication sharedApplication] openURL:instagramURL];
                        saveMediaToPhotoLibrarySuccess();
                    }];
                }
                else// not found
                    saveMediaToPhotoLibraryFailure(nil);
            }
            else// not found
                saveMediaToPhotoLibraryFailure(nil);
        }];
    }
}

@end
