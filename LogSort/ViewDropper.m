//
//  ViewDropper.m
//  OverlayPack
//
//  Created by Alonso on 17/3/23.
//  Copyright © 2017年 Alonso. All rights reserved.
//

#import "ViewDropper.h"

@implementation ViewDropper {
    BOOL highlight;
}

- (void) awakeFromNib {
    [self registerForDraggedTypes:@[NSFilenamesPboardType]];
}

// Stop the NSView implementation getting in the way
- (NSDragOperation)draggingUpdated:(id <NSDraggingInfo>)sender {
    
    return [self draggingEntered:sender];
}

- (BOOL)performDragOperation:(id < NSDraggingInfo >)sender {
    NSPasteboard *pboard = [sender draggingPasteboard];
    NSArray *filenames = [pboard propertyListForType:NSFilenamesPboardType];
    [[self delegate] dragShowStation:filenames];
    highlight = NO;
    [self setNeedsDisplay: YES];
    return YES;
}

- (BOOL)prepareForDragOperation:(id)sender {
    return YES;
}

- (NSDragOperation)draggingEntered:(id <NSDraggingInfo>)sender
{
    if (highlight == NO) {
        highlight = YES;
        [self setNeedsDisplay: YES];
    }
    return NSDragOperationCopy;
}

- (void)draggingExited:(id)sender
{
    highlight = NO;
    [self setNeedsDisplay: YES];
}

-(void)drawRect:(NSRect)rect
{
    [super drawRect:rect];
    if ( highlight ) {
        [[NSColor blueColor] set];
        [NSBezierPath setDefaultLineWidth: 15];
        [NSBezierPath strokeRect: rect];
    }
}


@end
