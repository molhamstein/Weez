//
//  ChatController.h
//  Weez
//
//  Created by Molham on 7/31/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "JSQMessages.h"

#import "User.h"
#import "Group.h"
#import "ChatMessage.h"
#import "Timeline.h"
#import "SDRecordButton.h"
#import "JSQCustomAudioMediaItem.h"
#import "IBActionSheet.h"
#import "Location.h"
@import GooglePlacePicker;
@protocol JSQCustomAudioMediaItemDelegate;

@class ChatController;

@protocol ChatControllerDelegate <NSObject>

- (void)didDismissChatController:(ChatController *)vc;
- (void)didTapParentMessage:(ChatMessage*)parentMessage;

@end

@interface ChatController : JSQMessagesViewController <JSQMessagesComposerTextViewPasteDelegate, AVAudioRecorderDelegate, JSQCustomAudioMediaItemDelegate, IBActionSheetDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, CLLocationManagerDelegate, UIGestureRecognizerDelegate, ChatControllerDelegate>
{
    Group *group;
    
    UIView *loadingView;
    NSMutableArray *messages;
    NSMutableDictionary *avatars;
    JSQMessagesBubbleImage *outgoingBubbleImageData;
    JSQMessagesBubbleImage *incomingBubbleImageData;
    JSQMessagesBubbleImage *dummyBubbleImageData; // used to insert empty messsages
    Timeline *activeTimeline;
    NSTimer *updateTimer;
    NSString *lastMessageId; // used to detect when a new message is recieved;
    UIButton *recordMediaButton;
    
    CLLocationManager *locationManagr;
    GMSPlacePicker *placePicker;
    
    // sound recording
    AVAudioRecorder *recorder;
    AVAudioPlayer *player;
    SDRecordButton *recordAudioProgressButton;
    UIView *recordView;
    UILabel *recordTime;
    NSTimer *recordTimer;
    float timeOut;
    BOOL isAnimating;
    
    // temp data holders to keep user messages when submission failes
    NSURL *inSubmissionVideoURL;
    NSURL *inSubmissionAudioURL;
    UIImage *inSubmissionImage;
    NSString *inSubmissionText;
    CLLocationCoordinate2D inSubmissionCoord;
    
    //preview media
    NSURL *selectedVideoUrlForPreview;
    CLLocationCoordinate2D selectedCoordinateForPreview;
    UIImage *selectedImageForPreview;
    Location *selectedMediaLocationForPreview;
    Friend *selectedFriendForTimelinePreview;
    Location *selectedLocationForTimelinePreview;
    Event *selectedEventForTimelinePreview;
    
    Friend *userToshareAsMessage;
    Location *locationToshareAsMessage;
    Event *eventToshareAsMessage;
    
    // custom date formating
    NSDateFormatter *formatter;
    BOOL blockUpdates;
    UIViewController *parentContorller;
    
    // reply to messages
    UILabel *lblOriginalMsgPreviewSender;
    UILabel *lblOriginalMsgPreviewText;
    UIImageView *imgOriginalMsgPreviewImg;
    UIButton *btnOriginalMsgPreviewCansel;
    UIView *vOriginalMsgPreviewContainer;
    ChatMessage *messageToReplyTo;
    
    //swipe to back
    int swipeGestureStartPositionX;
}

@property (strong, nonatomic) IBOutlet UIView *loadingView;
@property (strong, nonatomic) IBOutlet SDRecordButton *recordAudioProgressButton;
@property (strong, nonatomic) IBOutlet UIView *recordView;
@property (strong, nonatomic) IBOutlet UILabel *recordTime;
@property (strong, nonatomic) IBOutlet UIButton *recordMediaButton;
@property (strong, nonatomic) GMSPlacePicker *placePicker;

@property (weak, nonatomic) id<ChatControllerDelegate> delegateModal;

@property (strong, nonatomic) Group *group;

@property (strong, nonatomic) NSMutableArray *messages;
@property (strong, nonatomic) NSMutableDictionary *avatars;
@property (strong, nonatomic) JSQMessagesBubbleImage *outgoingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *incomingBubbleImageData;
@property (strong, nonatomic) JSQMessagesBubbleImage *dummyBubbleImageData;

// reply to messages
@property (strong, nonatomic) IBOutlet UILabel *lblOriginalMsgPreviewSender;
@property (strong, nonatomic) IBOutlet UILabel *lblOriginalMsgPreviewText;
@property (strong, nonatomic) IBOutlet UIImageView *imgOriginalMsgPreviewImg;
@property (strong, nonatomic) IBOutlet UIView *vOriginalMsgPreviewContainer;
@property (strong, nonatomic) IBOutlet UIButton *btnOriginalMsgPreviewCansel;
@property (strong, nonatomic) ChatMessage *messageToReplyTo;
@property (strong, nonatomic) NSString *messageToReplyToOriginalGroupId;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *originalMsgPreviewHeightConstraint;
@property (strong, nonatomic) IBOutlet NSLayoutConstraint *originalMsgPreviewPhotoConstraint;

@property (strong, nonatomic) ChatMessage *messageToHightLight;

@property (strong, nonatomic) Friend *userToshareAsMessage;
@property (strong, nonatomic) Location *locationToshareAsMessage;
@property (strong, nonatomic) Event *eventToshareAsMessage;

- (void)setTimeline:(Timeline*)timeline;
// not used for now
- (void)setPeerUser:(User*)peer;
- (void)setGroup:(Group*) newGroup withParent:(UIViewController*)parentController;
- (void)closePressed;
- (IBAction)onRecordMediaClicked;
- (IBAction)moreAction:(id)sender;
- (IBAction)unwindPreviewMediaSegue:(UIStoryboardSegue*)segue;
- (IBAction)unwindPickLocationForChat:(UIStoryboardSegue*)segue;
- (IBAction)actionCanselMsgPreview;


@end

