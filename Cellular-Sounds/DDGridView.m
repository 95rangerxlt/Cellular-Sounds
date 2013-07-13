//
//  DDGridView.m
//  Cellular-Sounds
//
//  Created by Vasco Orey on 7/13/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "DDGridView.h"

@interface DDGridView ()
@property (nonatomic) NSUInteger lastNumRows;
@property (nonatomic) NSUInteger lastNumCols;
@property (nonatomic) CGFloat cellSide;
@property (nonatomic) CGFloat xPadding;
@property (nonatomic) CGFloat yPadding;
@end

@implementation DDGridView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      // Disable multi-touch for now
      self.multipleTouchEnabled = NO;
    }
    return self;
}

#warning TODO - Improve this method
-(void)drawRect:(CGRect)rect
{
  // Drawing code
  CGContextRef context = UIGraphicsGetCurrentContext();
  NSUInteger numRows = [self.grid count];
  CGRect cellRect = CGRectMake(0, 0, self.cellSide, self.cellSide);
  CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
  for(NSUInteger row = 0; row < numRows; row ++)
  {
    NSUInteger numCols = [self.grid[row] count];
    for(NSUInteger col = 0; col < numCols; col ++)
    {
      id cellContents = self.grid[row][col];
      cellRect.origin.x = self.xPadding + (col * self.cellSide);
      cellRect.origin.y = self.yPadding + (row * self.cellSide);
      UIColor *color = [cellContents isKindOfClass:[UIColor class]] ? (UIColor *)cellContents : [self.delegate gridView:self colorForCellContents:cellContents];
      CGContextSetFillColorWithColor(context, [color CGColor]);
      CGContextSetLineWidth(context, 10.0f);
      CGContextStrokeRect(context, cellRect);
      CGContextFillRect(context, cellRect);
    }
  }
}

#pragma mark - Grid

-(void)setGrid:(NSArray *)grid
{
  NSUInteger rows = [grid count];
  NSUInteger cols = [grid[0] count];
  if(rows != self.lastNumRows || cols != self.lastNumCols)
  {
    self.lastNumCols = cols;
    self.lastNumRows = rows;
    CGFloat cellWidth = self.bounds.size.width / cols;
    CGFloat cellHeight = self.bounds.size.height / rows;
    self.cellSide = (cellWidth > cellHeight) ? cellHeight : cellWidth;
    self.yPadding = (cellWidth > cellHeight) ? 0.0f : (self.bounds.size.height - (rows * cellWidth)) / 2;
    self.xPadding = (cellWidth > cellHeight) ? (self.bounds.size.width - (cols * cellHeight)) / 2 : 0.0f;
  }
  _grid = grid;
  [self setNeedsDisplay];
}

-(void)activateRow:(NSUInteger)row col:(NSUInteger)col color:(UIColor *)color
{
  self.grid[row][col] = color;
  [self setNeedsDisplay];
}

#pragma mark - Touch Events

-(void)handleTouch:(UITouch *)touch started:(BOOL)started
{
  CGPoint location = [touch locationInView:self];
  NSInteger row = (location.y - self.yPadding) / self.cellSide;
  NSInteger col = (location.x - self.xPadding) / self.cellSide;
  if(row >= 0 && row < self.lastNumRows &&
     col >= 0 && col < self.lastNumCols)
  {
    [self.delegate gridView:self didDetectTouchAtRow:row col:col justStarted:started];
  }
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
  [touches enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
    [self handleTouch:(UITouch *)obj started:YES];
  }];
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
  [touches enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
    [self handleTouch:(UITouch *)obj started:NO];
  }];
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
  
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  
}

@end
