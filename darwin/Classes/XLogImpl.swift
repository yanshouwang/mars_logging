//
//  XLogImpl.swift
//  mars_logging
//
//  Created by 闫守旺 on 2025/3/19.
//

import Foundation

class XLogImpl: XLogApi {
    func open(mode: AppenderModeApi, logsDir: String, cacheDir: String, cacheDays: Int64, nameprefix: String, useConsole: Bool, level: XLogLevelApi) throws {
        XLog.open(mode.obj, logsDir: logsDir, cacheDir: cacheDir, cacheDays: Int32(cacheDays), nameprefix: nameprefix, useConsole: useConsole, level: level.obj)
    }
    
    func flush(isSync: Bool) throws {
        XLog.flush(isSync)
    }
    
    func close() throws {
        XLog.close()
    }
    
    func verbose(tag: String, message: String) throws {
        XLog.verbose(tag, message: message)
    }
    
    func debug(tag: String, message: String) throws {
        XLog.debug(tag, message: message)
    }
    
    func info(tag: String, message: String) throws {
        XLog.info(tag, message: message)
    }
    
    func warning(tag: String, message: String) throws {
        XLog.warning(tag, message: message)
    }
    
    func error(tag: String, message: String) throws {
        XLog.error(tag, message: message)
    }
    
    func fatal(tag: String, message: String) throws {
        XLog.fatal(tag, message: message)
    }
}

extension AppenderModeApi {
    var obj: AppenderMode {
        switch self {
        case .async:
            return .async
        case .sync:
            return .sync
        }
    }
}

extension XLogLevelApi {
    var obj: XLogLevel {
        switch self {
        case .all:
            return .all
        case .verbose:
            return .verbose
        case .debug:
            return .debug
        case .info:
            return .info
        case .warning:
            return .warning
        case .error:
            return .error
        case .fatal:
            return .fatal
        case .none:
            return .none
        }
    }
}
