//
//  WeezCollectionController.h
//  Weez
//
//  Created by Dania on 11/13/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//
#import "WeezBaseViewController.h"
#import "Media.h"
#import "Friend.h"
#import "Timeline.h"

typedef enum{
    COLLECTION_TYPE_TIMELINES = 0,
    COLLECTION_TYPE_LOACTIONS = 1,
} COLLECTION_TYPE;

@interface WeezCollectionController : WeezBaseViewController <UICollectionViewDataSource, UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
{
    //views
    UICollectionView * mainCollectionView;
    UIView *noResultView;
    UILabel *noResultLabel;
    //data
    NSMutableArray *data;
    COLLECTION_TYPE type;
    
    //selected data
    Timeline *selectedMedia;
    Location *selectedLocation;
    Event *selectedEvent;
}

@property (nonatomic, retain) IBOutlet UICollectionView * mainCollectionView;
@property (nonatomic, strong) IBOutlet UIView *noResultView;
@property (nonatomic, strong) IBOutlet UILabel *noResultLabel;

-(void) loadViewWithData:(NSMutableArray*)array type:(COLLECTION_TYPE)type;

@end
