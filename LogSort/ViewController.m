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
    NSFileManager *sortfm = [NSFileManager defaultManager];
    NSArray *desktoppaths = NSSearchPathForDirectoriesInDomains(NSDesktopDirectory, NSUserDomainMask, YES);
    NSString * totalLog = [[NSString alloc]init];
    NSMutableArray *logdetailArray = [[NSMutableArray alloc]init];
    for (NSDictionary*eachLog in LogArray) {
        NSString *logInfo = [[NSString alloc]initWithContentsOfFile:[eachLog objectForKey:@"logPath"] encoding:NSUTF8StringEncoding error:nil];
        NSArray * logdataArray = [logInfo componentsSeparatedByString:@"\n["];
        //NSLog(@"%@",logdataArray);
        for (NSString *logString in logdataArray) {
            //NSLog(@"%@",[self findFirstinString:logString withregex:@"\\d{4}-\\d{1,2}-\\d{1,2} \\d{1,2}:\\d{1,2}:\\d{1,2}\\.\\d{3}"]);
            NSString *logtimestamp = [self findFirstinString:logString withregex:@"\\d{4}-\\d{1,2}-\\d{1,2} \\d{1,2}:\\d{1,2}:\\d{1,2}\\.\\d{3}"];
            NSString *loginfo = [self findFirstinString:logString withregex:@"(?<=] )[\\s\\S]*"];
            NSMutableDictionary *detailLog = [NSMutableDictionary dictionaryWithObjects:[NSArray arrayWithObjects:logtimestamp,loginfo, nil] forKeys:[NSArray arrayWithObjects:@"logTime",@"logInfo", nil]];
            [logdetailArray addObject:detailLog];
            
            //NSLog(@"%@",[self findFirstinString:logString withregex:@"(?<=] )[\\s\\S]*"]);
        }
    }
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
