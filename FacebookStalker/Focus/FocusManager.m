//
//  FocusManager.m
//  FacebookStalker
//
//  Created by Alex Nichol on 7/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "FocusManager.h"


@implementation FocusManager

@synthesize secondaryMainApp;

+ (FocusManager *)sharedFocusManager {
	static FocusManager * man = nil;
	if (!man) man = [[FocusManager alloc] init];
	return man;
}

- (void)forceAppFocus {
	if (![[CarbonAppProcess currentProcess] isEqual:[CarbonAppProcess frontmostProcess]]) {
		[self setSecondaryMainApp:[CarbonAppProcess frontmostProcess]];
	}
	[[CarbonAppProcess currentProcess] makeFrontmost];
}

- (void)resignAppFocus {
	[self.secondaryMainApp makeFrontmost];
}

- (void)showAndCenterWindow:(NSWindow *)aWindow {
    NSRect frame = aWindow.frame;
    NSRect bounds = [[NSScreen mainScreen] frame];
    frame.origin.x = round((bounds.size.width - frame.size.width) / 2);
    frame.origin.y = round((bounds.size.height - frame.size.height) / 2);
    [aWindow setFrameOrigin:frame.origin];
    [aWindow makeKeyAndOrderFront:self];
    [self forceAppFocus];
}

@end
