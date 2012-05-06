//
//  Account.h
//  FacebookStalker
//
//  Created by Alex Nichol on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Buddy;

@interface Account : NSManagedObject

@property (nonatomic, retain) NSString * username;
@property (nonatomic, retain) NSSet * eventLog;
@property (nonatomic, retain) NSSet * buddies;

- (NSDictionary *)buddiesByJID;
- (Buddy *)buddyWithJID:(NSString *)jid;
- (Buddy *)addBuddyWithJID:(NSString *)jid nickname:(NSString *)nick;
- (NSArray *)eventsSortedByDate;

@end

@interface Account (CoreDataGeneratedAccessors)

- (void)insertObject:(NSManagedObject *)value inEventLogAtIndex:(NSUInteger)idx;
- (void)removeObjectFromEventLogAtIndex:(NSUInteger)idx;
- (void)insertEventLog:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeEventLogAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInEventLogAtIndex:(NSUInteger)idx withObject:(NSManagedObject *)value;
- (void)replaceEventLogAtIndexes:(NSIndexSet *)indexes withEventLog:(NSArray *)values;
- (void)addEventLogObject:(NSManagedObject *)value;
- (void)removeEventLogObject:(NSManagedObject *)value;
- (void)addEventLog:(NSSet *)values;
- (void)removeEventLog:(NSSet *)values;
- (void)addBuddiesObject:(NSManagedObject *)value;
- (void)removeBuddiesObject:(NSManagedObject *)value;
- (void)addBuddies:(NSSet *)values;
- (void)removeBuddies:(NSSet *)values;

@end
