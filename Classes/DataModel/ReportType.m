//
//  ReportType.h
//  Weez
//
//  Created by Molham on 11/6/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "ReportType.h"
#import "ConnectionManager.h"

@implementation ReportType

@synthesize type;
@synthesize msg;

#pragma mark -
#pragma mark Friend Object
// Init with Friend decoder
- (id)initWithCoder:(NSCoder*)decoder{
    self = [super init];
    if (!self){
        return nil;
    }
    msg = [decoder decodeObjectForKey:@"message"];
    type = [decoder decodeIntForKey:@"type"];
    return self;
}

// Encode with Friend encoder
- (void)encodeWithCoder:(NSCoder*)encoder{
    [encoder encodeInt:type forKey:@"type"];
    [encoder encodeObject:msg forKey:@"message"];
}

// Fill Friend object form json object
- (void)fillWithJSON:(NSDictionary*)jsonObject{
    type = [[jsonObject objectForKey:@"type"] intValue];
    msg = (NSString*)[jsonObject objectForKey:@"message"];
}

@end
