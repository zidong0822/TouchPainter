//
//  Mark.h
//  TouchPainter
//
//  Created by Harvey He on 2019/9/19.
//  Copyright © 2019 Harvey He. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MarkVisitor.h"

@protocol Mark <NSObject>

@property (nonatomic, retain) UIColor *color;
@property (nonatomic, assign) CGFloat size;
@property (nonatomic, assign) CGPoint location;
@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly) id<Mark> lastChild;

-(id)copy;
-(void) addMark:(id <Mark>) mark;
-(void) removeMark:(id <Mark>) mark;
-(id <Mark>) childMarkAtIndex: (NSUInteger) index;

- (void) acceptMarkVisitor:(id <MarkVisitor>) visitor;

- (NSEnumerator *) enumerator;

// for internal iterator implementation
- (void) enumerateMarksUsingBlock:(void (^)(id <Mark> item, BOOL *stop)) block;

// for a bad example
- (void) drawWithContext:(CGContextRef) context;

@end
