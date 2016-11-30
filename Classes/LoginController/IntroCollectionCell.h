//
//  IntroCollectionCell.h
//  Weez
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface IntroCollectionCell : UICollectionViewCell
{
    UIImageView *introImage;
    UILabel *introTitle;
    UILabel *introDescription;
}

@property(nonatomic, retain) IBOutlet UIImageView *introImage;
@property(nonatomic, retain) IBOutlet UILabel *introTitle;
@property(nonatomic, retain) IBOutlet UILabel *introDescription;

- (void)populateCellWithContent:(NSString*)imageName withTitle:(NSString*)title withDescription:(NSString*)description;

@end
