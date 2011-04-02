ObjectiveMetrics
================

ObjectiveMetrics is a Objective-C API (or *component*, as DeskMetrics calls
them) for the desktop application analytics service [DeskMetrics][dm]. You link
against ObjectiveMetrics and specify what events you want to track via an
intuitive API, and we take care of having them delivered to DeskMetrics, so that
they'll show up on your dashboard.

Requirements
------------

* iOS v4.0 or above. This means it will run on iPhones, iPads, and iPod Touches.
* Mac OS X 10.5 or above.
* Xcode 4.

There's no known reason it wouldn't work on earlier iOS versions, but it has not
been tested. It's only thoroughly tested on iOS 4.3 - please let me know if you
have luck running it on older versions.

Similarly, there's no reason it won't build under Xcode 3, but it has not been
tested. I'd love to hear from you if you've built it under Xcode 3. :)

Getting started for OS X
------------------------

Using ObjectiveMetrics is hopefully very straightforward. You can either build
it from source or get a [prebuilt binary][download] from GitHub.

1. Build the framework using the enclosed Xcode project or download a prebuilt
   version.
2. Link your project with `ObjectiveMetrics.framework` - and set your project up
   to copy the framework into its bundle. To do this, you need a `Copy Files`
   build phase which copies `ObjectiveMetrics.framework` to the `Framework`
   path.
3. Find your **application id** on the DeskMetrics dashboard page, and put this
   in your applications `Info.plist` as a string with key `DMAppId`.
4. Make sure you send the `DMTracker` a `startApp` message as soon as your app
   is starting up, to initialize your session.
5. Add tracking to any file you want. See below for syntax.

Getting started for iOS
-----------------------

When using ObjectiveMetrics on iOS, you need to link against the static library
(libTouchMetrics.a) and import DMTracker.h.

1. Build the library using the enclosed Xcode project or download a prebuilt
   version.
2. Link your project with `libTouchMetrics.a` and copy `DMTracker.h`.
3. Find your **application id** on the DeskMetrics dashboard page, and put this
   in your applications `Info.plist` as a string with key `DMAppId`.
4. Make sure you send the `DMTracker` a `startApp` message as soon as your app
   is starting up, to initialize your session.
5. Add tracking to any file you want. See below for syntax.

Tracking events
---------------

To track any event, you need the following at the start of the file:

    #import <ObjectiveMetrics/ObjectiveMetrics.h>

Or, under iOS (iPhone):

    #import "DMTracker.h"

Then, anywhere you want to track an event, retrieve the DMTracker singleton
instance using:

    [DMTracker defaultInstance]

On this instance, you can call any number of tracking events. It is very
important that you call the `startApp` method soon after your app starts. This
is because it initializes the session and prepares the DMTracker for more
tracking events:

    [[DMTracker defaultInstance] startApp];

While there is a matching `stopApp`, you should never need to call it. It is
called automatically for you when your NSApplication terminates. If the app is
stopped abruptly and it cannot send stopApp, then it'll queue the events and
send `stopApp` along with the events the next time the app is started.

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

License
-------

ObjectiveMetrics uses other open-source libraries, and is covered by a couple of
licenses:

* Original code is licensed under the [simplified BSD license][bsd-license].
* [UIDevice-Extension][uide] is licensed under the [BSD license][bsd-license].
* [Sparkle][sparkle] is licensed under the [MIT license][mit-license].
* [GTM][gtm] is licensed under the [Apache 2.0 license][apache2-license].


[dm]: http://www.deskmetrics.com
[header]: DMTracker.h
[download]: /downloads/jorgenpt/ObjectiveMetrics/ObjectiveMetrics%201.0.zip
[sparkle]: http://sparkle.andymatuschak.org/
[gtm]: http://code.google.com/p/google-toolbox-for-mac/
[uide]: https://github.com/erica/uidevice-extension
[bsd-license]: http://www.opensource.org/licenses/bsd-license.php
[mit-license]: http://www.opensource.org/licenses/mit-license.php
[apache2-license]: http://www.apache.org/licenses/LICENSE-2.0
