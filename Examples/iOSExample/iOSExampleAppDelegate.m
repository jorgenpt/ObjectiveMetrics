//
//  iOSExampleAppDelegate.m
//  iOSExample
//
//  Created by Jorgen Tjerno on 4/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "iOSExampleAppDelegate.h"

#import "iOSExampleViewController.h"

#import "DMTracker.h"

@implementation iOSExampleAppDelegate


@synthesize window=_window;

@synthesize viewController=_viewController;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Override point for customization after application launch.
     
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    // Delete the #error line and update APP_ID_HERE to make this test application work.
    // You can find your application id on app.deskmetrics.com, under "Settings" (bottom left corner) for your app.
#error You need to specify app id in DesktopExample to run it.
    [[DMTracker defaultTracker] startWithApplicationId:@"APP_ID_HERE"];

    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    [[DMTracker defaultTracker] trackEvent:@"FocusTransition"
                            withProperties:@{@"Transition": @"ResignActive"}];
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    [[DMTracker defaultTracker] trackEvent:@"FocusTransition"
                            withProperties:@{@"Transition": @"EnterBackground"}];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    [[DMTracker defaultTracker] trackEvent:@"FocusTransition"
                            withProperties:@{@"Transition": @"EnterForeground"}];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [[DMTracker defaultTracker] trackEvent:@"FocusTransition"
                            withProperties:@{@"Transition": @"BecomeActive"}];
}

// Note: This does not get called if the user terminates the application using the task switcher.
- (void)applicationWillTerminate:(UIApplication *)application
{
    // XXX: You should NOT use synchronous stop this in your released application.
    // This will "hang" the application until events have been sent, which can be a really bad user experience,
    // if they're on a slow or spotty connection. Just use "YES" when testing, send "NO" in real user scenarios.
    [[DMTracker defaultTracker] stopAndFlushSynchronously:YES];
}

- (void)dealloc
{
    [_window release];
    [_viewController release];
    [super dealloc];
}

@end
