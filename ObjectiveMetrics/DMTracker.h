//
//  DMTracker.h
//  ObjectiveMetrics
//
//  Created by Jørgen P. Tjernø on 3/22/11.
//  Copyright 2011 devSoft. All rights reserved.
//

#import <Foundation/Foundation.h>

@class DMTrackingQueue;

@interface DMTracker : NSObject {
@private
    DMTrackingQueue *queue;
    NSString *session;
    int flow;
}

+ (id) defaultTracker;
- (void)startApp;
- (void)stopApp;

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
