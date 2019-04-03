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
    LogArray = [[NSMutableArray alloc] init];
    startdate = [[NSDate alloc]init];
    enddate = [[NSDate alloc]init];
    [_starttime setDateValue:[NSDate date]];
    _timestepper.stringValue = @"5";
    [_steptime setStringValue:_timestepper.stringValue];
    [self setStartTime:_starttime];
    dateformatter = [[NSDateFormatter alloc] init];
    [dateformatter setDateFormat:@"yyyy-MM-dd HH:mm:ss.SSS"];
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
    NSLog(@"start");
    NSArray *desktoppaths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
    NSMutableArray *logdetailArray = [[NSMutableArray alloc]init];
    for (NSDictionary*eachLog in LogArray) {
        NSString *logInfo = [[NSString alloc]initWithContentsOfFile:[eachLog objectForKey:@"logPath"] encoding:NSUTF8StringEncoding error:nil];
        NSMutableArray *logtimestampArray = [self findinString:logInfo withregex:@"\\d{4}-\\d{1,2}-\\d{1,2} \\d{1,2}:\\d{1,2}:\\d{1,2}\\.\\d{3}"];
        NSDate *firstdate = [dateformatter dateFromString:[logtimestampArray firstObject]];
        NSDate *lastdate = [dateformatter dateFromString:[logtimestampArray lastObject]];
        if (!([enddate timeIntervalSinceDate:firstdate] < 0 || [startdate timeIntervalSinceDate:lastdate] > 0)) {
            NSLog(@"aaa");
            for (NSString *logtimestamp in logtimestampArray) {
                BOOL stepout = false;
                if ([self judgeInTimeInterval:[dateformatter dateFromString:logtimestamp]]) {
                    stepout = true;
                    NSString *eachloginfo = [self findFirstinString:logInfo withregex:@"(?<=] )[\\s\\S]*(?<=[201)"];
                    NSMutableDictionary *detailLog = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:logtimestamp,eachloginfo, nil] forKeys:[NSArray arrayWithObjects:@"logTime",@"logInfo", nil]];
                    [logdetailArray addObject:detailLog];
                }else{
                    if (stepout) {
                        break;
                    }
                }
            }
            NSLog(@"bbb");
            
//            NSArray * logdataArray = [logInfo componentsSeparatedByString:@"\n["];
//            for (NSString *logString in logdataArray) {
//                NSString *logtimestamp = [self findFirstinString:logString withregex:@"\\d{4}-\\d{1,2}-\\d{1,2} \\d{1,2}:\\d{1,2}:\\d{1,2}\\.\\d{3}"];
//                BOOL stepout = false;
//                if ([self judgeInTimeInterval:[dateformatter dateFromString:logtimestamp]]){
//                    stepout = true;
//                    NSString *loginfo = [self findFirstinString:logString withregex:@"(?<=] )[\\s\\S]*"];
//                    NSMutableDictionary *detailLog = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:logtimestamp,loginfo, nil] forKeys:[NSArray arrayWithObjects:@"logTime",@"logInfo", nil]];
//                    [logdetailArray addObject:detailLog];
//                }else{
//                    if (stepout) {
//                        break;
//                    }
//                }
//            }
        }
    }
    NSLog(@"%@",logdetailArray);
//    NSSortDescriptor *sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"logTime" ascending:YES];
//    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
//    NSArray *sortedArray = [logdetailArray sortedArrayUsingDescriptors:sortDescriptors];
//    logdetailArray = [sortedArray mutableCopy];
    NSString *finalString = [[NSString alloc]init];
//    for (NSDictionary *finalDic in logdetailArray) {
//        finalString = [NSString stringWithFormat:@"%@\n[%@] %@",finalString,[finalDic objectForKey:@"logTime"],[finalDic objectForKey:@"logInfo"]];
//    }
    finalString = [logdetailArray componentsJoinedByString:@"\n"];
    //[finalString writeToFile:[NSString stringWithFormat:@"%@/aaa.log",[desktoppaths objectAtIndex:0]] atomically:true];
    [finalString writeToFile:[NSString stringWithFormat:@"%@/aaa.log",[desktoppaths objectAtIndex:0]] atomically:true encoding:NSUTF8StringEncoding error:nil];
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

-(NSString *)findFirstinString:(NSString *)TargetString withregex:(NSString *) regexString
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

-(NSMutableArray *)findinString:(NSString *)TargetString withregex:(NSString *) regexString
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
