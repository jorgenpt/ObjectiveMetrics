//
//  DesktopExampleAppDelegate.m
//  DesktopExample
//
//  Created by Jørgen P. Tjernø on 3/23/11.
//  Copyright 2011 devSoft. All rights reserved.
//

#import "DesktopExampleAppDelegate.h"

#import <ObjectiveMetrics/ObjectiveMetrics.h>

@implementation DesktopExampleAppDelegate

- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication *)sender
{
    return YES;
}

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    DMTracker *tracker = [DMTracker defaultTracker];
    
    // Delete the #error line and update APP_ID_HERE to make this test application work.
    // You can find your application id on app.deskmetrics.com, under "Settings" (bottom left corner) for your app.
#error You need to specify app id in DesktopExample to run it.
    [tracker startWithApplicationId:@"APP_ID_HERE"];
}

- (IBAction) simpleButtonPressed:(id)sender
{
    [[DMTracker defaultTracker] trackEvent:@"Simple Button"];
}

- (IBAction) nameButtonPressed:(id)sender
{
    NSString *name = self.nameField.stringValue;
    if ([name length] > 0) {
        [[DMTracker defaultTracker] trackEvent:@"Name Button"
                                withProperties:@{@"Name": name}];
    }
}

- (IBAction) logTime:(id)sender
{
    [[DMTracker defaultTracker] trackLog:@"Time is now %@", [NSDate date]];
}

- (void)applicationWillTerminate:(NSNotification *)notification
{
    [[DMTracker defaultTracker] stop];
}

@end
