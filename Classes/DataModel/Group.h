//
//  Group.h
//  Weez
//
//  Created by Molham on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Friend.h"

@interface Group : NSObject <NSCoding>
{
    NSString *objectId;
    NSString *name;
    NSString *description;
    NSString *image;
    NSMutableArray *members;
    NSMutableArray *admins;
    NSMutableArray *messages;
    NSDate *createdAt;
    BOOL isGroup;
}

@property (nonatomic, retain) NSString *objectId;
@property (nonatomic, retain) NSString *name;
@property (nonatomic, retain) NSString *description;
@property (nonatomic, retain) NSString *image;
@property (nonatomic, retain) NSMutableArray *members;
@property (nonatomic, retain) NSMutableArray *admins;
@property (nonatomic, retain) NSMutableArray *messages;
@property (nonatomic, retain) NSDate *createdAt;
@property (nonatomic) BOOL isGroup;

- (void)fillWithJSON:(NSDictionary*)jsonObject;
- (Friend *) getGroupAdmin;


@end