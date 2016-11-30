//
//  WeezNavigationController.m
//  Weez
//
//  Created by Molham on 9/28/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "WeezBaseViewController.h"
#import "AppManager.h"

@implementation WeezBaseViewController

{
    int swipeGestureStartPositionX;
}

-(void) viewWillAppear:(BOOL)animated{
}
-(void)viewDidLoad{
    
    self.navigationController.interactivePopGestureRecognizer.delegate = self;
    //self.view.backgroundColor = [UIColor whiteColor];
    swipeGestureStartPositionX = 3000;
    UIPanGestureRecognizer* panRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeToBack:)];
    [panRec setDelegate:self];
    [self.view addGestureRecognizer:panRec];
    
//    UIScreenEdgePanGestureRecognizer *pan = [[UIScreenEdgePanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan)];
//    [pan setEdges:UIRectEdgeLeft];
//    [pan setDelegate:self];
//    [self.view addGestureRecognizer:pan];
    
    self.enableSwipeToBack = YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (void)didSwipeToBack:(UIPanGestureRecognizer*)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan && _enableSwipeToBack){
        CGPoint point = [gestureRecognizer locationInView:self.view];
        swipeGestureStartPositionX = point.x;
    }else if(gestureRecognizer.state == UIGestureRecognizerStateChanged){
        
    }else if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        CGPoint movement = [gestureRecognizer translationInView:self.view];
        
        if(_enableSwipeToBack && movement.x > 150 && swipeGestureStartPositionX < 50){
            // close
            if([self respondsToSelector:@selector(cancelAction)]){
                [self performSelector:@selector(cancelAction)];
            }else if([self respondsToSelector:@selector(cancelAction:)]){
                [self performSelector:@selector(cancelAction:) withObject:nil];
            }else{
                if(self.navigationController){
                    if(self.navigationController.viewControllers[0] == self){
                        [self dismissViewControllerAnimated:YES completion:nil];
                    }else{
                        [self.navigationController popViewControllerAnimated:YES];
                    }
                }
            }
            swipeGestureStartPositionX = 3000;
        }
    }
}

- (void)cancelAction{
}

- (void)cancelAction:(id)sender{
}

-(void)handlePan {
    NSLog(@"UI screen gest");
}


@end
