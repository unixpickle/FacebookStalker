//
//  LogWindow.m
//  FacebookStalker
//
//  Created by Alex Nichol on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "LogWindow.h"

@implementation LogWindow

+ (LogWindow *)logWindow {
    return [[LogWindow alloc] initWithContentRect:NSMakeRect(0, 0, kLogWindowWidth, kLogWindowHeight)
                                                  styleMask:(NSTitledWindowMask | NSClosableWindowMask | NSResizableWindowMask | NSMiniaturizableWindowMask)
                                                    backing:NSBackingStoreBuffered
                                                      defer:NO screen:[NSScreen mainScreen]];
}

- (id)initWithContentRect:(NSRect)contentRect styleMask:(NSUInteger)aStyle backing:(NSBackingStoreType)bufferingType defer:(BOOL)flag screen:(NSScreen *)screen {
    if ((self = [super initWithContentRect:contentRect styleMask:aStyle backing:bufferingType defer:flag screen:screen])) {
        accounts = [[NSPopUpButton alloc] initWithFrame:NSMakeRect(10, contentRect.size.height - 32, contentRect.size.width - 20, 22) pullsDown:NO];
        tableScrollView = [[NSScrollView alloc] initWithFrame:NSMakeRect(10, 10, contentRect.size.width - 20, contentRect.size.height - 52)];
        eventTable = [[ANDeletableTable alloc] initWithFrame:[[tableScrollView contentView] bounds]];
        
        [accounts setTarget:self];
        [accounts setAction:@selector(accountSelectionChanged:)];
        
        [eventTable setDelegate:self];
        [eventTable setDataSource:self];
        [eventTable setAllowsMultipleSelection:YES];
        [eventTable setDeleteTarget:self];
        [eventTable setDeleteAction:@selector(deleteLogItems:)];
        
        NSTableColumn * buddyColumn = [[NSTableColumn alloc] initWithIdentifier:@"Buddy"];
        [[buddyColumn headerCell] setStringValue:@"Buddy Name"];
        [buddyColumn setWidth:150];
        [eventTable addTableColumn:buddyColumn];
        
        NSTableColumn * detailsColumn = [[NSTableColumn alloc] initWithIdentifier:@"Details"];
        [[detailsColumn headerCell] setStringValue:@"Event Details"];
        [detailsColumn setWidth:150];
        [detailsColumn setEditable:NO];
        [eventTable addTableColumn:detailsColumn];
        
        NSTableColumn * dateColumn = [[NSTableColumn alloc] initWithIdentifier:@"Date"];
        [[dateColumn headerCell] setStringValue:@"Date/Time"];
        [dateColumn setWidth:150];
        [dateColumn setEditable:NO];
        [eventTable addTableColumn:dateColumn];
        
        [tableScrollView setDocumentView:eventTable];
        [tableScrollView setBorderType:NSBezelBorder];
        [tableScrollView setHasVerticalScroller:YES];
        [tableScrollView setHasHorizontalScroller:YES];
        [tableScrollView setAutohidesScrollers:NO];
        
        [self.contentView addSubview:tableScrollView];
        [self.contentView addSubview:accounts];
        [self setLevel:CGShieldingWindowLevel()];
        
        [self setMinSize:self.frame.size];
        [tableScrollView setAutoresizingMask:(NSViewWidthSizable | NSViewHeightSizable)];
        [accounts setAutoresizingMask:(NSViewWidthSizable | NSViewMaxXMargin | NSViewMinYMargin)];
        
        [self handleAccountsChanged];
        [self registerKVOs];
        self.title = @"Event Log";
    }
    return self;
}

- (void)accountSelectionChanged:(id)sender {
    NSInteger index = [accounts indexOfSelectedItem];
    [self unregisterKVOs];
    currentAccount = [[[ANDataManager sharedDataManager] accounts] objectAtIndex:index];
    [self registerKVOs];
    [self handleEventsChanged];
}

- (void)deleteLogItems:(id)sender {
    NSIndexSet * rows = [eventTable selectedRowIndexes];
    NSMutableSet * deleteEvents = [NSMutableSet set];
    [rows enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        Event * evt = [events objectAtIndex:idx];
        [deleteEvents addObject:evt];
        [eventTable deselectRow:idx];
    }];
    if ([deleteEvents count] > 0) {
        [currentAccount removeEventLog:deleteEvents];
        [[ANDataManager sharedDataManager] saveContext];
    }
}

- (void)orderOut:(id)sender {
    [super orderOut:self];
    [self unregisterKVOs];
}

#pragma mark - KVO Observing -

- (void)registerKVOs {
    if (isRegistered) [self unregisterKVOs];
    isRegistered = YES;
    [currentAccount addObserver:self forKeyPath:@"eventLog" options:NSKeyValueObservingOptionNew context:NULL];
    [[ANDataManager sharedDataManager] addObserver:self forKeyPath:@"accounts" options:NSKeyValueObservingOptionNew context:NULL];
}

- (void)unregisterKVOs {
    if (!isRegistered) return;
    isRegistered = NO;
    [currentAccount removeObserver:self forKeyPath:@"eventLog"];
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

- (void)handleEventsChanged {
    BOOL scrollToBottom = YES;
    if ([tableScrollView documentVisibleRect].origin.y == 0) {
        scrollToBottom = YES;
    }
    events = [currentAccount eventsSortedByDate];
    [eventTable reloadData];
    if (scrollToBottom) {
        [eventTable scrollToEndOfDocument:self];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (object == [ANDataManager sharedDataManager]) {
        [self handleAccountsChanged];
    } else {
        // key/value on the current account
        [self handleEventsChanged];
    }
}

#pragma mark - Table View -

- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView {
    return [events count];
}

- (id)tableView:(NSTableView *)tableView objectValueForTableColumn:(NSTableColumn *)tableColumn row:(NSInteger)row {
    if ([[tableColumn identifier] isEqualToString:@"Buddy"]) {
        return [[events objectAtIndex:row] buddyName];
    } else if ([[tableColumn identifier] isEqualToString:@"Details"]) {
        return [(Event *)[events objectAtIndex:row] kind];
    } else {
        NSDate * date = [[events objectAtIndex:row] date];
        NSDateFormatter * dateFormatter = [[NSDateFormatter alloc] init];
        [dateFormatter setDateStyle:NSDateFormatterShortStyle];
        [dateFormatter setTimeStyle:NSDateFormatterShortStyle];
        NSString * dateString = [dateFormatter stringFromDate:date];
        return dateString;
    }
}

@end
