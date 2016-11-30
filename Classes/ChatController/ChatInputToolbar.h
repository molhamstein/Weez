//  Weez
//
//  Created by Molham on 7/31/16.
//  Copyright © 2016 AlphaApps. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

#import "JSQMessagesInputToolbar.h"

@class ChatInputToolbar;


@interface ChatInputToolbar : JSQMessagesInputToolbar
{
    CGRect minimizedTextFieldFrame;
    CGRect maximizedTextFieldFrame;
}


-(void) maximizeTextField;
-(void) minimizeTextField;


@end
