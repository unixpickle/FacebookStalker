//
//  ANNotificationBackground.m
//  FacebookStalker
//
//  Created by Alex Nichol on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ANNotificationBackground.h"

@implementation ANNotificationBackground

- (id)initWithFrame:(NSRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

- (NSView *)hitTest:(NSPoint)aPoint {
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    // Drawing code here.
    [[NSColor colorWithCalibratedWhite:0 alpha:0.75] set];
    [[NSBezierPath bezierPathWithRoundedRect:self.bounds xRadius:5 yRadius:5] fill];
}

@end
