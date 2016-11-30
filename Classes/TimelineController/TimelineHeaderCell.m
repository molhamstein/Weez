//
//  TimelineHeaderCellTableViewCell.m
//  Weez
//
//  Created by Dania on 11/21/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "TimelineHeaderCell.h"
#import "AppManager.h"

@implementation TimelineHeaderCell
@synthesize titleLabel;
-(void) setTitle:(NSString*)title
{
    titleLabel.text = title;
    titleLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellTitle];
}
@end
