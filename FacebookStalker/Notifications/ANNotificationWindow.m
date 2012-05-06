//
//  ANNotificationWindow.m
//  FacebookStalker
//
//  Created by Alex Nichol on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ANNotificationWindow.h"

// code from http://stackoverflow.com/questions/1992950/nsstring-sizewithattributes-content-rect
static float heightForStringDrawing (NSString * myString, NSFont * myFont, float myWidth);

@implementation ANNotificationWindow

+ (NSMutableArray *)visibleNotifications {
    static NSMutableArray * notes = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        notes = [[NSMutableArray alloc] init];
    });
    return notes;
}

+ (NSPoint)pointForWindow:(NSWindow *)noteWindow {
    NSSize screenSize = [[NSScreen mainScreen] frame].size;
    NSSize size = noteWindow.frame.size;
    NSPoint start = NSMakePoint(screenSize.width - size.width - 20, screenSize.height - size.height - 30);
    for (NSWindow * window in [self visibleNotifications]) {
        NSRect ourFrame = NSMakeRect(start.x, start.y, size.width, size.height);
        if (CGRectIntersectsRect(NSRectToCGRect(ourFrame), NSRectToCGRect(window.frame))) {
            start.y = window.frame.origin.y - size.height - 10;
        }
    }
    return start;
}

- (id)initWithTitle:(NSString *)title message:(NSString *)message {
    NSFont * messageFont = [NSFont systemFontOfSize:12];
    float height = heightForStringDrawing(message, messageFont, kNotificationWidth - 20);
    if ((self = [super initWithContentRect:NSMakeRect(0, 0, kNotificationWidth, height + 40) styleMask:NSBorderlessWindowMask backing:NSBackingStoreBuffered defer:NO])) {
        self.contentView = [[ANNotificationBackground alloc] initWithFrame:NSMakeRect(0, 0, kNotificationWidth, height + 40)];
        [self setOpaque:NO];
        [self setHasShadow:YES];
        [self setBackgroundColor:[NSColor clearColor]];
        [self setLevel:CGShieldingWindowLevel()];
        
        NSTextField * titleField = [[NSTextField alloc] initWithFrame:NSMakeRect(10, height + 15, kNotificationWidth - 20, 18)];
        NSTextView * detailField = [[NSTextView alloc] initWithFrame:NSMakeRect(10, 7, kNotificationWidth - 14, height)];
        
        [titleField setFont:[NSFont boldSystemFontOfSize:14]];
        [titleField setBackgroundColor:[NSColor clearColor]];
        [titleField setBordered:NO];
        [titleField setSelectable:NO];
        [titleField setTextColor:[NSColor whiteColor]];
        [titleField setStringValue:title];

        [detailField setFont:messageFont];
        [detailField setBackgroundColor:[NSColor clearColor]];
        [detailField setSelectable:NO];
        [detailField setEditable:NO];
        [detailField setTextColor:[NSColor whiteColor]];
        [detailField setString:message];
        [detailField setDrawsBackground:NO];
        
        [self.contentView addSubview:titleField];
        [self.contentView addSubview:detailField];
    }
    return self;
}

- (void)show {
    [self setFrameOrigin:[[self class] pointForWindow:self]];
    [[[self class] visibleNotifications] addObject:self];
    vanishTimer = [NSTimer scheduledTimerWithTimeInterval:15 target:self selector:@selector(dispose) userInfo:nil repeats:NO];
    [self setAlphaValue:0];
    [self makeKeyAndOrderFront:self];
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:1];
    [[self animator] setAlphaValue:1];
    [NSAnimationContext endGrouping];
}

- (void)dispose {
    [NSAnimationContext beginGrouping];
    [[NSAnimationContext currentContext] setDuration:0.5];
    [[NSAnimationContext currentContext] setCompletionHandler:^{
        [[NSAnimationContext currentContext] setCompletionHandler:nil];
        [self orderOut:self];
        [[[self class] visibleNotifications] removeObject:self];
    }];
    [[self animator] setAlphaValue:0];
    [NSAnimationContext endGrouping];
}

- (void)mouseDown:(NSEvent *)theEvent {
    [vanishTimer invalidate];
    vanishTimer = nil;
    [self dispose];
}

@end

static float heightForStringDrawing (NSString * myString, NSFont * myFont, float myWidth) {
    NSTextStorage * textStorage = [[NSTextStorage alloc] initWithString:myString];
    NSTextContainer * textContainer = [[NSTextContainer alloc] initWithContainerSize:NSMakeSize(myWidth, FLT_MAX)];
    
    NSLayoutManager * layoutManager = [[NSLayoutManager alloc] init];
    [layoutManager addTextContainer:textContainer];
    [textStorage addLayoutManager:layoutManager];
    [textStorage addAttribute:NSFontAttributeName value:myFont
                        range:NSMakeRange(0, [textStorage length])];
    [textContainer setLineFragmentPadding:0.0];
    
    [layoutManager glyphRangeForTextContainer:textContainer];
    return [layoutManager usedRectForTextContainer:textContainer].size.height;
}
