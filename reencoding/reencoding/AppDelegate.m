//
//  AppDelegate.m
//  reencoding
//
//  Created by wld on 22/07/2015.
//  Copyright (c) 2015 wld. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    return YES;
}



- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillResignActive:(UIApplication *)application {
    NSLog(@"applicationDidEnterBackground");
    [[NSNotificationCenter defaultCenter]  postNotificationName:@"stopPlayOther" object:nil];
    __block UIBackgroundTaskIdentifier background_task;
    self.isInBackground=YES;
    background_task = [application beginBackgroundTaskWithExpirationHandler:^ {
        self.isInBackground=NO;
        [application endBackgroundTask: background_task];
        background_task = UIBackgroundTaskInvalid;
    }];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
