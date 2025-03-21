import Cocoa
import FlutterMacOS

public class MarsLoggingPlugin: NSObject, FlutterPlugin {
    public static func register(with registrar: FlutterPluginRegistrar) {
        let messenger = registrar.messenger
        let api = XLogImpl()
        XLogApiSetup.setUp(binaryMessenger: messenger, api: api)
    }
}
