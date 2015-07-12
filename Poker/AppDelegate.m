//
//  AppDelegate.m
//  Poker
//
//  Created by Admin on 20.04.15.
//  Copyright (c) 2015 by.bsuir.eLearning. All rights reserved.
//

#import "AppDelegate.h"
#import "GCDAsyncSocket.h"
#import "DDLog.h"
#import "DDTTYLogger.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

@synthesize viewController = _viewController;
@synthesize asyncSocket = asyncSocket;
@synthesize mainQueue = mainQueue;

- (id)init
{
    if ((self = [super init]))
    {
        // Setup logging framework
        [DDLog addLogger:[DDTTYLogger sharedInstance]];
    }
    return self;
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    [FBSDKAppEvents activateApp];
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                    didFinishLaunchingWithOptions:launchOptions];
}

- (BOOL)application:(UIApplication *)application
            openURL:(NSURL *)url
  sourceApplication:(NSString *)sourceApplication
         annotation:(id)annotation {
    return [[FBSDKApplicationDelegate sharedInstance] application:application
                                                          openURL:url
                                                sourceApplication:sourceApplication
                                                       annotation:annotation];
}


- (void)applicationWillResignActive:(UIApplication *)application {
   // DDLogInfo(@"%@", THIS_METHOD);
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    //DDLogInfo(@"%@", THIS_METHOD);
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
   // DDLogInfo(@"%@", THIS_METHOD);
}

//- (void)applicationDidBecomeActive:(UIApplication *)application {
//    static BOOL isAppLaunch = YES;
//    if (isAppLaunch)
//    {
//        isAppLaunch = NO;
//        return;
//    }
//    
//    DDLogInfo(@"%@", THIS_METHOD);
//}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
