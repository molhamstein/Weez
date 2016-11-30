//
//  BalancedGallery.h
//  Weez
//
//  Created by Dania on 10/25/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GalleryCell.h"
#import "NHLinearPartition.h"
#import "NHBalancedFlowLayout.h"
#import "Friend.h"
#import "Tag.h"
#import "Location.h"

@protocol GalleryViewDelegate
-(void) onFriendCellSelected : (Friend*) selectedFriend;
-(void) onLocationCellSelected : (Location*) selectedLocation;
-(void) onTagCellSelected : (Tag*) selectedTag;
@end

@interface GalleryView : UIView <NHBalancedFlowLayoutDelegate, UICollectionViewDataSource, GalleryCellDelegate>
{
    //data
    GALLERY_TYPE galleryType;
    id<GalleryViewDelegate> delegate;
    NSMutableArray *data;
    //views
    UICollectionView *galleryCollectionView;
}

-(void) setGalleryType:(GALLERY_TYPE) type;
-(void) setDelegate:(id<GalleryViewDelegate>)cellDelegate;
-(void) setData:(NSMutableArray*) array;
-(void) reloadData;

@property (nonatomic, strong) IBOutlet UICollectionView *galleryCollectionView;

@end
