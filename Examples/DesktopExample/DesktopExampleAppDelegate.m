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

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    DMTracker *tracker = [DMTracker defaultTracker];
    [tracker start];

    [tracker trackEvent:@"Startup"];
    [tracker trackEvent:@"Startup"
         withProperties:@{@"Test": @"Hello!"}];
    [tracker trackLog:@"Hello world!"];

    [tracker stop];
}

@end
