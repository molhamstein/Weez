//
//  ChatMessage.m
//  Weez
//
//  Created by Molham on 8/2/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "Tag.h"

@implementation Tag

@synthesize objectId;
@synthesize display;
@synthesize mediaCount;
@synthesize thumb;

#pragma mark -
#pragma mark User Object
// Init with message decoder
- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super init];
    if (!self){
        return nil;
    }
    objectId = [decoder decodeObjectForKey:@"objectId"];
    display = [decoder decodeObjectForKey:@"display"];
    thumb = [decoder decodeObjectForKey:@"thumb"];
    mediaCount = [decoder decodeIntForKey:@"mediaCount"];
    return self;
}

// Encode with User encoder
- (void)encodeWithCoder:(NSCoder*)encoder
{
    [encoder encodeObject:objectId forKey:@"objectId"];
    [encoder encodeObject:display forKey:@"display"];
    [encoder encodeObject:display forKey:@"thumb"];
    [encoder encodeInteger:mediaCount forKey:@"mediaCount"];
}

// Fill User object form json object
- (void)fillWithJSON:(NSDictionary*)jsonObject
{
    objectId = (NSString*)[jsonObject objectForKey:@"id"];
    display = (NSString*)[jsonObject objectForKey:@"display"];
    thumb = (NSString*)[jsonObject objectForKey:@"thumb"];
    mediaCount = [[jsonObject objectForKey:@"mediaCount"] intValue];
}

@end
