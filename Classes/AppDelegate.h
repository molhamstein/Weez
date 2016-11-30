//
//  AppDelegate.h
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>
{
    
}

@property (strong, nonatomic) UIWindow *window;

+ (AppDelegate*)sharedDelegate;
- (void)changeRemoteNotification;

@end

