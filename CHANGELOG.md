v1.1 (11/??/2011)
=================

Added
-----

 * iOS support.
 * -[DMTracker disable] for disabling tracking for this session.
 * -[DMTracker flush] to manually flush queue.

Changed
-------

 * -[DMTracker trackLog:] now behaves like NSLog.
 * Cache stored in apps config rather than our own - this is required for Mac
   App Store submittal.
 * Data is now submitted over HTTPS.

Fixed
-----

 * Issues when using a DMTracker instance from multiple threads.
 * Crash when response didn't have content encoding.
 * Less blocking in DMTracker methods - hopefully resolve issues with apps
   freezing for a while at startup.
