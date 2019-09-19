//
//  CanvasViewController.m
//  TouchPainter
//
//  Created by Harvey He on 2019/9/19.
//  Copyright © 2019 Harvey He. All rights reserved.
//

#import "CanvasViewController.h"
#import "Dot.h"
#import "Stroke.h"
@interface CanvasViewController ()

@end

@implementation CanvasViewController
- (void) setScribble:(Scribble *)aScribble
{
    if (scribble_ != aScribble)
    {
        scribble_ = aScribble;
        
        // add itself to the scribble as
        // an observer for any changes to
        // its internal state - mark
        [scribble_ addObserver:self
                    forKeyPath:@"mark"
                       options:NSKeyValueObservingOptionInitial |
         NSKeyValueObservingOptionNew
                       context:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    CanvasViewGenerator *defaultGenerator = [[CanvasViewGenerator alloc] init];
    [self loadCanvasViewWithGenerator:defaultGenerator];
    Scribble *scribble = [[Scribble alloc] init];
    [self setScribble:scribble];
    
    // setup default stroke color and size
    NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
    CGFloat redValue = [userDefaults floatForKey:@"red"];
    CGFloat greenValue = [userDefaults floatForKey:@"green"];
    CGFloat blueValue = [userDefaults floatForKey:@"blue"];
    CGFloat sizeValue = [userDefaults floatForKey:@"size"];
    
    strokeSize_ = 10;
    strokeColor_ = [UIColor greenColor];
}

- (void) setStrokeSize:(CGFloat) aSize
{
    // enforce the smallest size
    // allowed
    if (aSize < 5.0)
    {
        strokeSize_ = 5.0;
    }
    else
    {
        strokeSize_ = aSize;
    }
}

- (void) loadCanvasViewWithGenerator:(CanvasViewGenerator *)generator
{
    [canvasView_ removeFromSuperview];
    CGRect aFrame = UIScreen.mainScreen.bounds;
    CanvasView *aCanvasView = [generator canvasViewWithFrame:aFrame];
   // aCanvasView.backgroundColor = [UIColor redColor];
    canvasView_ = aCanvasView;
//    [self setCanvasView:aCanvasView];
//    [self.view addSubview:aCanvasView];
    NSLog(@"%@1111",canvasView_);
//    canvasView_.backgroundColor = [UIColor blueColor];
    [self.view addSubview:canvasView_];
//    NSInteger viewIndex = [[[self view] subviews] count] - 1;
//    [[self view] insertSubview:canvasView_ atIndex:viewIndex];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    startPoint_ = [[touches anyObject] locationInView:canvasView_];
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint lastPoint = [[touches anyObject] previousLocationInView:canvasView_];
    
    // add a new stroke to scribble
    // if this is indeed a drag from
    // a finger
    if (CGPointEqualToPoint(lastPoint, startPoint_))
    {
        id <Mark> newStroke = [[Stroke alloc] init];
        newStroke.color = strokeColor_;
        newStroke.size = strokeSize_;
        
        //[scribble_ addMark:newStroke shouldAddToPreviousMark:NO];
        
        // retrieve a new NSInvocation for drawing and
        // set new arguments for the draw command
        NSInvocation *drawInvocation = [self drawScribbleInvocation];
        [drawInvocation setArgument:&newStroke atIndex:2];
        
        // retrieve a new NSInvocation for undrawing and
        // set a new argument for the undraw command
        NSInvocation *undrawInvocation = [self undrawScribbleInvocation];
        [undrawInvocation setArgument:&newStroke atIndex:2];
        
        // execute the draw command with the undraw command
        [self executeInvocation:drawInvocation withUndoInvocation:undrawInvocation];
    }
    
    // add the current touch as another vertex to the
    // temp stroke
    CGPoint thisPoint = [[touches anyObject] locationInView:canvasView_];
    Vertex *vertex = [[Vertex alloc]
                       initWithLocation:thisPoint];
    
    // we don't need to undo every vertex
    // so we are keeping this
    [scribble_ addMark:vertex shouldAddToPreviousMark:YES];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    CGPoint lastPoint = [[touches anyObject] previousLocationInView:canvasView_];
    CGPoint thisPoint = [[touches anyObject] locationInView:canvasView_];
    
    // if the touch never moves (stays at the same spot until lifted now)
    // just add a dot to an existing stroke composite
    // otherwise add it to the temp stroke as the last vertex
    if (CGPointEqualToPoint(lastPoint, thisPoint))
    {
        Dot *singleDot = [[Dot alloc]
                           initWithLocation:thisPoint];
        [singleDot setColor:strokeColor_];
        [singleDot setSize:strokeSize_];
        
        //[scribble_ addMark:singleDot shouldAddToPreviousMark:NO];
        
        // retrieve a new NSInvocation for drawing and
        // set new arguments for the draw command
        NSInvocation *drawInvocation = [self drawScribbleInvocation];
        [drawInvocation setArgument:&singleDot atIndex:2];
        
        // retrieve a new NSInvocation for undrawing and
        // set a new argument for the undraw command
        NSInvocation *undrawInvocation = [self undrawScribbleInvocation];
        [undrawInvocation setArgument:&singleDot atIndex:2];
        
        // execute the draw command with the undraw command
        [self executeInvocation:drawInvocation withUndoInvocation:undrawInvocation];
    }
    
    // reset the start point here
    startPoint_ = CGPointZero;
    
    // if this is the last point of stroke
    // don't bother to draw it as the user
    // won't tell the difference
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    // reset the start point here
    startPoint_ = CGPointZero;
}

#pragma mark -
#pragma mark Scribble observer method

- (void) observeValueForKeyPath:(NSString *)keyPath
                       ofObject:(id)object
                         change:(NSDictionary *)change
                        context:(void *)context
{
    if ([object isKindOfClass:[Scribble class]] &&
        [keyPath isEqualToString:@"mark"])
    {
        id <Mark> mark = [change objectForKey:NSKeyValueChangeNewKey];
        [canvasView_ setMark:mark];
        [canvasView_ setNeedsDisplay];
    }
}


#pragma mark -
#pragma mark Draw Scribble Invocation Generation Methods

- (NSInvocation *) drawScribbleInvocation
{
    NSMethodSignature *executeMethodSignature = [scribble_
                                                 methodSignatureForSelector:
                                                 @selector(addMark:
                                                           shouldAddToPreviousMark:)];
    NSInvocation *drawInvocation = [NSInvocation
                                    invocationWithMethodSignature:
                                    executeMethodSignature];
    [drawInvocation setTarget:scribble_];
    [drawInvocation setSelector:@selector(addMark:shouldAddToPreviousMark:)];
    BOOL attachToPreviousMark = NO;
    [drawInvocation setArgument:&attachToPreviousMark atIndex:3];
    
    return drawInvocation;
}

- (NSInvocation *) undrawScribbleInvocation
{
    NSMethodSignature *unexecuteMethodSignature = [scribble_
                                                   methodSignatureForSelector:
                                                   @selector(removeMark:)];
    NSInvocation *undrawInvocation = [NSInvocation
                                      invocationWithMethodSignature:
                                      unexecuteMethodSignature];
    [undrawInvocation setTarget:scribble_];
    [undrawInvocation setSelector:@selector(removeMark:)];
    
    return undrawInvocation;
}

#pragma mark Draw Scribble Command Methods

- (void) executeInvocation:(NSInvocation *)invocation
        withUndoInvocation:(NSInvocation *)undoInvocation
{
    [invocation retainArguments];
    
    [[self.undoManager prepareWithInvocationTarget:self]
     unexecuteInvocation:undoInvocation
     withRedoInvocation:invocation];
    
    [invocation invoke];
}

- (void) unexecuteInvocation:(NSInvocation *)invocation
          withRedoInvocation:(NSInvocation *)redoInvocation
{
    [[self.undoManager prepareWithInvocationTarget:self]
     executeInvocation:redoInvocation
     withUndoInvocation:invocation];
    
    [invocation invoke];
}

@end
