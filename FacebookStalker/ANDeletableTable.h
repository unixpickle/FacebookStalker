//
//  ANDeletableTable.h
//  FacebookStalker
//
//  Created by Alex Nichol on 5/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ANDeletableTable : NSTableView {
    __unsafe_unretained id deleteTarget;
    SEL deleteAction;
}

@property (assign) id deleteTarget;
@property (readwrite) SEL deleteAction;

@end
