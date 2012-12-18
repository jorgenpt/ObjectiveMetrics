//
//  DMNullQueue.m
//  ObjectiveMetrics
//
//  Created by Jørgen P. Tjernø on 6/19/11.
//  Copyright 2011 bitSpatter. All rights reserved.
//

#import "DMNullQueue.h"


@implementation DMNullQueue

- (void)add:(NSDictionary *)event { return; }

- (void)flushAndIncludeCurrent:(BOOL)includeCurrent { return; }
- (BOOL)blockingFlush { return YES; }
- (void)discard { return; }

@end
