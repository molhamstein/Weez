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
    UIImageView *redImageView;
    BOOL blinkingSelected;
}

@property(nonatomic, retain) IBOutlet UIImageView *thumbnailImageView;
@property(nonatomic, retain) IBOutlet UIView *selectedView;
@property(nonatomic, retain) IBOutlet UIImageView *redImageView;

- (void)populateCellWithContent:(NSString*)image withSelected:(BOOL)isSelected;

@end