//
//  ViewController.h
//  LogSort
//
//  Created by hyc on 2019/3/28.
//  Copyright © 2019 HYC. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "ViewDropper.h"

@interface ViewController : NSViewController<DragShowStationDelegate>{
    NSMutableArray *LogArray;
    NSMutableArray *LogPathArray;
}

@property (strong) IBOutlet ViewDropper *viewDropper;
@property (weak) IBOutlet NSTableView *logNameTableView;
@property (weak) IBOutlet NSTextField *infoMessage;
- (IBAction)reset:(NSButton *)sender;
- (IBAction)sort:(NSButton *)sender;

@end

