//
//  ANSessionManager.h
//  FacebookStalker
//
//  Created by Alex Nichol on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FacebookSession.h"
#import "ANDataManager.h"
#import "ANPreferences.h"

#define ANSessionManagerSignedOnNotification @"ANSessionManagerSignedOnNotification"
#define ANSessionManagerSignonFailedNotification @"ANSessionManagerSignonFailedNotification"
#define ANSessionManagerSignedOffNotification @"ANSessionManagerSignedOffNotification"
#define ANSessionManagerBuddyOnlineNotification @"ANSessionManagerBuddyOnlineNotification"
#define ANSessionManagerBuddyOfflineNotification @"ANSessionManagerBuddyOfflineNotification"
#define ANSessionManagerMessageReceivedNotification @"ANSessionManagerMessageReceivedNotification"
#define ANSessionManagerTypingReceivedNotification @"ANSessionManagerTypingReceivedNotification"

#define kANSessionManagerMessageKey @"message"
#define kANSessionManagerBuddyKey @"user"

@interface ANSessionManager : NSObject <FacebookSessionDelegate> {
    FacebookSession * session;
    
    NSTimer * reconnectTimer;
    NSString * reconnUsername, * reconnPassword;
}

@property (readonly) FacebookSession * session;

+ (ANSessionManager *)sharedSessionManager;

- (void)signOnWithUsername:(NSString *)username password:(NSString *)password;
- (void)signOff;
- (BOOL)isOnline;
- (NSString *)currentUsername;

- (void)reconnect;

@end
