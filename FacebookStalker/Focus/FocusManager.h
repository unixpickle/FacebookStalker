//
//  FocusManager.h
//  FacebookStalker
//
//  Created by Alex Nichol on 7/3/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CarbonAppProcess.h"

@interface FocusManager : NSObject {
    CarbonAppProcess * secondaryMainApp;
}

@property (retain) CarbonAppProcess * secondaryMainApp;

+ (FocusManager *)sharedFocusManager;
- (void)forceAppFocus;
- (void)resignAppFocus;

- (void)showAndCenterWindow:(NSWindow *)aWindow;

@end
