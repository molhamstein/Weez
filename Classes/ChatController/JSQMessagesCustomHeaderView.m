//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//


#import "JSQMessagesCustomHeaderView.h"

#import "NSBundle+JSQMessages.h"


const CGFloat kJSQMessagesCustomHeaderViewHeight = 32.0f;


@interface JSQMessagesCustomHeaderView ()

@property (weak, nonatomic) IBOutlet UIButton *loadButton;

@end


@implementation JSQMessagesCustomHeaderView

#pragma mark - Class methods

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([JSQMessagesCustomHeaderView class])
                          bundle:[NSBundle bundleForClass:[JSQMessagesCustomHeaderView class]]];
}

+ (NSString *)headerReuseIdentifier
{
    return NSStringFromClass([JSQMessagesCustomHeaderView class]);
}

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];

    self.backgroundColor = [UIColor clearColor];

    
//    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
//    // show the date of creation for the group along with the creator name
//    [formatter setDateFormat:TIMELINE_SHORT_DATE_FORMAT];
//    // check if today date
//    //ChatMessage *firstMessage = [group.messages firstObject];
//    //Friend *groupAdmin = @"Admin Name";
//    
//    NSCalendar *cal = [NSCalendar currentCalendar];
//    NSDateComponents *components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
//    NSDate *today = [cal dateFromComponents:components];
//    components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:firstMessage.date];
//    NSDate *otherDate = [cal dateFromComponents:components];
//    // set time formater
//    if ([today isEqualToDate:otherDate])
//        [formatter setDateFormat:TIMELINE_DISPLAY_TIME_FORMAT];
//    NSString *dateString = [formatter stringFromDate:firstMessage.date];
//    NSString *fullText = [NSString stringWithFormat:[[AppManager sharedManager] getLocalizedString:@"CHAT_GROUP_CREATE_BY"], groupAdmin.username, dateString];
    
    [self.loadButton setTitle:@"" forState:UIControlStateNormal];//[NSBundle jsq_localizedStringForKey:@"load_earlier_messages"] forState:UIControlStateNormal];
    self.loadButton.titleLabel.font = [UIFont preferredFontForTextStyle:UIFontTextStyleCaption2];
}

- (void)dealloc
{
    _loadButton = nil;
    _delegate = nil;
}

#pragma mark - Reusable view

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    self.loadButton.backgroundColor = backgroundColor;
}

#pragma mark - Actions

- (IBAction)loadButtonPressed:(UIButton *)sender
{
    [self.delegate headerView:self didPressLoadButton:sender];
}

@end
