//
//  ANDataManager.m
//  FacebookStalker
//
//  Created by Alex Nichol on 5/4/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "ANDataManager.h"

@interface ANDataManager (Private)

- (NSString *)coreDataSavePath;
- (void)configureCoreData;

@end

@implementation ANDataManager

@synthesize accounts;

#pragma mark - Creation -

+ (id)sharedDataManager {
    static ANDataManager * manager = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[ANDataManager alloc] init];
    });
    return manager;
}

- (id)init {
    if ((self = [super init])) {
        [self configureCoreData];
    }
    return self;
}

- (NSString *)coreDataSavePath {
    NSString * appSupport = [NSString stringWithFormat:@"%@/Library/Application Support/FacebookStalker", NSHomeDirectory()];
    if (![[NSFileManager defaultManager] fileExistsAtPath:appSupport]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:appSupport
                                  withIntermediateDirectories:NO
                                                   attributes:nil
                                                        error:nil];
    }
    return [appSupport stringByAppendingPathComponent:@"Accounts.data"];
}

- (void)configureCoreData {
    NSURL * accountsURL = [[NSBundle mainBundle] URLForResource:@"Accounts" withExtension:@"momd"];
    NSManagedObjectModel * model = [[NSManagedObjectModel alloc] initWithContentsOfURL:accountsURL];
    context = [[NSManagedObjectContext alloc] init];
    
    NSPersistentStoreCoordinator * coordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:model];
    [context setPersistentStoreCoordinator:coordinator];
    
    NSString * storeType = NSXMLStoreType;
    NSString * storeFile = [self coreDataSavePath];;
    
    NSError * error = nil;
    NSURL * url = [NSURL fileURLWithPath:storeFile];
    
    NSPersistentStore * newStore = [coordinator addPersistentStoreWithType:storeType
                                                             configuration:nil
                                                                       URL:url
                                                                   options:nil
                                                                     error:&error];
    
    if (newStore == nil) {
        NSLog(@"Store Configuration Failure\n%@",
              ([error localizedDescription] != nil) ?
              [error localizedDescription] : @"Unknown Error");
    }
    
    // find all accounts
    NSFetchRequest * request = [[NSFetchRequest alloc] init];
    [request setEntity:[[model entitiesByName] objectForKey:@"Account"]];
    NSArray * allAccountsObjects = [context executeFetchRequest:request error:nil];
    accounts = [allAccountsObjects mutableCopy];
}

#pragma mark - Data -

- (NSArray *)accountUsernames {
    NSMutableArray * names = [NSMutableArray array];
    for (Account * acc in accounts) {
        [names addObject:[acc username]];
    }
    return [NSArray arrayWithArray:names];
}

- (Account *)accountForUsername:(NSString *)username {
    for (Account * acc in accounts) {
        NSString * aUsername = acc.username;
        if ([username isEqualToString:aUsername]) {
            return acc;
        }
    }
    Account * account = [NSEntityDescription insertNewObjectForEntityForName:@"Account"
                                                      inManagedObjectContext:context];
    account.username = username;
    [self willChangeValueForKey:@"accounts"];
    [accounts addObject:account];
    [self didChangeValueForKey:@"accounts"];
    [context save:nil];
    return account;
}

- (void)saveContext {
    [context save:nil];
}

@end
