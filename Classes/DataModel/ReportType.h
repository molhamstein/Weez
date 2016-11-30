//
//  ReportType.h
//  Weez
//
//  Created by Molham on 11/6/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface ReportType : NSObject <NSCoding>
{
    int type;
    NSString *msg;
}

@property (nonatomic) int type;
@property (nonatomic,retain) NSString *msg;

- (void)fillWithJSON:(NSDictionary*)jsonObject;

@end
