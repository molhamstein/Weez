//
//  SettiingsItemCell.m
//  Weez
//
//  Created by Molham on 6/28/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "SettingsItemCell.h"
#import "AppManager.h"

@implementation SettingsItemCell

@synthesize titleLable;
@synthesize countLabel;
@synthesize decorationArrow;
@synthesize switchView;
@synthesize separatorView;

- (void)populateCellWithContent:(NSString*)title count:(NSString*)count enableCount:(BOOL)enablCount decorationArrow:(BOOL)enablDecorationArrow
{
    titleLable.font = [[AppManager sharedManager] getFontType:kAppFontDescriptionBold];
    countLabel.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    
    titleLable.text = title;
    countLabel.text = count;
    
    if(enablDecorationArrow)
        decorationArrow.hidden = NO;
    else
        decorationArrow.hidden = YES;
    
    if(enablCount)
        countLabel.hidden = NO;
    else
        countLabel.hidden = YES;
    
    switchView.hidden = YES;
    
    // hide separateor
    separatorView.hidden = YES;
    // flip direction
    //[[AppManager sharedManager] flipViewDirection:self.contentView];
    // EN case
    int transform = 1;
        titleLable.textAlignment = NSTextAlignmentLeft;
    // AR case
    if ([[AppManager sharedManager] appLanguage] == kAppLanguageAR)
    {
        transform = -1;
        titleLable.textAlignment = NSTextAlignmentRight;
    }
    [titleLable setTransform:CGAffineTransformMakeScale(transform, 1)];
    [countLabel setTransform:CGAffineTransformMakeScale(transform, 1)];
    [self.contentView setTransform:CGAffineTransformMakeScale(transform, 1)];
}

- (void)populateCellWithSwitch:(NSString*)title enableSwitch:(BOOL)enablSwitch{
    titleLable.font = [[AppManager sharedManager] getFontType:kAppFontDescriptionBold];
    
    titleLable.text = title;
    
    decorationArrow.hidden = YES;
    countLabel.hidden = YES;
    
    [switchView setOn:enablSwitch animated:YES];
    // hide separateor
    separatorView.hidden = YES;
    // EN case
    int transform = 1;
    titleLable.textAlignment = NSTextAlignmentLeft;
    // AR case
    if ([[AppManager sharedManager] appLanguage] == kAppLanguageAR){
        transform = -1;
        titleLable.textAlignment = NSTextAlignmentRight;
    }
    [titleLable setTransform:CGAffineTransformMakeScale(transform, 1)];
    [self.contentView setTransform:CGAffineTransformMakeScale(transform, 1)];
}
@end
