//
//  TouchTestAppDelegate.m
//  TouchTest
//
//  Created by Jorgen Tjerno on 4/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "TouchTestAppDelegate.h"

#import "TouchTestViewController.h"

#import "DMTracker.h"

@implementation TouchTestAppDelegate


@synthesize window=_window;

@synthesize viewController=_viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
     
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    [[DMTracker defaultTracker] startApp];
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[DMTracker defaultTracker] trackEventInCategory:@"Focus"
                                            withName:@"ResignActive"];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[DMTracker defaultTracker] trackEventInCategory:@"Focus"
                                            withName:@"EnterBackground"];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[DMTracker defaultTracker] trackEventInCategory:@"Focus"
                                            withName:@"EnterForeground"];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[DMTracker defaultTracker] trackEventInCategory:@"Focus"
                                            withName:@"BecomeActive"];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

@end
