#import <Foundation/Foundation.h>
#import <mars/xlog/xloggerbase.h>

typedef NS_ENUM(NSUInteger, XLogLevel) {
    XLogLevelAll = kLevelAll,
    XLogLevelVerbose = kLevelVerbose,
    XLogLevelDebug = kLevelDebug,
    XLogLevelInfo = kLevelInfo,
    XLogLevelWarning = kLevelWarn,
    XLogLevelError = kLevelError,
    XLogLevelFatal = kLevelFatal,
    XLogLevelNone = kLevelNone
};

typedef NS_ENUM(NSUInteger, AppenderMode) {
    AppenderModeAsync,
    AppenderModeSync
};

@interface XLog: NSObject

+ (void)open: (AppenderMode)mode logsDir: (NSString*)logsDir cacheDir: (NSString*)cacheDir cacheDays: (int)cacheDays nameprefix: (const char*)nameprefix useConsole: (bool)useConsole level: (XLogLevel)level;
+ (void)flush: (bool)isSync;
+ (void)close;
+ (void)verbose: (const char*)tag message: (NSString*)message;
+ (void)debug: (const char*)tag message: (NSString*)message;
+ (void)info: (const char*)tag message: (NSString*)message;
+ (void)warning: (const char*)tag message: (NSString*)message;
+ (void)error: (const char*)tag message: (NSString*)message;
+ (void)fatal: (const char*)tag message: (NSString*)message;

@end
