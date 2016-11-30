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

#import "JSQMessagesCustomToolbarContentView.h"

#import "UIView+JSQMessages.h"


@interface JSQMessagesCustomToolbarContentView ()

@property (weak, nonatomic) IBOutlet UIView *moreBarButtonContainerView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *moreBarButtonContainerViewWidthConstraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *moreHorizontalSpacingConstraint;

@end


@implementation JSQMessagesCustomToolbarContentView

#pragma mark - Class methods

+ (UINib *)nib
{
    return [UINib nibWithNibName:NSStringFromClass([JSQMessagesCustomToolbarContentView class])
                          bundle:[NSBundle bundleForClass:[JSQMessagesCustomToolbarContentView class]]];
}

#pragma mark - Initialization

- (void)awakeFromNib
{
    [super awakeFromNib];
}

#pragma mark - Setters

- (void)setBackgroundColor:(UIColor *)backgroundColor
{
    [super setBackgroundColor:backgroundColor];
    self.moreBarButtonContainerView.backgroundColor = backgroundColor;
}

- (void)setMoreBarButtonItem:(UIButton *)moreBarButtonItem
{
    if (_moreBarButtonItem) {
        [_moreBarButtonItem removeFromSuperview];
    }

    if (!moreBarButtonItem) {
        _moreBarButtonItem = nil;
        self.moreHorizontalSpacingConstraint.constant = 0.0f;
        self.moreBarButtonItemWidth = 0.0f;
        self.moreBarButtonContainerView.hidden = YES;
        return;
    }

    if (CGRectEqualToRect(moreBarButtonItem.frame, CGRectZero)) {
        moreBarButtonItem.frame = self.moreBarButtonContainerView.bounds;
    }

    self.moreBarButtonContainerView.hidden = NO;
    self.moreHorizontalSpacingConstraint.constant = kJSQMessagesToolbarContentViewHorizontalSpacingDefault;
    self.moreBarButtonItemWidth = CGRectGetWidth(moreBarButtonItem.frame);

    [moreBarButtonItem setTranslatesAutoresizingMaskIntoConstraints:NO];

    [self.moreBarButtonContainerView addSubview:moreBarButtonItem];
    [self.moreBarButtonContainerView jsq_pinAllEdgesOfSubview:moreBarButtonItem];
    [self setNeedsUpdateConstraints];

    _moreBarButtonItem = moreBarButtonItem;
}

- (void)setMoreBarButtonItemWidth:(CGFloat)moreBarButtonItemWidth
{
    self.moreBarButtonContainerViewWidthConstraint.constant = moreBarButtonItemWidth;
    [self setNeedsUpdateConstraints];
}

- (void)setMoreContentPadding:(CGFloat)moreContentPadding
{
    self.moreHorizontalSpacingConstraint.constant = moreContentPadding;
    [self setNeedsUpdateConstraints];
}

#pragma mark - Getters

- (CGFloat)moreBarButtonItemWidth
{
    return self.moreBarButtonContainerViewWidthConstraint.constant;
}

- (CGFloat)moreContentPadding
{
    return self.moreHorizontalSpacingConstraint.constant;
}

@end
