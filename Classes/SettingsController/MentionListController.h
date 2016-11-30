//
//  MentionListController.h
//  Weez
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2016 AlphaApps. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Timeline.h"
#import "WeezBaseViewController.h"

@interface MentionListController : WeezBaseViewController <UITableViewDelegate, UITableViewDataSource>
{
    NSMutableArray *listOfTimelines;
    Timeline *selectedTimeline;
    UITableView *timelineTableView;
    UIView *noResultView;
    UILabel *noResultLabel;
    UIView *loaderView;
}

@property (nonatomic, retain) IBOutlet UITableView *timelineTableView;
@property (nonatomic, retain) IBOutlet UIView *noResultView;
@property (nonatomic, retain) IBOutlet UILabel *noResultLabel;
@property (nonatomic, retain) IBOutlet UIView *loaderView;

@end
