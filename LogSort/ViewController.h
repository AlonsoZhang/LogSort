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
    NSDate *startdate;
    NSDate *enddate;
    NSDateFormatter *dateformatter;
}

@property (strong) IBOutlet ViewDropper *viewDropper;
@property (weak) IBOutlet NSTableView *logNameTableView;
@property (weak) IBOutlet NSTextField *infoMessage;
@property (weak) IBOutlet NSDatePicker *starttime;
@property (weak) IBOutlet NSDatePicker *endTime;
@property (weak) IBOutlet NSTextField *steptime;
@property (weak) IBOutlet NSStepper *timestepper;
@property (weak) IBOutlet NSButton *sortBtn;
@property (weak) IBOutlet NSButton *resetBtn;


- (IBAction)reset:(NSButton *)sender;
- (IBAction)sort:(NSButton *)sender;
- (IBAction)setStartTime:(NSDatePicker *)sender;
- (IBAction)setStepTime:(NSStepper *)sender;

@end

