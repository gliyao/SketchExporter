//
//  NSObject_Extension.m
//  SketchExporter
//
//  Created by Liyao on 2015/5/31.
//  Copyright (c) 2015年 Liyao. All rights reserved.
//


#import "NSObject_Extension.h"
#import "SketchExporter.h"

@implementation NSObject (Xcode_Plugin_Template_Extension)

+ (void)pluginDidLoad:(NSBundle *)plugin
{
    static dispatch_once_t onceToken;
    NSString *currentApplicationName = [[NSBundle mainBundle] infoDictionary][@"CFBundleName"];
    if ([currentApplicationName isEqual:@"Xcode"]) {
        dispatch_once(&onceToken, ^{
            sharedPlugin = [[SketchExporter alloc] initWithBundle:plugin];
        });
    }
}
@end
