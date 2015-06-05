//
//  SketchExporter.m
//  SketchExporter
//
//  Created by Liyao on 2015/5/31.
//  Copyright (c) 2015年 Liyao. All rights reserved.
//

#import "SketchExporter.h"

@interface SketchExporter()

@property (nonatomic, strong, readwrite) NSBundle *bundle;
@end

@implementation SketchExporter

+ (instancetype)sharedPlugin
{
    return sharedPlugin;
}

- (id)initWithBundle:(NSBundle *)plugin
{
    if (self = [super init]) {
        // reference to plugin's bundle, for resource access
        self.bundle = plugin;
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(didApplicationFinishLaunchingNotification:)
                                                     name:NSApplicationDidFinishLaunchingNotification
                                                   object:nil];
    }
    return self;
}

- (void)didApplicationFinishLaunchingNotification:(NSNotification*)noti
{
    //removeObserver
    [[NSNotificationCenter defaultCenter] removeObserver:self name:NSApplicationDidFinishLaunchingNotification object:nil];
    
    // Create menu items, initialize UI, etc.
    // Sample Menu Item:
    NSMenuItem *menuItem = [[NSApp mainMenu] itemWithTitle:@"Edit"];
    if (menuItem) {
        [[menuItem submenu] addItem:[NSMenuItem separatorItem]];
        NSMenuItem *actionMenuItem = [[NSMenuItem alloc] initWithTitle:@"Import Sketch assests with 2x" action:@selector(doMenuAction) keyEquivalent:@""];
        [actionMenuItem setTarget:self];
        [[menuItem submenu] addItem:actionMenuItem];
		
		NSMenuItem *actionMenuItem2 = [[NSMenuItem alloc] initWithTitle:@"Import Sketch assests with 1x" action:@selector(doMenuAction2) keyEquivalent:@""];
		[actionMenuItem2 setTarget:self];
		[[menuItem submenu] addItem:actionMenuItem2];
    }
}

// Sample Action, for menu item:
- (void)doMenuAction
{
    NSString *sketchPath = [[self urlWithSelectedFile] path];
    NSString *workspacePath = [self getWorksapcePath];
    NSString *projectDir = workspacePath.stringByDeletingLastPathComponent;
    NSLog(@"dir %@",projectDir);
    NSString *imageAssetsPath = [self getImagesAssetsFolderPathWithWorkspacePath:workspacePath];
    
  
    if([sketchPath length] == 0 || [workspacePath length] == 0 || [imageAssetsPath length] == 0) {
        return;
    }
    
    // get script file path
    NSString *shFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"do_sketch" ofType:@"sh"];
    shFilePath = [self replaceSpaceIfNeed:shFilePath];
    projectDir = [self replaceSpaceIfNeed:projectDir];
    sketchPath = [self replaceSpaceIfNeed:sketchPath];
    imageAssetsPath = [self replaceSpaceIfNeed:imageAssetsPath];
    
    NSString *script = [NSString stringWithFormat:@"sh %@ %@ %@ %@", shFilePath, projectDir, sketchPath, imageAssetsPath];

    // run shell script
    NSTask *task = [[NSTask alloc] init];
    task.launchPath = @"/bin/bash";
    task.arguments = @[@"-l", @"-c", script];
    [task launch];
}

- (void)doMenuAction2
{
	NSString *sketchPath = [[self urlWithSelectedFile] path];
	NSString *workspacePath = [self getWorksapcePath];
	NSString *projectDir = workspacePath.stringByDeletingLastPathComponent;
	NSLog(@"dir %@",projectDir);
	NSString *imageAssetsPath = [self getImagesAssetsFolderPathWithWorkspacePath:workspacePath];
	
	
	if([sketchPath length] == 0 || [workspacePath length] == 0 || [imageAssetsPath length] == 0) {
		return;
	}
	
	// get script file path
	NSString *shFilePath = [[NSBundle bundleForClass:[self class]] pathForResource:@"do_sketch1" ofType:@"sh"];
	shFilePath = [self replaceSpaceIfNeed:shFilePath];
	projectDir = [self replaceSpaceIfNeed:projectDir];
	sketchPath = [self replaceSpaceIfNeed:sketchPath];
	imageAssetsPath = [self replaceSpaceIfNeed:imageAssetsPath];
	
	NSString *script = [NSString stringWithFormat:@"sh %@ %@ %@ %@", shFilePath, projectDir, sketchPath, imageAssetsPath];
	
	// run shell script
	NSTask *task = [[NSTask alloc] init];
	task.launchPath = @"/bin/bash";
	task.arguments = @[@"-l", @"-c", script];
	[task launch];
}

- (NSString *)replaceSpaceIfNeed:(NSString *)string
{
    return [string stringByReplacingOccurrencesOfString:@" " withString:@"\\ "];
}

- (NSString *)getWorksapcePath
{
    NSArray *workspaceWindowControllers = [NSClassFromString(@"IDEWorkspaceWindowController") valueForKey:@"workspaceWindowControllers"];
    
    id workspace;
    for(id controller in workspaceWindowControllers){
        if([[controller valueForKey:@"window"] isEqual:[NSApp keyWindow]]){
            workspace = [controller valueForKey:@"_workspace"];
        }
    }
    
    NSString *workspacePath = [[workspace valueForKey:@"representingFilePath"] valueForKey:@"_pathString"];
    return workspacePath;
}

- (NSString *)getImagesAssetsFolderPathWithWorkspacePath:(NSString *)workspacePath
{
    NSString *homePath = workspacePath.stringByDeletingLastPathComponent;
    NSError *e = nil;
    NSArray *list = [[NSFileManager defaultManager] subpathsOfDirectoryAtPath:homePath error:&e];
    if(e){
        return @"";
    }
    
    NSString *ImagesXcassetsPath = @"";
    for(NSString *item in list){
        if([item containsString:@"AppDelegate.h"]){
            ImagesXcassetsPath = [[homePath stringByAppendingPathComponent:item.stringByDeletingLastPathComponent] stringByAppendingPathComponent:@"Images.xcassets"];
        }
    }
    return ImagesXcassetsPath;
}

- (NSString *)applicationDocumentsDirectory
{
    // Get the documents directory
    NSArray *dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *docsDir = [dirPaths objectAtIndex:0];
    return docsDir;
}

- (void)showAlertWithMsg:(NSString *)msg
{
    NSAlert *alert = [[NSAlert alloc] init];
    [alert setMessageText:msg];
    [alert runModal];
}

- (NSURL *)urlWithSelectedFile
{
    // get sketch file path
    NSOpenPanel *openPanel = [[NSOpenPanel alloc]init];
    openPanel.allowedFileTypes = @[@"sketch"];
    openPanel.canChooseFiles = YES;
    openPanel.canCreateDirectories = NO;
    openPanel.allowsMultipleSelection = NO;
    
    BOOL isFileSelection = [openPanel runModal];
    if(isFileSelection == NSFileHandlingPanelCancelButton){
        return nil;
    }
    
    NSURL *fileURL = openPanel.URL;
    return fileURL;
}


- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
