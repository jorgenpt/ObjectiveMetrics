//
//  MetricsTestAppDelegate.m
//  MetricsTest
//
//  Created by Jørgen P. Tjernø on 3/23/11.
//  Copyright 2011 devSoft. All rights reserved.
//

#import "MetricsTestAppDelegate.h"

#import "CocoaMetrics/DMTracker.h"

@implementation MetricsTestAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    DMTracker *tracker = [[[DMTracker alloc] init] autorelease];
    [tracker trackEventInCategory:@"General" withName:@"Startup"];
    [tracker trackLog:@"Hello world!"];
}

@end
