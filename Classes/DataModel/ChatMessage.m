//
//  ChatMessage.m
//  Weez
//
//  Created by Molham on 8/2/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "ChatMessage.h"
#import "ConnectionManager.h"

@implementation ChatMessage

@synthesize objectId;
@synthesize sender;
@synthesize date;
@synthesize text;
@synthesize media;
@synthesize location;
@synthesize parentMessage;
@synthesize timelineMsgUser;
@synthesize timelineMsgEvent;
@synthesize timelineMsgLocation;
@synthesize thumb;
@synthesize groupId;

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
    sender = [decoder decodeObjectForKey:@"sender"];
    date = [decoder decodeObjectForKey:@"date"];
    text = [decoder decodeObjectForKey:@"text"];
    media = [decoder decodeObjectForKey:@"media"];
    location = [decoder decodeObjectForKey:@"location"];
    parentMessage = [decoder decodeObjectForKey:@"parentMessage"];
    timelineMsgUser = [decoder decodeObjectForKey:@"timelineMsgUser"];
    timelineMsgLocation = [decoder decodeObjectForKey:@"timelineMsgLocation"];
    timelineMsgEvent = [decoder decodeObjectForKey:@"timelineMsgEvent"];
    thumb = [decoder decodeObjectForKey:@"largeWideThumb"];
    groupId = [decoder decodeObjectForKey:@"groupId"];
    return self;
}

// Encode with User encoder
- (void)encodeWithCoder:(NSCoder*)encoder
{
    [encoder encodeObject:objectId forKey:@"objectId"];
    [encoder encodeObject:sender forKey:@"sender"];
    [encoder encodeObject:date forKey:@"date"];
    [encoder encodeObject:text forKey:@"text"];
    [encoder encodeObject:media forKey:@"media"];
    [encoder encodeObject:location forKey:@"location"];
    [encoder encodeObject:parentMessage forKey:@"parentMessage"];
    [encoder encodeObject:timelineMsgUser forKey:@"timelineMsgUser"];
    [encoder encodeObject:timelineMsgLocation forKey:@"timelineMsgLocation"];
    [encoder encodeObject:timelineMsgEvent forKey:@"timelineMsgEvent"];
    [encoder encodeObject:thumb forKey:@"largeWideThumb"];
    [encoder encodeObject:groupId forKey:@"groupId"];
}

// Fill User object form json object
- (void)fillWithJSON:(NSDictionary*)jsonObject
{
    objectId = (NSString*)[jsonObject objectForKey:@"id"];
    
    // sender
    sender = [[User alloc] init];
    sender.objectId = @"";
    if ([jsonObject objectForKey:@"sender"] != nil)
        [sender fillWithJSON:[jsonObject objectForKey:@"sender"]];
    
    // date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:OBJECT_UPDATE_DATE_FORMAT];
    dateFormatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:DATE_SERVER_DATES_LOCALE];
    NSString *dateStr = [jsonObject objectForKey:@"date"];
    date = [dateFormatter dateFromString:dateStr];
    if(!date){
        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
        [[ConnectionManager sharedManager] submitLog:[NSString stringWithFormat:@"msg date parsing issue with locale:%@ date:%@",locale.description, [jsonObject objectForKey:@"date"] ] success:^{}];
        dateFormatter.locale = locale;
        date = [dateFormatter dateFromString:dateStr];
    }
    // convert the date from GMT to local time
    NSTimeInterval timeZoneSeconds = [[NSTimeZone localTimeZone] secondsFromGMT];
    NSDate *tempDateHolder = [date dateByAddingTimeInterval:timeZoneSeconds];
    if(!tempDateHolder)
        [[ConnectionManager sharedManager] submitLog:[NSString stringWithFormat:@"msg date locslizing issue with sec:%f date:%@",timeZoneSeconds, date ] success:^{}];
    date = tempDateHolder;
    
    if([jsonObject objectForKey:@"groupId"])
        groupId = [jsonObject objectForKey:@"groupId"];
    
    // text
    if ([jsonObject objectForKey:@"text"] != nil)
        text = [jsonObject objectForKey:@"text"];
    
    if([jsonObject objectForKey:@"largeWideThumb"])
        thumb = [jsonObject objectForKey:@"largeWideThumb"];
    
    // media
    media = [[Media alloc] init];
    media.objectId = @"";
    if ([jsonObject objectForKey:@"media"] != [NSNull null])
        [media fillWithJSON:[jsonObject objectForKey:@"media"]];
    
    // location
    location = nil;
    if ([jsonObject objectForKey:@"locationId"] && [jsonObject objectForKey:@"locationId"] != [NSNull null]){
        location = [[Location alloc] init];
        [location fillWithJSON:[jsonObject objectForKey:@"locationId"]];
    }
    
    // parent message
    parentMessage = nil;
    if ([jsonObject objectForKey:@"parent"] && [jsonObject objectForKey:@"parent"] != [NSNull null]){
        parentMessage = [[ChatMessage alloc] init];
        [parentMessage fillWithJSON:[jsonObject objectForKey:@"parent"]];
    }
    
    if ([jsonObject objectForKey:@"timeline"] && [jsonObject objectForKey:@"timeline"] != [NSNull null]){
        NSDictionary* jsonTimelineObject = [jsonObject objectForKey:@"timeline"];
        // timelineMsgUser message
        timelineMsgUser = nil;
        if ([jsonTimelineObject objectForKey:@"user"] && [jsonTimelineObject objectForKey:@"user"] != [NSNull null]){
            timelineMsgUser = [[Friend alloc] init];
            [timelineMsgUser fillWithJSON:[jsonTimelineObject objectForKey:@"user"]];
        }
        
        // timelineMsgLocation message
        timelineMsgLocation = nil;
        if ([jsonTimelineObject objectForKey:@"location"] && [jsonTimelineObject objectForKey:@"location"] != [NSNull null]){
            timelineMsgLocation = [[Location alloc] init];
            [timelineMsgLocation fillWithJSON:[jsonTimelineObject objectForKey:@"location"]];
        }
        
        thumb = [jsonTimelineObject objectForKey:@"largeWideThumb"];
        
        // timelineMsgEvent message
        timelineMsgEvent = nil;
        if ([jsonTimelineObject objectForKey:@"event"] && [jsonTimelineObject objectForKey:@"event"] != [NSNull null]){
            timelineMsgEvent = [[Event alloc] init];
            [timelineMsgEvent fillWithJSON:[jsonTimelineObject objectForKey:@"event"]];
        }
    }
    
    
}

- (BOOL) isMediaMessage{
    if([media.objectId length] != 0 || location || [self isTimelineMsg])
        return YES;
    return NO;
}

- (BOOL) isTimelineMsg{
    return timelineMsgEvent || timelineMsgUser || timelineMsgLocation;
}

- (NSString*) getMessageDescription{
    NSString *desc =nil;
    if([self isTimelineMsg]){
        if(timelineMsgUser)
            return timelineMsgUser.username;
        else if(timelineMsgLocation)
            return timelineMsgLocation.name;
        else if(timelineMsgEvent)
            return timelineMsgEvent.name;
    }
    return desc;
}

@end
