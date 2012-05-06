//
//  ANPreferences.m
//  FacebookStalker
//
//  Created by Alex Nichol on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ANPreferences.h"

@interface ANPreferences (Private)

- (BOOL)getBooleanValue:(NSString *)name initial:(BOOL)defValue;
- (void)setBooleanValue:(BOOL)value forName:(NSString *)name;
- (NSString *)getStringValue:(NSString *)name initial:(NSString *)defValue;
- (void)setStringValue:(NSString *)value forName:(NSString *)name;

@end

@implementation ANPreferences

+ (ANPreferences *)sharedPreferences {
    static ANPreferences * preferences = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        preferences = [[ANPreferences alloc] init];
    });
    return preferences;
}

- (id)init {
    if ((self = [super init])) {
        defaults = [NSUserDefaults standardUserDefaults];
        autoLaunch = [ANAutoLaunch autoLauncheForCurrentBundle];
    }
    return self;
}

- (BOOL)automaticallySignIn {
    return [self getBooleanValue:@"autosignin" initial:YES];
}

- (void)setAutomaticallySignIn:(BOOL)flag {
    [self setBooleanValue:flag forName:@"autosignin"];
}

- (NSString *)username {
    return [self getStringValue:@"username" initial:@""];
}

- (void)setUsername:(NSString *)value {
    [self setStringValue:value forName:@"username"];
}

- (NSString *)password {
    return [self getStringValue:@"password" initial:@""];
}

- (void)setPassword:(NSString *)value {
    [self setStringValue:value forName:@"password"];
}

- (BOOL)startAtLogin {
    return [autoLaunch bundleExistsInLaunchItems];
}

- (void)setStartAtLogin:(BOOL)flag {
    if (flag != [self startAtLogin]) {
        if (flag) {
            [autoLaunch addBundleToLaunchItems];
        } else {
            [autoLaunch removeBundleFromLaunchItems];
        }
    }
}

- (BOOL)automaticallyReconnect {
    return [self getBooleanValue:@"reconnect" initial:NO];
}

- (void)setAutomaticallyReconnect:(BOOL)flag {
    [self setBooleanValue:flag forName:@"reconnect"];
}

- (BOOL)notifyOnMessage {
    return [self getBooleanValue:@"noteMsg" initial:YES];
}

- (void)setNotifyOnMessage:(BOOL)flag {
    [self setBooleanValue:flag forName:@"noteMsg"];
}

#pragma mark - Generic -

- (BOOL)getBooleanValue:(NSString *)name initial:(BOOL)defValue {
    NSNumber * number = [defaults valueForKey:name];
    if (!number) {
        [defaults setBool:defValue forKey:name];
        [defaults synchronize];
        return defValue;
    }
    return [number boolValue];
}

- (void)setBooleanValue:(BOOL)value forName:(NSString *)name {
    [defaults setBool:value forKey:name];
    [defaults synchronize];
}

- (NSString *)getStringValue:(NSString *)name initial:(NSString *)defValue {
    NSString * value = [defaults valueForKey:name];
    if (!value) {
        [defaults setObject:defValue forKey:name];
        [defaults synchronize];
        return defValue;
    }
    return value;
}

- (void)setStringValue:(NSString *)value forName:(NSString *)name {
    [defaults setObject:value forKey:name];
    [defaults synchronize];
}

@end
