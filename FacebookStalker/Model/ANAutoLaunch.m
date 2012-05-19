//
//  ANAutoLaunch.m
//  FacebookStalker
//
//  Created by Alex Nichol on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ANAutoLaunch.h"

@implementation ANAutoLaunch

+ (ANAutoLaunch *)autoLauncheForCurrentBundle {
    return [[ANAutoLaunch alloc] initWithBundlePath:[[NSBundle mainBundle] bundlePath]];
}

- (id)initWithBundlePath:(NSString *)appBundle {
    if ((self = [super init])) {
        bundlePath = [appBundle stringByStandardizingPath];
    }
    return self;
}

- (BOOL)bundleExistsInLaunchItems {
    BOOL wasFound = NO;
	UInt32 seed;
	LSSharedFileListRef theLoginItemsRefs = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
	CFArrayRef loginItems = LSSharedFileListCopySnapshot(theLoginItemsRefs, &seed);
	for (int i = 0; i < CFArrayGetCount(loginItems); i++) {
		CFTypeRef object = CFArrayGetValueAtIndex(loginItems, i);
		LSSharedFileListItemRef item = (LSSharedFileListItemRef)object;
		CFURLRef itemURL;
		if (LSSharedFileListItemResolve(item, 0, &itemURL, NULL) == noErr) {
			CFStringRef origPath = CFURLCopyFileSystemPath(itemURL, kCFURLPOSIXPathStyle);
			NSString * string = [(__bridge_transfer NSString *)origPath stringByStandardizingPath];
			if ([string isEqualToString:bundlePath]) {
				wasFound = YES;
			}
			CFRelease(itemURL);
			if (wasFound) break;
		}
	}
	CFRelease(loginItems);
	CFRelease(theLoginItemsRefs);
	return wasFound;
}

- (void)addBundleToLaunchItems {
    LSSharedFileListRef theLoginItemsRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
	CFURLRef url = (__bridge CFURLRef)[NSURL fileURLWithPath:bundlePath];
	LSSharedFileListItemRef item = LSSharedFileListInsertItemURL(theLoginItemsRef, kLSSharedFileListItemLast, NULL, NULL, url, NULL, NULL);
	if (item) CFRelease(item);
	CFRelease(theLoginItemsRef);
}

- (void)removeBundleFromLaunchItems {
    UInt32 seed;
	LSSharedFileListRef theLoginItemsRef = LSSharedFileListCreate(NULL, kLSSharedFileListSessionLoginItems, NULL);
	CFURLRef url = CFURLCreateFilePathURL(NULL, (__bridge CFURLRef)[NSURL fileURLWithPath:bundlePath], NULL);
	CFArrayRef items = LSSharedFileListCopySnapshot(theLoginItemsRef, &seed);
	for (CFIndex i = 0; i < CFArrayGetCount(items); i++) {
		CFTypeRef object = CFArrayGetValueAtIndex(items, i);
		LSSharedFileListItemRef item = (LSSharedFileListItemRef)object;
		CFURLRef itemURL;
		if (LSSharedFileListItemResolve(item, 0, &itemURL, NULL) == noErr) {
			CFStringRef origPath = CFURLCopyFileSystemPath(itemURL, kCFURLPOSIXPathStyle);
			NSString * string = [(__bridge_transfer NSString *)origPath stringByStandardizingPath];
			if ([string isEqualToString:bundlePath]) {
				LSSharedFileListItemRemove(theLoginItemsRef, item);
				CFRelease(itemURL);
				break;
			}
		}
		CFRelease(itemURL);
	}
	CFRelease(items);
	CFRelease(url);
	CFRelease(theLoginItemsRef);
}

@end
