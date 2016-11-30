//
//  AppManager.h
//  Tahady
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2014 AlphaApps. All rights reserved.
//

#import "User.h"
#import "Constants.h"
#import "ChatMessage.h"
@import CoreLocation;

@interface AppManager : NSObject
{
    AppLanguageType appLanguage;
    UITextField *activeField;
    CLLocation *currenttUserLocation;
    NSArray *textColorsArray;
}

@property (nonatomic) AppLanguageType appLanguage;
@property (nonatomic, retain) UITextField *activeField;
@property (nonatomic) CLLocation *currenttUserLocation;

+ (AppManager*)sharedManager;
// Interface Functions
- (void)initAppLanguage;
- (void)changeAppLanguage:(AppLanguageType)lang;
- (NSString*)getLocalizedString:(NSString*)key;
- (void)setNavigationBarStyle;
- (UIColor*)getColorType:(AppColorType)type;
- (UIFont*)getFontType:(AppFontType)type;
// Cache Functions
- (void)saveUserData:(User*)data;
- (User*)cachedUserData;
- (void)saveDictionaryData:(NSMutableDictionary*)data cachFolder:(NSString*)cachFolder cachFile:(NSString*)cachFile;
- (NSMutableDictionary*)cachedDicotionaryData:(NSString*)cachFolder cachFile:(NSString*)cachFile;
- (void)saveArrayData:(NSMutableArray*)data cachFolder:(NSString*)cachFolder cachFile:(NSString*)cachFile;
- (NSMutableArray*)cachedArrayData:(NSString*)cachFolder cachFile:(NSString*)cachFile;
- (void)removeFolder:(NSString*)cachFolder;
// Videos
- (NSURL*)generateLocalVideoURL:(NSString*)videoName;
- (NSURL*)fetchLocalVideoURL:(NSString*)videoName;
- (void)removeVideoAtPath:(NSURL*)filePath;
- (void)removeAllVideos;
// Sorting
- (NSArray*)sortObjectsArray:(NSMutableArray*)originalArray;
// Notification
- (void)showNotification:(NSString*)key withType:(NotificationType)notifyType;
// Utility
- (UIImage *)convertImageToCircle:(UIImage*)image clipToCircle:(BOOL)clipToCircle withDiamter:(CGFloat)diameter
                      borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth shadowOffSet:(CGSize)shadowOffset;
- (UIImage*)resizeImage:(UIImage*)sourceImage scaledToWidth:(float)width;
- (UIImage*)resizeImage:(UIImage*)sourceImage scaledToHeight:(float)height;
- (UIImage*)scaleImage:(UIImage*)sourceImage scaleToSize:(CGSize)newSize;
- (UIImage*)takeSnapshot:(UIView*)view;
- (BOOL)validateEmail:(NSString*)email;
- (int)getRandomNumber:(int)range;
- (NSString*)getMediaDuration:(int)totalSeconds;
- (NSString*)timeIntervalToStringWithInterval:(NSTimeInterval)interval;
- (void)addViewDropShadow:(UIView*)view withOpacity:(CGFloat)opacity;
- (void)flipViewDirection:(UIView*)view;
- (BOOL)isCloseToCurrentLocation:(double) lat longitude:(double) longitude;
- (UIColor*)getColorForText:(NSString*)text;
- (NSString*)getViewedDuration:(int)totalSeconds;
- (UIView *) getChatMessagePreviewFor:(ChatMessage *) msg inSize:(CGSize)size extraLeftSpacing:(int)extraLeftSpacing;
- (NSString *)getGoogleStaticMaplinkForLat:(float)lat lng:(float)lng width:(int)width height:(int)height;
- (UIImage*)blur:(UIImage*)theImage;
- (void)blurredImageWithImage:(UIImage *)sourceImage onDone:(void (^)(UIImage *blurreedImage))onDone;
- (void)openGoogleMapsAppForLat:(float)lat andLong:(float)lng;
- (void)customizeImageForNavBarBackground: (UIImage*) sourceImage completionHandler:(void(^)(UIImage *navBarBackgroundImage)) delegate;
- (CGSize)getExtraSizeForChatMessage;

@end
