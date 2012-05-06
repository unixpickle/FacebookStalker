//
//  ANPreferences.h
//  FacebookStalker
//
//  Created by Alex Nichol on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ANAutoLaunch.h"

@interface ANPreferences : NSObject {
    NSUserDefaults * defaults;
    ANAutoLaunch * autoLaunch;
}

+ (ANPreferences *)sharedPreferences;

- (BOOL)automaticallySignIn;
- (void)setAutomaticallySignIn:(BOOL)flag;

- (NSString *)username;
- (void)setUsername:(NSString *)value;

- (NSString *)password;
- (void)setPassword:(NSString *)value;

- (BOOL)startAtLogin;
- (void)setStartAtLogin:(BOOL)flag;

- (BOOL)automaticallyReconnect;
- (void)setAutomaticallyReconnect:(BOOL)flag;

- (BOOL)notifyOnMessage;
- (void)setNotifyOnMessage:(BOOL)flag;

@end
