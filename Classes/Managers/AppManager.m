//
//  AppManager.m
//  Tahady
//
//  Created by Hani Abu Shaer on 02/02/14.
//  Copyright (c) 2014 AlphaApps. All rights reserved.
//

#import "AppManager.h"
#import "ConnectionManager.h"
#include <stdlib.h>
#import "CRToast.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation AppManager

@synthesize appLanguage;
@synthesize activeField;
@synthesize currenttUserLocation;

static AppManager *sharedManager = nil;

#pragma mark -
#pragma mark Singilton Init Methods
// init shared Cache singleton.
+ (AppManager*)sharedManager
{
    @synchronized(self)
    {
        if ( !sharedManager )
        {
            sharedManager = [[AppManager alloc] init];
        }
    }
    return sharedManager;
}

// Dealloc shared API singleton.
+ (id)alloc
{
    @synchronized( self )
    {
        NSAssert(sharedManager == nil, @"Attempted to allocate a second instance of a singleton.");
        return [super alloc];
    }
    
    return nil;
}

// Init the manager
- (id)init
{
    if ( self = [super init] )
    {
        // active text field
        activeField = nil;
        
        // textColorsArray
        textColorsArray = [[NSArray alloc] initWithObjects:
                           //[UIColor colorWithRed:191.0/255.0 green:10.0/255.0 blue:31.0/255.0 alpha:1], // dark red
                           //[UIColor colorWithRed:42.0/255.0 green:81.0/255.0 blue:181.0/255.0 alpha:1],         // blue
                           [UIColor colorWithRed:0/255.0 green:186.0/255.0 blue:241.0/255.0 alpha:1],         // blue
                           //[UIColor colorWithRed:33.0/255.0 green:124.0/255.0 blue:3/255.0 alpha:1],  // green
                           //[UIColor colorWithRed:188.0/255.0 green:66.0/255.0 blue:90.0/255.0 alpha:1],         // red
                           //[UIColor colorWithRed:0.0 green:119.0/255.0 blue:82.0/255.0 alpha:1],   // light green
                           //[UIColor colorWithRed:90.0/255.0 green:32.0/255.0 blue:102.0/255.0 alpha:1],   // purple
                           //[UIColor colorWithRed:181.0/255.0 green:107.0/255.0 blue:0 alpha:1], nil];     // orange
                           nil];
    }
    return self;
}

#pragma mark -
#pragma mark Interface Functions
// Init application language
- (void)initAppLanguage
{
    // English lang by default
    appLanguage = kAppLanguageEN;
    // get last saved lang
    NSMutableArray *langArray = [[AppManager sharedManager] cachedArrayData:CACH_USER_FOLDER cachFile:CACH_LANG_FILE];
    // check if language set before
    if ([langArray count] > 0)
        appLanguage = [[langArray objectAtIndex:0] intValue];
    else// first time launching the app
    {
        NSString *language = [[[NSBundle mainBundle] preferredLocalizations] objectAtIndex:0];
        // check Arabic langauge
        if ([language isEqualToString:@"ar"])
            appLanguage = kAppLanguageAR;
    }
}

// Change application language
- (void)changeAppLanguage:(AppLanguageType)lang
{
    // change language
    appLanguage = lang;
    // save new language
    NSMutableArray *langArray = [[NSMutableArray alloc] initWithObjects:[NSNumber numberWithInt:appLanguage], nil];
    [[AppManager sharedManager] saveArrayData:langArray cachFolder:CACH_USER_FOLDER cachFile:CACH_LANG_FILE];
    // refresh tabs titles
    [self setNavigationBarStyle];
}

// Get localized string
- (NSString*)getLocalizedString:(NSString*)key
{
    // EN case
    NSString *keyString = [NSString stringWithFormat:@"%@_EN", key];
    // AR case
    if (appLanguage == kAppLanguageAR)
        keyString = [NSString stringWithFormat:@"%@_AR", key];
    return NSLocalizedString(keyString, nil);
}

// Set navigation bar style
- (void)setNavigationBarStyle
{
    UIColor *color = [self getColorType:kAppColorBlue];//[UIColor colorWithRed:160.0/255.0 green:33.0/255.0 blue:0 alpha:1.0];//[self getColorType:kAppColorRed];//
    // set status bar to white
    [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    // set navigation color
    [[UINavigationBar appearance] setBarTintColor:color];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    
    // set navigation font
    NSMutableDictionary *titleBarAttributes = [NSMutableDictionary dictionaryWithDictionary: [[UINavigationBar appearance] titleTextAttributes]];
    [titleBarAttributes setValue:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    [titleBarAttributes setValue:[[AppManager sharedManager] getFontType:kAppFontLogo] forKey:NSFontAttributeName];
    [[UINavigationBar appearance] setTitleTextAttributes:titleBarAttributes];
}

// Get application colors
- (UIColor*)getColorType:(AppColorType)type
{
    // swith on color types
    switch (type)
    {
        case kAppColorRed:
            return [UIColor colorWithRed:251.0/255.0 green:67.0/255.0 blue:81.0/255.0 alpha:1.0];
            break;
        case kAppColorGreen:
            return [UIColor colorWithRed:61.0/255.0 green:217.0/255.0 blue:124.0/255.0 alpha:1.0];
            break;
        case kAppColorBlue:
            return [UIColor colorWithRed:0.0 green:186.0/255.0 blue:241.0/255.0 alpha:1.0];
            break;
        case kAppColorDarkBlue:
            return [UIColor colorWithRed:42.0/255.0 green:81.0/255.0 blue:181.0/255.0 alpha:1];
            break;
        case kAppColorLightGray:
            return [UIColor colorWithRed:224.0/255.0 green:223.0/255.0 blue:227.0/255.0 alpha:1];
            break;
        default:
        {
            return [UIColor whiteColor];
            break;
        }
    }
}

// Get application fonts
- (UIFont*)getFontType:(AppFontType)type
{
    NSString *englishMediumFont = @"MullerMedium";
    NSString *englishRegularFont = @"MullerRegular";
    NSString *englisghBoldFont = @"MullerBold";
    NSString *arabicFont = @"DroidArabicKufi";
    int size = 15;
    NSString *fontName = @"";
    UIFont *font;
    // swith on color types
    switch (type)
    {
        case kAppFontLogo:
        {
            // iPhone 4 & 5 (480 - 568)
            if ([UIScreen mainScreen].bounds.size.height <= 568)
                size = 20;
            else// iPhone 6 & 6+ (667 - 736)
                size = 20;
            fontName = englisghBoldFont;
            break;
        }
        case kAppFontTitle:
        {
            // iPhone 4 & 5 (480 - 568)
            if ([UIScreen mainScreen].bounds.size.height <= 568)
                size = 18;
            else// iPhone 6 & 6+ (667 - 736)
                size = 20;
            fontName = englishMediumFont;
            break;
        }
        case kAppFontSubtitle:
        {
            // iPhone 4 & 5 (480 - 568)
            if ([UIScreen mainScreen].bounds.size.height <= 568)
                size = 16;
            else// iPhone 6 & 6+ (667 - 736)
                size = 18;
            fontName = englishRegularFont;
            break;
        }
        case kAppFontSubtitleBold:
        {
            // iPhone 4 & 5 (480 - 568)
            if ([UIScreen mainScreen].bounds.size.height <= 568)
                size = 16;
            else// iPhone 6 & 6+ (667 - 736)
                size = 18;
            fontName = englisghBoldFont;
            break;
        }
        case kAppFontDescription:
        {
            // iPhone 4 & 5 (480 - 568)
            if ([UIScreen mainScreen].bounds.size.height <= 568)
                size = 13;
            else// iPhone 6 & 6+ (667 - 736)
                size = 15;
            fontName = englishMediumFont;
            break;
        }
        case kAppFontDescriptionBold:
        {
            // iPhone 4 & 5 (480 - 568)
            if ([UIScreen mainScreen].bounds.size.height <= 568)
                size = 13;
            else// iPhone 6 & 6+ (667 - 736)
                size = 15;
            fontName = englisghBoldFont;
            break;
        }
        case kAppFontCellTitle:
        {
            // iPhone 4 & 5 (480 - 568)
            if ([UIScreen mainScreen].bounds.size.height <= 568)
                size = 14;
            else// iPhone 6 & 6+ (667 - 736)
                size = 16;
            fontName = englishMediumFont;
            break;
        }
        case kAppFontCellNumber:
        {
            // iPhone 4 & 5 (480 - 568)
            if ([UIScreen mainScreen].bounds.size.height <= 568)
                size = 12;
            else// iPhone 6 & 6+ (667 - 736)
                size = 14;
            return [UIFont fontWithName:englishRegularFont size:size];
            break;
        }
        case kAppFontCellLargeNumber:
        {
            // iPhone 4 & 5 (480 - 568)
            if ([UIScreen mainScreen].bounds.size.height <= 568)
                size = 18;
            else// iPhone 6 & 6+ (667 - 736)
                size = 20;
            return [UIFont fontWithName:englisghBoldFont size:size];
            break;
        }
        default:
        {
            size = 15;
            fontName = englishMediumFont;
            break;
        }
    }
    // English language
    font = [UIFont fontWithName:fontName size:size];
    // Arabic language
    if (appLanguage == kAppLanguageAR)
        font = [UIFont fontWithName:arabicFont size:size-1];
    return font;
}

#pragma mark -
#pragma mark Caching Data
// Save user data
- (void)saveUserData:(User*)player
{
    NSMutableDictionary* dic = [NSMutableDictionary dictionaryWithObjectsAndKeys:player, @"data", nil];
    [[AppManager sharedManager] saveDictionaryData:dic cachFolder:CACH_USER_FOLDER cachFile:CACH_USER_FILE];
}

// Return the cached user data
- (User*)cachedUserData
{
    NSMutableDictionary* dic = [[AppManager sharedManager] cachedDicotionaryData:CACH_USER_FOLDER cachFile:CACH_USER_FILE];
    return [dic objectForKey:@"data"];
}

// Save dictionary data to certain folder and file
- (void)saveDictionaryData:(NSMutableDictionary*)data cachFolder:(NSString*)cachFolder cachFile:(NSString*)cachFile
{
    // Saving an offline copy of the data.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *folderPath = [libraryDirectory stringByAppendingPathComponent:cachFolder];
    NSString *filePath = [folderPath stringByAppendingPathComponent:cachFile];
    BOOL isDir;
    // folder not exist
    if (![fileManager fileExistsAtPath:folderPath isDirectory:&isDir])
    {
        NSError *dirWriteError = nil;
        if (![fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&dirWriteError])
        {
            NSLog(@"Error: failed to create folder!");
        }
    }
    // wrote to disk
    if ([NSKeyedArchiver archiveRootObject:data toFile:filePath])
    {
        NSLog(@"Successfully wrote data to disk!");
    }
    else // failed to write
    {
        NSLog(@"Failed to write data to disk!");
    }
}

// Return the cached dictionary data from folder and file
- (NSMutableDictionary*)cachedDicotionaryData:(NSString*)cachFolder cachFile:(NSString*)cachFile
{
    // return the data from saved file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *pathString = [NSString stringWithFormat:@"%@/%@", cachFolder, cachFile];
    NSString *filePath =  [libraryDirectory stringByAppendingPathComponent:pathString];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        return [[NSKeyedUnarchiver unarchiveObjectWithFile:filePath] mutableCopy];
    return [[NSMutableDictionary alloc] init];
}

// Save array data to cached folder and file
- (void)saveArrayData:(NSMutableArray*)data cachFolder:(NSString*)cachFolder cachFile:(NSString*)cachFile
{
    // Saving an offline copy of the data.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *folderPath = [libraryDirectory stringByAppendingPathComponent:cachFolder];
    NSString *filePath = [folderPath stringByAppendingPathComponent:cachFile];
    BOOL isDir;
    // folder not exist
    if (![fileManager fileExistsAtPath:folderPath isDirectory:&isDir])
    {
        NSError *dirWriteError = nil;
        if (![fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&dirWriteError])
        {
            NSLog(@"Error: failed to create folder!");
        }
    }
    // wrote to disk
    if ([NSKeyedArchiver archiveRootObject:data toFile:filePath])
    {
        NSLog(@"Successfully wrote data to disk!");
    }
    else // failed to write
    {
        NSLog(@"Failed to write data to disk!");
    }
}

// Return array of data from folder and file
- (NSMutableArray*)cachedArrayData:(NSString*)cachFolder cachFile:(NSString*)cachFile
{
    // return the data from saved file
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *pathString = [NSString stringWithFormat:@"%@/%@", cachFolder, cachFile];
    NSString *filePath =  [libraryDirectory stringByAppendingPathComponent:pathString];
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        return [[NSKeyedUnarchiver unarchiveObjectWithFile:filePath] mutableCopy];
    return [[NSMutableArray alloc] init];
}

// Remove folder
- (void)removeFolder:(NSString*)cachFolder
{
    // set the directory path
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES);
    NSString *libraryDirectory = [paths objectAtIndex:0];
    NSString *folderPath =  [libraryDirectory stringByAppendingPathComponent:cachFolder];
    BOOL isDir;
    NSError *dirError = nil;
    // folder exist
    if ([fileManager fileExistsAtPath:folderPath isDirectory:&isDir])
    {
        if (![fileManager removeItemAtPath:folderPath error:&dirError])
            NSLog(@"Failed to remove folder");
    }
}

#pragma mark -
#pragma mark Videos
// Generate local video URL
- (NSURL*)generateLocalVideoURL:(NSString*)videoName
{
    // Saving an offline copy of the data.
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString *folderPath = [cachesDirectory stringByAppendingPathComponent:CACH_VIDEO_FOLDER];
    BOOL isDir;
    // folder not exist
    if (![fileManager fileExistsAtPath:folderPath isDirectory:&isDir])
    {
        NSError *dirWriteError = nil;
        if (![fileManager createDirectoryAtPath:folderPath withIntermediateDirectories:YES attributes:nil error:&dirWriteError])
        {
            NSLog(@"Error: failed to create folder!");
        }
    }
    NSURL *cachesDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
    NSString *pathString = [NSString stringWithFormat:@"%@/%@", CACH_VIDEO_FOLDER, videoName];
    return [cachesDirectoryURL URLByAppendingPathComponent:pathString];
}

// Fetch local video URL
- (NSURL*)fetchLocalVideoURL:(NSString*)videoName
{
    NSURL *fullURL = nil;
    // local url
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString *pathString = [NSString stringWithFormat:@"%@/%@", CACH_VIDEO_FOLDER, videoName];
    NSString *filePath = [cachesDirectory stringByAppendingPathComponent:pathString];
    // file downloaded
    if ([[NSFileManager defaultManager] fileExistsAtPath:filePath])
    {
        NSURL *cachesDirectoryURL = [[NSFileManager defaultManager] URLForDirectory:NSCachesDirectory inDomain:NSUserDomainMask appropriateForURL:nil create:NO error:nil];
        fullURL = [cachesDirectoryURL URLByAppendingPathComponent:pathString];
    }
    return fullURL;
}

// Remove video at path
- (void)removeVideoAtPath:(NSURL*)filePath
{
    NSString *stringPath = filePath.path;
    NSFileManager *fileManager = [NSFileManager defaultManager];
    if ([fileManager fileExistsAtPath:stringPath]) {
        [fileManager removeItemAtPath:stringPath error:NULL];
    }
}

// Remove all videos folder
- (void)removeAllVideos
{
    // set the directory path
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES);
    NSString *cachesDirectory = [paths objectAtIndex:0];
    NSString *folderPath =  [cachesDirectory stringByAppendingPathComponent:CACH_VIDEO_FOLDER];
    BOOL isDir;
    NSError *dirError = nil;
    // folder exist
    if ([fileManager fileExistsAtPath:folderPath isDirectory:&isDir])
    {
        if (![fileManager removeItemAtPath:folderPath error:&dirError])
            NSLog(@"Failed to remove folder");
    }
}

#pragma mark -
#pragma mark Sorting
// Sort array of objects
- (NSArray*)sortObjectsArray:(NSMutableArray*)originalArray
{
    NSArray *sortedArray;
    sortedArray = [originalArray sortedArrayUsingComparator:^NSComparisonResult(id a, id b)
                   {
                       return [a compare:b];
                   }];
    return sortedArray;
}

#pragma mark -
#pragma mark Notification
// Display notification
- (void)showNotification:(NSString*)key withType:(NotificationType)notifyType
{
    UIColor *notificationColor;
    // check the type of notification
    switch (notifyType)
    {
        case kNotificationTypeFailed:// Error
        {
            notificationColor = [UIColor grayColor];
            break;
        }
        case kNotificationTypeSuccess:// Success
        {
            notificationColor = [self getColorType:kAppColorGreen];
            break;
        }
        case kNotificationTypeAlert:// Alert
        {
            notificationColor = [UIColor grayColor];
            break;
        }
        default:
        {
            notificationColor = [UIColor grayColor];
            break;
        }
    }
    // get localized string
    NSString *message = [self getLocalizedString:key];
    NSTextAlignment alignment = NSTextAlignmentLeft;
    UIFont *font = [self getFontType:kAppFontDescription];
    if (appLanguage == kAppLanguageAR)
        alignment = NSTextAlignmentRight;
    // set notification options
    [CRToastManager setDefaultOptions:@{kCRToastNotificationTypeKey : @(CRToastTypeNavigationBar),
                                        kCRToastFontKey             : font,
                                        kCRToastTextColorKey        : [UIColor whiteColor],
                                        kCRToastBackgroundColorKey  : notificationColor}];
    // set notification options
    NSMutableDictionary *options = [@{kCRToastNotificationTypeKey               : @(CRToastTypeNavigationBar),
                                      kCRToastNotificationPresentationTypeKey   : @(CRToastPresentationTypeCover),
                                      kCRToastUnderStatusBarKey                 : @(YES),
                                      kCRToastTextKey                           : message,
                                      kCRToastTimeIntervalKey                   : @(2.0),
                                      kCRToastTextAlignmentKey                  : @(alignment),
                                      kCRToastTimeIntervalKey                   : @(2.0),
                                      kCRToastAnimationInTypeKey                : @(CRToastAnimationTypeLinear),
                                      kCRToastAnimationOutTypeKey               : @(CRToastAnimationTypeLinear),
                                      kCRToastAnimationInDirectionKey           : @(0),
                                      kCRToastAnimationOutDirectionKey          : @(0)} mutableCopy];
    [CRToastManager showNotificationWithOptions:options
                                completionBlock:^{
                                    NSLog(@"Completed");
                                }];
}

#pragma mark -
#pragma mark Utilities
// Convert image to circle
- (UIImage *)convertImageToCircle:(UIImage*)image clipToCircle:(BOOL)clipToCircle withDiamter:(CGFloat)diameter
                      borderColor:(UIColor *)borderColor borderWidth:(CGFloat)borderWidth shadowOffSet:(CGSize)shadowOffset
{
    // increase given size for border and shadow
    CGFloat increase = diameter * 0.1f;
    CGFloat newSize = diameter + increase;
    CGRect newRect = CGRectMake(0.0f, 0.0f, newSize, newSize);
    // fit image inside border and shadow
    CGRect imgRect = CGRectMake(increase, increase, newRect.size.width - (increase * 2.0f), newRect.size.height - (increase * 2.0f));
    UIGraphicsBeginImageContextWithOptions(newRect.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    // draw shadow
    if (!CGSizeEqualToSize(shadowOffset, CGSizeZero))
    {
        CGContextSetShadowWithColor(context, CGSizeMake(shadowOffset.width, shadowOffset.height),
                                    2.0f, [UIColor colorWithWhite:0.0f alpha:0.45f].CGColor);
    }
    // draw border
    if (borderColor && borderWidth)
    {
        CGPathRef borderPath = (clipToCircle) ? CGPathCreateWithEllipseInRect(imgRect, NULL) : CGPathCreateWithRect(imgRect, NULL);
        CGContextAddPath(context, borderPath);
        CGContextSetStrokeColorWithColor(context, borderColor.CGColor);
        CGContextSetLineWidth(context, borderWidth);
        CGContextDrawPath(context, kCGPathFillStroke);
        CGPathRelease(borderPath);
    }
    CGContextRestoreGState(context);
    if (clipToCircle)
    {
        UIBezierPath *imgPath = [UIBezierPath bezierPathWithOvalInRect:imgRect];
        [imgPath addClip];
    }
    [image drawInRect:imgRect];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

// Resize image to scaled width
- (UIImage*)resizeImage:(UIImage*)sourceImage scaledToWidth:(float)width
{
    float oldWidth = sourceImage.size.width;
    float scaleFactor = width / oldWidth;
    
    float newHeight = sourceImage.size.height * scaleFactor;
    float newWidth = oldWidth * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

// Resize image to scaled height
- (UIImage*)resizeImage:(UIImage*)sourceImage scaledToHeight:(float)height
{
    float oldHeight = sourceImage.size.height;
    float scaleFactor = height / oldHeight;
    
    float newWidth = sourceImage.size.width * scaleFactor;
    float newHeight = oldHeight * scaleFactor;
    
    UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
    [sourceImage drawInRect:CGRectMake(0, 0, newWidth, newHeight)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return newImage;
}

// Scale image to new size
- (UIImage*)scaleImage:(UIImage*)sourceImage scaleToSize:(CGSize)newSize
{
    CGRect scaledImageRect = CGRectZero;
    CGFloat aspectWidth = newSize.width / sourceImage.size.width;
    CGFloat aspectHeight = newSize.height / sourceImage.size.height;
    CGFloat aspectRatio = MIN ( aspectWidth, aspectHeight );
    scaledImageRect.size.width = sourceImage.size.width * aspectRatio;
    scaledImageRect.size.height = sourceImage.size.height * aspectRatio;
    scaledImageRect.origin.x = (newSize.width - scaledImageRect.size.width) / 2.0f;
    scaledImageRect.origin.y = (newSize.height - scaledImageRect.size.height) / 2.0f;
    UIGraphicsBeginImageContextWithOptions( newSize, NO, 0);
    [sourceImage drawInRect:scaledImageRect];
    UIImage* scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

// Take snap shot
- (UIImage*)takeSnapshot:(UIView*)view
{
    UIGraphicsBeginImageContextWithOptions(view.bounds.size, NO, [[UIScreen mainScreen] scale]);
    [view.layer renderInContext: UIGraphicsGetCurrentContext()];
    UIImage *viewImage = UIGraphicsGetImageFromCurrentImageContext();
    return viewImage;
}

// Check valid email address
- (BOOL)validateEmail:(NSString*)email
{
    BOOL valid = NO;
    // check email string
    if ([email length] > 0)
    {
        // regular expresion for email string
        NSString *emailRegex = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
        NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegex];
        valid = [emailTest evaluateWithObject:email];
        return valid;
    }
    return valid;
}

// Get random number between 0 and range
- (int)getRandomNumber:(int)range
{
    int r = arc4random_uniform(range);
    return r;
}

// Get media duration
- (NSString*)getMediaDuration:(int)totalSeconds
{
    int seconds = totalSeconds % 60;
    int minutes = (totalSeconds / 60) % 60;
    int hours = totalSeconds / 3600;
    if (hours > 0)
        return [NSString stringWithFormat:@"%02d:%02d:%02d",hours, minutes, seconds];
    else
        return [NSString stringWithFormat:@"%02d:%02d", minutes, seconds];
}

// Get View duration
- (NSString*)getViewedDuration:(int)totalSeconds
{
    // round to top value when result on the second top
    int seconds = totalSeconds;
    int minutes = (seconds)/ 60;
    int hours = (minutes)/60;
    int days = (hours)/24;
    
    NSString *unit = [self getLocalizedString:@"DATE_FORMATE_DAY"];
    int num = totalSeconds;
    if (days > 0)
    {
        num = days;
        if (days > 1)
            unit = [self getLocalizedString:@"DATE_FORMATE_DAYS"];
    }
    else if (hours > 0)
    {
        num = hours;
        unit = (hours > 1) ? [self getLocalizedString:@"DATE_FORMATE_HOURS"] : [self getLocalizedString:@"DATE_FORMATE_HOUR"];
    }
    else if (minutes > 0)
    {
        num = minutes;
        unit = (minutes > 1) ? [self getLocalizedString:@"DATE_FORMATE_MINUTES"] : [self getLocalizedString:@"DATE_FORMATE_MINUTE"];
    }
    else
    {
        num = seconds;
        unit = (seconds > 1) ? [self getLocalizedString:@"DATE_FORMATE_SECONDS"] : [self getLocalizedString:@"DATE_FORMATE_SECOND"];
    }
    return [NSString stringWithFormat:@"%d %@", num, unit];
}

// Return tme interval to string
- (NSString*)timeIntervalToStringWithInterval:(NSTimeInterval)interval
{
    NSString *retVal = @"At time of event";
    if (interval == 0)
        return retVal;
    int second = 1;
    int minute = second*60;
    int hour = minute*60;
    int day = hour*24;
    // interval can be before (negative) or after (positive)
    int num = abs((int)interval);
    NSString *beforeOrAfter = @"";
    NSString *unit = [self getLocalizedString:@"DATE_FORMATE_DAY"];
    NSString *prefix = [self getLocalizedString:@"DATE_FORMATE_PREFIX"];
    if (interval > 0)
    {
        beforeOrAfter = [self getLocalizedString:@"DATE_FORMATE_SUFFIX"];
    }
    if (num >= day)
    {
        num /= day;
        if (num > 1) unit = [self getLocalizedString:@"DATE_FORMATE_DAYS"];
    }
    else if (num >= hour)
    {
        num /= hour;
        unit = (num > 1) ? [self getLocalizedString:@"DATE_FORMATE_HOURS"] : [self getLocalizedString:@"DATE_FORMATE_HOUR"];
    }
    else if (num >= minute)
    {
        num /= minute;
        unit = (num > 1) ? [self getLocalizedString:@"DATE_FORMATE_MINUTES"] : [self getLocalizedString:@"DATE_FORMATE_MINUTE"];
    }
    else if (num >= second)
    {
        num /= second;
        unit = (num > 1) ? [self getLocalizedString:@"DATE_FORMATE_SECONDS"] : [self getLocalizedString:@"DATE_FORMATE_SECOND"];
    }
    return [NSString stringWithFormat:@"%@%d %@ %@", prefix, num, unit, beforeOrAfter];
}

// Add view drop shadow
- (void)addViewDropShadow:(UIView*)view withOpacity:(CGFloat)opacity
{
    // add view drop shadow
    view.layer.masksToBounds = NO;
    view.layer.shadowOffset = CGSizeMake(0.0, 1.0);
    view.layer.shadowRadius = 10.0;
    view.layer.shadowOpacity = opacity;
}

// Flip view direction
- (void)flipViewDirection:(UIView*)view
{
    // EN case
    int transform = 1;
    // AR case
    if (appLanguage == kAppLanguageAR)
        transform = -1;
    [view setTransform:CGAffineTransformMakeScale(transform, 1)];
    //disable all text fields
    for (UIView *v in view.subviews)
    {
        [v setTransform:CGAffineTransformMakeScale(transform, 1)];
        if ([v isKindOfClass:[UITextField class]])
        {
            ((UITextField*)v).textAlignment = NSTextAlignmentLeft;
            if (transform == -1)
                ((UITextField*)v).textAlignment = NSTextAlignmentRight;
        }
        else if ([v isKindOfClass:[UILabel class]])
        {
            // if not aligned center
            if (((UILabel*)v).textAlignment != NSTextAlignmentCenter)
            {
                ((UILabel*)v).textAlignment = NSTextAlignmentLeft;
                if (transform == -1)
                    ((UILabel*)v).textAlignment = NSTextAlignmentRight;
            }
        }
    }
}

- (BOOL)isCloseToCurrentLocation:(double)lat longitude:(double) longitude{
    
    CLLocation *centerLoc = [[CLLocation alloc]initWithLatitude:lat longitude:longitude ];
    CLLocationDistance distance = [currenttUserLocation distanceFromLocation:centerLoc];
    NSLog(@"dist:%f, max:%f ", distance, PICKED_LOCATION_MAX_DISTANCE);
    if(distance <= PICKED_LOCATION_MAX_DISTANCE)
        return YES;
    return NO;
}

- (UIColor*)getColorForText:(NSString *)text{
    if(text && text.length>0){
        const char *c = [text UTF8String];
        int num = toupper(c[0]) - 'A' + 1;
        int index = num % [textColorsArray count];
        UIColor* randomColor = textColorsArray[index];
        return randomColor;
    }
    return textColorsArray[1];
}

-(UIView *) getChatMessagePreviewFor:(ChatMessage *) msg inSize:(CGSize)size extraLeftSpacing:(int)extraLeftSpacing{
    
    UIView *previewContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, size.width, size.height)];
    previewContainer.backgroundColor = [UIColor clearColor];//[UIColor colorWithWhite:0.9 alpha:1.0];
    previewContainer.clipsToBounds = YES;
    //previewContainer.layer.cornerRadius = 5;
    
    UIView *vDecorationBg = [[UIView alloc] initWithFrame:CGRectMake(9.0f + extraLeftSpacing, 24.0f, size.width-23, size.height-26)];
    vDecorationBg.backgroundColor = [UIColor colorWithWhite:0.95 alpha:1.0];
    vDecorationBg.clipsToBounds = YES;
    vDecorationBg.layer.cornerRadius = 5;
    [previewContainer addSubview:vDecorationBg];
    
    //    previewContainer.layer.borderWidth = 0.5f;
    //    previewContainer.layer.borderColor = [UIColor colorWithWhite:0.5 alpha:1.0].CGColor;
    
    UILabel *lblSenderName = [[UILabel alloc] initWithFrame:CGRectMake(12.0f+extraLeftSpacing, 5.0f, size.width-27, 20)];
    lblSenderName.font = [[AppManager sharedManager] getFontType:kAppFontCellNumber];
    lblSenderName.text = msg.sender.username;
    lblSenderName.textColor = [[AppManager sharedManager] getColorType:kAppColorBlue];
    //lblSenderName.backgroundColor = [UIColor blueColor];
    
    if(msg.isMediaMessage){
        CGFloat previewImgDimens = size.height - 32;
        UIImageView *imgPreview = [[UIImageView alloc] initWithFrame:CGRectMake(12.0f + extraLeftSpacing, 27.0f, previewImgDimens, previewImgDimens)];
        //imgPreview.backgroundColor = [UIColor yellowColor];
        UILabel *lblOriginalMsgDescription = [[UILabel alloc] initWithFrame:CGRectMake(previewImgDimens+19 + extraLeftSpacing, 28, size.width -previewImgDimens - 30 , previewImgDimens)];
        lblOriginalMsgDescription.font = [[AppManager sharedManager] getFontType:kAppFontDescription];
        lblOriginalMsgDescription.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
        lblOriginalMsgDescription.numberOfLines = 3;
        //lblOriginalMsgDescription.backgroundColor = [UIColor greenColor];
        if(msg.media.mediaType == kMediaTypeAudio){
            lblOriginalMsgDescription.text = @"Audio";
            imgPreview.image = [UIImage imageNamed:@"messageTypeSound"];
        }else{
            NSString *thumbUrl = @"";
            NSString *description = @"";
            if(msg.isTimelineMsg){
                thumbUrl = msg.thumb;
                description = @"Timeline";
            }else if(msg.media.location){
                thumbUrl = [self getGoogleStaticMaplinkForLat:msg.location.latitude lng:msg.location.longitude width:100 height:100];
                description = @"Map Location";
            }else if(msg.media.mediaType == kMediaTypeImage){
                thumbUrl = msg.media.thumbLink;
                description = @"Photo";
            }else if(msg.media.mediaType == kMediaTypeVideo){
                thumbUrl = msg.media.thumbLink;
                description = @"Video";
            }
            lblOriginalMsgDescription.text = description;
            
            SDWebImageManager *manager = [SDWebImageManager sharedManager];
            [manager downloadImageWithURL:[NSURL URLWithString:thumbUrl] options:SDWebImageRetryFailed
                                 progress:^(NSInteger receivedSize, NSInteger expectedSize) {}
                                completed:^(UIImage *image, NSError *error, SDImageCacheType cacheType, BOOL finished, NSURL *imageURL) {
                                    if (image) {
                                        imgPreview.image = image;
                                    }else{
                                        NSLog(@"Failed to retrieve reply thumb image");
                                    }
                                }];
        }
        
        [previewContainer addSubview:imgPreview];
        [previewContainer addSubview:lblOriginalMsgDescription];
    }else{
        UILabel *lblText = [[UILabel alloc] initWithFrame:CGRectMake(18, 17.0f, size.width - 36, size.height - 14)];
        lblText.font = [[AppManager sharedManager] getFontType:kAppFontCellNumber];
        lblText.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
        lblText.numberOfLines = 3;
        lblText.text = msg.text;
        
        [previewContainer addSubview:lblText];
    }
    
    [previewContainer addSubview:lblSenderName];
    return previewContainer;
}
- (NSString *)getGoogleStaticMaplinkForLat:(float)lat lng:(float)lng width:(int)width height:(int)height{
    NSString* stringURL = [NSString stringWithFormat:@"https://maps.googleapis.com/maps/api/staticmap?markers=color:green|%f,%f&size=%dx%d&zoom=15&style=element:labels|visibility:off&key=%@", lat, lng, width, height, STATIC_MAPS_API_KEY];
    NSString *imageUrl = [stringURL stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    return imageUrl;
}

#pragma mark -
#pragma mark blure image

- (UIImage*) blur:(UIImage*)theImage
{
    // ***********If you need re-orienting (e.g. trying to blur a photo taken from the device camera front facing camera in portrait mode)
    theImage = [self reOrientIfNeeded:theImage];
    
    // create our blurred image
    CIContext *context = [CIContext contextWithOptions:nil];
    CIImage *inputImage = [CIImage imageWithCGImage:theImage.CGImage];
    
    // setting up Gaussian Blur (we could use one of many filters offered by Core Image)
    CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
    [filter setValue:inputImage forKey:kCIInputImageKey];
    [filter setValue:[NSNumber numberWithFloat:3.0f] forKey:@"inputRadius"];
    CIImage *result = [filter valueForKey:kCIOutputImageKey];
    
    // CIGaussianBlur has a tendency to shrink the image a little,
    // this ensures it matches up exactly to the bounds of our original image
    CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
    
    // *************** if you need scaling
    //UIImage *returnImage =  [[self class] scaleIfNeeded:cgImage];
    
    UIImage *returnImage = [UIImage imageWithCGImage:cgImage];//create a UIImage for this function to "return" so that ARC can manage the memory of the blur... ARC can't manage CGImageRefs so we need to release it before this function "returns" and ends.
    CGImageRelease(cgImage);//release CGImageRef because ARC doesn't manage this on its own.
    
    return returnImage;
    
}

- (UIImage*) reOrientIfNeeded:(UIImage*)theImage{
    
    if (theImage.imageOrientation != UIImageOrientationUp) {
        
        CGAffineTransform reOrient = CGAffineTransformIdentity;
        switch (theImage.imageOrientation) {
            case UIImageOrientationDown:
            case UIImageOrientationDownMirrored:
                reOrient = CGAffineTransformTranslate(reOrient, theImage.size.width, theImage.size.height);
                reOrient = CGAffineTransformRotate(reOrient, M_PI);
                break;
            case UIImageOrientationLeft:
            case UIImageOrientationLeftMirrored:
                reOrient = CGAffineTransformTranslate(reOrient, theImage.size.width, 0);
                reOrient = CGAffineTransformRotate(reOrient, M_PI_2);
                break;
            case UIImageOrientationRight:
            case UIImageOrientationRightMirrored:
                reOrient = CGAffineTransformTranslate(reOrient, 0, theImage.size.height);
                reOrient = CGAffineTransformRotate(reOrient, -M_PI_2);
                break;
            case UIImageOrientationUp:
            case UIImageOrientationUpMirrored:
                break;
        }
        
        switch (theImage.imageOrientation) {
            case UIImageOrientationUpMirrored:
            case UIImageOrientationDownMirrored:
                reOrient = CGAffineTransformTranslate(reOrient, theImage.size.width, 0);
                reOrient = CGAffineTransformScale(reOrient, -1, 1);
                break;
            case UIImageOrientationLeftMirrored:
            case UIImageOrientationRightMirrored:
                reOrient = CGAffineTransformTranslate(reOrient, theImage.size.height, 0);
                reOrient = CGAffineTransformScale(reOrient, -1, 1);
                break;
            case UIImageOrientationUp:
            case UIImageOrientationDown:
            case UIImageOrientationLeft:
            case UIImageOrientationRight:
                break;
        }
        
        CGContextRef myContext = CGBitmapContextCreate(NULL, theImage.size.width, theImage.size.height, CGImageGetBitsPerComponent(theImage.CGImage), 0, CGImageGetColorSpace(theImage.CGImage), CGImageGetBitmapInfo(theImage.CGImage));
        
        CGContextConcatCTM(myContext, reOrient);
        
        switch (theImage.imageOrientation) {
            case UIImageOrientationLeft:
            case UIImageOrientationLeftMirrored:
            case UIImageOrientationRight:
            case UIImageOrientationRightMirrored:
                CGContextDrawImage(myContext, CGRectMake(0,0,theImage.size.height,theImage.size.width), theImage.CGImage);
                break;
                
            default:
                CGContextDrawImage(myContext, CGRectMake(0,0,theImage.size.width,theImage.size.height), theImage.CGImage);
                break;
        }
        
        CGImageRef CGImg = CGBitmapContextCreateImage(myContext);
        theImage = [UIImage imageWithCGImage:CGImg];
        
        CGImageRelease(CGImg);
        CGContextRelease(myContext);
    }
    
    return theImage;
}

//  Needs CoreImage.framework

- (void)blurredImageWithImage:(UIImage *)sourceImage onDone:(void(^)(UIImage *blurredImage))onDone{

    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        //  Create our blurred image
        CIContext *context = [CIContext contextWithOptions:nil];
        CIImage *inputImage = [CIImage imageWithCGImage:sourceImage.CGImage];
        
        //  Setting up Gaussian Blur
        CIFilter *filter = [CIFilter filterWithName:@"CIGaussianBlur"];
        [filter setValue:inputImage forKey:kCIInputImageKey];
        [filter setValue:[NSNumber numberWithFloat:2.0f] forKey:@"inputRadius"];
        CIImage *result = [filter valueForKey:kCIOutputImageKey];
        
        /*  CIGaussianBlur has a tendency to shrink the image a little, this ensures it matches
         *  up exactly to the bounds of our original image */
        CGImageRef cgImage = [context createCGImage:result fromRect:[inputImage extent]];
        
        UIImage *retVal = [UIImage imageWithCGImage:cgImage];
        CGImageRelease(cgImage);
        
        dispatch_async(dispatch_get_main_queue(), ^{
            onDone(retVal);
        });
    });
}

-(void) openGoogleMapsAppForLat:(float)lat andLong:(float)lng{
    if([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]]){
        //[[UIApplication sharedApplication] openURL:[NSURL URLWithString:[NSString stringWithFormat:@"comgooglemaps://?daddr=%f ,%f", lat,lng]]];
        NSString *latlong = [NSString stringWithFormat:@"%f,%f",lat,lng];
        NSString *url = [NSString stringWithFormat: @"http://maps.google.com/maps?saddr=&daddr=%@",
                         [latlong stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:url]];
    }
}
//scale image to fill navbar bounds in respect to its aspect ratio then crop the center recatangle and add black overlay to it
-(void) customizeImageForNavBarBackground: (UIImage*) sourceImage completionHandler:(void(^)(UIImage *navBarBackgroundImage)) delegate
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        //nav bar background image size should be 320*44 and 640*88 for @2x
        float oldWidth = sourceImage.size.width;
        
        int barWidth = [UIScreen mainScreen].bounds.size.width + 40;
        int barHeight = 88;
        int cropBegning = 20;
        if ([UIScreen mainScreen].bounds.size.height <= 568)
        {
            barWidth = [UIScreen mainScreen].bounds.size.width + 20;
            barHeight = 44;
            cropBegning = 10;
        }
        float scaleFactor = barWidth / oldWidth;
        // scale up to fill the nav bar
        float newHeight = sourceImage.size.height * scaleFactor;
        float newWidth = oldWidth * scaleFactor;
        UIGraphicsBeginImageContext(CGSizeMake(newWidth, newHeight));
        CGRect newRect = CGRectMake(0, 0, newWidth, newHeight);
        [sourceImage drawInRect:newRect];
        
        //add blackoverlay with opacity
        CGContextRef context = UIGraphicsGetCurrentContext();
        UIColor *blackWithAlpha = [[UIColor alloc] initWithRed:0 green:0 blue:0 alpha:0.3];
        CGContextSetFillColorWithColor(context,blackWithAlpha.CGColor);
        CGContextFillRect(context, newRect);
        //get the new Image
        UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
        //crop center rect of the new image
        CGRect cropRect = CGRectMake(cropBegning, newHeight /2 - barHeight/2, barWidth, barHeight+cropBegning*2);
        
        CGImageRef imageRef = CGImageCreateWithImageInRect([newImage CGImage], cropRect);
        UIImage *cropped = [UIImage imageWithCGImage:imageRef scale:0.0 orientation:sourceImage.imageOrientation];
        CGImageRelease(imageRef);
        UIGraphicsEndImageContext();
        dispatch_async(dispatch_get_main_queue(), ^{
            delegate(cropped);
        });
    });
}
- (CGSize)getExtraSizeForChatMessage{
    CGSize extraSize = CGSizeMake(0,0) ;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if([[UIScreen mainScreen] scale] == 2.0){
            extraSize = CGSizeMake(25, 28);
        }else if([[UIScreen mainScreen] scale] >= 2.0){
            extraSize = CGSizeMake(80, 80);
        }
    }
    return extraSize;
}

@end
