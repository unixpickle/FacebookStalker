//
//  PreferencesWindow.h
//  FacebookStalker
//
//  Created by Alex Nichol on 5/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ANPreferences.h"
#import "FocusManager.h"
#import "ANSessionManager.h"

#define kPreferencesWindowWidth 440
#define kPreferencesWindowHeight 212

@interface PreferencesWindow : NSWindow {
    NSTextField * usernameField;
    NSTextField * passwordField;
    NSButton * autoSignInButton;
    NSButton * autoLaunchButton;
    NSButton * autoReconnectButton;
    NSButton * notifyMessageButton;
    NSButton * saveButton;
}

+ (PreferencesWindow *)preferencesWindow;

- (void)autoSigninChange:(id)sender;
- (void)autoLaunchChange:(id)sender;
- (void)autoReconnectChange:(id)sender;
- (void)notifyMessageChange:(id)sender;
- (void)donePressed:(id)sender;

@end
