//
//  PushManager.m
//  Weez
//
//  Created by Dania on 11/6/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "PushManager.h"
//#import "NotificationsListController.h"
#import "HomeController.h"
#import "LoginController.h"
#import "UIWindow+VisibleController.h"

@implementation PushManager

+ (void) handleNotification : (NSDictionary *)userInfo isAppRunning:(BOOL) appIsRunning;
{
    
    NSDictionary *apsInfo = [userInfo objectForKey:@"aps"];
    //there is some pending push notification, so do something
    if(apsInfo) {
        NSString *jsonString = [userInfo objectForKey:@"u"];
        NSData *data = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
        NSDictionary *payload = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if(payload)
        {
            NSDictionary *notificationInfo = [payload objectForKey:@"notification"];
            if(notificationInfo)
            {
                AppNotification *obj = [[AppNotification alloc] init];
                [obj fillWithJSON:notificationInfo];
                if(appIsRunning)
                {
                    [self popNotificationListToTheTop:obj];
                }
                else
                {
                    [PushManager showNotificationsList:obj];
                }
            }
        }
    }
}

+(void) showNotificationsList :(AppNotification*) notification
{
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    LoginController* root = (LoginController*) appDelegate.window.rootViewController;
    [root setRecievedNotification:notification];
}

+(void) popNotificationListToTheTop:(AppNotification*) notification
{
    //storyboard
    UIStoryboard *mainstoryboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
    
    //find current navigation controller
     AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    UIViewController *vc = [appDelegate.window visibleViewController];//appDelegate.window.rootViewController;
    UINavigationController *navController;
    if(![vc isKindOfClass:[UINavigationController class]])
    {
        navController = [vc navigationController];
    }
    else
    {
        navController = (UINavigationController*)vc;
    }
    
    
    NSString *identifireHomeNavigationController = @"HomeNavigationController";
    UINavigationController* homeNavController;
    
    //if HomeNavController is in current stack just pop all controllers to back to the root one (HomeController)
    if([navController.restorationIdentifier isEqualToString:identifireHomeNavigationController])
    {
        homeNavController = navController;
        HomeController *homeController = (HomeController*)[homeNavController viewControllers][0];
        [homeNavController popToRootViewControllerAnimated:NO];
        [homeController hideAllViews];
        [homeController setRecievedDeepLinkingNotification:notification];
        [homeController handlePushNotificationTapEvent];
    }
    else
    {
    //make new instance of HomeNavigationController and present it modally
        homeNavController = [mainstoryboard instantiateViewControllerWithIdentifier:identifireHomeNavigationController];
        HomeController *homeController = (HomeController*)[homeNavController viewControllers][0];
        [homeController hideAllViews];
            [navController presentViewController:homeNavController animated:YES completion:^{
                [homeController setRecievedDeepLinkingNotification:notification];
                [homeController handlePushNotificationTapEvent];
        }];
    }
}


+ (void) showAlert:(NSString*) title msg: (NSString*)msg
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title
                                                    message:msg
                                                   delegate:self
                                          cancelButtonTitle:@"Cancel"
                                          otherButtonTitles:@"Ok",nil];
    [alert show];
}

@end
