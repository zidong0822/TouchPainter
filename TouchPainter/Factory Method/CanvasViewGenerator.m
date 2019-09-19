//
//  CanvasViewGenerator.m
//  TouchPainter
//
//  Created by Carlo Chung on 10/16/10.
//  Copyright 2010 Carlo Chung. All rights reserved.
//

#import "CanvasViewGenerator.h"


@implementation CanvasViewGenerator

- (CanvasView *) canvasViewWithFrame:(CGRect) aFrame
{
    CanvasView *canvasView = [[CanvasView alloc] initWithFrame:aFrame];
   // canvasView.backgroundColor = [UIColor redColor];
    return canvasView;
}

@end
