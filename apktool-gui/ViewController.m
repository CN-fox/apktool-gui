//
//  ViewController.m
//  apktool-gui
//
//  Created by wq on 15/5/25.
//  Copyright (c) 2015年 wq. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.spinner setHidden:YES];
    // Do any additional setup after loading the view.
}

- (void)setRepresentedObject:(id)representedObject {
    [super setRepresentedObject:representedObject];
    
    // Update the view, if already loaded.
}

- (IBAction)runClick:(id)sender {
    if (self.isRunning) {
        return;
    }else{
        //重置
        self.outputText.string = @"";
    }
    
    NSMutableArray *array = [[NSMutableArray alloc] init];
    
    [array addObject:@"-jar"];
    
    NSMatrix *matrix = self.matrix;
    NSButtonCell *cell = matrix.selectedCell;
    
    
    NSString *jar;
    if (cell.tag == 1) {
        jar = @"apktool-1.5.2.jar";
        NSLog(@"1.5.2");
    }else if(cell.tag == 0){
        jar = @"apktool-2.0.0.jar";
        NSLog(@"2.0.0");
    }
    
    NSString *jarPath =[NSBundle.mainBundle
                        pathForResource:jar
                        ofType:nil
                        ];
    
    [array addObject:jarPath];
    [array addObject:@"decode"];
    
    if (self.force.state == NSOnState) {
        [array addObject:@"-f"];
    }
    
    if (self.nores.state == NSOnState) {
        [array addObject:@"-r"];
    }
    
    if (self.nosrc.state == NSOnState) {
        [array addObject:@"-s"];
    }
    
    if (self.apkDirTextField.stringValue.length > 0) {
        [array addObject:self.apkDirTextField.stringValue];
    }else{
        NSAlert * alert = [[NSAlert alloc]init];
        alert.informativeText = @"apk-dir is null!";
        alert.messageText =@"ERROR";
        [alert runModal];
        return;
    }
    
    if (self.outPathTextField.stringValue.length > 0) {
        if (cell.tag == 0) {
            [array addObject:@"-o"];
        }
        [array addObject:self.outPathTextField.stringValue];
    }else{
        NSAlert * alert = [[NSAlert alloc]init];
        alert.informativeText = @"out-dir is null!";
        alert.messageText = @"ERROR";
        [alert runModal];
        return;
    }

    //异步
    dispatch_queue_t taskQueue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0);
    dispatch_async(taskQueue, ^{
        self.isRunning = YES;
        [self.spinner setHidden:NO];
        [self.spinner startAnimation:self];
        [self.runButton setEnabled:NO];

        @try {
            NSTask *task =  [[NSTask alloc]init];
            task.launchPath =@"/usr/bin/java";
            task.arguments = array;
            //[NSTask launchedTaskWithLaunchPath:@"/usr/bin/java" arguments:array];

            
            NSPipe *pipe = [[NSPipe alloc]init];
            //恩 java的输出是标准错误输出，很科学你妹啊~
            if (cell.tag == 0) {
                task.standardOutput = pipe;
            }else{
                task.standardError = pipe;
            }

            [[pipe fileHandleForReading] waitForDataInBackgroundAndNotify];
            //下面摘自 某处。。。
            [[NSNotificationCenter defaultCenter] addObserverForName:NSFileHandleDataAvailableNotification object:[pipe fileHandleForReading] queue:nil usingBlock:^(NSNotification *notification){
                
                NSData *output = [[pipe fileHandleForReading] availableData];
                NSString *outStr = [[NSString alloc] initWithData:output encoding:NSUTF8StringEncoding];
                
                dispatch_sync(dispatch_get_main_queue(), ^{
                    self.outputText.string = [self.outputText.string stringByAppendingString:[NSString stringWithFormat:@"\n%@", outStr]];
                    // Scroll to end of outputText field
                    NSRange range;
                    range = NSMakeRange([self.outputText.string length], 0);
                    [self.outputText scrollRangeToVisible:range];
                });
                
                [[pipe fileHandleForReading] waitForDataInBackgroundAndNotify];
            }];
            
            [task launch];
            [task waitUntilExit];
            
        }
        @catch (NSException *exception) {
            NSLog(@"Problem Running Task: %@", [exception description]);
        }
        @finally {
            self.isRunning = NO;
            [self.spinner setHidden:YES];
            [self.spinner stopAnimation:self];
            [self.runButton setEnabled:YES];
        }
    });
}

- (IBAction)apkSelect:(id)sender {
    NSOpenPanel *open = [NSOpenPanel openPanel];
    [open setCanChooseFiles:YES];
    open.allowedFileTypes = [NSArray arrayWithObject:@"apk"];
    [open runModal];
    NSString *dir = open.URL.relativePath;
    NSString *out = [dir substringToIndex:dir.length - [dir rangeOfString:@".apk"].length];
    NSTextField *apk = self.apkDirTextField;
    [apk setStringValue:dir];
    NSTextField *outField = self.outPathTextField;
    [outField setStringValue:out];
}

- (IBAction)outSelect:(id)sender {
    NSOpenPanel *open = [NSOpenPanel openPanel];
    // [open setCanChooseFiles:NO];
    [open setCanChooseDirectories:YES];
    [open runModal];
    
    NSString *dir = open.URL.relativePath;
    NSTextField *out = self.outPathTextField;
    [out setStringValue:dir];
}

@end
