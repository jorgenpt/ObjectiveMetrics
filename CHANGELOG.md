v2.0 (released 2012-12-31)
==========================

* Updated to DeskMetrics v2.0 API.
* Improved example apps.


v1.1 (released 2012-01-21)
==========================


Added
-----

* iOS support
* Reporting of resolution, free RAM and CPU brand
* `-[DMTracker trackException]` to report NSExceptions
* `-[DMTracker flushQueue]` to manually send the queue of events
* `-[DMTracker discardQueue]` to discard the queue of events
* `-[DMTracker disable]` to disable tracking for the rest of this session

Changed
-------

* `-[DMTracker trackLog:]` now takes a format like NSLog.
* You can now disable automatic sending of events on app-exit, as some people
  (especially on iOS) have reported that this can be annoying. A simple
  `-[DMTracker setAutoflush:NO]` will use this new behavior, and the queued
  events will be sent the next time your app is started.
* Cache is now stored in the app's NSUserDefaults rather than our own - this is
  required for Mac App Store submittal. Migration from old format should happen
  automatically.
* Data is now submitted over HTTPS.
* API should now be thread safe.

Fixed
-----

* Fixed an intermittent crash when DeskMetrics returned bad encoding
  information. ([issue #10][gh-10]], reported by Stuart Clayton)
* Fixed an intermittent freeze on startup & shutdown ([issue #7][gh-7])
* Classes from Sparkle have been renamed to not cause a symbol conflict if the
  app uses Sparkle.
* Issues when using a DMTracker instance from multiple threads. ([issue
  #3][gh-3])
* Less blocking in DMTracker methods - hopefully resolve issues with apps
  freezing for a while at startup.

[gh-3]: https://github.com/jorgenpt/ObjectiveMetrics/issues/3
[gh-7]: https://github.com/jorgenpt/ObjectiveMetrics/issues/7
[gh-10]: https://github.com/jorgenpt/ObjectiveMetrics/issues/10
