//
//  DMTracker.h
//  ObjectiveMetrics
//
//  Created by Jørgen P. Tjernø on 3/22/11.
//  Copyright 2011 bitSpatter. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DMTrackingQueueProtocol

- (void)add:(NSDictionary *)event;

- (void)flushAndIncludeCurrent:(BOOL)includeCurrent;
- (void)blockingFlush;
- (void)discard;

@end

/**
 * A class representing an ongoing application session for tracking purposes.
 */
@interface DMTracker : NSObject {
@private
    int flow;
    id<DMTrackingQueueProtocol> queue;
}

/**
 * Returns the singleton instance of the DMTracker.
 */
+ (DMTracker *)defaultTracker;

#pragma mark - Session management

/**
 * Initialize the tracker for a new session with your app.
 *
 * @param appId The application id, from your DeskMetrics dashboard.
 */
- (void)startWithApplicationId:(NSString *)appId;

/**
 * Discard all requests to the tracker.
 */
- (void)disable;

/**
 * Stop and flush queue, async. Shortcut for [tracker stopAndFlushSynchronously:NO].
 */
- (void)stop;

/**
 * Finalize the current app session. Only valid a single time after a call to
 * start.
 *
 * You should send this when your app is exiting.
 *
 * Finalizing the app session will attempt to send all queued messages.
 * If it fails, they will be attempted sent at the next app startup.
 *
 * @param synchronously If YES, then do not return until we've sent our events
 *  to DeskMetrics. If the sending fails, the events are stored for sending next
 *  startup.
 *
 */
- (void)stopAndFlushSynchronously:(BOOL)synchronously;

/**
 * Manually flush the queue of events, sending them to the server.
 * You can use this for long-running apps instead of using the
 * DMEventQueueMaxSize and DMEventQueueMaxDaysOld keys in your application's
 * Info.plist (default values for them are 100 and 7, respectively).
 */
- (void)flushQueue;

/**
 * Throw away every event currently in the queue. They will not be
 * received by the server, and this method should be used sparingly.
 *
 * Useful for debugging or error recovery when you have bad data.
 */
- (void)discardQueue;


// TODO: identifyUser:

#pragma mark - Event tracking

/**
 * Track an event.
 * This is a batched event that will be sent when the app exits.
 *
 * @param eventName The name of the event.
 */

- (void)trackEvent:(NSString *)eventName;

/**
 * Track an event.
 * This is a batched event that will be sent when the app exits.
 *
 * @param eventName The name of the event.
 * @param properties A dictionary of key-value pairs to send along.
 */
- (void)trackEvent:(NSString *)eventName
    withProperties:(NSDictionary *)properties;

/**
 * Track a log entry.
 * This is a batched event that will be sent when the app exits.

 * @param format The message you want to log.
 * @param ... Format-specific arguments.
 */
- (void)trackLog:(NSString *)format, ... NS_FORMAT_FUNCTION(1,2);

@end
