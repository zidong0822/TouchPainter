//
//  Dot.h
//  TouchPainter
//
//  Created by Harvey He on 2019/9/19.
//  Copyright © 2019 Harvey He. All rights reserved.
//

#import "Vertex.h"
@protocol MarkVisitor;
@interface Dot : Vertex
{
    @private
    UIColor *color_;
    CGFloat size_;
}
@property (nonatomic, retain) UIColor *color;
@property (nonatomic, assign) CGFloat size;

- (void) acceptMarkVisitor:(id <MarkVisitor>)visitor;
- (id) copyWithZone:(NSZone *)zone;

- (id)initWithCoder:(NSCoder *)coder;
- (void)encodeWithCoder:(NSCoder *)coder;

@end
