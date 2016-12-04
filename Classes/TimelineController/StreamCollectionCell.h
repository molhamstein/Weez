//
//  StreamCollectionCell.h
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StreamCollectionCell : UICollectionViewCell
{
    UIImageView *thumbnailImageView;
    UIView *selectedView;
    UIView *topBarView;
    UIImageView *redImageView;
    BOOL blinkingSelected;
    NSLayoutConstraint *thumbnailImageViewHieght;
}

@property(nonatomic, retain) IBOutlet UIImageView *thumbnailImageView;
@property(nonatomic, retain) IBOutlet UIView *selectedView;
@property(nonatomic, retain) IBOutlet UIView *topBarView;
@property(nonatomic, retain) IBOutlet UIImageView *redImageView;
@property(nonatomic, retain) IBOutlet NSLayoutConstraint *thumbnailImageViewHieght;
- (void)populateCellWithContent:(NSString*)image withSelected:(BOOL)isBlinkSelected withViewed:(BOOL)isViewed;


@end