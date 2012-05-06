//
//  ANAppDelegate.h
//  FacebookStalker
//
//  Created by Alex Nichol on 4/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "DDTTYLogger.h"
#import "FacebookSession.h"
#import "FocusManager.h"
#import "PreferencesWindow.h"
#import "NotificationsWindow.h"
#import "LogWindow.h"
#import "ANNotifications.h"

@interface ANAppDelegate : NSObject <NSApplicationDelegate, FacebookSessionDelegate> {
    FacebookSession * session;
    
    NSStatusItem * systemMenu;
    BOOL isSignedOn;
    
    PreferencesWindow * preferencesWindow;
    NotificationsWindow * notificationsWindow;
    LogWindow * logWindow;
}

- (void)sessionManagerSignedOn:(NSNotification *)notification;
- (void)sessionManagerSignedOff:(NSNotification *)notification;
- (void)sessionManagerSignonFailed:(NSNotification *)notification;
- (void)sessionManagerBuddyOnline:(NSNotification *)notification;
- (void)sessionManagerBuddyOffline:(NSNotification *)notification;
- (void)sessionManagerMessageReceived:(NSNotification *)notification;
- (void)sessionManagerTypingReceived:(NSNotification *)notification;

- (NSString *)currentUsername;
- (void)handleSignonForUsername:(NSString *)aUsername;
- (void)handleSignoff;

- (void)statusItemQuit:(id)sender;
- (void)statusItemPrefences:(id)sender;
- (void)statusItemSignIn:(id)sender;
- (void)statusItemSignOut:(id)sender;
- (void)statusItemLog:(id)sender;
- (void)statusItemNotifications:(id)sender;

- (void)configureInitialStatusItem;

@end
