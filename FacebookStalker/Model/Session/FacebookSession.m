//
//  FacebookSession.m
//  FacebookStalker
//
//  Created by Nichol, Alexander on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "FacebookSession.h"

@implementation FacebookSession

@synthesize delegate;
@synthesize signedIn;
@synthesize account;
@synthesize username;
@synthesize password;

- (id)initWithUsername:(NSString *)aUsername password:(NSString *)aPassword {
    if ((self = [super init])) {
        username = aUsername;
        password = aPassword;
    }
    return self;
}

- (BOOL)beginSession {
    NSString * jid = [NSString stringWithFormat:@"%@@chat.facebook.com", username];
    stream = [[XMPPStream alloc] init];
    [stream setMyJID:[XMPPJID jidWithString:jid]];
    [stream addDelegate:self delegateQueue:dispatch_get_main_queue()];
    
    // configure roster
    rosterStorage = [[XMPPRosterMemoryStorage alloc] init];
    roster = [[XMPPRoster alloc] initWithRosterStorage:rosterStorage];
    [roster addDelegate:self delegateQueue:dispatch_get_main_queue()];
    [roster activate:stream];
    
    if (![stream connect:nil]) {
        return NO;
    }
    return YES;
}

- (void)endSession {
    signedIn = NO;
    [stream disconnect];
    stream = nil;
}

#pragma mark - XMPP Callbacks -

- (void)xmppStreamDidConnect:(XMPPStream *)sender {
    [stream authenticateWithPassword:password error:nil];
}

- (void)xmppStreamDidAuthenticate:(XMPPStream *)sender {
    account = [[ANDataManager sharedDataManager] accountForUsername:username];
    firstPresences = [[NSMutableArray alloc] init];
    // send our initial presence
    XMPPPresence * presence = [[XMPPPresence alloc] initWithName:@"presence"];
    [presence addAttributeWithName:@"from" stringValue:[stream.myJID description]];
    [stream sendElement:presence];
    
    signedIn = YES;
    
    if ([delegate respondsToSelector:@selector(facebookSessionAuthenticated:)]) {
        [delegate facebookSessionAuthenticated:self];
    }
}

- (void)xmppStream:(XMPPStream *)sender didNotAuthenticate:(NSXMLElement *)error {
    if ([delegate respondsToSelector:@selector(facebookSessionLoginFailed:)]) {
        [delegate facebookSessionLoginFailed:self];
    }
    [stream removeDelegate:self];
}

- (void)xmppStreamDidDisconnect:(XMPPStream *)sender withError:(NSError *)error {
    signedIn = NO;
    if ([delegate respondsToSelector:@selector(facebookSessionDisconnected:)]) {
        [delegate facebookSessionDisconnected:self];
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceiveMessage:(XMPPMessage *)message {
    if ([delegate respondsToSelector:@selector(facebookSession:gotMessage:)]) {
        [delegate facebookSession:self gotMessage:message];
    }
}

- (void)xmppStream:(XMPPStream *)sender didReceivePresence:(XMPPPresence *)presence {
    if (![firstPresences containsObject:[presence fromStr]]) {
        [firstPresences addObject:[presence fromStr]];
        return;
    }
    if ([delegate respondsToSelector:@selector(facebookSession:gotPresence:)]) {
        [delegate facebookSession:self gotPresence:presence];
    }
}

#pragma mark Roster

- (void)xmppRoster:(XMPPRosterMemoryStorage *)sender didAddUser:(XMPPUserMemoryStorageObject *)user {
    Buddy * buddy = [account buddyWithJID:[user.jid description]];
    buddy.nickname = user.nickname;
    [[ANDataManager sharedDataManager] saveContext];
}

- (void)xmppRoster:(XMPPRosterMemoryStorage *)sender didRemoveUser:(XMPPUserMemoryStorageObject *)user {
    Buddy * buddy = [account buddyWithJID:[user.jid description]];
    [account removeBuddiesObject:buddy];
    [[ANDataManager sharedDataManager] saveContext];
}

- (void)xmppRoster:(XMPPRosterMemoryStorage *)sender didUpdateUser:(XMPPUserMemoryStorageObject *)user {
    Buddy * buddy = [account buddyWithJID:[user.jid description]];
    buddy.nickname = user.nickname;
    [[ANDataManager sharedDataManager] saveContext];
}

- (void)xmppRosterDidPopulate:(XMPPRosterMemoryStorage *)sender {
    NSArray * users = [sender unsortedUsers];
    NSMutableDictionary * buddies = [[account buddiesByJID] mutableCopy];
    NSMutableSet * addedBuddies = [NSMutableSet set];
    for (XMPPUserMemoryStorageObject * object in users) {
        Buddy * buddy = [buddies objectForKey:[object.jid description]];
        if (buddy) {
            buddy.nickname = object.nickname;
        } else {
            NSLog(@"Creating a new buddy");
            Buddy * buddy = [NSEntityDescription insertNewObjectForEntityForName:@"Buddy"
                                                          inManagedObjectContext:account.managedObjectContext];
            buddy.jabberID = [object.jid description];
            buddy.nickname = object.nickname;
            [addedBuddies addObject:buddy];
        }
    }
    if ([addedBuddies count] > 0) {
        [account addBuddies:addedBuddies];
    }
    [[ANDataManager sharedDataManager] saveContext];
}

@end
