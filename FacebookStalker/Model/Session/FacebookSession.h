//
//  FacebookSession.h
//  FacebookStalker
//
//  Created by Nichol, Alexander on 5/1/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "XMPPFramework.h"
#import "XMPPRoster.h"
#import "XMPPRosterMemoryStorage.h"
#import "ANDataManager.h"

@class FacebookSession;

@protocol FacebookSessionDelegate <NSObject>

@optional
- (void)facebookSessionAuthenticated:(FacebookSession *)_session;
- (void)facebookSessionLoginFailed:(FacebookSession *)_session;
- (void)facebookSessionDisconnected:(FacebookSession *)_session;
- (void)facebookSession:(FacebookSession *)_session gotMessage:(XMPPMessage *)message;
- (void)facebookSession:(FacebookSession *)_session gotPresence:(XMPPPresence *)presence;

@end

@interface FacebookSession : NSObject <XMPPStreamDelegate, XMPPRosterMemoryStorageDelegate> {
    XMPPStream * stream;
    NSString * username;
    NSString * password;
    __weak id<FacebookSessionDelegate> delegate;
    BOOL signedIn;
    Account * account;
    
    XMPPRoster * roster;
    XMPPRosterMemoryStorage * rosterStorage;
    NSMutableArray * firstPresences;
}

@property (nonatomic, weak) id<FacebookSessionDelegate> delegate;
@property (readonly, getter = isSignedIn) BOOL signedIn;
@property (readonly) Account * account;
@property (readonly) NSString * username;
@property (readonly) NSString * password;

- (id)initWithUsername:(NSString *)aUsername password:(NSString *)aPassword;
- (BOOL)beginSession;
- (void)endSession;

@end
