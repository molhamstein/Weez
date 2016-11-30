//
//  ChatMessage.m
//  Weez
//
//  Created by Molham on 8/24/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "AppNotification.h"
#import "AppManager.h"

@implementation AppNotification

@synthesize objectId;
@synthesize actor;
@synthesize date;
@synthesize type;
@synthesize group;
@synthesize user;
@synthesize timeline;
@synthesize event;

#pragma mark -
#pragma mark User Object
// Init with decoder
- (id)initWithCoder:(NSCoder*)decoder
{
    self = [super init];
    if (!self){
        return nil;
    }
    objectId = [decoder decodeObjectForKey:@"objectId"];
    actor = [decoder decodeObjectForKey:@"actor"];
    date = [decoder decodeObjectForKey:@"date"];
    type = [decoder decodeIntForKey:@"type"];
    group = [decoder decodeObjectForKey:@"media"];
    event = [decoder decodeObjectForKey:@"event"];
    return self;
}

// Encode with encoder
- (void)encodeWithCoder:(NSCoder*)encoder
{
    [encoder encodeObject:objectId forKey:@"objectId"];
    [encoder encodeObject:actor forKey:@"actor"];
    [encoder encodeInt:type forKey:@"type"];
    [encoder encodeObject:date forKey:@"date"];
    [encoder encodeObject:group forKey:@"media"];
    [encoder encodeObject:event forKey:@"event"];
}

// Fill object form json object
- (void)fillWithJSON:(NSDictionary*)jsonObject
{
    objectId = (NSString*)[jsonObject objectForKey:@"id"];
    
    // sender
    actor = [[User alloc] init];
    actor.objectId = @"";
    if ([jsonObject objectForKey:@"actor"] != nil)
        [actor fillWithJSON:[jsonObject objectForKey:@"actor"]];
    
    // date
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:OBJECT_UPDATE_DATE_FORMAT];
    NSString *dateStr = [jsonObject objectForKey:@"createdAt"];
    date = [dateFormatter dateFromString:dateStr];
    // convert the date from GMT to local time
    NSTimeInterval timeZoneSeconds = [[NSTimeZone localTimeZone] secondsFromGMT];
    date = [date dateByAddingTimeInterval:timeZoneSeconds];
    
    type = [[jsonObject objectForKey:@"type"] intValue];
    
    // fill the corresponding object according to the notification Type
    switch (type) {
        case kAppNotificationTypeSomeoneStartedFollowingYou:
            user = [[User alloc] init];
            [user fillWithJSON:[jsonObject objectForKey:@"object"]];
            break;
        case kAppNotificationTypeNewMessageInGroup:
        case kAppNotificationTypeSomeoneAddedYouToGroup:
            group = [[Group alloc] init];
            [group fillWithJSON:[jsonObject objectForKey:@"object"]];
            break;
        case kAppNotificationTypeNewMessageInChat:
        case kAppNotificationTypeSomeoneMentionedYou:
            timeline = [[Timeline alloc] init];
            [timeline fillWithJSON:[jsonObject objectForKey:@"object"]];
            break;
        case kAppNotificationTypeSomeoneMentionedYouInEvent:
            event = [[Event alloc] init];
            [event fillWithJSON:[jsonObject objectForKey:@"object"]];
            break;
    }
}

// Get updated date string
- (NSString*)getCreatedDateString:(BOOL)isShort
{
    if (date == nil)
        return @"";
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    [formatter setDateFormat:TIMELINE_SHORT_DATE_FORMAT];
//    // check if today date
//    NSCalendar *cal = [NSCalendar currentCalendar];
//    NSDateComponents *components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
//    NSDate *today = [cal dateFromComponents:components];
//    components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:date];
//    NSDate *otherDate = [cal dateFromComponents:components];
//    // set time formater
//    if ([today isEqualToDate:otherDate])
//        [formatter setDateFormat:TIMELINE_DISPLAY_TIME_FORMAT];
//    return [formatter stringFromDate:date];
    
    // past date
    NSDate *currentDate = [NSDate date];
    //NSDate* localDateTime = [NSDate dateWithTimeInterval:[[NSTimeZone systemTimeZone] secondsFromGMT] sinceDate:date];
    NSTimeInterval difference = [currentDate timeIntervalSinceDate:date];
    return [[AppManager sharedManager] timeIntervalToStringWithInterval:difference];
}


@end
