//
//  ANAutoLaunch.h
//  FacebookStalker
//
//  Created by Alex Nichol on 5/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface ANAutoLaunch : NSObject {
    NSString * bundlePath;
}

+ (ANAutoLaunch *)autoLauncheForCurrentBundle;
- (id)initWithBundlePath:(NSString *)appBundle;

- (BOOL)bundleExistsInLaunchItems;
- (void)addBundleToLaunchItems;
- (void)removeBundleFromLaunchItems;

@end
