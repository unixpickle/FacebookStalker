//
//  ANAppDelegate.m
//  FacebookStalker
//
//  Created by Alex Nichol on 4/29/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ANAppDelegate.h"

@implementation ANAppDelegate

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    // [DDLog addLogger:[DDTTYLogger sharedInstance]];
    [self configureInitialStatusItem];
    [ANDataManager sharedDataManager];
    [ANNotifications sharedNotifications];
    
    id object = [ANSessionManager sharedSessionManager];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionManagerSignedOn:)
                                                 name:ANSessionManagerSignedOnNotification object:object];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionManagerSignedOff:)
                                                 name:ANSessionManagerSignedOffNotification object:object];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionManagerSignonFailed:)
                                                 name:ANSessionManagerSignonFailedNotification object:object];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionManagerBuddyOffline:)
                                                 name:ANSessionManagerBuddyOfflineNotification object:object];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionManagerBuddyOnline:)
                                                 name:ANSessionManagerBuddyOnlineNotification object:object];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionManagerMessageReceived:)
                                                 name:ANSessionManagerMessageReceivedNotification object:object];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(sessionManagerTypingReceived:)
                                                 name:ANSessionManagerTypingReceivedNotification object:object];
    
    if ([[ANPreferences sharedPreferences] automaticallySignIn]) {
        if ([[[ANPreferences sharedPreferences] username] length] > 0) {
            [self statusItemSignIn:self];
        }
    }
}

- (void)applicationDidResignActive:(NSNotification *)notification {
	[[FocusManager sharedFocusManager] setSecondaryMainApp:[CarbonAppProcess frontmostProcess]];
}

- (void)applicationWillBecomeActive:(NSNotification *)notification {
	CarbonAppProcess * frontmost = [CarbonAppProcess frontmostProcess];
	CarbonAppProcess * current = [CarbonAppProcess currentProcess];
	if (![frontmost isEqual:current]) {
		[[FocusManager sharedFocusManager] setSecondaryMainApp:[CarbonAppProcess frontmostProcess]];
	}
}

#pragma mark - Session Manager -

- (void)sessionManagerSignedOn:(NSNotification *)notification {
    NSLog(@"Signed online");
    [[ANNotifications sharedNotifications] notifyWithType:ANNotificationsTypeSignedOnline
                                                  message:[NSString stringWithFormat:@"Online as %@", [self currentUsername]]];
    [self handleSignonForUsername:[self currentUsername]];
}

- (void)sessionManagerSignedOff:(NSNotification *)notification {
    NSLog(@"Signed off");
    [[ANNotifications sharedNotifications] notifyWithType:ANNotificationsTypeSignedOffline
                                                  message:@"No longer online"];
    [self handleSignoff];

}

- (void)sessionManagerSignonFailed:(NSNotification *)notification {
    [[ANNotifications sharedNotifications] notifyWithType:ANNotificationsTypeSignonFailed
                                                  message:@"Signon failed!"];
}

- (void)sessionManagerBuddyOnline:(NSNotification *)notification {
    Buddy * buddy = [[notification userInfo] objectForKey:kANSessionManagerBuddyKey];
    [buddy addEventOfKind:@"Online" date:[NSDate date]];
    if ([[buddy notify] boolValue]) {
        NSString * message = [NSString stringWithFormat:@"%@ is now online", buddy.nickname];
        [[ANNotifications sharedNotifications] notifyWithType:ANNotificationsTypeBuddyOnline
                                                      message:message];
    }
}

- (void)sessionManagerBuddyOffline:(NSNotification *)notification {
    Buddy * buddy = [[notification userInfo] objectForKey:kANSessionManagerBuddyKey];
    [buddy addEventOfKind:@"Offline" date:[NSDate date]];
    if ([[buddy notify] boolValue]) {
        NSString * message = [NSString stringWithFormat:@"%@ is now offline", buddy.nickname];
        [[ANNotifications sharedNotifications] notifyWithType:ANNotificationsTypeBuddyOffline
                                                      message:message];
    }
}

- (void)sessionManagerMessageReceived:(NSNotification *)notification {
    Buddy * buddy = [[notification userInfo] objectForKey:kANSessionManagerBuddyKey];
    XMPPMessage * msg = [[notification userInfo] objectForKey:kANSessionManagerMessageKey];
    // TODO: use msg for a notification later
    NSLog(@"Message from %@: %@", buddy, [[msg elementForName:@"body"] stringValue]);
    NSString * msgDetails = [NSString stringWithFormat:@"Message: %@", [[msg elementForName:@"body"] stringValue]];
    [buddy addEventOfKind:msgDetails date:[NSDate date]];
    
    if (![[ANPreferences sharedPreferences] notifyOnMessage]) return;
    NSString * noteMsg = [NSString stringWithFormat:@"%@: %@", buddy.nickname, [[msg elementForName:@"body"] stringValue]];
    [[ANNotifications sharedNotifications] notifyWithType:ANNotificationsTypeMessageReceived
                                                  message:noteMsg];
}

- (void)sessionManagerTypingReceived:(NSNotification *)notification {
    Buddy * buddy = [[notification userInfo] objectForKey:kANSessionManagerBuddyKey];
    XMPPMessage * msg = [[notification userInfo] objectForKey:kANSessionManagerMessageKey];
    NSString * noteMsg = nil;
    NSString * logMsg = nil;
    ANNotificationsType noteType = 0;
    BOOL isComposing = NO;
    for (NSXMLElement * child in msg.children) {
        if ([[child name] isEqualToString:@"composing"]) {
            isComposing = YES;
            break;
        }
    }
    if (isComposing) {
        noteMsg = [NSString stringWithFormat:@"%@ is typing...", buddy.nickname];
        logMsg = [NSString stringWithFormat:@"Began Typing", buddy.nickname];
        noteType = ANNotificationsTypeTyping;
    } else {
        noteMsg = [NSString stringWithFormat:@"%@ paused typing", buddy.nickname];
        logMsg = [NSString stringWithFormat:@"Paused Typing", buddy.nickname];
        noteType = ANNotificationsTypeStoppedTyping;
    }
    [buddy addEventOfKind:logMsg date:[NSDate date]];
    
    if (![[ANPreferences sharedPreferences] notifyOnMessage]) return;
    [[ANNotifications sharedNotifications] notifyWithType:noteType
                                                  message:noteMsg];
}

#pragma mark - Status Item -

#pragma mark Actions

- (void)statusItemQuit:(id)sender {
    [[NSApplication sharedApplication] terminate:self];
}

- (void)statusItemPrefences:(id)sender {
    if (preferencesWindow) {
        [preferencesWindow orderOut:self];
    }
    preferencesWindow = [PreferencesWindow preferencesWindow];
    [preferencesWindow setReleasedWhenClosed:NO];
    [[FocusManager sharedFocusManager] showAndCenterWindow:preferencesWindow];
}

- (void)statusItemSignIn:(id)sender {
    NSString * username = [[ANPreferences sharedPreferences] username];
    
    if ([username length] == 0) {
        NSRunAlertPanel(@"Invalid username", @"Before you can log in, you must first set your username in the application preferences", @"OK", nil, nil);
        return;
    }
    
    NSString * password = [[ANPreferences sharedPreferences] password];
    [[ANSessionManager sharedSessionManager] signOnWithUsername:username password:password];
}

- (void)statusItemSignOut:(id)sender {
    [[ANSessionManager sharedSessionManager] signOff];
}

- (void)statusItemLog:(id)sender {
    if (logWindow) {
        [logWindow orderOut:self];
    }
    logWindow = [LogWindow logWindow];
    [logWindow setReleasedWhenClosed:NO];
    [[FocusManager sharedFocusManager] showAndCenterWindow:logWindow];
}

- (void)statusItemNotifications:(id)sender {
    if (notificationsWindow) {
        [notificationsWindow orderOut:self];
    }
    notificationsWindow = [NotificationsWindow notificationsWindow];
    [notificationsWindow setReleasedWhenClosed:NO];
    [[FocusManager sharedFocusManager] showAndCenterWindow:notificationsWindow];
}

#pragma mark Configuring States

- (NSString *)currentUsername {
    return [[ANSessionManager sharedSessionManager] currentUsername];
}

- (void)handleSignonForUsername:(NSString *)aUsername {
    if (isSignedOn) {
        [self handleSignoff];
    }
    isSignedOn = YES;
    
    NSMenu * menu = [systemMenu menu];
    [menu removeItemAtIndex:2];
    
    NSString * usernameTitle = [NSString stringWithFormat:@"Logged in as %@", aUsername];
    NSMenuItem * usernameItem = [[NSMenuItem alloc] initWithTitle:usernameTitle action:nil keyEquivalent:@""];
    [usernameItem setEnabled:NO];
    [menu insertItem:usernameItem atIndex:2];
    [[menu insertItemWithTitle:@"Sign Out" action:@selector(statusItemSignOut:) keyEquivalent:@"" atIndex:3] setTarget:self];
}

- (void)handleSignoff {
    if (!isSignedOn) return;
    isSignedOn = NO;
    NSMenu * menu = [systemMenu menu];
    for (int i = 0; i < 2; i++) {
        [menu removeItemAtIndex:2];
    }
    
    [[menu insertItemWithTitle:@"Sign In" action:@selector(statusItemSignIn:) keyEquivalent:@"" atIndex:2] setTarget:nil];
}

- (void)configureInitialStatusItem {
	NSZone * menuZone = [NSMenu menuZone];
	NSMenu * menu = [[NSMenu allocWithZone:menuZone] init];
	systemMenu = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
		
	[[menu addItemWithTitle:@"Preferences" action:@selector(statusItemPrefences:) keyEquivalent:@""] setTarget:self];
	[menu addItem:[NSMenuItem separatorItem]];
	[[menu addItemWithTitle:@"Sign In" action:@selector(statusItemSignIn:) keyEquivalent:@""] setTarget:self];
    [menu addItem:[NSMenuItem separatorItem]];
    [[menu addItemWithTitle:@"Log..." action:@selector(statusItemLog:) keyEquivalent:@""] setTarget:self];
    [[menu addItemWithTitle:@"Notifications..." action:@selector(statusItemNotifications:) keyEquivalent:@""] setTarget:self];
    [menu addItem:[NSMenuItem separatorItem]];
	[[menu addItemWithTitle:@"Quit" action:@selector(statusItemQuit:) keyEquivalent:@""] setTarget:self];
	
	systemMenu = [[NSStatusBar systemStatusBar] statusItemWithLength:NSSquareStatusItemLength];
    [systemMenu setMenu:menu];
    [systemMenu setHighlightMode:YES];
    [systemMenu setToolTip:@"FBStalker"];
    [systemMenu setImage:[NSImage imageNamed:@"facebookmini.png"]];
    [systemMenu setAlternateImage:[NSImage imageNamed:@"facebookmini_inverted.png"]];
}

@end
