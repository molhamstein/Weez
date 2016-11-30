//
//  TimelinesCollectionHeaderViewCollectionReusableView.h
//  Weez
//
//  Created by Dania on 11/15/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TimelinesCollectionReusableView : UICollectionReusableView
{
    UILabel *titleLabel;
}
@property (nonatomic, retain) IBOutlet UILabel *titleLabel;
-(void) setTitle:(NSString*)title;
@end
