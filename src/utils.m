#import "utils.h"
#include <Foundation/NSString.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@implementation Utils

+ (const char *)getCString:(NSString *)nsString {
  return [nsString UTF8String];
}

+ (int)toInt:(NSString *)nsString {
  return [nsString intValue];
}

+ (float)toFloat:(NSString *)nsString {
  return [nsString floatValue];
}

+ (NSString *)getNSStringByAppendingPathComponent:(NSString *)path
                                             name:(NSString *)name {
  return [path stringByAppendingPathComponent:name];
}

/* + (NSString *)getDocumentPath {
  return NSFileManager.NSSearchPathDirectory.documentDirectory;
} */

@end
