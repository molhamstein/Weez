//
//  ChatController.m
//  Weez
//
//  Created by Molham on 7/31/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import "ChatController.h"
#import "Media.h"
#import "ConnectionManager.h"
#import "AppManager.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import "Friend.h"
#import "ChatMessage.h"
#import "RecordMediaController.h"
#import "PreviewMediaController.h"
#import "GroupDetailsController.h"
#import "CustomIOSAlertView.h"
#import "ChatInputToolbar.h"
#import "JTSImageViewController.h"
#import "TimelineController.h"
#import "TimelineController.h"
#import "TimelinesCollectionController.h"
#import "LocationPickerController.h"

#import "JSQCustomVideoMediaItemWithThumb.h"
#import "JSQCustomPhotoMediaItem.h"
#import "JSQCustomAudioMediaItem.h"
#import "JSQCustomReplyMediaItem.h"
#import "JSQCustomLocationMediaItem.h"
#import "JSQCustomReplyMediaItem.h"
#import "JSQCustomTimelineMediaItem.h"
#import "JSQMessagesCustomHeaderView.h"
#import "CoordinatesDetailsController.h"
#import "CustomImageViewerController.h"

@implementation ChatController

@synthesize group;
@synthesize messages;
@synthesize avatars;
@synthesize outgoingBubbleImageData;
@synthesize incomingBubbleImageData;
@synthesize recordView;
@synthesize recordAudioProgressButton;
@synthesize recordTime;
@synthesize loadingView;
@synthesize recordMediaButton;
@synthesize dummyBubbleImageData;
@synthesize placePicker;
@synthesize lblOriginalMsgPreviewText;
@synthesize lblOriginalMsgPreviewSender;
@synthesize imgOriginalMsgPreviewImg;
@synthesize vOriginalMsgPreviewContainer;
@synthesize messageToReplyTo;
@synthesize btnOriginalMsgPreviewCansel;
@synthesize eventToshareAsMessage;
@synthesize locationToshareAsMessage;
@synthesize userToshareAsMessage;

#pragma mark - View lifecycle

- (void)viewDidLoad {
    [super viewDidLoad];
    [[ConnectionManager sharedManager] submitLog:@"chat viewDidLoad" success:^{}];
    [self configureView];
    self.loadingView.hidden = NO;
    
    // We need to re-configure the view after recieving the group for the first time to make sure we get the avatars
    if(activeTimeline == nil){
        [[ConnectionManager sharedManager] getGroup:group success:^(Group *newGroup) {
            [[ConnectionManager sharedManager] submitLog:[NSString stringWithFormat:@"chat start initialGetGroup %@", newGroup.objectId] success:^{}];
            self.group = newGroup;
            [self configureView];
            [self publishGroupData:newGroup];
            [[ConnectionManager sharedManager] submitLog:[NSString stringWithFormat:@"chat end initialGroupPublish %@", newGroup.objectId] success:^{}];
            
            self.title = group.name;
            
            //submit passed msg
            if((([group.objectId length] > 0) || [activeTimeline.userId length] > 0) &&(userToshareAsMessage ||locationToshareAsMessage || eventToshareAsMessage) ){
                [self submitTimelineMessage:userToshareAsMessage orLocation:locationToshareAsMessage orEvent:eventToshareAsMessage withDate:[NSDate dateWithTimeIntervalSinceNow:0]];
            }
            
            // highlight the message passed by the previous controller if found
            if(_messageToHightLight){
                int index = [self getMessageIndexInCollectionViewById:_messageToHightLight.objectId];
                if(index >= 0){
                    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:index inSection:0];
                    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:YES];
                    
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 0.7 * NSEC_PER_SEC), dispatch_get_main_queue(), ^{
                        
                        JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[self.collectionView cellForItemAtIndexPath:indexPath];
                        
                        // animate highlight
                        [cell.contentView setBackgroundColor:[UIColor colorWithRed:0.0 green:186.0/255.0 blue:241.0/255.0 alpha:0.5]];
                        [UIView animateWithDuration:3.0 animations:^{
                            [cell.contentView setBackgroundColor:[UIColor colorWithRed:0.0 green:186.0/255.0 blue:241.0/255.0 alpha:0.0]];
                        }];
                    });
                }
                _messageToHightLight = nil;
            }
        } failure:^(NSError *error) {
            [[ConnectionManager sharedManager] submitLog:[NSString stringWithFormat:@"chat initialGetFailed %@", error] success:^{}];
        }];
    }else{
        // Request group chat from timeline
        NSString *userId = activeTimeline.userId;
        if ((activeTimeline.timelineType == kTimelineTypeMention) || (activeTimeline.timelineType == kTimelineTypeBoost))
            userId = activeTimeline.actorId;
        [[ConnectionManager sharedManager] getChat:userId success:^(Group *newGroup) {
            [[ConnectionManager sharedManager] submitLog:[NSString stringWithFormat:@"chat start initialGetChat %@", newGroup.objectId] success:^{}];
            self.group = newGroup;
            [self configureView];
            [self publishGroupData:newGroup];
            [[ConnectionManager sharedManager] submitLog:[NSString stringWithFormat:@"chat end initialChatPublish %@", newGroup.objectId] success:^{}];
            self.title = group.name;
            
            //submit passed msg
            if((([group.objectId length] > 0) || [activeTimeline.userId length] > 0) &&(userToshareAsMessage ||locationToshareAsMessage || eventToshareAsMessage) ){
                [self submitTimelineMessage:userToshareAsMessage orLocation:locationToshareAsMessage orEvent:eventToshareAsMessage withDate:[NSDate dateWithTimeIntervalSinceNow:0]];
            }
            
            // highlight the message passed by the previous controller if found
            if(_messageToHightLight){
                int index = [self getMessageIndexInCollectionViewById:_messageToHightLight.objectId];
                if(index >= 0){
                    NSIndexPath *indexPath = [[NSIndexPath alloc] initWithIndex:index];
                    [self.collectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionCenteredVertically animated:NO];
                }
                _messageToHightLight = nil;
            }
        } failure:^(NSError *error) {
            [[ConnectionManager sharedManager] submitLog:[NSString stringWithFormat:@"chat initialGetFailed %@", error] success:^{}];
        }];
    }
}

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    
    [[ConnectionManager sharedManager] submitLog:@"chat start viewWillAppear" success:^{}];
    // customize navigationBar
    UIColor *color = [UIColor whiteColor];
    // set status bar to white
    UINavigationBar *bar = [self.navigationController navigationBar];
    [bar setBarTintColor:color];
    // title color
    NSMutableDictionary *titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
    [titleBarAttributes setValue:[[AppManager sharedManager] getColorType:kAppColorBlue] forKey:NSForegroundColorAttributeName];
    [titleBarAttributes setValue:[[AppManager sharedManager] getFontType:kAppFontLogo] forKey:NSFontAttributeName];
    [bar setTitleTextAttributes:titleBarAttributes];
    // statusbar
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleDefault];
    [self setNeedsStatusBarAppearanceUpdate];
    
    [[ConnectionManager sharedManager] submitLog:@"chat start viewWillAppear updateGroup" success:^{}];
    [self updateGroup];
    
    // schedule update chat
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    updateTimer = [NSTimer timerWithTimeInterval:15.0f target:self selector:@selector(updateGroup) userInfo:nil repeats:YES];
    [runner addTimer:updateTimer forMode:NSDefaultRunLoopMode];
    [[ConnectionManager sharedManager] submitLog:@"chat end viewWillAppear" success:^{}];
    [[ConnectionManager sharedManager] flushLog];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    // stop scheduled updates
    if(updateTimer != nil){
        [updateTimer invalidate];
    }
    // stop any audio being played
    [self stopAllAudioSounds];
    
    // set the navbar to its original status
    UIColor *color = [[AppManager sharedManager] getColorType:kAppColorBlue];
    // set status bar to white
    UINavigationBar *bar = [self.navigationController navigationBar];
    [bar setBarTintColor:color];
    NSMutableDictionary *titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
    [titleBarAttributes setValue:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [titleBarAttributes setValue:[[AppManager sharedManager] getFontType:kAppFontLogo] forKey:NSFontAttributeName];
    [bar setTitleTextAttributes:titleBarAttributes];
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    [self setNeedsStatusBarAppearanceUpdate];
    
}



- (void) configureView{
    [[ConnectionManager sharedManager] submitLog:@"chat StartConfigureView" success:^{}];
//    [self.collectionView registerNib:[JSQMessagesCustomHeaderView nib]
//          forSupplementaryViewOfKind:UICollectionElementKindSectionHeader
//                 withReuseIdentifier:[JSQMessagesCustomHeaderView headerReuseIdentifier]];
    
//    // set locale for date formatter
//    if([[AppManager sharedManager] appLanguage] == kAppLanguageAR){
//        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"ar"];
//        [JSQMessagesTimestampFormatter sharedFormatter].dateFormatter.locale = locale;
//    }else{
//        NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US"];
//        [JSQMessagesTimestampFormatter sharedFormatter].dateFormatter.locale = locale;
//    }
    
    formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:DATE_SERVER_DATES_LOCALE];
    
    UIButton *backButton = [UIButton  buttonWithType:UIButtonTypeCustom];
    backButton.frame = CGRectMake(0, 0, 16, 14);
    [backButton setBackgroundImage:[UIImage imageNamed:@"navBackIconRed"] forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(closePressed) forControlEvents:UIControlEventTouchUpInside];
    // Initialize UIBarbuttonitem
    UIBarButtonItem *barButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    self.navigationItem.leftBarButtonItem = barButton;
    
    // loading indicator
    self.loadingView.layer.cornerRadius = 5;
    self.loadingView.layer.masksToBounds = YES;
    self.loadingView.layer.zPosition = 5;
    self.loadingView.hidden = YES;
    
    recordTime.font = [[AppManager sharedManager] getFontType:kAppFontCellNumber];
    self.senderId = [ConnectionManager sharedManager].userObject.objectId;
    self.senderDisplayName = [ConnectionManager sharedManager].userObject.username;
    
    self.inputToolbar.contentView.textView.pasteDelegate = self;
    self.inputToolbar.contentView.textView.placeHolder = [[AppManager sharedManager] getLocalizedString:@"CHAT_NEW_MESSAGE"];
    self.inputToolbar.contentView.textView.accessibilityLabel = [NSBundle jsq_localizedStringForKey:@"CHAT_NEW_MESSAGE"];
    
    // load peers avatars
    self.avatars = [[NSMutableDictionary alloc] init];
    // load avatars
    if (group != nil){
        SDWebImageManager *manager = [SDWebImageManager sharedManager];
        for (int i = 0; i<[group.members count]; i++) {
            Friend * member = [group.members objectAtIndex:i];
            [manager downloadImageWithURL:[NSURL URLWithString:member.profilePic] options:0
                                 progress:^(NSInteger receivedSize, NSInteger expectedSize) {}
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                    if (image) {
                                        JSQMessagesAvatarImage *avatar = [JSQMessagesAvatarImageFactory avatarImageWithImage:image
                                                                                                                    diameter:kJSQMessagesCollectionViewAvatarSizeDefault];
                                        [self.avatars setObject:avatar forKey:member.objectId];
                                    }
                                }];
        }
    }
    
    JSQMessagesBubbleImageFactory *bubbleFactory = [[JSQMessagesBubbleImageFactory alloc] init];
    self.outgoingBubbleImageData = [bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    self.incomingBubbleImageData = [bubbleFactory incomingMessagesBubbleImageWithColor:[UIColor jsq_messageBubbleLightGrayColor]];
    self.dummyBubbleImageData =[bubbleFactory outgoingMessagesBubbleImageWithColor:[UIColor clearColor]];
    self.collectionView.collectionViewLayout.messageBubbleFont = [[AppManager sharedManager] getFontType:kAppFontDescription];
    
    self.showLoadEarlierMessagesHeader = NO;
    self.automaticallyScrollsToMostRecentMessage = NO;
    self.collectionView.collectionViewLayout.springinessEnabled = NO;
    self.collectionView.showsVerticalScrollIndicator = NO;
    self.inputToolbar.maximumHeight = 150;
    
    if (group != nil && activeTimeline == nil){
//        UIButton *settingsButton = [UIButton  buttonWithType:UIButtonTypeCustom];
//        settingsButton.frame = CGRectMake(0, 0, 20, 20);
//        [settingsButton setBackgroundImage:[UIImage imageNamed:@"navChatSettings"] forState:UIControlStateNormal];
//        [settingsButton addTarget:self action:@selector(showGroupDetails:) forControlEvents:UIControlEventTouchUpInside];
//        // Initialize UIBarbuttonitem
//        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:settingsButton];
        
        // profile button
        UIButton *profileButton = [UIButton  buttonWithType:UIButtonTypeCustom];
        profileButton.frame = CGRectMake(0, 0, 32, 32);
        [profileButton addTarget:self action:@selector(showGroupDetails:) forControlEvents:UIControlEventTouchUpInside];
        UIView *profileView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [profileView addSubview:profileButton];
        UIImageView *profileImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 32, 32)];
        [profileImageView sd_setImageWithURL:[NSURL URLWithString:group.image] placeholderImage:nil options:SDWebImageRefreshCached
                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
         {
             profileImageView.image = [[AppManager sharedManager] convertImageToCircle:profileImageView.image clipToCircle:YES withDiamter:100 borderColor:[UIColor whiteColor] borderWidth:10 shadowOffSet:CGSizeMake(0, 0)];
         }];
        [profileView addSubview:profileImageView];
        // Initialize UIBarbuttonitem
        UIBarButtonItem *fixedSeperator = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
        fixedSeperator.width = -6;
        UIBarButtonItem *barButton2 = [[UIBarButtonItem alloc] initWithCustomView:profileView];
        self.navigationItem.rightBarButtonItems = @[fixedSeperator, barButton2];
        
    }
    if(group && group.isGroup){
        //Register custom menu actions for cells.
        [JSQMessagesCollectionViewCell registerMenuAction:@selector(replyActionForItemAtIndexPath:)];
        [UIMenuController sharedMenuController].menuItems =  @[ [[UIMenuItem alloc] initWithTitle:@"Reply in Private" action:@selector(replyActionForItemAtIndexPath:)] ];
    }
    
    // OPT-IN: allow cells to be deleted
    //[JSQMessagesCollectionViewCell registerMenuAction:@selector(delete:)];
    
    // record sound
    // Configure colors
    self.recordAudioProgressButton.buttonColor = [UIColor whiteColor];
    self.recordAudioProgressButton.progressColor = [[AppManager sharedManager] getColorType:kAppColorBlue];
    
    self.recordView.layer.cornerRadius = 5;
    self.recordView.layer.masksToBounds = YES;
    
    UILongPressGestureRecognizer* panRec = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(didPressRecordAudio:)];
    [((ChatInputToolbar *)self.inputToolbar).contentView.leftBarButtonItem addGestureRecognizer:panRec];
    self.recordView.hidden = YES;
    self.recordAudioProgressButton.enabled = NO;
    // add recording progress view if not added before
    if(![self.recordView isDescendantOfView:self.view]){
        [self.view addSubview:recordView];
        NSLayoutConstraint *centreHorizontallyConstraint = [NSLayoutConstraint constraintWithItem:self.recordView attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
        NSLayoutConstraint *centreVerticallyConstraint = [NSLayoutConstraint constraintWithItem:self.recordView attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
        [self.view addConstraint:centreHorizontallyConstraint];
        [self.view addConstraint:centreVerticallyConstraint];
        
        recordTime.font = [[AppManager sharedManager] getFontType:kAppFontCellNumber];
    }
    
    // configure audio recorder
    NSURL *outputFileURL = [[[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"recordedAudio"] URLByAppendingPathExtension:@"m4a"];
    // Setup audio session
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];
    
    // Define the recorder setting
    NSMutableDictionary *recordSetting = [[NSMutableDictionary alloc] init];
    
    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt: 2] forKey:AVNumberOfChannelsKey];
    
    // Initiate and prepare the recorder
    recorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:NULL];
    recorder.delegate = self;
    recorder.meteringEnabled = YES;
    [recorder prepareToRecord];
    
    // to hide keyboard when touching outside
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(hideKeyboard)];
    [self.view addGestureRecognizer:tap];
    
    // messasge reply preview
    lblOriginalMsgPreviewSender.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    lblOriginalMsgPreviewText.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
    [btnOriginalMsgPreviewCansel addTarget:self action:@selector(actionCanselMsgPreview) forControlEvents:UIControlEventTouchUpInside];
    self.vOriginalMsgPreviewContainer.layer.cornerRadius = 2;
    self.vOriginalMsgPreviewContainer.layer.masksToBounds = YES;
    [self showReplyToPreview:messageToReplyTo]; // if nil preview will be hidden
    
    // swipe to back 
    swipeGestureStartPositionX = 3000;
    UIPanGestureRecognizer* panToBackRec = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeToBack:)];
    [panToBackRec setDelegate:self];
    [self.view addGestureRecognizer:panToBackRec];
    
    [[ConnectionManager sharedManager] submitLog:@"chat DoneConfigureView" success:^{}];
}

// not used for now
- (void)setPeerUser:(User*)peer{
    Timeline *composedTimeline = [Timeline alloc];
    composedTimeline.timelineType = kTimelineTypeUser;
    composedTimeline.username = peer.username;
    composedTimeline.userId = peer.objectId;
    [self setTimeline:composedTimeline];
}

// Set active timeline
- (void)setTimeline:(Timeline*)timeline{
    if(timeline.timelineType == kTimelineTypeGroup){
        group = [[Group alloc] init];
        group.objectId = timeline.userId;
        group.name = timeline.username;
        group.isGroup = NO;
        [self setGroup:group withParent:nil];
        return;
    }
    
    activeTimeline = timeline;
    
    if ((activeTimeline.timelineType == kTimelineTypeMention) || (activeTimeline.timelineType == kTimelineTypeBoost)){
        self.title = activeTimeline.actorUsername;
        group.objectId = activeTimeline.actorId;
    }else{// normal case
        self.title = activeTimeline.username;
        group.objectId = activeTimeline.userId;
    }
    
    // no need for parent view
    parentContorller = nil;
}

- (void) setGroup:(Group*) newGroup withParent:(UIViewController*)parent {
    group = newGroup;
    if (group != nil)
        self.title = group.name;
    // set parent view for closing the chat
    parentContorller = parent;
}

- (IBAction)unwindPreviewMediaSegue:(UIStoryboardSegue*)segue{
    // submit the media the user captured
    PreviewMediaController *detailsController = (PreviewMediaController*)segue.sourceViewController;
    
    // get selected location from previous controller to submit with message
    Location * customLocation = nil;
    NSString *locationId = nil;
    if(detailsController.selectedLocation){
        if(detailsController.selectedLocation.isUnDefinedPlace){ // google places location
            customLocation = detailsController.selectedLocation;
        }else{
            locationId = detailsController.selectedLocation.objectId;
        }
    }
    
    if (detailsController.pickedImage != nil){ // user captured image
        [self submitPhotoMessage:detailsController.pickedImage withDate:[NSDate dateWithTimeIntervalSinceNow:0] inLoactionWithId:locationId orCustomLocation:customLocation];
    }else if(detailsController.videoURL != nil){ // user recorded video
        [self submitVideoMessage:detailsController.videoURL withDate:[NSDate dateWithTimeIntervalSinceNow:0] inLoactionWithId:locationId orCustomLocation:customLocation];
    }
}

- (IBAction)unwindPickLocationForChat:(UIStoryboardSegue*)segue{
    // submit the media the user captured
    LocationPickerController *detailsController = (LocationPickerController*)segue.sourceViewController;
    Location *pickedLocation = detailsController.selectedLocation;
    if(pickedLocation){
        CLLocationCoordinate2D pickedLocationCoords = CLLocationCoordinate2DMake(pickedLocation.latitude, pickedLocation.longitude);
        [self submitLocationMessage:pickedLocationCoords withDate:[NSDate dateWithTimeIntervalSinceNow:0]];
    }
}


#pragma mark - Custom menu actions for cells

- (void)didReceiveMenuWillShowNotification:(NSNotification *)notification{
    // Display custom menu actions for cells.
    UIMenuController *menu = [notification object];
    if(group.isGroup){
        menu.menuItems = @[ [[UIMenuItem alloc] initWithTitle:@"Reply in Private" action:@selector(replyActionForItemAtIndexPath:)] ];
    }
}

#pragma mark - Actions
- (void) hideKeyboard{
    [self.inputToolbar.contentView.textView resignFirstResponder];
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    [super textViewDidBeginEditing:textView];
    [self scrollToBottomAnimated:YES];
    
    if([self.inputToolbar isMemberOfClass:[ChatInputToolbar class]]){
        ChatInputToolbar* inputBar = (ChatInputToolbar*) self.inputToolbar;
        [inputBar maximizeTextField];
    }
}

- (void)textViewDidEndEditing:(UITextView *)textView{
    [[ConnectionManager sharedManager] submitLog:@"chat start TextViewDidEndEditiing" success:^{}];
    [super textViewDidEndEditing:textView];
    if([self.inputToolbar isMemberOfClass:[ChatInputToolbar class]]){
        ChatInputToolbar* inputBar = (ChatInputToolbar*) self.inputToolbar;
        [inputBar minimizeTextField];
    }
    [[ConnectionManager sharedManager] submitLog:@"chat end TextViewDidEndEditiing" success:^{}];
}

- (void)showGroupDetails:(UIBarButtonItem *)sender{
    [self.inputToolbar.contentView.textView resignFirstResponder];
    self.inputToolbar.contentView.textView.text = @"";
    [self performSegueWithIdentifier:@"chatGroupDetailsSegue" sender:self];
}

- (void)closePressed{
    // hide the parent contoller
    if (parentContorller != nil)
        [parentContorller dismissViewControllerAnimated:YES completion:nil];
    else// back to normal list
        [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)actionCanselMsgPreview{
    messageToReplyTo = nil;
    [self showReplyToPreview:nil];
}

- (void) onRecordMediaClicked{
    [self performSegueWithIdentifier:@"chatRecordMediaSegue" sender:self];
}

- (void) submitTextMessage:(NSString *) text withDate:(NSDate *) date {
    [[ConnectionManager sharedManager] submitLog:[NSString stringWithFormat:@"chat start submitTextMessage:%@" ,text] success:^{}];
    if(!group.objectId)
        return;
    ChatMessage *templOriginalMsg = messageToReplyTo;
    [[ConnectionManager sharedManager] sendChatMessage:text ToGroup:group mediaType:kMediaTypeText media:nil withFileURL:nil orLocationMessageAt:kCLLocationCoordinate2DInvalid withLocationId:nil orCustomLocation:nil asReplyToMessage:messageToReplyTo.objectId inOriginalGroup:self.messageToReplyToOriginalGroupId sharedTimelineId:nil sharedLocationId:nil sharedEventId:nil success:^{
        [[ConnectionManager sharedManager] submitLog:[NSString stringWithFormat:@"chat start submitSuccessBlock" ] success:^{}];
        [self updateGroup];
        [self actionCanselMsgPreview];
        [[ConnectionManager sharedManager] submitLog:[NSString stringWithFormat:@"chat end submitSuccessBlock" ] success:^{}];
        [[ConnectionManager sharedManager] flushLog];
    } failure:^(NSError *error, NSString *errorMsg) {
        
        [[ConnectionManager sharedManager] submitLog:[NSString stringWithFormat:@"chat start submitFailureBlock %@",error ] success:^{}];
        // on failure to submit message refill text input with the message that failed
        // and show parent message preview if excists
        self.inputToolbar.contentView.textView.text = text;
        [self showReplyToPreview:templOriginalMsg];
        if(errorMsg && [errorMsg isEqualToString:@"chat_forbidden"]){
            [[AppManager sharedManager] showNotification:@"CHAT_SUBMISSION_FORBIDDEN"  withType:kNotificationTypeFailed];
        }else{
            [[AppManager sharedManager] showNotification:@"CHAT_SUBMISSION_FAILED"  withType:kNotificationTypeFailed];
        }
        
        // reomve the temp message we just added and referesh
        [self.messages removeLastObject];
        [self.inputToolbar toggleSendButtonEnabled];
        [self.collectionView.collectionViewLayout invalidateLayoutWithContext:[JSQMessagesCollectionViewFlowLayoutInvalidationContext context]];
        [self.collectionView reloadData];
        [self updateGroup];
        [[ConnectionManager sharedManager] flushLog];
    }];
    
    // adding a temp local copy of the message till the responce is recieved from the api
    if(messageToReplyTo){
        JSQCustomReplyMediaItem *replyMsg = [[JSQCustomReplyMediaItem alloc] initWithText:text];
        replyMsg.parentChatMessage = messageToReplyTo;
        replyMsg.hostControllerDelegate = self;
        replyMsg.appliesMediaViewMaskAsOutgoing = YES;
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:[ConnectionManager sharedManager].userObject.objectId
                                                 senderDisplayName:[ConnectionManager sharedManager].userObject.username
                                                              date:date
                                                              media:replyMsg];
        [self.messages addObject:message];
    }else{
//        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:[ConnectionManager sharedManager].userObject.objectId
//                                                 senderDisplayName:[ConnectionManager sharedManager].userObject.username
//                                                              date:date
//                                                              text:text];
        JSQCustomReplyMediaItem *item = [[JSQCustomReplyMediaItem alloc] initWithText:text];
        item.hostControllerDelegate = self;
        item.appliesMediaViewMaskAsOutgoing = YES;
        JSQMessage *message = [[JSQMessage alloc] initWithSenderId:[ConnectionManager sharedManager].userObject.objectId
                                                 senderDisplayName:[ConnectionManager sharedManager].userObject.username
                                                              date:date
                                                             media:item];
        [self.messages addObject:message];
    }
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    [self actionCanselMsgPreview];
    [self finishSendingMessageAnimated:YES];
    [self scrollToBottomAnimated:YES];
    [[ConnectionManager sharedManager] submitLog:[NSString stringWithFormat:@"chat end submitTextMessage:%@" ,text] success:^{}];
}

- (void) submitPhotoMessage:(UIImage *) photo withDate:(NSDate *) date inLoactionWithId:(NSString *)locationId orCustomLocation:(Location*)customLocation{
    if(!group.objectId)
        return;
    ChatMessage *templOriginalMsg = messageToReplyTo;
    [[ConnectionManager sharedManager] sendChatMessage:@"" ToGroup:group mediaType:kMediaTypeImage media:photo withFileURL:nil orLocationMessageAt:kCLLocationCoordinate2DInvalid withLocationId:locationId orCustomLocation:customLocation asReplyToMessage:messageToReplyTo.objectId inOriginalGroup:self.messageToReplyToOriginalGroupId sharedTimelineId:nil sharedLocationId:nil sharedEventId:nil success:^{
        blockUpdates = NO;
        inSubmissionImage = nil;
        [self updateGroup];
    } failure:^(NSError *error, NSString *errorMsg) {
        blockUpdates = NO;
        inSubmissionImage = photo;
        [self updateGroup];
        [self showReplyToPreview:templOriginalMsg];
        if(errorMsg && [errorMsg isEqualToString:@"chat_forbidden"]){
            [[AppManager sharedManager] showNotification:@"CHAT_SUBMISSION_FORBIDDEN"  withType:kNotificationTypeFailed];
            lastMessageId = @"";
            [self publishGroupData:group];
            // show a retry alert to the user
        }else{
            // we are using a custom alertView to enable the user open the Control Center while the alert is open
            CustomIOSAlertView *alertView = [self createSubmissionFailureAlert];
            [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
                if (buttonIndex == 1){
                    if(inSubmissionImage != nil){
                        lastMessageId = @"";
                        [self publishGroupData:group]; // to remove the temporary message we added
                        [self submitPhotoMessage:inSubmissionImage withDate:[NSDate dateWithTimeIntervalSinceNow:0] inLoactionWithId:locationId orCustomLocation:customLocation];
                    }
                }
                [alertView close];
            }];
            [alertView show];
        }
    }];
    [self actionCanselMsgPreview];
    blockUpdates = YES; // prevent chat from being updated while uploading media
    
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    JSQCustomPhotoMediaItem *mediaItem = [[JSQCustomPhotoMediaItem alloc] initWithImage:photo];
    mediaItem.parentChatMessage = messageToReplyTo;
    mediaItem.hostControllerDelegate = self;
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:[ConnectionManager sharedManager].userObject.objectId
                                             senderDisplayName:[ConnectionManager sharedManager].userObject.username
                                                          date:date
                                                          media:mediaItem];
    [self.messages addObject:message];
    
    [self finishSendingMessageAnimated:YES];
    [self scrollToBottomAnimated:YES];
}

- (void) submitVideoMessage:(NSURL *) videoUrl withDate:(NSDate *) date inLoactionWithId:(NSString *)locationId orCustomLocation:(Location*)customLocation{
    if(!group.objectId)
        return;
    ChatMessage *templOriginalMsg = messageToReplyTo;
    [[ConnectionManager sharedManager] sendChatMessage:@"" ToGroup:group mediaType:kMediaTypeVideo media:nil withFileURL:videoUrl orLocationMessageAt:kCLLocationCoordinate2DInvalid withLocationId:locationId orCustomLocation:customLocation asReplyToMessage:messageToReplyTo.objectId inOriginalGroup:self.messageToReplyToOriginalGroupId sharedTimelineId:nil sharedLocationId:nil sharedEventId:nil success:^{
        blockUpdates = NO;
        inSubmissionVideoURL = nil;
        [self updateGroup];
        [self actionCanselMsgPreview];
    } failure:^(NSError *error, NSString *errorMsg) {
        blockUpdates = NO;
        inSubmissionVideoURL = videoUrl;
        [self updateGroup];
        [self showReplyToPreview:templOriginalMsg];
        if(errorMsg && [errorMsg isEqualToString:@"chat_forbidden"]){
            [[AppManager sharedManager] showNotification:@"CHAT_SUBMISSION_FORBIDDEN"  withType:kNotificationTypeFailed];
            lastMessageId = @"";
            [self publishGroupData:group];
            // show a retry alert to the user
        }else{
            // we are using a custom alertView to enable the user open the Control Center while the alert is open
            CustomIOSAlertView *alertView = [self createSubmissionFailureAlert];
            [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
                if (buttonIndex == 1){
                    if(inSubmissionVideoURL != nil){
                        lastMessageId = @"";
                        [self publishGroupData:group]; // to remove the temporary message we added
                        [self submitVideoMessage:inSubmissionVideoURL withDate:[NSDate dateWithTimeIntervalSinceNow:0] inLoactionWithId:locationId orCustomLocation:customLocation];
                    }
                }
                [alertView close];
            }];
            [alertView show];
        }
    }];
    blockUpdates = YES; // prevent chat from being updated while uploading media
    [self actionCanselMsgPreview];
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    JSQCustomVideoMediaItemWithThumb *mediaItem = [[JSQCustomVideoMediaItemWithThumb alloc] initWithFileURL:videoUrl andThumb:nil mediaModel:nil isReadyToPlay:NO];
    mediaItem.parentChatMessage = messageToReplyTo;
    mediaItem.hostControllerDelegate = self;
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:[ConnectionManager sharedManager].userObject.objectId
                                             senderDisplayName:[ConnectionManager sharedManager].userObject.username
                                                          date:date
                                                         media:mediaItem];
    [self.messages addObject:message];
    
    [self finishSendingMessageAnimated:YES];
    [self scrollToBottomAnimated:YES];
}

- (void) submitTimelineMessage:(Friend *)user orLocation:(Location *)location orEvent:(Event *)event withDate:(NSDate *) date{
    if(!group.objectId)
        return;
    ChatMessage *templOriginalMsg = messageToReplyTo;
    [[ConnectionManager sharedManager] sendChatMessage:@"" ToGroup:group mediaType:kMediaTypeVideo media:nil withFileURL:nil orLocationMessageAt:kCLLocationCoordinate2DInvalid withLocationId:nil orCustomLocation:nil asReplyToMessage:messageToReplyTo.objectId inOriginalGroup:self.messageToReplyToOriginalGroupId sharedTimelineId:user.objectId sharedLocationId:location.objectId sharedEventId:event.objectId success:^{
        blockUpdates = NO;
        userToshareAsMessage = nil;
        eventToshareAsMessage = nil;
        locationToshareAsMessage = nil;
        [self updateGroup];
        [self actionCanselMsgPreview];
    } failure:^(NSError *error, NSString *errorMsg) {
        blockUpdates = NO;
        [self updateGroup];
        [self showReplyToPreview:templOriginalMsg];
        if(errorMsg && [errorMsg isEqualToString:@"chat_forbidden"]){
            [[AppManager sharedManager] showNotification:@"CHAT_SUBMISSION_FORBIDDEN"  withType:kNotificationTypeFailed];
            lastMessageId = @"";
            [self publishGroupData:group];
            // show a retry alert to the user
        }else{
            // we are using a custom alertView to enable the user open the Control Center while the alert is open
            CustomIOSAlertView *alertView = [self createSubmissionFailureAlert];
            [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
                if (buttonIndex == 1){
                    if(userToshareAsMessage ||locationToshareAsMessage || eventToshareAsMessage){
                        lastMessageId = @"";
                        [self publishGroupData:group]; // to remove the temporary message we added
                        [self submitTimelineMessage:userToshareAsMessage orLocation:locationToshareAsMessage orEvent:eventToshareAsMessage withDate:[NSDate dateWithTimeIntervalSinceNow:0]];
                    }
                }
                [alertView close];
            }];
            [alertView show];
        }
    }];
    blockUpdates = YES; // prevent chat from being updated while uploading media
    [self actionCanselMsgPreview];
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    JSQCustomTimelineMediaItem *mediaItem = [[JSQCustomTimelineMediaItem alloc] initWithTimeline:nil orLocation:location orEvent:event withThumb:nil];
    mediaItem.parentChatMessage = messageToReplyTo;
    mediaItem.hostControllerDelegate = self;
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:[ConnectionManager sharedManager].userObject.objectId
                                             senderDisplayName:[ConnectionManager sharedManager].userObject.username
                                                          date:date
                                                         media:mediaItem];
    [self.messages addObject:message];
    
    [self finishSendingMessageAnimated:YES];
    [self scrollToBottomAnimated:YES];
}

- (void) submitAudioMessage:(NSURL *) audioUrl withDate:(NSDate *) date inLoactionWithId:(NSString *)locationId orCustomLocation:(Location*)customLocation{
    if(!group.objectId)
        return;
    ChatMessage *templOriginalMsg = messageToReplyTo;
    [[ConnectionManager sharedManager] sendChatMessage:@"" ToGroup:group mediaType:kMediaTypeAudio media:nil withFileURL:audioUrl orLocationMessageAt:kCLLocationCoordinate2DInvalid withLocationId:locationId orCustomLocation:customLocation asReplyToMessage:messageToReplyTo.objectId inOriginalGroup:self.messageToReplyToOriginalGroupId sharedTimelineId:nil sharedLocationId:nil sharedEventId:nil success:^{
        blockUpdates = NO;
        inSubmissionAudioURL = nil;
        [self updateGroup];
        [self actionCanselMsgPreview];
    } failure:^(NSError *error, NSString *errorMsg) {
        blockUpdates = NO;
        inSubmissionAudioURL = audioUrl;
        [self updateGroup];
        [self showReplyToPreview:templOriginalMsg];
        if(errorMsg && [errorMsg isEqualToString:@"chat_forbidden"]){
            [[AppManager sharedManager] showNotification:@"CHAT_SUBMISSION_FORBIDDEN"  withType:kNotificationTypeFailed];
            lastMessageId = @"";
            [self publishGroupData:group];
            // show a retry alert to the user
        }else{
            // we are using a custom alertView to enable the user open the Control Center while the alert is open
            CustomIOSAlertView *alertView = [self createSubmissionFailureAlert];
            [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
                if (buttonIndex == 1){
                    if(inSubmissionAudioURL != nil){
                        lastMessageId = @"";
                        [self publishGroupData:group]; // to remove the temporary message we added
                        [self submitAudioMessage:inSubmissionAudioURL withDate:[NSDate dateWithTimeIntervalSinceNow:0] inLoactionWithId:locationId orCustomLocation:customLocation];
                    }
                }
                [alertView close];
            }];
            [alertView show];
        }
    }];
    blockUpdates = YES; // prevent chat from being updated while uploading media
    [self actionCanselMsgPreview];
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    
    
    //NSString * sample = [[NSBundle mainBundle] pathForResource:@"jsq_messages_sample" ofType:@"m4a"];
    NSData * audioData = [NSData dataWithContentsOfURL:audioUrl];
    JSQCustomAudioMediaItem *mediaItem = [[JSQCustomAudioMediaItem alloc] initWithData:audioData];
    mediaItem.parentChatMessage = messageToReplyTo;
    mediaItem.delegate = self;
    mediaItem.hostControllerDelegate = self;
    JSQMessage *message = [JSQMessage messageWithSenderId:[ConnectionManager sharedManager].userObject.objectId
                                                   displayName:[ConnectionManager sharedManager].userObject.username
                                                         media:mediaItem];
    [self.messages addObject:message];
    
    [self finishSendingMessageAnimated:YES];
    [self scrollToBottomAnimated:YES];
}

- (void) submitLocationMessage:(CLLocationCoordinate2D) coord withDate:(NSDate *) date{
    if(!group.objectId)
        return;
    ChatMessage *templOriginalMsg = messageToReplyTo;
    [[ConnectionManager sharedManager] sendChatMessage:@"" ToGroup:group mediaType:kMediaTypeLocation media:nil withFileURL:nil orLocationMessageAt:coord withLocationId:nil orCustomLocation:nil asReplyToMessage:messageToReplyTo.objectId inOriginalGroup:self.messageToReplyToOriginalGroupId sharedTimelineId:nil sharedLocationId:nil sharedEventId:nil success:^{
        blockUpdates = NO;
        inSubmissionCoord = kCLLocationCoordinate2DInvalid;
        [self updateGroup];
        [self actionCanselMsgPreview];
    } failure:^(NSError *error, NSString *errorMsg) {
        blockUpdates = NO;
        inSubmissionCoord = coord;
        [self updateGroup];
        [self showReplyToPreview:templOriginalMsg];
        
        if(errorMsg && [errorMsg isEqualToString:@"chat_forbidden"]){
            [[AppManager sharedManager] showNotification:@"CHAT_SUBMISSION_FORBIDDEN"  withType:kNotificationTypeFailed];
            lastMessageId = @"";
            [self publishGroupData:group];
        // show a retry alert to the user
        }else{
            // we are using a custom alertView to enable the user open the Control Center while the alert is open
            CustomIOSAlertView *alertView = [self createSubmissionFailureAlert];
            [alertView setOnButtonTouchUpInside:^(CustomIOSAlertView *alertView, int buttonIndex) {
                if (buttonIndex == 1){
                    if(inSubmissionImage != nil){
                        lastMessageId = @"";
                        [self publishGroupData:group]; // to remove the temporary message we added
                        [self submitLocationMessage:coord withDate:[NSDate dateWithTimeIntervalSinceNow:0]];
                    }
                }
                [alertView close];
            }];
            [alertView show];
        }
    }];
    blockUpdates = YES; // prevent chat from being updated while uploading media
    [self actionCanselMsgPreview];
    [JSQSystemSoundPlayer jsq_playMessageSentSound];
    JSQCustomLocationMediaItem *mediaItem = [[JSQCustomLocationMediaItem alloc] initWithParentMsg:messageToReplyTo Lat:coord.latitude andLong:coord.longitude showProgress:YES];
    JSQMessage *message = [[JSQMessage alloc] initWithSenderId:[ConnectionManager sharedManager].userObject.objectId
                                             senderDisplayName:[ConnectionManager sharedManager].userObject.username
                                                          date:date
                                                         media:mediaItem];
    [self.messages addObject:message];
    
    [self finishSendingMessageAnimated:YES];
    [self scrollToBottomAnimated:YES];
}

-(CustomIOSAlertView *) createSubmissionFailureAlert{
    CustomIOSAlertView *alertView = [[CustomIOSAlertView alloc] init];
    [alertView setButtonTitles:[NSMutableArray arrayWithObjects:[[AppManager sharedManager] getLocalizedString:@"CHAT_SUBMISSION_FAILED_CANCEL"], [[AppManager sharedManager] getLocalizedString:@"CHAT_SUBMISSION_FAILED_RETRY"], nil]];
    UIView *alertContetn = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 270, 100)];
    UILabel *alertTitle = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 250, 100)];
    alertTitle.numberOfLines = 3;
    alertTitle.textAlignment= NSTextAlignmentCenter;
    alertTitle.text = [[AppManager sharedManager] getLocalizedString:@"CHAT_SUBMISSION_FAILED_MSG"];
    [alertContetn addSubview:alertTitle];
    [alertView setContainerView: alertContetn];
    return alertView;
}

-(void) onMessageSubmisionForbidden{
    
}

#pragma mark - Data
-(void) updateGroup{
    if(blockUpdates)
        return;
    else
        [[ConnectionManager sharedManager] submitLog:@"chat updateChat blocked" success:^{}];
    if(activeTimeline != nil){ // its a chat with one single user
        NSString *userId = activeTimeline.userId;
        if ((activeTimeline.timelineType == kTimelineTypeMention) || (activeTimeline.timelineType == kTimelineTypeBoost))
            userId = activeTimeline.actorId;
        [[ConnectionManager sharedManager] getChat:userId success:^(Group *newGroup) {
            [[ConnectionManager sharedManager] submitLog:[NSString stringWithFormat: @"chat start UpdateGroupSuccessBlocak %@",newGroup.objectId] success:^{}];
            self.loadingView.hidden = YES;
            [self publishGroupData:newGroup];
        } failure:^(NSError *error) {
            [[ConnectionManager sharedManager] submitLog:@"chat updateChat failure" success:^{}];
            self.loadingView.hidden = YES;
        }];
    }else{ //its a group chat
        [[ConnectionManager sharedManager] getGroup:group success:^(Group *newGroup) {
            [[ConnectionManager sharedManager] submitLog:[NSString stringWithFormat: @"chat start UpdateChatSuccessBlocak %@",newGroup.objectId] success:^{}];
            self.loadingView.hidden = YES;
            [self publishGroupData:newGroup];
        } failure:^(NSError *error) {
            [[ConnectionManager sharedManager] submitLog:[NSString stringWithFormat: @"chat updateGroup failure %@",error] success:^{}];
            self.loadingView.hidden = YES;
        }];
    }
}

- (void) publishGroupData:(Group *) newGroup{
    
    self.group = newGroup;
    
    // dont refresh view if no new messages detected
    if(lastMessageId != nil && [lastMessageId isEqualToString:[[newGroup.messages lastObject] objectId]]){
        return;
    }
    
    self .messages = [[NSMutableArray alloc] init];
    
    // if its a group add one extra message at the top to show Group Creation date as a suplimantary top view
    if(group.isGroup){
        [[ConnectionManager sharedManager] submitLog:[NSString stringWithFormat:@"publishing group:%@" ,group.objectId] success:^{}];
        JSQMessage *dummyMessage = [JSQMessage alloc];
        dummyMessage = [dummyMessage initWithSenderId:group.getGroupAdmin.objectId
                                senderDisplayName:group.getGroupAdmin.username
                                             date:group.createdAt
                                             text:@""];
        [self.messages addObject:dummyMessage];
    }else{
        [[ConnectionManager sharedManager] submitLog:[NSString stringWithFormat:@"chat start publishingChat:%@" ,group.objectId] success:^{}];
    }
    
    // itrate over group ChatMessages
    for(int i = 0 ; i< [group.messages count] ; i++){
        JSQMessage *newMessage;
        ChatMessage *chatMessage = [group.messages objectAtIndex:i];
        
        if([chatMessage isMediaMessage] || chatMessage.parentMessage){
            JSQMediaItem *mediaItem;
            
            if(![chatMessage isMediaMessage] && chatMessage.parentMessage ){ // its a text reply message
                JSQCustomReplyMediaItem *item = [[JSQCustomReplyMediaItem alloc] initWithText:chatMessage.text];
                item.parentChatMessage = chatMessage.parentMessage;
                item.hostControllerDelegate = self;
                mediaItem = item;
            }else if(chatMessage.location){// location message
                mediaItem = [[JSQCustomLocationMediaItem alloc] initWithParentMsg:chatMessage.parentMessage Lat:chatMessage.location.latitude andLong:chatMessage.location.longitude showProgress:YES];
            // timeline message
            }else if([chatMessage isTimelineMsg]){
                JSQCustomTimelineMediaItem *item = [[JSQCustomTimelineMediaItem alloc] initWithTimeline:chatMessage.timelineMsgUser orLocation:chatMessage.timelineMsgLocation orEvent:chatMessage.timelineMsgEvent withThumb:chatMessage.thumb];
                item.parentChatMessage = chatMessage.parentMessage;
                item.hostControllerDelegate = self;
                mediaItem = item;
            // photo message
            }else if(chatMessage.media.mediaType == kMediaTypeImage){
                JSQCustomPhotoMediaItem *item = [[JSQCustomPhotoMediaItem alloc] initWithChatMessage:chatMessage showProgress:YES];
                item.parentChatMessage = chatMessage.parentMessage;
                item.hostControllerDelegate = self;
                mediaItem = item;
            // video message
            }else if(chatMessage.media.mediaType == kMediaTypeVideo){
                JSQCustomVideoMediaItemWithThumb *item = [[JSQCustomVideoMediaItemWithThumb alloc] initWithFileURL:[NSURL URLWithString:chatMessage.media.mediaLink] andThumb:chatMessage.media.largeWideThumb mediaModel:chatMessage.media isReadyToPlay:YES];
                item.parentChatMessage = chatMessage.parentMessage;
                item.hostControllerDelegate = self;
                mediaItem = item;
            }else if(chatMessage.media.mediaType == kMediaTypeAudio){
                NSURL *audioLink = [NSURL URLWithString:chatMessage.media.mediaLink];
                JSQCustomAudioMediaItem *item = [[JSQCustomAudioMediaItem alloc] initWithData:nil audioViewAttributes:[[JSQAudioMediaViewAttributes alloc] init] audioLink:audioLink duration:(double)chatMessage.media.duration];
                item.parentChatMessage = chatMessage.parentMessage;
                item.delegate = self;
                item.hostControllerDelegate = self;
                mediaItem = item;
            }
            if([chatMessage.sender.objectId isEqualToString:[ConnectionManager sharedManager].userObject.objectId])
                mediaItem.appliesMediaViewMaskAsOutgoing = YES;
            else
                mediaItem.appliesMediaViewMaskAsOutgoing = NO;
            
            newMessage = [JSQMessage alloc];
            newMessage = [newMessage initWithSenderId:chatMessage.sender.objectId
                                    senderDisplayName:chatMessage.sender.username
                                                 date:chatMessage.date
                                                media:mediaItem];
        }else{
//            newMessage = [JSQMessage alloc];
//            newMessage = [newMessage initWithSenderId:chatMessage.sender.objectId
//                                    senderDisplayName:chatMessage.sender.username
//                                                 date:chatMessage.date
//                                                 text:chatMessage.text];
            JSQCustomReplyMediaItem *item = [[JSQCustomReplyMediaItem alloc] initWithText:chatMessage.text];
            item.hostControllerDelegate = self;
            if([chatMessage.sender.objectId isEqualToString:[ConnectionManager sharedManager].userObject.objectId])
                item.appliesMediaViewMaskAsOutgoing = YES;
            else
                item.appliesMediaViewMaskAsOutgoing = NO;
            newMessage = [[JSQMessage alloc] initWithSenderId:chatMessage.sender.objectId
                                                     senderDisplayName:chatMessage.sender.username
                                                                  date:chatMessage.date
                                                                 media:item];

        }
        [self.messages addObject:newMessage];
    }
    [[ConnectionManager sharedManager] submitLog:[NSString stringWithFormat:@"chat end group Messages inflation:%lu" ,[group.messages count]] success:^{}];
    // stop any audio being played so the app won't creash when the audio is finished, as cell views will get invalidated
    [self stopAllAudioSounds];
    [self.collectionView reloadData];
    
    // if new message detected, scroll to bottom
    if(lastMessageId != nil && ![lastMessageId isEqualToString:[[group.messages lastObject] objectId]]){
        [JSQSystemSoundPlayer jsq_playMessageReceivedSound];
        [self scrollToBottomAnimated:YES];
    }
    if(lastMessageId == nil) // scroll to buttom the first time we get the messages
        [self scrollToBottomAnimated:NO];
    lastMessageId = [[group.messages lastObject] objectId];
    
    [[ConnectionManager sharedManager] submitLog:[NSString stringWithFormat:@"chat end publish:%@" ,group.objectId] success:^{}];
}

-(void) showReplyToPreview:(ChatMessage*)msg{
    if(msg){
        NSString *previewText = @"";
        if([msg isMediaMessage]){
            self.originalMsgPreviewPhotoConstraint.constant = 40;
            
            if(msg.media.mediaType == kMediaTypeAudio){
                previewText = @"Audio";
                imgOriginalMsgPreviewImg.contentMode = UIViewContentModeScaleAspectFit;
                imgOriginalMsgPreviewImg.image = [UIImage imageNamed:@"messageTypeSound"];
            }else{
                NSString *thumbUrl = @"";
                if(msg.isTimelineMsg){
                    thumbUrl = msg.thumb;
                    previewText = @"Timeline";
                }else if(msg.location){
                    thumbUrl = [[AppManager sharedManager] getGoogleStaticMaplinkForLat:msg.location.latitude lng:msg.location.longitude width:100 height:100];
                    previewText = @"Map Location";
                }else if(msg.media.mediaType == kMediaTypeImage){
                    thumbUrl = msg.media.thumbLink;
                    previewText = @"Photo";
                }else if(msg.media.mediaType == kMediaTypeVideo){
                    thumbUrl = msg.media.thumbLink;
                    previewText = @"Video";
                }
                imgOriginalMsgPreviewImg.contentMode = UIViewContentModeScaleAspectFill;
                [imgOriginalMsgPreviewImg sd_setImageWithURL:[NSURL URLWithString:thumbUrl] placeholderImage:nil
                                                   completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, NSURL *imageURL)
                 {
                     NSLog(@"err");
                 }];
            }
        }else{
            self.originalMsgPreviewPhotoConstraint.constant = 0;
            previewText = msg.text;
        }
        lblOriginalMsgPreviewText.text = previewText;
        lblOriginalMsgPreviewSender.text = msg.sender.username;
        
        self.originalMsgPreviewHeightConstraint.constant = 50;
        [self.view setNeedsUpdateConstraints];
        [UIView animateWithDuration:0.2 animations:^{
            [self.view layoutIfNeeded];
        }];
        
    }else{ // hide preview
        self.originalMsgPreviewHeightConstraint.constant = 0;
        [self.view setNeedsUpdateConstraints];
        [self.view layoutIfNeeded];
    }
}
#pragma mark - JSQMessagesViewController method overrides

- (void)didPressSendButton:(UIButton *)button
           withMessageText:(NSString *)text
                  senderId:(NSString *)senderId
         senderDisplayName:(NSString *)senderDisplayName
                      date:(NSDate *)date
{
    [self submitTextMessage:text withDate:date];
}

- (void)didPressAccessoryButton:(UIButton *)sender{
    //[self.inputToolbar.contentView.textView resignFirstResponder];
    //self.inputToolbar.contentView.textView.text = @"";
}

#pragma mark -
#pragma mark Actions Sheet
- (IBAction)moreAction:(id)sender
{
    
    [self hideKeyboard];
    // action sheet options
    NSString *cancelString = [[AppManager sharedManager] getLocalizedString:@"PHOTO_PICKER_CANCEL"];
    NSArray *actionList = @[[[AppManager sharedManager] getLocalizedString:@"CHAT_MORE_PICKER_FROM_GALLEREY"],
                            [[AppManager sharedManager] getLocalizedString:@"CHAT_MORE_PICKER_LOCATION"]
                            ];
    IBActionSheet *actionOptions = [[IBActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:cancelString destructiveButtonTitle:nil otherButtonTitlesArray:actionList];
    [actionOptions setFont:[[AppManager sharedManager] getFontType:kAppFontSubtitle]];
    [actionOptions setFont:[[AppManager sharedManager] getFontType:kAppFontSubtitleBold] forButtonAtIndex:2];
    [actionOptions setButtonTextColor:[UIColor blackColor] forButtonAtIndex:0];
    [actionOptions setButtonTextColor:[UIColor blackColor] forButtonAtIndex:1];
    [actionOptions setButtonTextColor:[UIColor colorWithRed:0.0f green:122.0f/255.0f blue:224.0f/255.0f alpha:1.0] forButtonAtIndex:2];
    // add images
    NSArray *buttonsArray = [actionOptions buttons];
    UIButton *btnFacebook = [buttonsArray objectAtIndex:0];
    [btnFacebook setImage:[UIImage imageNamed:@"pickerGalleryIcon"] forState:UIControlStateNormal];
    btnFacebook.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btnFacebook.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 36.0f, 0.0f, 0.0f);
    btnFacebook.imageEdgeInsets = UIEdgeInsetsMake(0, 18, 0, 0);
    UIButton *btnTwitter = [buttonsArray objectAtIndex:1];
    [btnTwitter setImage:[UIImage imageNamed:@"submitLocationIcon"] forState:UIControlStateNormal];
    btnTwitter.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    btnTwitter.titleEdgeInsets = UIEdgeInsetsMake(0.0f, 36.0f, 0.0f, 0.0f);
    btnTwitter.imageEdgeInsets = UIEdgeInsetsMake(0, 18, 0, 0);
    
    [actionOptions setButtonBackgroundColor:[UIColor colorWithWhite:0.98 alpha:1.0]];
    // view the action sheet
    [actionOptions showInView:self.navigationController.view];
    CGRect newFrame = actionOptions.frame;
    newFrame.origin.y -= 10;
    actionOptions.frame = newFrame;

//    [actionOptions showInView:self.view];
    
}

// Action sheet pressed button
- (void)actionSheet:(IBActionSheet*)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    // Gallery button
    if (buttonIndex == 0)
    {
        // photo library
        if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary])
        {
            UIImagePickerController *picker = [[UIImagePickerController alloc] init];
            picker.delegate = self;
            picker.allowsEditing = NO;
            picker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
            picker.navigationBar.tintColor = [UIColor whiteColor];
            [self presentViewController:picker animated:YES completion:nil];
            
        }
        else//not available
        {
            UIAlertView *alert = [[UIAlertView alloc]initWithTitle:[[AppManager sharedManager] getLocalizedString:@"GALLERY_NOT_AVAILABLE_TITLE"]
                                                           message:[[AppManager sharedManager] getLocalizedString:@"GALLERY_NOT_AVAILABLE_MSG"] delegate:nil
                                                 cancelButtonTitle:[[AppManager sharedManager] getLocalizedString:@"GALLERY_NOT_AVAILABLE_ACTION"]
                                                 otherButtonTitles:nil];
            [alert show];
        }
    }
    // pick location
    else if (buttonIndex == 1)
    {
        [self pickLocationFromMapAction];
    }
}


// ovveriding to add extra insets from the bottom so the record button won't cover with the messages
- (void)jsq_setCollectionViewInsetsTopValue:(CGFloat)top bottomValue:(CGFloat)bottom{
    
    UIEdgeInsets insets = UIEdgeInsetsMake(top, 0.0f, bottom + 65, 0.0f);
    self.collectionView.contentInset = insets;
    self.collectionView.scrollIndicatorInsets = insets;
}

#pragma mark - JSQMessages CollectionView DataSource

- (JSQMessage*) getMessageItemAtIndexPath:(NSIndexPath *) indexPath{
//    if(group.isGroup)
//        return [self.messages objectAtIndex:indexPath.item-1]; //we have added one extra message at the top to show group creation date
    return [self.messages objectAtIndex:indexPath.item];
}

- (int) getMessageIndexInMessagesFromCollectionViewIndexPath:(NSIndexPath *) indexPath{
    if(group.isGroup)
        return (int) indexPath.item-1; //we have added one extra message at the top to show group creation date
    return (int) indexPath.item;
}

- (id<JSQMessageData>)collectionView:(JSQMessagesCollectionView *)collectionView messageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    return [self getMessageItemAtIndexPath:indexPath]; //[self.messages objectAtIndex:indexPath.item];
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didDeleteMessageAtIndexPath:(NSIndexPath *)indexPath{
    [self.messages removeObjectAtIndex:indexPath.item];
}

- (id<JSQMessageBubbleImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView messageBubbleImageDataForItemAtIndexPath:(NSIndexPath *)indexPath{
    /**
     *  You may return nil here if you do not want bubbles.
     *  In this case, you should set the background color of your collection view cell's textView.
     *
     *  Otherwise, return your previously created bubble image data objects.
     */
    if(group.isGroup && indexPath.item == 0)
        return self.dummyBubbleImageData;
    
    JSQMessage *message = [self getMessageItemAtIndexPath:indexPath];
    
    if ([message.senderId isEqualToString:self.senderId]) {
        return self.outgoingBubbleImageData;
    }
    
    return self.incomingBubbleImageData;
}

- (id<JSQMessageAvatarImageDataSource>)collectionView:(JSQMessagesCollectionView *)collectionView avatarImageDataForItemAtIndexPath:(NSIndexPath *)indexPath
{
    /**
     *  Return `nil` here if you do not want avatars.
     *  If you do return `nil`, be sure to do the following in `viewDidLoad`:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize = CGSizeZero;
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero;
     *
     *  It is possible to have only outgoing avatars or only incoming avatars, too.
     */
    
    /**
     *  Return your previously created avatar image data objects.
     *
     *  Note: these the avatars will be sized according to these values:
     *
     *  self.collectionView.collectionViewLayout.incomingAvatarViewSize
     *  self.collectionView.collectionViewLayout.outgoingAvatarViewSize
     *
     *  Override the defaults in `viewDidLoad`
     */
    
    if(group.isGroup && indexPath.item == 0) // adding empty message at the top without avtar to show group creation date
        return nil;
    
    JSQMessage *message = [self getMessageItemAtIndexPath:indexPath];
    
    // if the net message has the same sender dont show avatar picture;
    if(indexPath.item+1 < [messages count]){
        JSQMessage *nextMessage = [self getMessageItemAtIndexPath:[NSIndexPath indexPathForItem:indexPath.item+1 inSection:0]];
        if([nextMessage.senderId isEqualToString:message.senderId])
            return nil;
    }
    
    return [self.avatars objectForKey:message.senderId];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath{
 
     // This logic should be consistent with what you return from `heightForCellTopLabelAtIndexPath:`
     // The other label text delegate methods should follow a similar pattern.
    // display creation info at the top in groups
    
    if(indexPath.item == 0 && group.isGroup){
        // show the date of creation for the group along with the creator name
        [formatter setDateFormat:TIMELINE_SHORT_DATE_FORMAT];
        formatter.locale = [[NSLocale alloc] initWithLocaleIdentifier:DATE_SERVER_DATES_LOCALE];
        // check if today date
        ChatMessage *firstMessage = [self.messages firstObject];
        Friend *groupAdmin = [group getGroupAdmin];
        
        NSCalendar *cal = [NSCalendar currentCalendar];
        NSDateComponents *components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
        NSDate *today = [cal dateFromComponents:components];
        components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:firstMessage.date];
        NSDate *otherDate = [cal dateFromComponents:components];
        // set time formater
        if ([today isEqualToDate:otherDate])
            [formatter setDateFormat:TIMELINE_DISPLAY_TIME_FORMAT];
        NSString *dateString = [formatter stringFromDate:firstMessage.date];
        NSString *fullText = [NSString stringWithFormat:[[AppManager sharedManager] getLocalizedString:@"CHAT_GROUP_CREATE_BY"], groupAdmin.username, dateString];
        return [[NSAttributedString alloc] initWithString:fullText];
        
    // Show a timestamp for every 3rd message
    }else if (indexPath.item % 3 == 0) {
        JSQMessage *message = [self getMessageItemAtIndexPath:indexPath];
        ChatMessage *chatMsg = [self getChatMessageAtCollectionViewIndexPath:indexPath];
        @try{
            if(!message.date){
                [[ConnectionManager sharedManager] submitLog:[NSString stringWithFormat:@"Chat message top label nil date:%@ originalDate:%@ msgId:%@ inGroup:%@", message.date, chatMsg.date, chatMsg.objectId, group.objectId] success:^{}];
                [[ConnectionManager sharedManager] submitLog:[NSString stringWithFormat:@"Chat message top locale settings:%@ originalDate:%@ msgId:%@ inGroup:%@", [[NSLocale preferredLanguages] objectAtIndex:0], chatMsg.date, chatMsg.objectId, group.objectId] success:^{}];
            }
            [formatter setDateFormat:TIMELINE_SHORT_DATE_FORMAT];
            formatter.calendar = [[NSCalendar alloc] initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
            // check if today date
            NSCalendar *cal = [NSCalendar currentCalendar];
            NSDateComponents *components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:[NSDate date]];
            NSDate *today = [cal dateFromComponents:components];
            components = [cal components:(NSCalendarUnitEra | NSCalendarUnitYear | NSCalendarUnitMonth | NSCalendarUnitDay) fromDate:message.date];
            NSDate *otherDate = [cal dateFromComponents:components];
            // set time formater
            if ([today isEqualToDate:otherDate])
                [formatter setDateFormat:TIMELINE_DISPLAY_TIME_FORMAT];
            NSString *dateString = [formatter stringFromDate:message.date];
            [[ConnectionManager sharedManager] submitLog:[NSString stringWithFormat:@"Chat message top label date %@ ",message.date] success:^{}];
            
            if(dateString){
                return [[NSAttributedString alloc] initWithString:dateString];
            }else{
                return [[NSAttributedString alloc] initWithString:@"Unknown Date"];
            }
        }@catch(NSException *e){
            [[ConnectionManager sharedManager] submitLog:[NSString stringWithFormat:@"Chat message date %@ exception:%@",message.date, e] success:^{}];
        }
    }
    
    return nil;
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath{
    JSQMessage *message = [self getMessageItemAtIndexPath:indexPath];
    
     // iOS7-style sender name labels
    if ([message.senderId isEqualToString:self.senderId]) {
        return nil;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:message.senderId]) {
            return nil;
        }
    }
    
     // Don't specify attributes to use the defaults.
    return [[NSAttributedString alloc] initWithString:message.senderDisplayName];
}

- (NSAttributedString *)collectionView:(JSQMessagesCollectionView *)collectionView attributedTextForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath{
    
    JSQMessage *msg = [self getMessageItemAtIndexPath:indexPath];
    if(msg.isMediaMessage){
        id<JSQMessageMediaData> mediaItem = msg.media;
        Location *mediaLocation = nil;
        if ([mediaItem isMemberOfClass:[JSQCustomPhotoMediaItem class]]) {
            JSQCustomPhotoMediaItem *photoMediaItem = (JSQCustomPhotoMediaItem*) mediaItem;
            mediaLocation = photoMediaItem.chatMessage.media.location;
        }else if([mediaItem isMemberOfClass:[JSQCustomVideoMediaItemWithThumb class]]){
            JSQCustomVideoMediaItemWithThumb *photoMediaItem = (JSQCustomVideoMediaItemWithThumb*) mediaItem;
            mediaLocation = photoMediaItem.mediaModel.location;
        }
        
        NSString *name;
        if(mediaLocation.isPrivateLocation)
            name = [[AppManager sharedManager] getLocalizedString:@"PRIVATE_LOCATION_NAME_PLACESHOLDER"];
        else
            name = mediaLocation.name;
        
        if([name length] > 0)
            return [[NSAttributedString alloc] initWithString:name];
    }
    return nil;
}

#pragma mark - UICollectionView DataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
//    if(group.isGroup)
//        return [self.messages count] + 1; // addinag one extra message at the top to show group creation date
    return [self.messages count];
}

- (UICollectionViewCell *)collectionView:(JSQMessagesCollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    
    JSQMessagesCollectionViewCell *cell = (JSQMessagesCollectionViewCell *)[super collectionView:collectionView cellForItemAtIndexPath:indexPath];
    
     // Configure almost *anything* on the cell
     // Text colors, label text, label colors, etc.

     // DO NOT set `cell.textView.font` !
     // Instead, you need to set `self.collectionView.collectionViewLayout.messageBubbleFont` to the font you want in `viewDidLoad`

     // DO NOT manipulate cell layout information!
     // Instead, override the properties you want on `self.collectionView.collectionViewLayout` from `viewDidLoad`

    JSQMessage *msg = [self getMessageItemAtIndexPath:indexPath];
    
    if (!msg.isMediaMessage) {
        cell.textView.textColor = [UIColor blackColor];
        cell.textView.linkTextAttributes = @{ NSForegroundColorAttributeName : cell.textView.textColor,
                                              NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle | NSUnderlinePatternSolid) };
    }
    return cell;
}



#pragma mark - UICollectionView Delegate
#pragma mark - Custom menu items

- (BOOL)collectionView:(UICollectionView *)collectionView canPerformAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    if (action == @selector(replyActionForItemAtIndexPath:)) {
        // can reply to only other people messages
        ChatMessage *msg = [self getChatMessageAtCollectionViewIndexPath:indexPath];
        if(group.isGroup && ![msg.sender.objectId isEqualToString:[ConnectionManager sharedManager].userObject.objectId])
            return YES;
        return  NO;
    }
    
    return [super collectionView:collectionView canPerformAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)collectionView:(UICollectionView *)collectionView performAction:(SEL)action forItemAtIndexPath:(NSIndexPath *)indexPath withSender:(id)sender{
    if (action == @selector(replyActionForItemAtIndexPath:)) {
        [self replyActionForItemAtIndexPath:indexPath];
        return;
    }
    
    [super collectionView:collectionView performAction:action forItemAtIndexPath:indexPath withSender:sender];
}

- (void)replyActionForItemAtIndexPath:(NSIndexPath *)indexPath{
    // start chat screen with the peer and set the message as a message to reply
    ChatMessage *msg = [self getChatMessageAtCollectionViewIndexPath:indexPath];
    if(![msg.sender.objectId isEqualToString:[ConnectionManager sharedManager].userObject.objectId]){
        NSString * storyboardName = @"Main";
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
        //UINavigationController *nc = [storyboard instantiateViewControllerWithIdentifier:@"ChatController"];
        ChatController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChatController"];
        [vc setPeerUser:msg.sender];
        vc.messageToReplyTo = msg;
        vc.messageToReplyToOriginalGroupId = group.objectId;
        [[self navigationController] pushViewController:vc animated:YES];
        //[self presentViewController:vc animated:YES completion:nil];
    }
}

- (ChatMessage*) getChatMessageAtCollectionViewIndexPath:(NSIndexPath *)indexPath{
    if(group.isGroup){
        if((indexPath.row-1) < [group.messages count])
            return [group.messages objectAtIndex:indexPath.row-1];
        return nil;
    }else{
        if((indexPath.row) < [group.messages count])
            return [group.messages objectAtIndex:indexPath.row];
        return nil;
    }
}

-(int) getMessageIndexInCollectionViewById:(NSString*)msgId{
    int indexInCollectionView = -1;
    if(group && group.messages){
        for (int i = 0; i < [group.messages count]; i++) {
            ChatMessage *msg = [group.messages objectAtIndex:i];
            if([msg.objectId isEqualToString:msgId]){
                indexInCollectionView = i;
                if(group.isGroup)
                    indexInCollectionView += 1;
                return indexInCollectionView;
            }
        }
    }
    return indexInCollectionView;
}


#pragma mark - JSQMessages collection view flow layout delegate

#pragma mark - Adjusting cell label heights

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellTopLabelAtIndexPath:(NSIndexPath *)indexPath{
    
     // Each label in a cell has a `height` delegate method that corresponds to its text dataSource method
    
     // This logic should be consistent with what you return from `attributedTextForCellTopLabelAtIndexPath:`
     // The other label height delegate methods should follow similarly

    // display creation info at the top in groups
    if(indexPath.item == 0 && group.isGroup){
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
     // Show a timestamp for every 3rd message
    if (indexPath.item % 3 == 0) {
        return kJSQMessagesCollectionViewCellLabelHeightDefault;
    }
    
    return 0.0f;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForMessageBubbleTopLabelAtIndexPath:(NSIndexPath *)indexPath{
    
    // first message in group is a dummey message, dont show top label
    if(group.isGroup && indexPath.item == 0)
        return 0.0f;
    
    /**
     *  iOS7-style sender name labels
     */
    JSQMessage *currentMessage = [self getMessageItemAtIndexPath:indexPath];
    if ([[currentMessage senderId] isEqualToString:self.senderId]) {
        return 0.0f;
    }
    
    if (indexPath.item - 1 > 0) {
        JSQMessage *previousMessage = [self.messages objectAtIndex:indexPath.item - 1];
        if ([[previousMessage senderId] isEqualToString:[currentMessage senderId]]) {
            return 0.0f;
        }
    }
    
    return kJSQMessagesCollectionViewCellLabelHeightDefault;
}

- (CGFloat)collectionView:(JSQMessagesCollectionView *)collectionView
                   layout:(JSQMessagesCollectionViewFlowLayout *)collectionViewLayout heightForCellBottomLabelAtIndexPath:(NSIndexPath *)indexPath{
    
    JSQMessage *msg = [self getMessageItemAtIndexPath:indexPath];
    if(msg.isMediaMessage){
        id<JSQMessageMediaData> mediaItem = msg.media;
        Location *mediaLocation = nil;
        if ([mediaItem isMemberOfClass:[JSQCustomPhotoMediaItem class]]) {
            JSQCustomPhotoMediaItem *photoMediaItem = (JSQCustomPhotoMediaItem*) mediaItem;
            mediaLocation = photoMediaItem.chatMessage.media.location;
        }else if([mediaItem isMemberOfClass:[JSQCustomVideoMediaItemWithThumb class]]){
            JSQCustomVideoMediaItemWithThumb *photoMediaItem = (JSQCustomVideoMediaItemWithThumb*) mediaItem;
            mediaLocation = photoMediaItem.mediaModel.location;
        }
        
        if(mediaLocation){
            return 25;
        }
    }

    return 0.0f;
}

#pragma mark - Responding to collection view tap events

- (void)collectionView:(JSQMessagesCollectionView *)collectionView
                header:(JSQMessagesLoadEarlierHeaderView *)headerView didTapLoadEarlierMessagesButton:(UIButton *)sender{
    NSLog(@"Load earlier messages!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapAvatarImageView:(UIImageView *)avatarImageView atIndexPath:(NSIndexPath *)indexPath{
    NSLog(@"Tapped avatar!");
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapMessageBubbleAtIndexPath:(NSIndexPath *)indexPath{
    // if tabed on a media mesasge, extract the media from the message and preview it
    JSQMessage *message = [self getMessageItemAtIndexPath:indexPath];
    if (message.isMediaMessage) {
        
        id<JSQMessageMediaData> mediaItem = message.media;
        
        if ([mediaItem isKindOfClass:[JSQCustomPhotoMediaItem class]]) {
            JSQCustomPhotoMediaItem *photoItem = (JSQCustomPhotoMediaItem *)mediaItem;
            selectedVideoUrlForPreview = nil;
            selectedCoordinateForPreview = kCLLocationCoordinate2DInvalid;
            
            // download full size image first to passe it to the preview Controller
            [photoItem downloadFullSizeImage:^(UIImage *downloadedImage) {
                if(downloadedImage){
                    
                    // Create image info
                    UICollectionViewCell * cell = [collectionView cellForItemAtIndexPath:indexPath];
                    JTSImageInfo *imageInfo = [[JTSImageInfo alloc] init];
                    imageInfo.image = downloadedImage;
                    imageInfo.referenceRect = cell.frame;
                    imageInfo.referenceView = self.view;
                    
                    // Setup view controller
                    CustomImageViewerController *imageViewer = [[CustomImageViewerController alloc]
                                                           initWithImageInfo:imageInfo
                                                           mode:JTSImageViewControllerMode_Image
                                                           backgroundStyle:JTSImageViewControllerBackgroundOption_None];
                    
                    int msgIndexInGroupMessages = [self getMessageIndexInMessagesFromCollectionViewIndexPath:indexPath];
                    [imageViewer prepareControllerWithLocation:photoItem.chatMessage.media.location user:photoItem.chatMessage.sender mediaArray:group.messages currentMediaIndex:msgIndexInGroupMessages];
                    
                    // Present the view controller.
                    [imageViewer showFromViewController:self transition:JTSImageViewControllerTransition_FromOriginalPosition];
                    
                }else{
                    [[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR"  withType:kNotificationTypeFailed];
                }
            }];
        }else if([mediaItem isKindOfClass:[JSQCustomVideoMediaItemWithThumb class]]){
            JSQCustomVideoMediaItemWithThumb *videoItem = (JSQCustomVideoMediaItemWithThumb *)mediaItem;
            selectedImageForPreview = nil;
            selectedCoordinateForPreview = kCLLocationCoordinate2DInvalid;
            // check if Video downloaded before
            if ([[AppManager sharedManager] fetchLocalVideoURL:videoItem.fileURL.lastPathComponent] == nil){
                
                [videoItem downloadVideo:^(NSURL *localVideoUrl) {
                    if(localVideoUrl != nil){
                        selectedVideoUrlForPreview = localVideoUrl;
                        selectedMediaLocationForPreview = [videoItem.mediaModel.location.objectId length] >0 ?videoItem.mediaModel.location:nil;
                        [self performSegueWithIdentifier:@"chatPreviewSegue" sender:self];
                    }else{
                        [[AppManager sharedManager] showNotification:@"MSG_CONNECTION_ERROR"  withType:kNotificationTypeFailed];
                    }
                }];
            }else{
                selectedVideoUrlForPreview = [[AppManager sharedManager] fetchLocalVideoURL:videoItem.fileURL.lastPathComponent];
                selectedMediaLocationForPreview = [videoItem.mediaModel.location.objectId length] >0 ?videoItem.mediaModel.location:nil;
                [self performSegueWithIdentifier:@"chatPreviewSegue" sender:self];
            }
        }else if([mediaItem isKindOfClass:[JSQCustomLocationMediaItem class]]){
            JSQCustomLocationMediaItem *locationItem = (JSQCustomLocationMediaItem *)mediaItem;
            int msgIndexInGroupMessages = [self getMessageIndexInMessagesFromCollectionViewIndexPath:indexPath];
            ChatMessage *msg = [[group messages] objectAtIndex:msgIndexInGroupMessages];
//            if(msg.location.isPrivateLocation){ // its a coordniates based location and we should show it in map
                if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]){
                    [[AppManager sharedManager] openGoogleMapsAppForLat:msg.location.latitude andLong:msg.location.longitude];
                }else{
                    selectedCoordinateForPreview = CLLocationCoordinate2DMake(locationItem.latitude, locationItem.longitude);
                    selectedVideoUrlForPreview = nil;
                    selectedImageForPreview = nil;
                    selectedMediaLocationForPreview = nil;
                    [self performSegueWithIdentifier:@"chatCoordinatesDetailsSegue" sender:self];
                }
//            }else{ // location is Defined in the system and we should display its details page
//                selectedFriendForTimelinePreview = nil;
//                selectedLocationForTimelinePreview = msg.location;
//                selectedEventForTimelinePreview = nil;
//                selectedVideoUrlForPreview = nil;
//                selectedImageForPreview = nil;
//                selectedMediaLocationForPreview = nil;
//                [self performSegueWithIdentifier:@"chatTimelinesCollectionSegue" sender:self];
//            }
        }else if([mediaItem isKindOfClass:[JSQCustomTimelineMediaItem class]]){
            JSQCustomTimelineMediaItem *locationItem = (JSQCustomTimelineMediaItem *)mediaItem;
            selectedFriendForTimelinePreview = locationItem.timeline;
            selectedLocationForTimelinePreview = locationItem.location;
            selectedEventForTimelinePreview = locationItem.event;
            selectedVideoUrlForPreview = nil;
            selectedImageForPreview = nil;
            selectedMediaLocationForPreview = nil;
            [self performSegueWithIdentifier:@"chatTimelinesCollectionSegue" sender:self];
        }
    }
    [self hideKeyboard];
}

- (void)didTapParentMessage:(ChatMessage*)parentMessage{
    if(parentMessage.groupId){
        // launch a ne instance of the chat controller to view parent message
        if(![parentMessage.groupId isEqualToString:self.group.objectId]){
            NSString *storyboardName = @"Main";
            UIStoryboard *storyboard = [UIStoryboard storyboardWithName:storyboardName bundle: nil];
            ChatController *vc = [storyboard instantiateViewControllerWithIdentifier:@"ChatController"];
            Group *groupOfParentMsg = [[Group alloc] init];
            groupOfParentMsg.objectId = parentMessage.groupId;
            groupOfParentMsg.isGroup = YES;
            [self setGroup:group withParent:nil];
            [vc setGroup:groupOfParentMsg];
            vc.messageToHightLight = parentMessage;
            [[self navigationController] pushViewController:vc animated:YES];
        }
    }
}

- (void)didDismissChatController:(ChatController *)vc{
}

- (void)collectionView:(JSQMessagesCollectionView *)collectionView didTapCellAtIndexPath:(NSIndexPath *)indexPath touchLocation:(CGPoint)touchLocation
{
//    NSLog(@"Tapped cell at %@!", NSStringFromCGPoint(touchLocation));
    [self hideKeyboard];
}

#pragma mark - JSQMessagesComposerTextViewPasteDelegate methods


- (BOOL)composerTextView:(JSQMessagesComposerTextView *)textView shouldPasteWithSender:(id)sender
{
    if ([UIPasteboard generalPasteboard].image) {
        // If there's an image in the pasteboard, construct a media item with that image and `send` it.
        [self submitPhotoMessage:[UIPasteboard generalPasteboard].image withDate:[NSDate dateWithTimeIntervalSinceNow:0] inLoactionWithId:nil orCustomLocation:nil];
        return NO;
    }
    return YES;
}


#pragma mark -
#pragma mark Audio record

// Get application documtnts directory to store recorded media in
- (NSURL *)applicationDocumentsDirectory{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (void)didPressRecordAudio:(UIGestureRecognizer*)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan){
        [self hideKeyboard];
        [self startRecordTimer];
    }else if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        [self stopRecorderTimer];
    }
}

// Start record timer
- (void)startRecordTimer{
    recordView.hidden = NO;
    // reset
    timeOut = 0.0;
    recordTime.text = [NSString stringWithFormat:@"%02d", (int)timeOut];
    [self.recordAudioProgressButton setProgress:0.0];
    // reset the timer
    [recordTimer invalidate];
    recordTimer = nil;
    // run the timer
    NSMethodSignature *sgn = [self methodSignatureForSelector:@selector(tickRecorder:)];
    NSInvocation *inv = [NSInvocation invocationWithMethodSignature:sgn];
    [inv setTarget: self];
    [inv setSelector:@selector(tickRecorder:)];
    recordTimer = [NSTimer timerWithTimeInterval:0.05 invocation:inv repeats:YES];
    // run the timer
    NSRunLoop *runner = [NSRunLoop currentRunLoop];
    [runner addTimer:recordTimer forMode:NSDefaultRunLoopMode];
    //NSURL *outputURL = [[[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"recordedAudio"] URLByAppendingPathExtension:@"mp4"];
    // start Recorder
    AVAudioSession *session = [AVAudioSession sharedInstance];
    [session setActive:YES error:nil];
    [recorder record];
//    [self.cameraController startRecordingWithOutputUrl:outputURL];
}

// Stop play image
- (void)tickRecorder:(NSTimer*)timer{
    // count down 0
    if (timeOut >= MAX_AUDIO_LENGTH)
    {
        // stop image timer
        [recordTimer invalidate];
        recordTimer = nil;
        // stop play image media
        [self stopRecorderTimer];
    }
    else// reduce counter
    {
        timeOut += 0.05;
        recordTime.text = [NSString stringWithFormat:@"%02d", (int)timeOut];
        [self.recordAudioProgressButton setProgress:(float)timeOut/(float)MAX_AUDIO_LENGTH];
    }
}

// Stop recorder timer
- (void)stopRecorderTimer{
    
    [self.recordAudioProgressButton setProgress:0.0];
    [recordView setHidden:YES];
    [recordTimer invalidate];
    recordTimer = nil;
    timeOut = 0;
    // stop recording
    [recorder stop];
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    [audioSession setActive:NO error:nil];
}

- (void) audioRecorderDidFinishRecording:(AVAudioRecorder *)avrecorder successfully:(BOOL)flag{
    if (!recorder.recording && flag){
//        player = [[AVAudioPlayer alloc] initWithContentsOfURL:recorder.url error:nil];
//        //[player setDelegate:self];
//        [player play];
        [self submitAudioMessage:recorder.url withDate:[NSDate dateWithTimeIntervalSinceNow:0] inLoactionWithId:nil orCustomLocation:nil];
    }
}

- (void)audioMediaItem:(JSQCustomAudioMediaItem *)audioMediaItem
didChangeAudioCategory:(NSString *)category
               options:(AVAudioSessionCategoryOptions)options
                 error:(nullable NSError *)error{
    NSLog(@"Audio category change");
}

- (void) audioWillPlay:(JSQCustomAudioMediaItem *)audioMediaItem{
    // stop any previously started audio sound before playing a new one
    [self stopAllAudioSounds];
}

- (void) stopAllAudioSounds{
    for (int i = 0 ; i < [messages count] ; i++){
        JSQMessage *message = [messages objectAtIndex:i];
        if(message.isMediaMessage && [message.media isKindOfClass:[JSQCustomAudioMediaItem class]]){
            JSQCustomAudioMediaItem *audioItem = (JSQCustomAudioMediaItem *) message.media;
            [audioItem stopAudioIfPlaying];
        }
    }
}

#pragma mark -
#pragma mark pick location
-(void) pickLocationFromMapAction
{   
    // check loaction permissions
    locationManagr = [[CLLocationManager alloc] init];
    locationManagr.delegate = self;
    //locationManagr.distanceFilter = 300;
    if ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorizedWhenInUse) {
        [locationManagr requestWhenInUseAuthorization];
    }else{
        [locationManagr requestLocation];
    }
    
    [self performSegueWithIdentifier:@"chatLocationPickerSegue" sender:self];
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status{
    if ([CLLocationManager authorizationStatus] == kCLAuthorizationStatusAuthorizedWhenInUse)
        [locationManagr requestLocation];
}
- (void)locationManager:(CLLocationManager *)manager didFailWithError:(nonnull NSError *)error
{
    NSLog(@"location falure %@",error.description);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations {
    
    CLLocation *newLocation = [locations lastObject];
    [AppManager sharedManager].currenttUserLocation = newLocation;
    [locationManagr stopUpdatingLocation];
}

#pragma mark -
#pragma mark ImagePickerDelegate
// Image picker picked image
- (void)imagePickerController:(UIImagePickerController*)reader didFinishPickingMediaWithInfo:(NSDictionary*)info
{
    UIImage *attachedImage = info[UIImagePickerControllerOriginalImage];
    [reader dismissViewControllerAnimated:NO completion:NULL];
    
    [self submitPhotoMessage:attachedImage withDate:[NSDate dateWithTimeIntervalSinceNow:0] inLoactionWithId:nil orCustomLocation:nil];
}

// Image picker canceled
- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:NULL];
}

// Navigation controller style
- (void)navigationController:(UINavigationController *)navigationController willShowViewController:(UIViewController *)viewController animated:(BOOL)animated
{
    if ([navigationController isKindOfClass:[UIImagePickerController class]])
    {
        viewController.navigationController.navigationBar.translucent = NO;
        viewController.edgesForExtendedLayout = UIRectEdgeNone;
    }
}

#pragma mark -
#pragma mark Swipe to back
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldBeRequiredToFailByGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer
{
    return NO;
}

- (void)didSwipeToBack:(UIPanGestureRecognizer*)gestureRecognizer {
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan){
        CGPoint point = [gestureRecognizer locationInView:self.view];
        swipeGestureStartPositionX = point.x;
    }else if(gestureRecognizer.state == UIGestureRecognizerStateChanged){
        
    }else if (gestureRecognizer.state == UIGestureRecognizerStateEnded){
        CGPoint movement = [gestureRecognizer translationInView:self.view];
        
        if(movement.x > 150 && swipeGestureStartPositionX < 50){
            // close
            [self closePressed];
            swipeGestureStartPositionX = 3000;
        }
    }
}

#pragma mark -
#pragma mark Navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender{
    
    if ([[segue identifier] isEqualToString:@"chatRecordMediaSegue"]){
        // pass the active user to profile page
        RecordMediaController *recordController = segue.destinationViewController;
        [recordController setRecordMediaFor:kRecordMediaForChat];
    }else if([[segue identifier] isEqualToString:@"chatGroupDetailsSegue"]){
        GroupDetailsController *groupDetailsController = (GroupDetailsController*)[segue destinationViewController];
        [groupDetailsController setGroup:self.group];
    }else if([[segue identifier] isEqualToString:@"chatPreviewSegue"]){
        PreviewMediaController *previewController =  (PreviewMediaController *) [segue destinationViewController];
        MediaType mediaType;
        if(selectedVideoUrlForPreview != nil){
            mediaType = kMediaTypeVideo;
        }else
            mediaType = kMediaTypeImage;
        [previewController setMediaObject:mediaType withImage:selectedImageForPreview withVideoURL:selectedVideoUrlForPreview];
        [previewController setRecordMediaFor:kRecordMediaForChat];
        [previewController setIsPreviewOnly:YES];
        [previewController setSelectedLocation:selectedMediaLocationForPreview];
        selectedMediaLocationForPreview = nil;
    }else if([[segue identifier] isEqualToString:@"chatCoordinatesDetailsSegue"]){
        UINavigationController *navController = [segue destinationViewController];
        CoordinatesDetailsController *coordDetailsController = (CoordinatesDetailsController*)[navController viewControllers][0];
        [coordDetailsController setCoordinatesLat:selectedCoordinateForPreview.latitude andLong:selectedCoordinateForPreview.longitude];
    }else if([[segue identifier] isEqualToString:@"chatTimelineSegue"]){
        if(selectedFriendForTimelinePreview || selectedLocationForTimelinePreview || selectedEventForTimelinePreview){ // play event timeline
            // pass the active user to profile page
            TimelineController *timelineController = segue.destinationViewController;
            [timelineController setTimelineObject:nil withLocation:selectedLocationForTimelinePreview orEvent:selectedEventForTimelinePreview];
            selectedLocationForTimelinePreview = nil;
            selectedFriendForTimelinePreview = nil;
            selectedEventForTimelinePreview = nil;
        }
    }else if([[segue identifier] isEqualToString:@"chatTimelinesCollectionSegue"]){
        if(selectedFriendForTimelinePreview || selectedLocationForTimelinePreview || selectedEventForTimelinePreview){ // show event/Location timeline
            UINavigationController *navController = [segue destinationViewController];
            TimelinesCollectionController *timelineController = [navController viewControllers][0];
            AppCollectionType type = kCollectionTypeLocationTimelines;
            if(selectedEventForTimelinePreview)
                type = kCollectionTypeEventTimelines;
            [timelineController setType:type withLocation:selectedLocationForTimelinePreview withTag:nil withEvent:selectedEventForTimelinePreview];
            selectedLocationForTimelinePreview = nil;
            selectedFriendForTimelinePreview = nil;
            selectedEventForTimelinePreview = nil;
        }
    }else if([[segue identifier] isEqualToString:@"chatLocationPickerSegue"]){
        CLLocationCoordinate2D center = [AppManager sharedManager].currenttUserLocation.coordinate;
        UINavigationController *navController = [segue destinationViewController];
        LocationPickerController *pickerController = [navController viewControllers][0];
        [pickerController prepareControllerWithlimitToOnlyNearLocations:NO initialMapPos:center enableTags:NO allowSelectingCoordinates:YES parentViewController:self];
    }
}

@end
