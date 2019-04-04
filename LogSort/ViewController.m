//
//  ViewController.m
//  LogSort
//
//  Created by hyc on 2019/3/28.
//  Copyright © 2019 HYC. All rights reserved.
//

#import "ViewController.h"

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[self logNameTableView] becomeFirstResponder];
    self.viewDropper.delegate = self;
    dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
    LogArray = [[NSMutableArray alloc] init];
    startdate = [[NSDate alloc]init];
    enddate = [[NSDate alloc]init];
    [_starttime setDateValue:[NSDate date]];
    //NSDate *nowdate = [dateformatter dateFromString:@"2017-10-12 00:20:22.000"];
    //[_starttime setDateValue:nowdate];
    _timestepper.stringValue = @"5";
    [_steptime setStringValue:_timestepper.stringValue];
    [self setStartTime:_starttime];
}

-(void)dragShowStation:(NSArray *)files {
    [self.logNameTableView reloadData];
    for (NSString *filePath in files) {
        [self showAllLogFileWithPath:filePath];
    }
    [self.logNameTableView reloadData];
}

- (void)showAllLogFileWithPath:(NSString *) path {
    NSFileManager * fileManger = [NSFileManager defaultManager];
    BOOL isDir = NO;
    BOOL isExist = [fileManger fileExistsAtPath:path isDirectory:&isDir];
    if (isExist) {
        if (isDir) {
            NSArray * dirArray = [fileManger contentsOfDirectoryAtPath:path error:nil];
            NSString * subPath = nil;
            for (NSString * str in dirArray) {
                subPath  = [path stringByAppendingPathComponent:str];
                BOOL issubDir = NO;
                [fileManger fileExistsAtPath:subPath isDirectory:&issubDir];
                [self showAllLogFileWithPath:subPath];
            }
        }else{
            NSString *fileName = [[path componentsSeparatedByString:@"/"] lastObject];
            if ([fileName hasSuffix:@".log"]) {
                BOOL checkExist = true;
                for (NSDictionary*exist in LogArray) {
                    if ([[exist objectForKey:@"logName"]isEqualToString:fileName]) {
                        checkExist = false;
                        break;
                    }
                }
                if (checkExist) {
                    NSMutableDictionary *existLog = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:fileName,path, nil] forKeys:[NSArray arrayWithObjects:@"logName",@"logPath", nil]];
                    [LogArray addObject:existLog];
                }
            }
        }
    }else{
        self.infoMessage.stringValue = @"Path is not exist!";
    }
}

- (IBAction)reset:(NSButton *)sender {
    [LogArray removeAllObjects];
    [self.logNameTableView reloadData];
}

- (IBAction)sort:(NSButton *)sender {
    self.infoMessage.stringValue = @"Sorting...";
    [_sortBtn setEnabled:false];
    [_resetBtn setEnabled:false];
    [_timestepper setEnabled:false];
    [_starttime setEnabled:false];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSArray *desktoppaths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
        NSMutableArray *logdetailArray = [[NSMutableArray alloc]init];
        for (NSDictionary*eachLog in self->LogArray) {
            NSString *logType = [[[eachLog objectForKey:@"logName"]componentsSeparatedByString:@" "]firstObject];
            NSString *logInfo = [[NSString alloc]initWithContentsOfFile:[eachLog objectForKey:@"logPath"] encoding:NSUTF8StringEncoding error:nil];
            NSMutableArray *logtimestampArray = [self findinString:logInfo withregex:@"\\[\\d{4}-\\d{1,2}-\\d{1,2} \\d{1,2}:\\d{1,2}:\\d{1,2}\\.\\d{3}\\][\\d\\D]*?(?=\\n\\[201)"];
            NSRange range = NSMakeRange(1, 23);
            NSDate *firstdate = [self->dateformatter dateFromString:[[logtimestampArray firstObject]substringWithRange:range]];
            NSDate *lastdate = [self->dateformatter dateFromString:[[logtimestampArray lastObject]substringWithRange:range]];
            if (!([self->enddate timeIntervalSinceDate:firstdate] < 0 || [self->startdate timeIntervalSinceDate:lastdate] > 0)) {
                for (NSString *logtimestamp in logtimestampArray) {
                    BOOL stepout = false;
                    NSDate * logtimestampdate = [self->dateformatter dateFromString:[logtimestamp substringWithRange:range]];
                    //NSString * eachlogInfo = [logtimestamp substringFromIndex:25];
                    NSString * eachlogInfo = [self ReplaceString:[logtimestamp substringFromIndex:25]  withregex:@"\\n\\s+" withString:@"\n                          "];
                    if ([self judgeInTimeInterval:logtimestampdate]) {
                        stepout = true;
                        NSMutableDictionary *detailLog = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:logtimestampdate,eachlogInfo,logType,nil] forKeys:[NSArray arrayWithObjects:@"logTime",@"logInfo",@"logType",nil]];
                        [logdetailArray addObject:detailLog];
                    }else{
                        if (stepout) {
                            break;
                        }
                    }
                }
            }
        }
        NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"logTime" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
        NSArray *sortedArray = [logdetailArray sortedArrayUsingDescriptors:sortDescriptors];
        logdetailArray = [sortedArray mutableCopy];
        NSString *finalString = [[NSString alloc]init];
        NSMutableArray *fianlArray = [[NSMutableArray alloc]init];
        NSString *compareType = [[NSString alloc]init];
        for (NSDictionary *eachlogdetail  in logdetailArray) {
            if ([compareType isEqualToString:[eachlogdetail objectForKey:@"logType"]]) {
                [fianlArray addObject:[NSString stringWithFormat:@"[%@]%@",[self->dateformatter stringFromDate:[eachlogdetail objectForKey:@"logTime"]],[eachlogdetail objectForKey:@"logInfo"]]];
            }else{
                compareType = [eachlogdetail objectForKey:@"logType"];
                NSString *typetitle = [self characterStringMainString:[NSString stringWithFormat:@"----------%@",[eachlogdetail objectForKey:@"logType"]] AddDigit:80 AddString:@"-" AddInPrefix:false];
                [fianlArray addObject:[NSString stringWithFormat:@"\n%@\n[%@]%@",typetitle,[self->dateformatter stringFromDate:[eachlogdetail objectForKey:@"logTime"]],[eachlogdetail objectForKey:@"logInfo"]]];
            }
        }
        finalString = [fianlArray componentsJoinedByString:@"\n"];
        NSDateFormatter *df = [[NSDateFormatter alloc] init];
        [df setDateFormat:@"yyyyMMddHHmmss"];
        [finalString writeToFile:[NSString stringWithFormat:@"%@/%@.log",[desktoppaths objectAtIndex:0],[df stringFromDate:[NSDate date]]] atomically:true encoding:NSUTF8StringEncoding error:nil];
        dispatch_async(dispatch_get_main_queue(), ^{
            self.infoMessage.stringValue = @"Finish";
            [self.sortBtn setEnabled:true];
            [self.resetBtn setEnabled:true];
            [self.timestepper setEnabled:true];
            [self.starttime setEnabled:true];
        });
    });
}

- (IBAction)setStartTime:(NSDatePicker *)sender {
    NSDatePicker *datePicker = sender;
    startdate = datePicker.dateValue;
    enddate = [startdate dateByAddingTimeInterval:[_steptime intValue]*60];
    [_endTime setDateValue:enddate];
}

- (IBAction)setStepTime:(NSStepper *)sender {
    NSStepper *stepper = sender;
    [_steptime setStringValue:stepper.stringValue];
    [self setStartTime:_starttime];
}

- (BOOL)judgeInTimeInterval:(NSDate *)date{
    if ([startdate timeIntervalSinceDate:date] > 0) {
        return false;
    }
    if ([enddate timeIntervalSinceDate:date] < 0) {
        return false;
    }
    return true;
}

-(NSString *)findFirstinString:(NSString *)TargetString
                     withregex:(NSString *) regexString
{
    NSError *error;
    NSString *pattern = [NSString stringWithFormat:@"%@",regexString];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:0 error:&error];
    if (regex != nil)
    {
        NSTextCheckingResult *firstMatch = [regex firstMatchInString:TargetString options:0 range:NSMakeRange(0, TargetString.length)];
        if (firstMatch != nil)
        {
            NSString *result=[TargetString substringWithRange:firstMatch.range];
            return result;
        }
    }
    return @"";
}

-(NSMutableArray *)findinString:(NSString *)TargetString
                      withregex:(NSString *) regexString
{
    NSError *error;
    NSString *pattern = [NSString stringWithFormat:@"%@",regexString];
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSMutableArray *temparr = [NSMutableArray new];
    if (regex != nil)
    {
        NSArray *array = [regex matchesInString:TargetString options:0 range:NSMakeRange(0, TargetString.length)];
        for (NSTextCheckingResult* b in array)
        {
            NSString * tmp = [TargetString substringWithRange:b.range] ;
            if (tmp.length > 0)
            {
                [temparr addObject:tmp];
            }
        }
        return temparr;
    }
    return nil;
}

- (NSString *)ReplaceString:(NSString *)TargetString withregex:(NSString *) regexString withString:(NSString *) newString
{
    NSError *error;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:regexString options:NSRegularExpressionCaseInsensitive error:&error];
    if (regex != nil)
    {
        NSString *newContents = [regex stringByReplacingMatchesInString:TargetString options:0 range:NSMakeRange(0, TargetString.length) withTemplate:newString];
        return newContents;
    }
    return TargetString;
}

- (NSString *)characterStringMainString:(NSString*)mainString
                               AddDigit:(int)addDigit
                              AddString:(NSString*)addString
                            AddInPrefix:(BOOL)inPrefix {
    NSString *completeString = [[NSString alloc] init];
    completeString = mainString;
    for(NSInteger index = 0; index < (addDigit - mainString.length); index++) {
        if (inPrefix) {
            completeString = [NSString stringWithFormat:@"%@%@", addString, completeString];
        }
        else {
            completeString = [NSString stringWithFormat:@"%@%@", completeString, addString];
        }
    }
    return completeString;
}

#pragma mark NSTableViewDataSource Delegate
- (NSInteger)numberOfRowsInTableView:(NSTableView *)tableView
{
    if(LogArray==nil){
        return 0;
    }
    else{
        return [LogArray count];
    }
}

- (nullable id)tableView:(NSTableView *)tableView objectValueForTableColumn:(nullable NSTableColumn *)tableColumn row:(NSInteger)row
{
    return [[LogArray objectAtIndex:row] objectForKey:[tableColumn identifier]];
}

@end
