import Flutter
import UIKit
import mars_logging

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let mode = AppenderMode.async
        let filesDir = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!
        let filesUrl = URL.init(fileURLWithPath: filesDir)
        let logsDir = filesUrl.appendingPathComponent("logs").path
        let cacheDir = filesUrl.appendingPathComponent("cache").path
        let cacheDays = Int32(0)
        let nameprefix = "log"
#if DEBUG
        XLog.open(mode, logsDir: logsDir, cacheDir: cacheDir, cacheDays: cacheDays, nameprefix: nameprefix, useConsole: true, level: .debug)
#else
        XLog.open(mode, logsDir: logsDir, cacheDir: cacheDir, cacheDays: cacheDays, nameprefix: nameprefix, useConsole: false, level: .info)
#endif
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    override func applicationWillTerminate(_ application: UIApplication) {
        XLog.close()
    }
}
