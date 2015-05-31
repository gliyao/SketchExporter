//
//  SketchExporter.h
//  SketchExporter
//
//  Created by Liyao on 2015/5/31.
//  Copyright (c) 2015年 Liyao. All rights reserved.
//

#import <AppKit/AppKit.h>

@class SketchExporter;

static SketchExporter *sharedPlugin;

@interface SketchExporter : NSObject

+ (instancetype)sharedPlugin;
- (id)initWithBundle:(NSBundle *)plugin;

@property (nonatomic, strong, readonly) NSBundle* bundle;
@end