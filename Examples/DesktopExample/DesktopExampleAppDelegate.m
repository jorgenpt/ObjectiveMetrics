//
//  DesktopExampleAppDelegate.m
//  DesktopExample
//
//  Created by J¿rgen P. Tjern¿ on 3/23/11.
//  Copyright 2011 devSoft. All rights reserved.
//

#import "DesktopExampleAppDelegate.h"

#import <ObjectiveMetrics/ObjectiveMetrics.h>

@implementation DesktopExampleAppDelegate

@synthesize window;

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    DMTracker *tracker = [DMTracker defaultTracker];
    [tracker startApp];

    [tracker trackEventInCategory:@"General" withName:@"Startup"];
    [tracker trackLog:@"Hello world!"];
}

@end
