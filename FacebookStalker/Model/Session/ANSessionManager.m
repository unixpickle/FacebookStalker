//
//  ANSessionManager.m
//  FacebookStalker
//
//  Created by Alex Nichol on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ANSessionManager.h"

@interface ANSessionManager (Private)

- (void)fireSignOnNotification;
- (void)fireSignOffNotification;
- (void)fireSignOnFailedNotification;
- (void)fireBuddyOnline:(Buddy *)user;
- (void)fireBuddyOffline:(Buddy *)user;
- (void)fireMessageReceived:(XMPPMessage *)message;
- (void)fireTypingReceived:(XMPPMessage *)message;

@end

@implementation ANSessionManager

@synthesize session;

+ (ANSessionManager *)sharedSessionManager {
    static ANSessionManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ANSessionManager alloc] init];
    });
    return manager;
}

- (void)signOnWithUsername:(NSString *)username password:(NSString *)password {
    if (reconnectTimer) {
        [reconnectTimer invalidate];
        reconnectTimer = nil;
    }
    if (session) {
        [self signOff];
    }
    session = [[FacebookSession alloc] initWithUsername:username password:password];
    [session setDelegate:self];
    [session beginSession];
}

- (void)signOff {
    if (reconnectTimer) {
        [reconnectTimer invalidate];
        reconnectTimer = nil;
    }
    if (session) {
        BOOL wasOnline = [session isSignedIn];
        [session setDelegate:nil];
        [session endSession];
        session = nil;
        if (wasOnline) [self fireSignOffNotification];
    }
}

- (BOOL)isOnline {
    return [session isSignedIn];
}

- (NSString *)currentUsername {
    return session.username;
}

- (void)reconnect {
    reconnectTimer = nil;
    [self signOnWithUsername:reconnUsername password:reconnPassword];
}

#pragma mark - Facebook Session -

- (void)facebookSessionAuthenticated:(FacebookSession *)_session {
    [self fireSignOnNotification];
}

- (void)facebookSessionLoginFailed:(FacebookSession *)_session {
    [self fireSignOnFailedNotification];
    [session endSession];
    session = nil;
}

- (void)facebookSessionDisconnected:(FacebookSession *)_session {
    if ([[ANPreferences sharedPreferences] automaticallyReconnect]) {
        reconnectTimer = [NSTimer scheduledTimerWithTimeInterval:60 target:self selector:@selector(reconnect) userInfo:nil repeats:NO];
        reconnUsername = session.username;
        reconnPassword = session.password;
    }
    [self fireSignOffNotification];
    session = nil;
}

- (void)facebookSession:(FacebookSession *)_session gotMessage:(XMPPMessage *)message {
    if (![message elementForName:@"body"]) {
        BOOL isTyping = NO;
        for (NSXMLElement * element in message.children) {
            if ([[element name] isEqualToString:@"composing"] || [[element name] isEqualToString:@"paused"]) {
                isTyping = YES;
                break;
            }
        }
        if (isTyping) {
            [self fireTypingReceived:message];
        }
    } else {
        [self fireMessageReceived:message];
    }
}

- (void)facebookSession:(FacebookSession *)_session gotPresence:(XMPPPresence *)presence {
    Buddy * buddy = [session.account buddyWithJID:[presence fromStr]];
    if ([[presence type] isEqualToString:@"available"]) {
        [self fireBuddyOnline:buddy];
    } else {
        [self fireBuddyOffline:buddy];
    }
}

#pragma mark - Notifications -

- (void)fireSignOnNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:ANSessionManagerSignedOnNotification object:self];
}

- (void)fireSignOffNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:ANSessionManagerSignedOffNotification object:self];
}

- (void)fireSignOnFailedNotification {
    [[NSNotificationCenter defaultCenter] postNotificationName:ANSessionManagerSignonFailedNotification object:self];
}

- (void)fireBuddyOnline:(Buddy *)user {
    NSDictionary * userInfo = [NSDictionary dictionaryWithObject:user
                                                          forKey:kANSessionManagerBuddyKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:ANSessionManagerBuddyOnlineNotification
                                                        object:self userInfo:userInfo];

}

- (void)fireBuddyOffline:(Buddy *)user {
    NSDictionary * userInfo = [NSDictionary dictionaryWithObject:user
                                                          forKey:kANSessionManagerBuddyKey];
    [[NSNotificationCenter defaultCenter] postNotificationName:ANSessionManagerBuddyOfflineNotification
                                                        object:self userInfo:userInfo];
}

- (void)fireMessageReceived:(XMPPMessage *)message {
    Buddy * buddy = [session.account buddyWithJID:[message fromStr]];
    NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:message, kANSessionManagerMessageKey,
                               buddy, kANSessionManagerBuddyKey, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:ANSessionManagerMessageReceivedNotification
                                                        object:self userInfo:userInfo];
}

- (void)fireTypingReceived:(XMPPMessage *)message {
    Buddy * buddy = [session.account buddyWithJID:[message fromStr]];
    NSDictionary * userInfo = [NSDictionary dictionaryWithObjectsAndKeys:message, kANSessionManagerMessageKey,
                               buddy, kANSessionManagerBuddyKey, nil];
    [[NSNotificationCenter defaultCenter] postNotificationName:ANSessionManagerTypingReceivedNotification
                                                        object:self userInfo:userInfo];
}

@end
