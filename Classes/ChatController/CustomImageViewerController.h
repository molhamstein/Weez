//
//  CustomImageViewerController.h
//  Weez
//
//  Created by Molham on 10/23/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "JTSImageViewController.h"
#import "Location.h"
#import "User.h"

@interface CustomImageViewerController : JTSImageViewController

// views
@property(nonatomic, retain) IBOutlet UIImageView *locationImageView;
@property(nonatomic, retain) IBOutlet UILabel *locationLabel;
@property(nonatomic, retain) IBOutlet UIButton *locationButton;
@property(nonatomic, retain) IBOutlet UIView *footerView;
@property(nonatomic, retain) IBOutlet UIImageView *senderImageView;
@property(nonatomic, retain) IBOutlet UILabel *senderNameLabel;

//data
@property(nonatomic, retain) Location *mediaLocation;
@property(nonatomic, retain) User *sender;
@property(nonatomic, retain) NSMutableArray *mediaArray;
@property(nonatomic) int currentMediIndex;

-(void)prepareControllerWithLocation:(Location*)location user:(User*)user mediaArray:(NSMutableArray*)mediArray currentMediaIndex:(int)index;
- (IBAction)locationAction:(id)sender;

@end
