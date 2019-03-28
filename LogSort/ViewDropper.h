//
//  ViewDropper.h
//  OverlayPack
//
//  Created by Alonso on 17/3/23.
//  Copyright © 2017年 Alonso. All rights reserved.
//

#import <Cocoa/Cocoa.h>

@protocol DragShowStationDelegate
-(void)dragShowStation:(NSArray *)files;
@end

@interface ViewDropper : NSView
@property (nonatomic, weak) id<DragShowStationDelegate> delegate;
@end
