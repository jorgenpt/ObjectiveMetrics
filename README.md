ObjectiveMetrics
================

ObjectiveMetrics is a Objective-C implementation of the desktop application
analytics service [DeskMetrics][dm]. You link against ObjectiveMetrics and
specify what events you want to track via an intuitive API, and we take care of
having them delivered to DeskMetrics, so that they'll show up on your dashboard.

Requirements
------------

* iOS v4.3 or above. This means it will run on iPhones, iPads, and iPod Touches.
* Mac OS X 10.6 or above.
* Xcode 4.4 or above.

There's no known reason it wouldn't work on earlier iOS versions, but it has not
been tested.

Getting started using CocoaPods on either OS X or iOS
-----------------------------------------------------

The preferred way of using ObjectiveMetrics is now [CocoaPods][cocoapods]. To
start using ObjectiveMetrics, all you need is to add the following to your
Podfile:

    pod 'ObjectiveMetrics'

This works for both iOS and OS X. Now, you just need to take the following steps
to use it:

1. Add `#import <ObjectiveMetrics/ObjectiveMetics.h>` to your files that will be
   using ObjectiveMetrics.
2. Find your **application id** on the DeskMetrics application settings page.
3. Make sure you send the `DMTracker` a `startWithApplicationId:` message with
   your application id as soon as your app is starting up, to initialize your
   session, e.g. in `applicationDidFinishLaunching:`.
4. Make sure you send the `DMTracker` a `stop` message when your application is
   shutting down, e.g. in `applicationWillTerminate:`.
5. Add tracking to any file you want. See below for syntax.

If you'd like to set up ObjectiveMetrics WITHOUT using CocoaPods, you can
attempt to follow the instructions in our [non-cocoapods readme][noncocoapods].

Be warned, instructions for setting it up without cocoapods are not as
frequently updated or as well tested as the ones you see in this file.

Tracking events
---------------

To track any event, you need the following at the start of the file:

    #import <ObjectiveMetrics/ObjectiveMetrics.h>

Or, under iOS (iPhone):

    #import "DMTracker.h"

Then, anywhere you want to track an event, retrieve the DMTracker singleton
instance using:

    [DMTracker defaultTracker]

On this instance, you can call any number of tracking events. It is very
important that you call the `startWithApplicationId:` method soon after your app
starts. This is because it initializes the session and prepares the DMTracker
for more tracking events:

    [[DMTracker defaultInstance] startWithApplicationId:@"MY APP ID HERE"];

You should then call `stop` when your application is shutting down, to track an
"app exiting" event and attempt to send the events to the server. If they can't
be sent, they'll be sent the next time the application starts.

Here are the different methods you can call: (See [DMTracker.h][header] for
a list that's guaranteed updated)

    DMTracker *tracker = [DMTracker defaultInstance];

    [tracker trackEvent:@"Event"];

    [tracker trackEvent:@"Event with properties"
         withProperties:@{@"Name": @"Joe Smith"}];

    [tracker trackLog:@"Time is now %@", [NSDate date]];


License
-------

ObjectiveMetrics uses other open-source libraries, and is covered by a couple of
licenses:

* Original code is licensed under the [simplified BSD license][bsd-license].
* [UIDevice-Extension][uide] is licensed under the [BSD license][bsd-license].
* [Sparkle][sparkle] is licensed under the [MIT license][mit-license].

[header]: /jorgenpt/ObjectiveMetrics/blob/master/ObjectiveMetrics/DMTracker.h
[cocoapods]: http://cocoapods.org/
[noncocoapods]: /jorgenpt/ObjectiveMetrics/blob/master/README_NON_COCOAPODS.md
[dm]: http://www.deskmetrics.com
[sparkle]: http://sparkle.andymatuschak.org/
[uide]: https://github.com/erica/uidevice-extension
[bsd-license]: http://www.opensource.org/licenses/bsd-license.php
[mit-license]: http://www.opensource.org/licenses/mit-license.php
