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
3. Set your project up to copy the prebuilt `SBJson.framework` binary (or build
   your own from https://github.com/stig/json-framework) into its bundle.  You
   can use the same `Copy Files` build phase as above.
4. Set up your project's Runtime Search Paths to contain
   `@loader_path/../Frameworks` - you can find this under Build Settings for
   Xcode 4.x, or see http://www.dribin.org/dave/blog/archives/2009/11/15/rpath/
   for Xcode 3.x
5. Find your **application id** on the DeskMetrics dashboard page, and put this
   in your applications `Info.plist` as a string with key `DMAppId`.
6. Make sure you send the `DMTracker` a `startApp` message as soon as your app
   is starting up, to initialize your session.
7. Add tracking to any file you want. See below for syntax.

Getting started for iOS
-----------------------

When using ObjectiveMetrics on iOS, you need to link against the static library
(libTouchMetrics.a), it's JSON dependency (libsbjson-ios.a) and import
DMTracker.h.

1. Build the library using the enclosed Xcode project or download a prebuilt
   version.
2. Link your project with `libTouchMetrics.a` and copy `DMTracker.h`.
3. Link your project with the prebuilt `libsbjson-ios.a` (or build your own from
   https://github.com/stig/json-framework)
4. Find your **application id** on the DeskMetrics dashboard page, and put this
   in your applications `Info.plist` as a string with key `DMAppId`.
5. Make sure you send the `DMTracker` a `startApp` message as soon as your app
   is starting up, to initialize your session.
6. Add tracking to any file you want. See below for syntax.

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

Troubleshooting
---------------

### dyld: Library not loaded: ObjectiveMetrics. Reason: image not found

If you get an error like this:

    dyld: Library not loaded: @rpath/ObjectiveMetrics.framework/Versions/A/ObjectiveMetrics
      Referenced from: /path/to/your/project/MyApp.app/Contents/MacOS/MyApp
      Reason: image not found

Then you probably need to set up your *Runtime Search Paths*. You can do this
under "Build Settings" for your target (Xcode 4.x) or via these instructions:
http://www.dribin.org/dave/blog/archives/2009/11/15/rpath/ (Xcode 3.x)

### dyld: Library not loaded: SBJson. Reason: image not found

If you get an error like this:

    dyld: Library not loaded: @rpath/SBJson.framework/Versions/A/SBJson
      Referenced from: /some/long/path//ObjectiveMetrics.framework/Versions/A/ObjectiveMetrics
      Reason: image not found

Then you probably need to make your project copy the prebuilt `SBJson.framework`
(or build your own from https://github.com/stig/json-framework) into its bundle.

You can re-use the `Copy Files` build phase which copies
`ObjectiveMetrics.framework` to also copy `SBJson.framework`.

### -[__NSArrayI JSONRepresentation]: unrecognized selector

If you get an error like this:

    -[__NSArrayI JSONRepresentation]: unrecognized selector sent to instance ...

Then it most likely means you forgot to add libsbjson-ios.a to your iOS Xcode
project. You can find this file in the Frameworks directory, or you can build it
from the source, available here: https://github.com/stig/json-framework

The code has only been tested with v3.0.4 of SBJson.


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
