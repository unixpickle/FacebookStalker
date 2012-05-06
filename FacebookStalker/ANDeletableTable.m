//
//  ANDeletableTable.m
//  FacebookStalker
//
//  Created by Alex Nichol on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ANDeletableTable.h"

@implementation ANDeletableTable

@synthesize deleteAction, deleteTarget;

- (BOOL)canBecomeKeyView {
    return YES;
}

- (BOOL)becomeFirstResponder {
    [super becomeFirstResponder];
    return YES;
}

- (void)keyDown:(NSEvent *)theEvent {
    if ([theEvent keyCode] == 51) {
        NSMethodSignature * sig = [deleteTarget methodSignatureForSelector:deleteAction];
        NSInvocation * invoc = [NSInvocation invocationWithMethodSignature:sig];
        [invoc setSelector:deleteAction];
        if ([sig numberOfArguments] >= 3) {
            void * selfPtr = (__bridge void *)self;
            [invoc setArgument:&selfPtr atIndex:2];
        }
        [invoc invokeWithTarget:deleteTarget];
    }
}

@end
