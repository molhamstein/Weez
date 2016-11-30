//
//  AppDelegate.m
//  Tahady
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2014 AlphaApps. All rights reserved.
//

#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "ConnectionManager.h"
#import "AppManager.h"
#import "IQKeyboardManager.h"
#import "PushManager.h"
@import GoogleMaps;
@import GooglePlaces;

@implementation AppDelegate

#pragma mark -
#pragma mark Application lifecycle
// Appliation finish launching
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // set application language
    [[AppManager sharedManager] initAppLanguage];
    // change navigation and status bars color
    [[AppManager sharedManager] setNavigationBarStyle];
    // keyboard manager
    [IQKeyboardManager sharedManager].enable = YES;
    [IQKeyboardManager sharedManager].enableAutoToolbar = NO;
    [GMSServices provideAPIKey:PLACES_API_KEY];
    [GMSPlacesClient provideAPIKey:PLACES_API_KEY];
    
    //handle push notification tap
    NSDictionary *userInfo = [launchOptions valueForKey:@"UIApplicationLaunchOptionsRemoteNotificationKey"];
    [PushManager handleNotification:userInfo isAppRunning:NO];
    
    //self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];

    // connect with Facebook sdk
    return [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
}

- (BOOL)application:(UIApplication *)application willFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    CGRect bounds = [[UIScreen mainScreen] bounds];
    [self.window setFrame:bounds];
    [self.window setBounds:bounds];
    
    return YES;
}

// Change remote notification
- (void)changeRemoteNotification
{
    // user logged in
    if ([[ConnectionManager sharedManager] isUserLoggedIn])
    {
        // register for notification
        if ([[[ConnectionManager sharedManager] userObject] isNotificationOn])
        {
            [self registerAllRemoteNotification];
        }
        else// unregister for notification
        {
            [[UIApplication sharedApplication] unregisterForRemoteNotifications];
        }
    }
    else// not logged in yet
    {
        [self registerAllRemoteNotification];
    }
}

// Register remote notification
- (void)registerAllRemoteNotification
{
    // use registerUserNotificationSettings
    UIUserNotificationSettings *setting = [UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert) categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:setting];
    [[UIApplication sharedApplication] registerForRemoteNotifications];
}

// Application resign active
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
}

// Application entered foreground
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    //[[NotificationManager sharedManager] stopAllTimers];
}

// Application will enter foreground
- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    // notify about timeline changes
    [[NSNotificationCenter defaultCenter] postNotificationName:NOTIFICATION_TIMELINE_CHANGED object:nil userInfo:nil];
}

// Application did become active again
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    // clear application icon badge
    [UIApplication sharedApplication].applicationIconBadgeNumber = 0;
    // tack activation
    [FBSDKAppEvents activateApp];
}

// Application terminate
- (void)applicationWillTerminate:(UIApplication *)application
{
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark
#pragma mark Application Notification
// Application did register for notification
- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)newDeviceToken
{
    NSString *token = [[newDeviceToken description] stringByTrimmingCharactersInSet: [NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    token = [token stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    [ConnectionManager sharedManager].deviceIdentifier = token;
    //register device if it it is not register yet
    if ([[ConnectionManager sharedManager] isUserLoggedIn] && ![ConnectionManager sharedManager].userObject.deviceRegistered && [[ConnectionManager sharedManager].userObject isNotificationOn])
    {
        //register device for notification
        NSString* deviceId = [ConnectionManager sharedManager].deviceIdentifier;
        [[ConnectionManager sharedManager] registerDeviceForNotification:deviceId success:^
        {
            [ConnectionManager sharedManager].userObject.deviceRegistered = YES;
            [[AppManager sharedManager] saveUserData:[ConnectionManager sharedManager].userObject];
        }
        failure:^(NSError *error)
        {
        }];
    }
}

// Application fail to register for notification
- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error
{
    if ( error.code == 3010 )
    {
        NSLog(@"Push notifications are not supported in the iOS Simulator.");
    }
    else
    {
        // Show some alert or otherwise handle the failure to register.
        NSLog(@"application:didFailToRegisterForRemoteNotificationsWithError: %@", error);
	}
}

// Application receive remote notification
- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    //handle tap on notification when app running
    if(application.applicationState == UIApplicationStateInactive){
        //app is transitioning from background to foreground (user taps notification), do what you need when user taps here
    [PushManager handleNotification:userInfo isAppRunning:YES];
    }
    
}

#pragma mark -
#pragma mark Facebook
// Open external app for facebook
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    // Facebook SDK * login flow *
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                        openURL:url
                                                        sourceApplication:sourceApplication
                                                        annotation:annotation
            ];
}

#pragma mark -
#pragma mark Delegate static functions
// Return shared delegate.
+ (AppDelegate*)sharedDelegate
{
    return (AppDelegate *)[[UIApplication sharedApplication] delegate];
}

@end
