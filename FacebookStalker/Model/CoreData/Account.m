//
//  Account.m
//  FacebookStalker
//
//  Created by Alex Nichol on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "Account.h"
#import "Buddy.h"


@implementation Account

@dynamic username;
@dynamic eventLog;
@dynamic buddies;

- (void)awakeFromInsert {
    [super awakeFromInsert];
    
    self.eventLog = [NSSet set];
    self.buddies = [NSSet set];
}

- (NSDictionary *)buddiesByJID {
    NSMutableDictionary * buds = [NSMutableDictionary dictionary];
    for (Buddy * buddy in self.buddies) {
        [buds setObject:buddy forKey:buddy.jabberID];
    }
    return buds;
}

- (Buddy *)buddyWithJID:(NSString *)jid {
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Buddy"];
    NSPredicate * jidPredicate = [NSPredicate predicateWithFormat:@"jabberID = %@ AND account.objectID = %@", jid,
                                  self.objectID];
    [fetchRequest setPredicate:jidPredicate];
    NSArray * buddies = [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
    for (Buddy * buddy in buddies) {
        if ([buddy.account isEqual:self]) {
            return buddy;
        }
    }
    Buddy * newBuddy = [self addBuddyWithJID:jid nickname:jid];
    [[self managedObjectContext] save:nil];
    return newBuddy;
}

- (Buddy *)addBuddyWithJID:(NSString *)jid nickname:(NSString *)nick {
    Buddy * buddy = [NSEntityDescription insertNewObjectForEntityForName:@"Buddy"
                                                  inManagedObjectContext:self.managedObjectContext];
    buddy.jabberID = jid;
    buddy.nickname = nick;
    [self addBuddiesObject:buddy];
    return buddy;
}

- (NSArray *)eventsSortedByDate {
    NSFetchRequest * fetchRequest = [[NSFetchRequest alloc] initWithEntityName:@"Event"];
    [fetchRequest setSortDescriptors:[NSArray arrayWithObject:[NSSortDescriptor sortDescriptorWithKey:@"date" ascending:YES]]];
    [fetchRequest setPredicate:[NSPredicate predicateWithFormat:@"account.objectID = %@", self.objectID]];
    return [self.managedObjectContext executeFetchRequest:fetchRequest error:nil];
}

@end
