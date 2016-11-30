//
//  MediaCollectionViewCell.h
//  Weez
//
//  Created by Molham on 6/27/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Media.h"
#import "Timeline.h"


@interface TagCollectionViewCell : UICollectionViewCell
{
}
    @property (nonatomic, retain) IBOutlet UIView *vContainer;
    @property (nonatomic, retain) IBOutlet UILabel *lblTag;
    @property (nonatomic, retain) IBOutlet UIButton *deleteButton;

- (void)populateCellWithContent:(NSString*)tagText;

@end
