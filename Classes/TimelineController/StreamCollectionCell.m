//
//  StreamCollectionCell.m
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "StreamCollectionCell.h"
#import "UIImageView+WebCache.h"
#import "AppManager.h"

@implementation StreamCollectionCell

@synthesize thumbnailImageView;
@synthesize selectedView;
@synthesize redImageView;

#pragma mark -
#pragma mark Cell main functions
// Set content for stream cell
- (void)populateCellWithContent:(NSString*)image withSelected:(BOOL)isBlinkSelected
{
    thumbnailImageView.contentMode = UIViewContentModeScaleAspectFill;
    // set icon
    [thumbnailImageView sd_setImageWithURL:[NSURL URLWithString:image] placeholderImage:nil
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
    {
    }];
    // selected view
    [selectedView setHidden:YES];
    blinkingSelected = isBlinkSelected;
    if (isBlinkSelected)
    {
        [selectedView setHidden:NO];
        selectedView.alpha = 0.0;
        [selectedView setHidden:NO];
        [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^
        {
            selectedView.alpha = 1.0;
        }
        completion:^(BOOL finished)
        {
        }];
        [self animateSelected];
    }else{
        [self.redImageView.layer removeAllAnimations];
    }
    
    
    // flip direction
    // EN case
    int transform = 1;
    // AR case
    if ([[AppManager sharedManager] appLanguage] == kAppLanguageAR)
        transform = -1;
    [thumbnailImageView setTransform:CGAffineTransformMakeScale(transform, 1)];
}

-(void)animateSelected{
    [self.redImageView.layer removeAllAnimations];
    [UIView animateKeyframesWithDuration:1.0
                                   delay:0.0
                                 options:UIViewKeyframeAnimationOptionCalculationModeLinear|UIViewKeyframeAnimationOptionRepeat
                              animations:^{
                                  [UIView addKeyframeWithRelativeStartTime:0.0 relativeDuration:0.5 animations:^{
                                      self.redImageView.alpha = 1.f;
                                  }];
                                  [UIView addKeyframeWithRelativeStartTime:0.5 relativeDuration:0.5 animations:^{
                                      self.redImageView.alpha = 0.f;
                                  }];
                              } completion:^(BOOL finished)
     {
         if(!blinkingSelected)
             [self.redImageView.layer removeAllAnimations];
     }];
}

@end
