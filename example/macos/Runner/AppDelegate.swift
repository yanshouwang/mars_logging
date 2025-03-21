import Cocoa
import FlutterMacOS
import Foundation
import mars_logging

@main
class AppDelegate: FlutterAppDelegate {
    override func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        return true
    }
    
    override func applicationSupportsSecureRestorableState(_ app: NSApplication) -> Bool {
        return true
    }
    
    override func applicationDidFinishLaunching(_ notification: Notification) {
        let mode = AppenderMode.async
        let filesDir = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!
        var filesUrl = URL.init(fileURLWithPath: filesDir)
#if os(macOS)
        // In a non-sandboxed app, these are shared directories where applications are
        // expected to use its bundle ID as a subdirectory. (For non-sandboxed apps,
        // adding the extra path is harmless).
        // This is not done for iOS, for compatibility with older versions of the
        // plugin.
        filesUrl = filesUrl.appendingPathComponent(Bundle.main.bundleIdentifier!)
#endif
        let logsDir = filesUrl.appendingPathComponent("logs").path
        let cacheDir = filesUrl.appendingPathComponent("cache").path
        let cacheDays = Int32(0)
        let nameprefix = "log"
#if DEBUG
        XLog.open(mode, logsDir: logsDir, cacheDir: cacheDir, cacheDays: cacheDays, nameprefix: nameprefix, useConsole: true, level: .debug)
#else
        XLog.open(mode, logsDir: logsDir, cacheDir: cacheDir, cacheDays: cacheDays, nameprefix: nameprefix, useConsole: false, level: .info)
#endif
    }
    
    override func applicationWillTerminate(_ notification: Notification) {
        XLog.close()
    }
}
