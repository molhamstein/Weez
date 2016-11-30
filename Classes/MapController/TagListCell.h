//
//  LocationListCell.h
//  Weez
//
//  Created by Hani Abu Shaer on 5/16/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "Tag.h"

@interface TagListCell : UITableViewCell
{
    UIImageView *tagImageView;
    UILabel *tagLabel;
    UILabel *mediaCountLabel;
}

@property(nonatomic, retain) IBOutlet UIImageView *tagImageView;
@property(nonatomic, retain) IBOutlet UILabel *tagLabel;
@property(nonatomic, retain) IBOutlet UILabel *mediaCountLabel;

- (void)populateCellWithContent:(Tag*)tagObject;

@end