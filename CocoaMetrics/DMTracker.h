//
//  DMTracker.h
//  CocoaMetrics
//
//  Created by Jørgen P. Tjernø on 3/22/11.
//  Copyright 2011 devSoft. All rights reserved.
//

#import <Cocoa/Cocoa.h>

#import "DMEventQueue.h"
//#import "DMSubmitter.h"


@interface DMTracker : NSObject {
@private
    NSString *appId;
    DMEventQueue *queue;
    int flow;
}

@property (retain) NSString *appId;

- (id)initWithAppId:(NSString *)theAppId;

#pragma mark -

- (void)trackEventInCategory:(NSString *)theCategory
                    withName:(NSString *)theName;

- (void)trackEventInCategory:(NSString *)theCategory
                    withName:(NSString *)theName
                       value:(NSString *)theValue;

- (void)trackEventInCategory:(NSString *)theCategory
                    withName:(NSString *)theName
                secondsSpent:(int)theSeconds
                   completed:(BOOL)wasCompleted;

- (void)trackLog:(NSString *)message;

- (void)trackCustomDataWithName:(NSString *)theName
                          value:(NSString *)theValue;

- (void)trackCustomDataRealtimeWithName:(NSString *)theName
                                  value:(NSString *)theValue;

- (void)trackException:(NSException *)theException;

@end