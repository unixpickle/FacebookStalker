//
//  LogWindow.h
//  FacebookStalker
//
//  Created by Alex Nichol on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ANDataManager.h"
#import "ANSessionManager.h"
#import "ANDeletableTable.h"

#define kLogWindowWidth 500
#define kLogWindowHeight 200

@interface LogWindow : NSWindow <NSTableViewDelegate, NSTableViewDataSource> {
    NSPopUpButton * accounts;
    NSScrollView * tableScrollView;
    ANDeletableTable * eventTable;
    Account * currentAccount;
    NSArray * events;
    BOOL isRegistered;
}

+ (LogWindow *)logWindow;

- (void)accountSelectionChanged:(id)sender;
- (void)deleteLogItems:(id)sender;

- (void)registerKVOs;
- (void)unregisterKVOs;
- (void)handleAccountsChanged;
- (void)handleEventsChanged;

@end
