//
//  ANNotifications.m
//  FacebookStalker
//
//  Created by Alex Nichol on 5/5/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ANNotifications.h"

@implementation ANNotifications

@synthesize supportsGrowl;

+ (ANNotifications *)sharedNotifications {
    static ANNotifications * notifications;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        notifications = [[ANNotifications alloc] init];
    });
    return notifications;
}

- (id)init {
    if ((self = [super init])) {
        if ([GrowlApplicationBridge isGrowlRunning]) {
            [GrowlApplicationBridge setGrowlDelegate:self];
            supportsGrowl = YES;
        }
    }
    return self;
}

- (void)notifyWithType:(ANNotificationsType)type message:(NSString *)message {
    NSArray * titles = [NSArray arrayWithObjects:@"Buddy Online",
                        @"Buddy Offline",
                        @"Message Received",
                        @"Signed Online",
                        @"Signed Offline",
                        @"Signon Failed", 
                        @"Typing",
                        @"Stopped Typing", nil];
    [GrowlApplicationBridge notifyWithTitle:[titles objectAtIndex:type]
                                description:message
                           notificationName:[titles objectAtIndex:type]
                                   iconData:nil
                                   priority:0
                                   isSticky:NO
                               clickContext:@"Show"];
}

@end
