//
//  IntroCollectionCell.m
//  Weez
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import "IntroCollectionCell.h"
#import "AppManager.h"

@implementation IntroCollectionCell

@synthesize introImage;
@synthesize introTitle;
@synthesize introDescription;

#pragma mark -
#pragma mark Cell main functions
// Set content
- (void)populateCellWithContent:(NSString*)imageName withTitle:(NSString*)title withDescription:(NSString*)description
{
    introTitle.font = [[AppManager sharedManager] getFontType:kAppFontTitle];
    introDescription.font = [[AppManager sharedManager] getFontType:kAppFontSubtitle];
    // set cell data
    introImage.image = [UIImage imageNamed:imageName];
    introTitle.text = title;
    introDescription.text = description;
    // flip direction
    // EN case
    int transform = 1;
    // AR case
    if ([AppManager sharedManager].appLanguage == kAppLanguageAR)
        transform = -1;
    [self setTransform:CGAffineTransformMakeScale(transform, 1)];
}

@end
