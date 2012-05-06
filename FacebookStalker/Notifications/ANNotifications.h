//
//  ANNotifications.h
//  FacebookStalker
//
//  Created by Alex Nichol on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Growl/Growl.h>
#import "ANNotificationWindow.h"

/*
 <string>Buddy Online</string>
 <string>Buddy Offline</string>
 <string>Message Received</string>
 <string>Signed Online</string>
 <string>Signed Offline</string>
 <string>Signon Failed</string>
 */

typedef enum {
    ANNotificationsTypeBuddyOnline,
    ANNotificationsTypeBuddyOffline,
    ANNotificationsTypeMessageReceived,
    ANNotificationsTypeSignedOnline,
    ANNotificationsTypeSignedOffline,
    ANNotificationsTypeSignonFailed,
    ANNotificationsTypeTyping,
    ANNotificationsTypeStoppedTyping
} ANNotificationsType;

@interface ANNotifications : NSObject <GrowlApplicationBridgeDelegate> {
    BOOL supportsGrowl;
}

@property (readonly) BOOL supportsGrowl;

+ (ANNotifications *)sharedNotifications;
- (void)notifyWithType:(ANNotificationsType)type message:(NSString *)message;

@end
