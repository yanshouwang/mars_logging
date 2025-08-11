#if os(iOS)
import Flutter
import UIKit
#elseif os(macOS)
import Cocoa
import FlutterMacOS
#else
#error("Unsupported platform.")
#endif

public class MarsLoggingDarwinPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let instance = MarsLoggingDarwinPlugin(with: registrar)
        registrar.publish(instance)
    }
    
    init(with registrar: FlutterPluginRegistrar) {
#if os(iOS)
        let messenger = registrar.messenger()
#else
        let messenger = registrar.messenger
#endif
        let api = XLogImpl()
        XLogHostApiSetup.setUp(binaryMessenger: messenger, api: api)
    }
    
    public func detachFromEngine(for registrar: any FlutterPluginRegistrar) {
#if os(iOS)
        let messenger = registrar.messenger()
#else
        let messenger = registrar.messenger
#endif
        XLogHostApiSetup.setUp(binaryMessenger: messenger, api: nil)
    }
}
