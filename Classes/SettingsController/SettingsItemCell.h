//
//  SettiingsItemCell.h
//  Weez
//
//  Created by Molham on 6/28/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SettingsItemCell : UITableViewCell
{
    UILabel *titleLable;
    UILabel *countLabel;
    UIImageView *decorationArrow;
    UISwitch *switchView;
    UIView *separatorView;
}

@property (nonatomic, retain) IBOutlet UILabel *titleLable;
@property (nonatomic, retain) IBOutlet UILabel *countLabel;
@property (nonatomic, retain) IBOutlet UIImageView *decorationArrow;
@property (nonatomic, retain) IBOutlet UISwitch *switchView;
@property (nonatomic, retain) IBOutlet UIView *separatorView;

- (void)populateCellWithContent:(NSString*)title count:(NSString*)count enableCount:(BOOL)enablCount decorationArrow:(BOOL)enablDecorationArrow;
- (void)populateCellWithSwitch:(NSString*)title enableSwitch:(BOOL)enablSwitch;

@end
