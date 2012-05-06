//
//  Event.h
//  FacebookStalker
//
//  Created by Alex Nichol on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Account, Buddy;

@interface Event : NSManagedObject

@property (nonatomic, retain) NSString * kind;
@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * buddyName;
@property (nonatomic, retain) Account * account;
@property (nonatomic, retain) Buddy * buddy;

@end
