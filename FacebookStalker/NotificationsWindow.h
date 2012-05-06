//
//  NotificationsWindow.h
//  FacebookStalker
//
//  Created by Alex Nichol on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ANDataManager.h"
#import "ANSessionManager.h"

#define kNotificationsWindowWidth 410
#define kNotificationsWindowHeight 200

@interface NotificationsWindow : NSWindow <NSTableViewDelegate, NSTableViewDataSource> {
    NSPopUpButton * accounts;
    NSTableView * buddyTable;
    Account * currentAccount;
    NSArray * buddies;
    BOOL isRegistered;
}

+ (NotificationsWindow *)notificationsWindow;

- (void)accountSelectionChanged:(id)sender;

- (void)registerKVOs;
- (void)unregisterKVOs;
- (void)handleAccountsChanged;
- (void)handleBuddiesChanged;

@end
