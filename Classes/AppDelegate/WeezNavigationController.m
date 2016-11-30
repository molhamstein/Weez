//
//  WeezNavigationController.m
//  Weez
//
//  Created by Molham on 9/28/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "WeezNavigationController.h"

@implementation WeezNavigationController



- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return [gestureRecognizer isKindOfClass:UIScreenEdgePanGestureRecognizer.class];
}


@end
