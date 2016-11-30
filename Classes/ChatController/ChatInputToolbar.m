//
//  Weez
//
//  Created by Molham on 7/31/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//


#import "ChatInputToolbar.h"
#import "ChatController.h"
#import "AppManager.h"
#import "JSQMessagesCustomToolbarContentView.h"

@implementation ChatInputToolbar

//@synthesize mediaButtonsContainer;
//@synthesize recordAudioButton;
//@synthesize recordMediaButton;
//@synthesize composeTextButtton;

#pragma mark - Initialization
- (void)awakeFromNib{
    
    // @AlphaApps
    // skipping parent implementation of this method to add or owne nib file and buttons
    //[super awakeFromNib];
    [self setTranslatesAutoresizingMaskIntoConstraints:NO];
    
    self.jsq_isObserving = NO;
    self.sendButtonOnRight = YES;
    
    self.preferredDefaultHeight = 44.0f;
    self.maximumHeight = NSNotFound;
    
    JSQMessagesCustomToolbarContentView *toolbarContentView = [self loadToolbarCustomContentView];
    toolbarContentView.frame = self.frame;
    [self addSubview:toolbarContentView];
    [self jsq_pinAllEdgesOfSubview:toolbarContentView];
    [self setNeedsUpdateConstraints];
    self.contentView = toolbarContentView;
    
    [self jsq_addObservers];
    
    self.contentView.leftBarButtonItem = [JSQMessagesToolbarButtonFactory defaultAccessoryButtonItem];
    self.contentView.rightBarButtonItem = [JSQMessagesToolbarButtonFactory defaultSendButtonItem];
    toolbarContentView.moreBarButtonItem = [JSQMessagesToolbarButtonFactory defaultAccessoryButtonItem];
    
    [self toggleSendButtonEnabled];

    [self configureView];
}

// adding custom views to the InputToolbar
-(void) configureView{
    self.contentView.hidden = NO;
    
//    CGRect newToolbarFrame = self.frame;
//    newToolbarFrame.size.height += 30;
//    newToolbarFrame.origin.y -= 30;
//    [self setFrame:newToolbarFrame];
    
    if([[AppManager sharedManager] appLanguage] == kAppLanguageAR){
        self.contentView.textView.textAlignment = NSTextAlignmentRight;
    }
    self.contentView.textView.placeHolder = [[AppManager sharedManager] getLocalizedString:@"CHAT_NEW_MESSAGE"];
    self.contentView.textView.accessibilityLabel = [NSBundle jsq_localizedStringForKey:@"CHAT_NEW_MESSAGE"];
    self.contentView.textView.font = [[AppManager sharedManager] getFontType:kAppFontSubtitle];
    self.contentView.textView.autocorrectionType = UITextAutocorrectionTypeNo;
    self.contentView.textView.layer.borderWidth = 0.0f;
    
    [self.contentView.rightBarButtonItem setTitle:@"" forState:UIControlStateNormal];
    [self.contentView.rightBarButtonItem setImage:[UIImage imageNamed:@"submitTextMsg"] forState:UIControlStateNormal];
    self.contentView.rightBarButtonItem.titleLabel.font = [[AppManager sharedManager] getFontType:kAppFontCellTitle];
    [self.contentView.leftBarButtonItem setImage:[UIImage imageNamed:@"recordSoundMsg" ] forState:UIControlStateNormal];
    [self.contentView.leftBarButtonItem setImage:[UIImage imageNamed:@"recordSoundMsg" ] forState:UIControlStateHighlighted];

    JSQMessagesCustomToolbarContentView *toolbarContentView = (JSQMessagesCustomToolbarContentView*) self.contentView;
    [toolbarContentView.moreBarButtonItem setImage:[UIImage imageNamed:@"chatMoreOptions" ] forState:UIControlStateNormal];
    [toolbarContentView.moreBarButtonItem setImage:[UIImage imageNamed:@"chatMoreOptions" ] forState:UIControlStateHighlighted];
    [toolbarContentView.moreBarButtonItem addTarget:self action:@selector(onMoreClicked) forControlEvents:UIControlEventTouchUpInside];
    
    [self setBackgroundColor:[UIColor whiteColor]];
    self.contentView.textView.backgroundColor = [UIColor whiteColor];
    [self.contentView setBackgroundColor:[UIColor whiteColor]];
    
    minimizedTextFieldFrame = toolbarContentView.textView.frame;
    maximizedTextFieldFrame = toolbarContentView.frame;
    
//    CGRect rec = self.contentView.frame;
//    CGFloat width = [UIScreen mainScreen].bounds.size.width;
//    mediaButtonsContainer = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, rec.size.height)];
//    mediaButtonsContainer.backgroundColor = [UIColor whiteColor];
//    
//    recordMediaButton = [[UIButton alloc] initWithFrame:CGRectMake((mediaButtonsContainer.frame.size.width/2)-22.5, 0, 45, 45)];
//    [recordMediaButton setImage:[UIImage imageNamed:@"recordMediaMsg"] forState:UIControlStateNormal];
//    //[recordMediaButton setBackgroundColor:[UIColor greenColor]];
//    [recordMediaButton addTarget:self action:@selector(onRecordMediaClicked) forControlEvents:UIControlEventTouchUpInside];
//    [mediaButtonsContainer addSubview:recordMediaButton];
    
//    recordAudioButton = [[UIButton alloc] initWithFrame:CGRectMake(recordMediaButton.frame.origin.x + recordMediaButton.frame.size.width +12, 5, 38, 38)];
//    [recordAudioButton setImage:[UIImage imageNamed:@"recordSoundMsg"] forState:UIControlStateNormal];
//    //[recordAudioButton setBackgroundColor:[UIColor greenColor]];
//    [mediaButtonsContainer addSubview:recordAudioButton];

//    composeTextButtton = [[UIButton alloc] initWithFrame:CGRectMake(recordMediaButton.frame.origin.x -12 -38, 5, 38, 38)];
//    [composeTextButtton setImage:[UIImage imageNamed:@"composeTextMsg"] forState:UIControlStateNormal];
//    //[composeTextButtton setBackgroundColor:[UIColor greenColor]];
//    [composeTextButtton addTarget:self action:@selector(onComposeTextClicked) forControlEvents:UIControlEventTouchUpInside];
//    [mediaButtonsContainer addSubview:composeTextButtton];

    //[self.contentView addSubview:mediaButtonsContainer];
}

// return 'best' size to fit given size. does not actually resize view. Default is return existing view size
- (CGSize)sizeThatFits:(CGSize)size {
    CGSize result = [super sizeThatFits:size];
    result.height = 55;
    return result;
};

-(void) onRecordMediaClicked{
    [((ChatController *) self.delegate) onRecordMediaClicked];
}

-(void) onMoreClicked{
    [((ChatController *) self.delegate) moreAction:nil];
}


//-(void) onComposeTextClicked{
//    mediaButtonsContainer.hidden = NO;
//    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^
//     {
//         CGRect newFrame = mediaButtonsContainer.frame;
//         newFrame.origin.y += newFrame.size.height;
//         mediaButtonsContainer.frame = newFrame;
//         //composeTextButtton.transform = CGAffineTransformScale(composeTextButtton.transform, 1.5, 1.5);
//     }
//     completion:^(BOOL finished)
//     {
//         //composeTextButtton.transform = CGAffineTransformScale(composeTextButtton.transform, 0.66, 0.66);
//        mediaButtonsContainer.hidden = YES;
//     }];
//    [self.contentView.textView becomeFirstResponder];
//}

//- (void)jsq_leftBarButtonPressed:(UIButton *)sender{
//    mediaButtonsContainer.hidden = NO;
//    [self.delegate messagesInputToolbar:self didPressLeftBarButton:sender];
//    [UIView animateWithDuration:0.2 delay:0.0 options:UIViewAnimationOptionTransitionCrossDissolve animations:^
//     {
//         CGRect newFrame = mediaButtonsContainer.frame;
//         newFrame.origin.y = 0;
//         mediaButtonsContainer.frame = newFrame;
//     }
//     completion:^(BOOL finished)
//     {
//     }];
//}

- (JSQMessagesCustomToolbarContentView *)loadToolbarCustomContentView
{
    NSArray *nibViews = [[NSBundle bundleForClass:[JSQMessagesInputToolbar class]] loadNibNamed:NSStringFromClass([JSQMessagesCustomToolbarContentView class])
                                                                                          owner:nil
                                                                                        options:nil];
    return nibViews.firstObject;
}

-(void) maximizeTextField{
    JSQMessagesCustomToolbarContentView *content = (JSQMessagesCustomToolbarContentView*) self.contentView;
    content.textFieldLeadingSpaceConstraint.constant = 8;
    [self.contentView.textView setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.2 animations:^{
        [self.contentView.textView layoutIfNeeded];
    }];
}

-(void) minimizeTextField{
    JSQMessagesCustomToolbarContentView *content = (JSQMessagesCustomToolbarContentView*) self.contentView;
    content.textFieldLeadingSpaceConstraint.constant = 92;
    [self.contentView.textView setNeedsUpdateConstraints];
    [UIView animateWithDuration:0.2 animations:^{
        [self.contentView.textView layoutIfNeeded];
    }];
}


@end
