import Cocoa
import FlutterMacOS
import Foundation
import mars_logging_darwin

@main
class AppDelegate: FlutterAppDelegate {
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
//    override func applicationDidFinishLaunching(_ notification: Notification) {
//        let mode = AppenderMode.async
//        let filesDir = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!
//        // In a non-sandboxed app, these are shared directories where applications are
//        // expected to use its bundle ID as a subdirectory. (For non-sandboxed apps,
//        // adding the extra path is harmless).
//        // This is not done for iOS, for compatibility with older versions of the
//        // plugin.
//        let filesUrl = URL.init(fileURLWithPath: filesDir).appendingPathComponent(Bundle.main.bundleIdentifier!)
//        let logsDir = filesUrl.appendingPathComponent("logs").path
//        let cacheDir = filesUrl.appendingPathComponent("cache").path
//        let cacheDays = Int32(0)
//        let nameprefix = "log"
//#if DEBUG
//        let useConsole = true
//        let level = XLogLevel.debug
//#else
//        let useConsole = false
//        let level = XLogLevel.info
//#endif
//        XLog.open(mode, logsDir: logsDir, cacheDir: cacheDir, cacheDays: cacheDays, nameprefix: nameprefix, useConsole: useConsole, level: level)
//    }
//    
//    override func applicationWillTerminate(_ notification: Notification) {
//        XLog.close()
//    }
}
