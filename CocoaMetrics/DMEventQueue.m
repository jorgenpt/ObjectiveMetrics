//
//  DMEventQueue.m
//  CocoaMetrics
//
//  Created by Jørgen P. Tjernø on 3/22/11.
//  Copyright 2011 devSoft. All rights reserved.
//

#import "DMEventQueue.h"

@interface DMEventQueue ()

@property (retain) NSMutableArray *events;

@end

@implementation DMEventQueue

@synthesize events;

- (id)init
{
    self = [super init];
    if (self) {
        [self setEvents:[NSMutableArray array]];
    }
    
    return self;
}

- (void)dealloc
{
    [super dealloc];
}

- (void)add:(NSDictionary *)event
{
    [events addObject:event];
}

@end
