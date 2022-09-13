#import <Foundation/Foundation.h>

@interface Utils : NSObject {
}

+ (const char *)getCString:(NSString *)nsString;

+ (int)toInt:(NSString *)nsString;

+ (float)toFloat:(NSString *)nsString;

+ (NSString *)getNSStringByAppendingPathComponent:(NSString *)path
                                             name:(NSString *)name;

// + (NSString*) getDocumentPath;

@end
