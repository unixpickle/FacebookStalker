//
//  PreferencesWindow.m
//  FacebookStalker
//
//  Created by Alex Nichol on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "PreferencesWindow.h"

@implementation PreferencesWindow

+ (PreferencesWindow *)preferencesWindow {
    return [[PreferencesWindow alloc] initWithContentRect:NSMakeRect(0, 0, kPreferencesWindowWidth, kPreferencesWindowHeight)
                                                styleMask:(NSTitledWindowMask | NSClosableWindowMask)
                                                  backing:NSBackingStoreBuffered
                                                    defer:NO screen:[NSScreen mainScreen]];
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen {
    if ((self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag screen:screen])) {
        [self setTitle:@"Preferences"];
        CGFloat height = contentRect.size.height;
        NSTextField * usernameLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(12, height - 32, 66, 20)];
        NSTextField * passwordLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(12, height - 64, 66, 20)];
        usernameField = [[NSTextField alloc] initWithFrame:NSMakeRect(86, height - 32, contentRect.size.width - 96, 22)];
        passwordField = [[NSSecureTextField alloc] initWithFrame:NSMakeRect(86, height - 64, contentRect.size.width - 96, 22)];
        autoSignInButton = [[NSButton alloc] initWithFrame:NSMakeRect(10, height - 96, contentRect.size.width - 20, 18)];
        autoLaunchButton = [[NSButton alloc] initWithFrame:NSMakeRect(10, height - 119, contentRect.size.width - 20, 18)];
        autoReconnectButton = [[NSButton alloc] initWithFrame:NSMakeRect(10, height - 142, contentRect.size.width - 20, 18)];
        notifyMessageButton = [[NSButton alloc] initWithFrame:NSMakeRect(10, height - 165, contentRect.size.width - 20, 18)];
        saveButton = [[NSButton alloc] initWithFrame:NSMakeRect(contentRect.size.width - 95, height - 207, 90, 32)];
        
        [usernameField setStringValue:[[ANPreferences sharedPreferences] username]];
        [passwordField setStringValue:[[ANPreferences sharedPreferences] password]];
        
        [autoSignInButton setButtonType:NSSwitchButton];
        [autoSignInButton setBezelStyle:NSRoundedBezelStyle];
        [autoSignInButton setTitle:@"Sign-In upon application launch"];
        [autoSignInButton setTarget:self];
        [autoSignInButton setAction:@selector(autoSigninChange:)];
        [autoSignInButton setState:[[ANPreferences sharedPreferences] automaticallySignIn]];
        
        [autoLaunchButton setButtonType:NSSwitchButton];
        [autoLaunchButton setBezelStyle:NSRoundedBezelStyle];
        [autoLaunchButton setTitle:@"Start automatically at login"];
        [autoLaunchButton setTarget:self];
        [autoLaunchButton setAction:@selector(autoLaunchChange:)];
        [autoLaunchButton setState:[[ANPreferences sharedPreferences] startAtLogin]];
        
        [autoReconnectButton setButtonType:NSSwitchButton];
        [autoReconnectButton setBezelStyle:NSRoundedBezelStyle];
        [autoReconnectButton setTitle:@"Automatically reconnect after 60 seconds"];
        [autoReconnectButton setTarget:self];
        [autoReconnectButton setAction:@selector(autoReconnectChange:)];
        [autoReconnectButton setState:[[ANPreferences sharedPreferences] automaticallyReconnect]];
        
        [notifyMessageButton setButtonType:NSSwitchButton];
        [notifyMessageButton setBezelStyle:NSRoundedBezelStyle];
        [notifyMessageButton setTitle:@"Notify when a new message is received"];
        [notifyMessageButton setTarget:self];
        [notifyMessageButton setAction:@selector(notifyMessageChange:)];
        [notifyMessageButton setState:[[ANPreferences sharedPreferences] notifyOnMessage]];
        
        [usernameLabel setStringValue:@"Username:"];
        [usernameLabel setBackgroundColor:[NSColor clearColor]];
        [usernameLabel setBordered:NO];
        [usernameLabel setSelectable:NO];
        [usernameLabel setAlignment:NSRightTextAlignment];
        
        [passwordLabel setStringValue:@"Password:"];
        [passwordLabel setBackgroundColor:[NSColor clearColor]];
        [passwordLabel setBordered:NO];
        [passwordLabel setSelectable:NO];
        [passwordLabel setAlignment:NSRightTextAlignment];
        
        [saveButton setTitle:@"Done"];
        [saveButton setBezelStyle:NSRoundedBezelStyle];
        [saveButton setTarget:self];
        [saveButton setAction:@selector(donePressed:)];
        
        [[self contentView] addSubview:usernameLabel];
        [[self contentView] addSubview:passwordLabel];
        [[self contentView] addSubview:usernameField];
        [[self contentView] addSubview:passwordField];
        [[self contentView] addSubview:autoSignInButton];
        [[self contentView] addSubview:autoLaunchButton];
        [[self contentView] addSubview:autoReconnectButton];
        [[self contentView] addSubview:notifyMessageButton];
        [[self contentView] addSubview:saveButton];
        [self setLevel:CGShieldingWindowLevel()];
    }
    return self;
}

- (void)autoSigninChange:(id)sender {
    [[ANPreferences sharedPreferences] setAutomaticallySignIn:[autoSignInButton state]];
}

- (void)autoLaunchChange:(id)sender {
    [[ANPreferences sharedPreferences] setStartAtLogin:[autoLaunchButton state]];
}

- (void)autoReconnectChange:(id)sender {
    [[ANPreferences sharedPreferences] setAutomaticallyReconnect:[autoReconnectButton state]];
}

- (void)notifyMessageChange:(id)sender {
    [[ANPreferences sharedPreferences] setNotifyOnMessage:[notifyMessageButton state]];
}

- (void)donePressed:(id)sender {
    NSString * oldUsername = [[ANPreferences sharedPreferences] username];
    NSString * oldPassword = [[ANPreferences sharedPreferences] password];
    if (![oldUsername isEqualToString:[usernameField stringValue]] || ![oldPassword isEqualToString:[passwordField stringValue]]) {
        [[ANPreferences sharedPreferences] setUsername:[usernameField stringValue]];
        [[ANPreferences sharedPreferences] setPassword:[passwordField stringValue]];
        // re-sign in with the new information
        if ([[ANSessionManager sharedSessionManager] isOnline]) {
            [[ANSessionManager sharedSessionManager] signOff];
            [[ANSessionManager sharedSessionManager] signOnWithUsername:[usernameField stringValue]
                                                               password:[passwordField stringValue]];
        }
    }
    [self orderOut:sender];
    [[FocusManager sharedFocusManager] resignAppFocus];
}

@end
