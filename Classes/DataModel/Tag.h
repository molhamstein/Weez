//
//  ChatMessage.h
//  Weez
//
//  Created by Molham on 8/2/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "User.h"
#import "Media.h"

@interface Tag : NSObject
{
    NSString *objectId;
    NSString *display;
    NSString *thumb;
    long mediaCount;
}

@property (nonatomic,retain) NSString *objectId;
@property (nonatomic,retain) NSString *display;
@property (nonatomic,retain) NSString *thumb;
@property long mediaCount;

- (void)fillWithJSON:(NSDictionary*)jsonObject;
@end
