//
//  Buddy.h
//  FacebookStalker
//
//  Created by Alex Nichol on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Account, Event;

@interface Buddy : NSManagedObject

@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSString * jabberID;
@property (nonatomic, retain) Account * account;
@property (nonatomic, retain) NSSet * events;
@property (nonatomic, retain) NSNumber * notify;

- (Event *)addEventOfKind:(NSString *)kind date:(NSDate *)date;

@end

@interface Buddy (CoreDataGeneratedAccessors)

- (void)addEventsObject:(Event *)value;
- (void)removeEventsObject:(Event *)value;
- (void)addEvents:(NSSet *)values;
- (void)removeEvents:(NSSet *)values;

- (NSComparisonResult)compareWithBuddy:(Buddy *)buddy;

@end
