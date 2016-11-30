//
//  WeezCollectionController.m
//  Weez
//
//  Created by Dania on 11/13/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "WeezCollectionController.h"
#import "TimelineController.h"
#import "TimelinesCollectionController.h"
#import "MediaCollectionViewCell.h"
#import "LocationCollectionViewCell.h"
#import "AppManager.h"

@implementation WeezCollectionController

@synthesize mainCollectionView;
@synthesize noResultView;
@synthesize noResultLabel;

#pragma mark -
#pragma mark - ViewController
// View did load
- (void)viewDidLoad
{
    [super viewDidLoad];
    // configure controls
    [self configureViewControls];
}

// Configure view controls
- (void)configureViewControls{
    // back button
    UIButton *backButton = [UIButton  buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 16, 14);
    [backButton setBackgroundImage:[UIImage imageNamed:@"navBackIcon"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(cancelAction) forControlEvents:UIControlEventTouchUpInside];
    // Initialize UIBarbuttonitem
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = barButton;
    
    if(type == COLLECTION_TYPE_TIMELINES)
    {
        self.navigationItem.title = [[AppManager sharedManager] getLocalizedString:@"PROFILE_BOOSTING_TIMELINES"];
        noResultLabel.text = [[AppManager sharedManager] getLocalizedString:@"PROFILE_BOOSTS_EMPTY"];
    }
    else
    {
        self.navigationItem.title = [[AppManager sharedManager] getLocalizedString:@"TIMELINE_LOCATION_TITLE"];
        noResultLabel.text = [[AppManager sharedManager] getLocalizedString:@"PROFILE_FAV_LOCATIONS_EMPTY"];
    }
    
    if(data == nil ||[data count] == 0)
    {
        [noResultView setHidden:NO];
        [mainCollectionView setHidden:YES];
    }
    else
    {
        [noResultView setHidden:YES];
        [mainCollectionView setHidden:NO];
    }
}

#pragma mark -
#pragma mark - Navigation
// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Pass the selected object to the new view controller.
    if([[segue identifier] isEqualToString:@"weezCollectionTimelineSegue"]){
        TimelineController *controler = (TimelineController*) segue.destinationViewController;
        [controler setTimelineObject:selectedMedia withLocation:nil orEvent:nil];
    }
    else if ([[segue identifier] isEqualToString:@"weezCollectionTimelinesCollectionSegue"]){
        if(selectedLocation != nil){
            // pass the selected Location
            UINavigationController *navController = [segue destinationViewController];
            TimelinesCollectionController *controller = (TimelinesCollectionController*)[navController viewControllers][0];
            [controller setType:kCollectionTypeLocationTimelines withLocation:selectedLocation withTag:nil withEvent:nil];
        }else{
            // pass the selected event
            UINavigationController *navController = [segue destinationViewController];
            TimelinesCollectionController *controller = (TimelinesCollectionController*)[navController viewControllers][0];
            [controller setType:kCollectionTypeEventTimelines withLocation:nil withTag:nil withEvent:selectedEvent];
        }
        selectedLocation = nil;
        selectedEvent = nil;
    }
}
// Cancel action
- (void)cancelAction
{
    // dismiss view
    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark -
#pragma mark - data
-(void) loadViewWithData:(NSMutableArray*)array type:(COLLECTION_TYPE)collectionType
{
    data = array;
    type = collectionType;
}

#pragma mark -
#pragma mark - UICollectionViewDataSource
// Number of sections in collection view
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView*)collectionView
{
    return 1;
}

// Number of items
- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if(data)
        return [data count];
    return 0;
}

// Cell for row at index path
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier1 = @"profileMediaCollectionCell";
    static NSString *CellIdentifier2 = @"profileLocationCollectionCell";
    
    if(type == COLLECTION_TYPE_TIMELINES){
        MediaCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier1 forIndexPath:indexPath];
        Timeline *media = [data objectAtIndex:indexPath.row];
        // populate cell
        [cell populateSquareCellWithTimeline:media];//show cell image as square
        cell.layer.borderWidth = 0.0;
        return cell;
    }else {
        LocationCollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:CellIdentifier2 forIndexPath:indexPath];
        //locations
        if([[data objectAtIndex:indexPath.row] isMemberOfClass:[Location class]]){
            Location *location = [data objectAtIndex:indexPath.row];
            [cell populateSquareCellWithLocationContent:location];
        }else{//events
            Event *event = [data objectAtIndex:indexPath.row];
            [cell populateSquareCellWithEventContent:event];
        }
        cell.layer.borderWidth = 0.0;
        return cell;
    }
}

#pragma mark -
#pragma mark - UICollectionViewDelegate
// Select item
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    
    if(type == COLLECTION_TYPE_TIMELINES){
        selectedMedia = [data objectAtIndex:indexPath.row];
        [self performSegueWithIdentifier:@"weezCollectionTimelineSegue" sender:self];
    }else {
        if([[data objectAtIndex:indexPath.row] isMemberOfClass:[Location class]]){
            selectedLocation = [data objectAtIndex:indexPath.row];
        }else{
            selectedEvent = [data objectAtIndex:indexPath.row];
        }
        [self performSegueWithIdentifier:@"weezCollectionTimelinesCollectionSegue" sender:self];
    }
}

#pragma mark –
#pragma mark – UICollectionViewDelegateFlowLayout
// Item size
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    float screenWidth = MIN(self.view.frame.size.width, self.view.frame.size.height);
    return CGSizeMake(screenWidth/3,screenWidth/3);
}

@end
