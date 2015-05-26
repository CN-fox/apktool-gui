//
//  ViewController.h
//  apktool-gui
//
//  Created by wq on 15/5/25.
//  Copyright (c) 2015年 wq. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@interface ViewController : NSViewController



- (IBAction)runClick:(id)sender;
- (IBAction)apkSelect:(id)sender;
- (IBAction)outSelect:(id)sender;


@property(nonatomic,weak) IBOutlet NSTextField *apkDirTextField;
@property(nonatomic,weak) IBOutlet NSTextField *outPathTextField;
@property (weak) IBOutlet NSProgressIndicator *spinner;
@property (unsafe_unretained) IBOutlet NSTextView *outputText;
@property (weak) IBOutlet NSButton *force;
@property (weak) IBOutlet NSButton *nores;
@property (weak) IBOutlet NSButton *nosrc;
@property (weak) IBOutlet NSMatrix *matrix;
@property (weak) IBOutlet NSButton *runButton;



@property (nonatomic) BOOL isRunning;

@end

