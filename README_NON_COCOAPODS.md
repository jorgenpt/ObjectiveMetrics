ObjectiveMetrics without CocoaPods
==================================

For ease of use, it is recommended that you use [CocoaPods][cocoapods] to set up
ObjectiveMetrics in your project. For information on how to do that, refer to
[the main README][readme].


If you'd like to try using it without CocoaPods, you can follow the below
instructions. Feel free to give suggestions for improving them, but they are not
as well tested as the cocoapods instructions.

Getting started for OS X
------------------------

Using ObjectiveMetrics is hopefully very straightforward. You can build
it from source from GitHub.

1. Build the framework using the enclosed Xcode project.
2. Link your project with `ObjectiveMetrics.framework` - and set your project up
   to copy the framework into its bundle. To do this, you need a `Copy Files`
   build phase which copies `ObjectiveMetrics.framework` to the `Framework`
   path.
3. Set your project up to copy [the prebuilt][sbjson-osx] `SBJson.framework`
   binary (or build your own from https://github.com/stig/json-framework) into
   its bundle.  You can use the same `Copy Files` build phase as above.
4. Set up your project's Runtime Search Paths to contain
   `@loader_path/../Frameworks` - you can find this under Build Settings for
   Xcode 4.x, or see http://www.dribin.org/dave/blog/archives/2009/11/15/rpath/
   for Xcode 3.x
5. Find your **application id** on the DeskMetrics application settings page.
6. Make sure you send the `DMTracker` a `startWithApplicationId:` message with
   your application id as soon as your app is starting up, to initialize your
   session, e.g. in `applicationDidFinishLaunching:`.
7. Make sure you send the `DMTracker` a `stop` message when your application is
   shutting down, e.g. in `applicationWillTerminate:`.
8. Add tracking to any file you want. See below for syntax.

Getting started for iOS
-----------------------

When using ObjectiveMetrics on iOS, you need to link against TouchMetrics , its
JSON dependency ([libsbjson-ios.a][sbjson-ios]) and import DMTracker.h.

1. Build the library using the enclosed Xcode project.
2. Link your project with `libTouchMetrics.a` and copy `DMTracker.h`.
3. Link your project with [the prebuilt][sbjson-ios] `libsbjson-ios.a` (or build
   your own from https://github.com/stig/json-framework)
4. Find your **application id** on the DeskMetrics dashboard page, and put this
   in your applications `Info.plist` as a string with key `DMAppId`.
5. Make sure you send the `DMTracker` a `startWithApplicationId:` message with
   your application id as soon as your app is starting up, to initialize your
   session, e.g. in `applicationDidFinishLaunching:`.
6. Make sure you send the `DMTracker` a `stop` message when your application is
   shutting down, e.g. in `applicationWillTerminate:`.
7. Add tracking to any file you want. See below for syntax.

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

Then you probably need to make your project copy [the prebuilt][sbjson-osx]
`SBJson.framework` (or build your own from
https://github.com/stig/json-framework) into its bundle.

You can re-use the `Copy Files` build phase which copies
`ObjectiveMetrics.framework` to also copy `SBJson.framework`.

### -[__NSArrayI JSONRepresentation]: unrecognized selector

If you get an error like this:

    -[__NSArrayI JSONRepresentation]: unrecognized selector sent to instance ...

Then it most likely means you forgot to add `libsbjson-ios.a` to your iOS Xcode
project. You can find a prebuilt copy of the library [in our downloads
section][sbjson-ios], or you can build it from the source, available here:
https://github.com/stig/json-framework

The code has only been tested with v3.0.4 of SBJson.

[cocoapods]: http://cocoapods.org/
[readme]: /jorgenpt/ObjectiveMetrics/blob/master/README.md
[sbjson-ios]: /downloads/jorgenpt/ObjectiveMetrics/libsbjson-ios.a
[sbjson-osx]: /downloads/jorgenpt/ObjectiveMetrics/SBJson%20v3.0.4.zip
