import Flutter
import UIKit
import mars_logging_darwin

@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
//        let mode = AppenderMode.async
//#if DEBUG
//        let level = XLogLevel.debug
//#else
//        let level = XLogLevel.info
//#endif
//        let filesDir = NSSearchPathForDirectoriesInDomains(.applicationSupportDirectory, .userDomainMask, true).first!
//        let filesUrl = URL.init(fileURLWithPath: filesDir)
//        let logsDir = filesUrl.appendingPathComponent("logs").path
//        let cacheDir = filesUrl.appendingPathComponent("cache").path
//        let cacheDays = Int32(0)
//        let namePrefix = "log"
//#if DEBUG
//        let useConsole = true
//#else
//        let useConsole = false
//#endif
//        let maxFileSize = UInt64(10 * 1024 * 1024)
//        let maxAliveDuration = 30 * 24 * 60 * 60
//        XLog.open(mode, level: level, logsDir: logsDir, cacheDir: cacheDir, cacheDays: cacheDays, namePrefix: namePrefix, useConsole: useConsole, maxFileSize: maxFileSize, maxAliveDuration: maxAliveDuration)
        
        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
    
    //    override func applicationWillTerminate(_ application: UIApplication) {
    //        XLog.close()
    //    }
}
