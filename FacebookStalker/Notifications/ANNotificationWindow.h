//
//  ANNotificationWindow.h
//  FacebookStalker
//
//  Created by Alex Nichol on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ANNotificationBackground.h"

#define kNotificationWidth 270

@interface ANNotificationWindow : NSWindow {
    NSTimer * vanishTimer;
}

+ (NSMutableArray *)visibleNotifications;
+ (NSPoint)pointForWindow:(NSWindow *)noteWindow;

- (id)initWithTitle:(NSString *)title message:(NSString *)message;
- (void)show;
- (void)dispose;

@end
