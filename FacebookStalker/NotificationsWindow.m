//
//  NotificationsWindow.m
//  FacebookStalker
//
//  Created by Alex Nichol on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "NotificationsWindow.h"

@implementation NotificationsWindow

+ (NotificationsWindow *)notificationsWindow {
    return [[NotificationsWindow alloc] initWithContentRect:NSMakeRect(0, 0, kNotificationsWindowWidth, kNotificationsWindowHeight)
                                                  styleMask:(NSTitledWindowMask | NSClosableWindowMask | NSResizableWindowMask | NSMiniaturizableWindowMask)
                                                    backing:NSBackingStoreBuffered
                                                      defer:NO screen:[NSScreen mainScreen]];
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen {
    if ((self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag screen:screen])) {
        accounts = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(10, contentRect.size.height - 32, contentRect.size.width - 20, 22) pullsDown:NO];
        NSScrollView * buddyScrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(10, 34, contentRect.size.width - 20, contentRect.size.height - 76)];
        buddyTable = [[NSTableView alloc] initWithFrame:[[buddyScrollView contentView] bounds]];
        NSTextField * detailLabel = [[NSTextField alloc] initWithFrame:NSMakeRect(10, 10, contentRect.size.width - 20, 14)];
        
        [detailLabel setBackgroundColor:[NSColor clearColor]];
        [detailLabel setBordered:NO];
        [detailLabel setSelectable:NO];
        [detailLabel setFont:[NSFont systemFontOfSize:10]];
        [detailLabel setTextColor:[NSColor darkGrayColor]];
        [detailLabel setStringValue:@"Check boxes next to buddies about whom you would like to be notified"];
        
        [accounts setTarget:self];
        [accounts setAction:@selector(accountSelectionChanged:)];
        
        [buddyTable setDelegate:self];
        [buddyTable setDataSource:self];
        
        NSTableColumn * checkColumn = [[NSTableColumn alloc] initWithIdentifier:@"Notify"];
        [[checkColumn headerCell] setStringValue:@"√"];
        [checkColumn setWidth:20];
        [buddyTable addTableColumn:checkColumn];
        
        NSTableColumn * usernameColumn = [[NSTableColumn alloc] initWithIdentifier:@"Username"];
        [[usernameColumn headerCell] setStringValue:@"Username"];
        [usernameColumn setWidth:200];
        [usernameColumn setEditable:NO];
        [buddyTable addTableColumn:usernameColumn];
        
        [buddyScrollView setDocumentView:buddyTable];
        [buddyScrollView setBorderType:NSBezelBorder];
        [buddyScrollView setHasVerticalScroller:YES];
        [buddyScrollView setHasHorizontalScroller:YES];
        [buddyScrollView setAutohidesScrollers:NO];
        
        [self.contentView addSubview:buddyScrollView];
        [self.contentView addSubview:accounts];
        [self.contentView addSubview:detailLabel];
        [self setLevel:CGShieldingWindowLevel()];
        
        [self setMinSize:self.frame.size];
        [buddyScrollView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
        [accounts setAutoresizingMask:(NSViewWidthSizable | NSViewMaxXMargin | NSViewMinYMargin)];
        [detailLabel setAutoresizingMask:NSViewMaxXMargin];
        
        [self handleAccountsChanged];
        [self registerKVOs];
        self.title = @"Notification Preferences";
    }
    return self;
}

- (void)accountSelectionChanged:(id)sender {
    NSInteger index = [accounts indexOfSelectedItem];
    [self unregisterKVOs];
    currentAccount = [[[ANDataManager sharedDataManager] accounts] objectAtIndex:index];
    [self registerKVOs];
    [self handleBuddiesChanged];
}

- (void)orderOut:(id)sender {
    [super orderOut:self];
    [self unregisterKVOs];
}

#pragma mark - KVO Observing -

- (void)registerKVOs {
    if (isRegistered) [self unregisterKVOs];
    isRegistered = YES;
    [currentAccount addObserver:self forKeyPath:@"buddies" options:NSKeyValueObservingOptionNew context:NULL];
    [[ANDataManager sharedDataManager] addObserver:self forKeyPath:@"accounts" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)unregisterKVOs {
    if (!isRegistered) return;
    isRegistered = NO;
    [currentAccount removeObserver:self forKeyPath:@"buddies"];
    [[ANDataManager sharedDataManager] removeObserver:self forKeyPath:@"accounts"];
}

- (void)handleAccountsChanged {
    NSString * current = [[accounts selectedItem] title];
    [accounts removeAllItems];
    for (Account * account in [[ANDataManager sharedDataManager] accounts]) {
        NSString * username = [account username];
        [accounts addItemWithTitle:username];
    }
    if (current) {
        [accounts selectItemWithTitle:current];
    } else {
        if ([[accounts menu] numberOfItems] > 0) {
            NSString * currentUsername = [[ANSessionManager sharedSessionManager] session].account.username;
            if (currentUsername) {
                [accounts selectItemWithTitle:currentUsername];
            } else {
                [accounts selectItemAtIndex:0];
            }
            [self accountSelectionChanged:self];
        }
    }
}

- (void)handleBuddiesChanged {
    buddies = [[[currentAccount buddies] allObjects] sortedArrayUsingSelector:@selector(compareWithBuddy:)];
    [buddyTable reloadData];
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == [ANDataManager sharedDataManager]) {
        [self handleAccountsChanged];
    } else {
        // key/value on the current account
        [self handleBuddiesChanged];
    }
}

#pragma mark - Table View -

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [buddies count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([[tableColumn identifier] isEqualToString:@"Notify"]) {
        return [[buddies objectAtIndex:row] notify];
    } else {
        return [[buddies objectAtIndex:row] nickname];
    }
}

- (void)tableView:(NSTableView *)tableView setObjectValue:(id)object forTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    Buddy * buddy = [buddies objectAtIndex:row];
    [buddy setNotify:object];
    [[ANDataManager sharedDataManager] saveContext];
    [self handleBuddiesChanged];
}

- (NSCell *)tableView:(NSTableView *)tableView dataCellForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([[tableColumn identifier] isEqualToString:@"Notify"]) {
        NSButtonCell * cell = [[NSButtonCell alloc] init];
        [cell setButtonType:NSSwitchButton];
        [cell setTitle:@""];
        return cell;
    }
    return nil;
}

@end
