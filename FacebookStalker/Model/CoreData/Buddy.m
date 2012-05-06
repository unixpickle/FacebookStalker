//
//  Buddy.m
//  FacebookStalker
//
//  Created by Alex Nichol on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Buddy.h"
#import "Account.h"
#import "Event.h"


@implementation Buddy

@dynamic nickname;
@dynamic jabberID;
@dynamic account;
@dynamic events;
@dynamic notify;

- (void)awakeFromInsert {
    [super awakeFromInsert];
    
    self.events = [NSSet set];
    self.notify = [NSNumber numberWithBool:NO];
}

- (Event *)addEventOfKind:(NSString *)kind date:(NSDate *)date {
    NSManagedObjectContext * context = self.managedObjectContext;
    Event * event = [NSEntityDescription insertNewObjectForEntityForName:@"Event"
                                                  inManagedObjectContext:context];
    event.date = date;
    event.kind = kind;
    event.buddyName = self.nickname;
    [self.account addEventLogObject:event];
    [self addEventsObject:event];
    [context save:nil];
    return event;
}

- (NSComparisonResult)compareWithBuddy:(Buddy *)buddy {
    return [self.nickname compare:buddy.nickname];
}

@end
