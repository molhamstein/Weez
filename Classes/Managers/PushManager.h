//
//  PushManager.h
//  Weez
//
//  Created by Dania on 11/6/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AppDelegate.h"
#import "AppNotification.h"
#import <UIKit/UIKit.h>

@interface PushManager : NSObject

+ (void) handleNotification : (NSDictionary *)userInfo isAppRunning:(BOOL) appIsRunning;
+ (void) showNotificationsList :(AppNotification*) notification;
+(void) popNotificationListToTheTop:(AppNotification*) notification;
@end
