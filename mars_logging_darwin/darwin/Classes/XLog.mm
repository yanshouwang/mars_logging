#import <mars/xlog/appender.h>
#import <mars/xlog/xloggerbase.h>

#import "XLog.h"
#import "LogUtil.h"

@implementation XLog

+ (void)open:(AppenderMode)mode logsDir:(NSString *)logsDir cacheDir:(NSString *)cacheDir cacheDays:(int)cacheDays nameprefix:(const char *)nameprefix useConsole:(bool)useConsole level:(XLogLevel)level {
    mars::xlog::XLogConfig config;
    config.mode_ = (mars::xlog::TAppenderMode)mode;
    config.logdir_ = [logsDir UTF8String];
    config.cachedir_ = [cacheDir UTF8String];
    config.cache_days_ = cacheDays;
    config.nameprefix_ = nameprefix;
    mars::xlog::appender_open(config);
    mars::xlog::appender_set_console_log(useConsole);
    xlogger_SetLevel((TLogLevel)level);
}

+ (void)flush:(bool)isSync {
    if (isSync) {
        mars::xlog::appender_flush_sync();
    } else {
        mars::xlog::appender_flush();
    }
}

+ (void)close {
    mars::xlog::appender_close();
}

+ (void) verbose: (const char*)tag message: (NSString*)message {
    LOG_VERBOSE(tag, message);
}

+ (void) debug: (const char*)tag message: (NSString*)message {
    LOG_DEBUG(tag, message);
}

+ (void) info: (const char*)tag message: (NSString*)message {
    LOG_INFO(tag, message);
}

+ (void) warning: (const char*)tag message: (NSString*)message {
    LOG_WARNING(tag, message);
}

+ (void) error: (const char*)tag message: (NSString*)message {
    LOG_ERROR(tag, message);
}

+ (void) fatal: (const char*)tag message: (NSString*)message {
    LOG_FATAL(tag, message);
}

@end
