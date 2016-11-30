//
//  Group.h
//  Weez
//
//  Created by Molham on 6/12/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "Group.h"
#import "Friend.h"
#import "ChatMessage.h"

@implementation Group

@synthesize objectId;
@synthesize name;
@synthesize description;
@synthesize image;
@synthesize members;
@synthesize admins;
@synthesize messages;
@synthesize createdAt;
@synthesize isGroup;

#pragma mark -
#pragma mark Group Object
// Init with Group decoder
- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super init];
    if (!self)
    {
        return nil;
    }
    // decode Group values
    // objectId - name - image - members - admins
    objectId = [decoder decodeObjectForKey:@"objectId"];
    name = [decoder decodeObjectForKey:@"name"];
    description = [decoder decodeObjectForKey:@"description"];
    image = [decoder decodeObjectForKey:@"image"];
    members = [decoder decodeObjectForKey:@"members"];
    admins = [decoder decodeObjectForKey:@"admins"];
    messages = [decoder decodeObjectForKey:@"messages"];
    createdAt = [decoder decodeObjectForKey:@"createdAt"];
    isGroup = [decoder decodeBoolForKey:@"isGroup"];
    return self;
}

// Encode with Group encoder
- (void)encodeWithCoder:(NSCoder*)encoder
{
    // encode Group values
    // objectId - name - image - members - admins
    [encoder encodeObject:objectId forKey:@"objectId"];
    [encoder encodeObject:name forKey:@"name"];
    [encoder encodeObject:description forKey:@"description"];
    [encoder encodeObject:image forKey:@"image"];
    [encoder encodeObject:members forKey:@"members"];
    [encoder encodeObject:admins forKey:@"admins"];
    [encoder encodeObject:messages forKey:@"messages"];
    [encoder encodeObject:createdAt forKey:@"createdAt"];
    [encoder encodeBool:isGroup forKey:@"isGroup"];
}

// Fill Group object form json object
- (void)fillWithJSON:(NSDictionary*)jsonObject
{
    // Group keys
    // id - name - image - members - admins
    objectId = (NSString*)[jsonObject objectForKey:@"id"];
    name = (NSString*)[jsonObject objectForKey:@"name"];
    description = (NSString*)[jsonObject objectForKey:@"description"];
    image = (NSString*)[jsonObject objectForKey:@"image"];
    members = [[NSMutableArray alloc] init];
    if ([jsonObject objectForKey:@"members"] != nil)
    {
        NSMutableArray *tempList = (NSMutableArray*)[jsonObject objectForKey:@"members"];
        // fill in the members list
        for (NSMutableDictionary *obj in tempList)
        {
            Friend *friend = [[Friend alloc] init];
            [friend fillWithJSON:obj];
            [members addObject:friend];
        }
    }
    
    // messages
    messages = [[NSMutableArray alloc] init];
    if ([jsonObject objectForKey:@"messages"] != nil)
    {
        NSMutableArray *tempList = (NSMutableArray*)[jsonObject objectForKey:@"messages"];
        // fill in the members list
        for (NSMutableDictionary *obj in tempList)
        {
            ChatMessage *msg = [[ChatMessage alloc] init];
            [msg fillWithJSON:obj];
            [messages addObject:msg];
        }
    }
    
    //admins
    admins = [[NSMutableArray alloc] init];
    if ([jsonObject objectForKey:@"admins"] != nil)
        admins = (NSMutableArray*)[jsonObject objectForKey:@"admins"];
    
    // creation date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:OBJECT_UPDATE_DATE_FORMAT];
    NSString *dateStr = [jsonObject objectForKey:@"createdAt"];
    createdAt = [dateFormatter dateFromString:dateStr];
    
    isGroup = [[jsonObject objectForKey:@"isGroup"] boolValue];
}

- (Friend*) getGroupAdmin{
    for(int i = 0 ; i < [members count] ; i++){
        Friend *member = [members objectAtIndex:i];
        NSString *adminId = [admins firstObject];
        if([member.objectId isEqualToString:adminId])
            return member;
    }
    return [members firstObject];
}


//- (BOOL) isGroup{
//    if([members count] > 2)
//        return YES;
//    return NO;
//}

@end