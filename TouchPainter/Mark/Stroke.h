//
//  Stroke.h
//  TouchPainter
//
//  Created by Harvey He on 2019/9/19.
//  Copyright © 2019 Harvey He. All rights reserved.
//

#import "Vertex.h"
#import "Mark.h"
#import "MarkEnumerator.h"
@protocol MarkVisitor;

@interface Stroke : NSObject<Mark,NSCopying>
{
    @private
    UIColor *color_;
    CGFloat size_;
    NSMutableArray *children_;
}
@property (nonatomic, retain) UIColor *color;
@property (nonatomic, assign) CGFloat size;
@property (nonatomic, assign) CGPoint location;
@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly) id <Mark> lastChild;
-(void) addMark:(id<Mark>)mark;
-(void) removeMark:(id<Mark>)mark;
-(id <Mark>) childMarkAtIndex:(NSUInteger)index;
-(id)copyWithZone:(NSZone *)zone;

@end
