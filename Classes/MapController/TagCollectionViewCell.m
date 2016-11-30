//
//  MediaCollectionViewCell.m
//  Weez
//
//  Created by Molham on 6/27/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "TagCollectionViewCell.h"
#import "UIImageView+WebCache.h"
#import "ConnectionManager.h"
#import "AppManager.h"


@implementation TagCollectionViewCell


#pragma mark -
#pragma mark Cell main functions
// Populate cell and set content
- (void)populateCellWithContent:(NSString*)tagText{
    
    _vContainer.layer.masksToBounds = YES;
    _vContainer.layer.cornerRadius = 5;
    
    // username, duration and last updated date
    _lblTag.font = [[AppManager sharedManager] getFontType:kAppFontCellNumber];
    _lblTag.text = tagText;
    
    // flip direction
    // EN case
    int transform = 1;
    // AR case
    if ([AppManager sharedManager].appLanguage == kAppLanguageAR)
        transform = -1;
    [self setTransform:CGAffineTransformMakeScale(transform, 1)];
}


- (BOOL)clipsToBounds{
    [super clipsToBounds];
    return YES;
}

@end
