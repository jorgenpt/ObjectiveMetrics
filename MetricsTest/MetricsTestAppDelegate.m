//
//  MetricsTestAppDelegate.m
//  MetricsTest
//
//  Created by J¿rgen P. Tjern¿ on 3/23/11.
//  Copyright 2011 devSoft. All rights reserved.
//

#import "MetricsTestAppDelegate.h"

#import "ObjectiveMetrics/ObjectiveMetrics.h"

@implementation MetricsTestAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    DMTracker *tracker = [DMTracker defaultTracker];
    [tracker trackEventInCategory:@"General" withName:@"Startup"];
    [tracker trackLog:@"Hello world!"];
}

@end
