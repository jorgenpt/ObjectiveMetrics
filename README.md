ObjectiveMetrics
================

ObjectiveMetrics is a Objective-C API (or *component*, as DeskMetrics calls
them) for the desktop application analytics service [DeskMetrics][dm]. You link
against ObjectiveMetrics and specify what events you want to track via an
intuitive API, and we take care of having them delivered to DeskMetrics, so that
they'll show up on your dashboard.

Getting started
---------------

Using ObjectiveMetrics is hopefully very straightforward.

1. Build it using the enclosed Xcode project.
2. Link your project with `ObjectiveMetrics.framework`.
3. Find your application id on the DeskMetrics dashboard page, and put this in your applications Info.plist as `DMAppId`.
4. Make sure you send the DMTracker a startApp message as soon as your app is starting up, to initialize your session.
5. Add tracking to any file you want. See below for syntax.

Tracking events
---------------

To track any event, you need the following at the start of the file:

    #import <ObjectiveMetrics/ObjectiveMetrics.h>

Then, anywhere you want to track an event, retrieve the DMTracker singleton
instance using:

    [DMTracker defaultInstance]

On this instance, you can call any number of tracking events. It is very
important that you call the `startApp` method soon after your app starts. This
is because it initializes the session and prepares the DMTracker for more
tracking events:

    [[DMTracker defaultInstance] startApp];

While there is a matching `stopApp`, you should never need to call it. It is
called automatically for you when your NSApplication terminates.

Here are the different methods you can call: (See [DMTracker.h][header] for
a list that's guaranteed updated)

    DMTracker *tracker = [DMTracker defaultInstance];

    [tracker trackEventInCategory:@"Features"
                         withName:@"ManualUpdate"];

    [tracker trackEventInCategory:@"Features"
                         withName:@"URLShortener"
                            value:@"bit.ly"];

    [tracker trackEventInCategory:@"Operations"
                         withName:@"Scanning"
                     secondsSpent:37
                        completed:YES];

    [tracker trackLog:@"Error when getting new definitions"];

    [tracker trackCustomDataWithName:@"ApiKey"
                               value:@"09123aef42"];

    // Here Realtime means that it's sent when you call this, instead of when
    // the app shuts down / enough data has been aggregated.
    [tracker trackCustomDataRealtimeWithName:@"ApiKey"
                                       value:@"09123aef42"];

    [tracker trackException:someException];

[dm]: http://www.deskmetrics.com
[header]: DMTracker.h
