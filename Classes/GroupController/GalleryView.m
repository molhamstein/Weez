//
//  BalancedGallery.m
//  Weez
//
//  Created by Dania on 10/25/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "GalleryView.h"
#import "UIImageView+WebCache.h"

#define NUMBER_OF_IMAGES 24
#define HORIZENTAL_SPACING 0
#define VERTICAL_SPACING 0
#define GALLERY_MARGIN 0


@implementation GalleryView

@synthesize galleryCollectionView;


- (void)setDelegate:(id<GalleryViewDelegate>)selectionDelegate
{
    delegate = selectionDelegate;
}

-(void) setData:(NSMutableArray*) array
{
    data = array;
}

-(void) setGalleryType:(GALLERY_TYPE)type {
    self->galleryType = type;
}

-(void) reloadData
{
    [galleryCollectionView reloadData];
}
-(void)awakeFromNib
{
    NHBalancedFlowLayout *layout = [[NHBalancedFlowLayout alloc] init];
    layout.minimumLineSpacing = HORIZENTAL_SPACING;
    layout.minimumInteritemSpacing = VERTICAL_SPACING;
    layout.sectionInset = UIEdgeInsetsMake(GALLERY_MARGIN, GALLERY_MARGIN, GALLERY_MARGIN, GALLERY_MARGIN);
    self.galleryCollectionView.collectionViewLayout = layout;
}

#pragma mark - UICollectionViewFlowLayoutDelegate

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(NHBalancedFlowLayout *)collectionViewLayout preferredSizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSURL *url = [self getCurrentImageUrl:indexPath.item];
    if ([self imageInCache:url])
    {
        return [self imageSize:url];
    }
    else
    {
        return CGSizeMake(150,150);
    }
}

#pragma mark - image util
-(BOOL)imageInCache:(NSURL*)url
{
    if(url == NULL)
        return NO;
    
    SDWebImageManager* imgMgr = [SDWebImageManager sharedManager];
    return [imgMgr cachedImageExistsForURL:url];
}

-(CGSize)imageSize:(NSURL*)url
{
    SDWebImageManager* imgMgr = [SDWebImageManager sharedManager];
        NSString* imageKey =[imgMgr cacheKeyForURL:url];
        SDImageCache* myCache = [SDImageCache sharedImageCache];
        UIImage* profileImage = [myCache imageFromDiskCacheForKey:imageKey];
        return [profileImage size];
}

-(NSURL *) getCurrentImageUrl : (NSInteger) index
{
    NSURL *url;
    switch (galleryType) {
        case GALLERY_USERS:
        {
            if([data count] > 0)
            {
                Friend *friendObj = [data objectAtIndex:index];
                url = [NSURL URLWithString:friendObj.profilePic];
            }
        }
            break;
        case GALLERY_LOACTIONS:
        {
            if([data count] > 0)
            {
                Location *locationObj = [data objectAtIndex:index];
                url = [NSURL URLWithString:locationObj.image];
            }
        }
            break;
        default:
            break;
    }
    return url;
}

#pragma mark - UICollectionView data source

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section;
{
    return [data count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath;
{
    static NSString *CellIdentifier1 = @"galleryCell";
    
    GalleryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier1 forIndexPath:indexPath];
    [cell setDelegate:self];
    
    switch (self->galleryType) {
        case GALLERY_USERS:
        {
            Friend *friendObj = [data objectAtIndex:indexPath.item];
            [cell populateCellWithFriend:friendObj];
            break;
        }
        case GALLERY_LOACTIONS:
        {
            Location *location = [data objectAtIndex:indexPath.row];
            [cell populateCellWithLocation:location];
            break;
        }
        case GALLERY_TAGS:
        {
            Tag *tag = [data objectAtIndex:indexPath.row];
            [cell populateCellWithTag:tag];
            break;
        }
        default:
            break;
    }
    
    return cell;
   
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    switch (self->galleryType) {
        case GALLERY_USERS:
        {
           Friend *friendObj = [data objectAtIndex:indexPath.item];
            if(delegate != NULL)
              [delegate onFriendCellSelected:friendObj];
        }
        break;
        case GALLERY_LOACTIONS:
        {
            Location *locationObj = [data objectAtIndex:indexPath.item];
            if(delegate != NULL)
                [delegate onLocationCellSelected:locationObj];
        }
        break;
        case GALLERY_TAGS:
        {
            Tag *tagObj = [data objectAtIndex:indexPath.item];
            if(delegate != NULL)
                [delegate onTagCellSelected:tagObj];
        }
            break;
        default:
            break;
    }
    
}
#pragma mark - GalleryCellDelegate
-(void) onImageLoadingCompleted
{
    [galleryCollectionView.collectionViewLayout invalidateLayout];
}
@end
