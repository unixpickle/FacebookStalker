//
//  ANDataManager.h
//  FacebookStalker
//
//  Created by Alex Nichol on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Account.h"
#import "Buddy.h"
#import "Event.h"

@interface ANDataManager : NSObject {
    NSMutableArray * accounts;
    NSManagedObjectContext * context;
}

@property (readonly) NSMutableArray * accounts;

+ (id)sharedDataManager;

- (NSArray *)accountUsernames;
- (Account *)accountForUsername:(NSString *)username;
- (void)saveContext;

@end
