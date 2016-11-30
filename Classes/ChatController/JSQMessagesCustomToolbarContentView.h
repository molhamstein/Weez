//
//  Created by Jesse Squires
//  http://www.jessesquires.com
//
//
//  Documentation
//  http://cocoadocs.org/docsets/JSQMessagesViewController
//
//
//  GitHub
//  https://github.com/jessesquires/JSQMessagesViewController
//
//
//  License
//  Copyright (c) 2014 Jesse Squires
//  Released under an MIT license: http://opensource.org/licenses/MIT
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "JSQMessagesComposerTextView.h"
#import "JSQMessagesToolbarContentView.h"


/**
 *  A `JSQMessagesToolbarContentView` represents the content displayed in a `JSQMessagesInputToolbar`.
 *  These subviews consist of a left button, a text view, and a right button. One button is used as
 *  the send button, and the other as the accessory button. The text view is used for composing messages.
 */
@interface JSQMessagesCustomToolbarContentView : JSQMessagesToolbarContentView


@property (weak, nonatomic) UIButton *moreBarButtonItem;

/**
 *  Specifies the width of the leftBarButtonItem.
 *
 *  @discussion This property modifies the width of the leftBarButtonContainerView.
 */
@property (assign, nonatomic) CGFloat moreBarButtonItemWidth;

/**
 *  Specifies the amount of spacing between the content view and the leading edge of leftBarButtonItem.
 *
 *  @discussion The default value is `8.0f`.
 */
@property (assign, nonatomic) CGFloat moreContentPadding;

/**
 *  The container view for the leftBarButtonItem.
 *
 *  @discussion
 *  You may use this property to add additional button items to the left side of the toolbar content view.
 *  However, you will be completely responsible for responding to all touch events for these buttons
 *  in your `JSQMessagesViewController` subclass.
 */
@property (weak, nonatomic, readonly) UIView *moreBarButtonContainerView;

@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textFieldTralingSpaceConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *textFieldLeadingSpaceConstraint;

@end
