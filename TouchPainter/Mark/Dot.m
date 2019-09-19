//
//  Dot.m
//  TouchPainter
//
//  Created by Harvey He on 2019/9/19.
//  Copyright © 2019 Harvey He. All rights reserved.
//

#import "Dot.h"

@implementation Dot
@synthesize size=size_, color=color_;

- (void) acceptMarkVisitor:(id <MarkVisitor>)visitor
{
    [visitor visitDot:self];
}

- (id)copyWithZone:(NSZone *)zone{
    Dot *dotCopy = [[[self class] allocWithZone:zone] initWithLocation:location_];
    [dotCopy setColor:[UIColor colorWithCGColor:[color_ CGColor]]];
    [dotCopy setSize:size_];
    return dotCopy;
}

#pragma mark -
#pragma mark NSCoder methods

- (id)initWithCoder:(NSCoder *)coder
{
    if (self = [super initWithCoder:coder])
    {
        color_ = [coder decodeObjectForKey:@"DotColor"];
        size_ = [coder decodeFloatForKey:@"DotSize"];
    }
    
    return self;
}

- (void)encodeWithCoder:(NSCoder *)coder
{
    [super encodeWithCoder:coder];
    [coder encodeObject:color_ forKey:@"DotColor"];
    [coder encodeFloat:size_ forKey:@"DotSize"];
}

#pragma mark -
#pragma mark An Extended Direct-draw Example

// for a direct draw example
- (void) drawWithContext:(CGContextRef)context
{
    CGFloat x = self.location.x;
    CGFloat y = self.location.y;
    CGFloat frameSize = self.size;
    CGRect frame = CGRectMake(x - frameSize / 2.0,
                              y - frameSize / 2.0,
                              frameSize,
                              frameSize);
    
    CGContextSetFillColorWithColor (context,[self.color CGColor]);
    CGContextFillEllipseInRect(context, frame);
}

@end
