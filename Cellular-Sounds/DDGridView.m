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
@property (nonatomic) NSUInteger rowToHighlight;
@property (nonatomic) NSInteger lastHighlightedRow;
@property (nonatomic) BOOL shouldHighlightRow;
@end

@implementation DDGridView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
      // Disable multi-touch for now
      self.multipleTouchEnabled = NO;
      self.lastNumCols = 0;
      self.lastNumRows = 0;
      self.lastHighlightedRow = -1;
    }
    return self;
}

-(void)drawRect:(CGRect)rect
{
  // Drawing code
  [[UIColor whiteColor] setStroke];
  NSUInteger numRows = [self.grid count];
  for(NSUInteger row = 0; row < numRows; row ++)
  {
    NSUInteger numCols = [self.grid[row] count];
    CGFloat yOriginDelta = 0.0f;
    CGFloat heightDelta = 0.0f;
    for(NSUInteger col = 0; col < numCols; col ++)
    {
      id cellContents = self.grid[row][col];
      CGRect cellRect = CGRectMake(self.xPadding + (col * self.cellSide), yOriginDelta + self.yPadding + (row * self.cellSide), self.cellSide, self.cellSide + heightDelta);
      UIBezierPath *path = [UIBezierPath bezierPathWithRect:cellRect];
      path.lineWidth = 2.0f;
      UIColor *cellColor;
      if([cellContents isKindOfClass:[UIColor class]])
      {
        cellColor = (UIColor *)cellContents;
      }
      else
      {
        cellColor = [self.delegate gridView:self colorForCellContents:cellContents];
      }
      [cellColor setFill];
      [path fill];
      [path stroke];
    }
  }
  self.shouldHighlightRow = NO;
}

#pragma mark - Grid

-(void)setLastHighlightedRow:(NSInteger)lastHighlightedRow
{
  if(lastHighlightedRow >= self.lastNumRows)
  {
    lastHighlightedRow = 0;
  }
  _lastHighlightedRow = lastHighlightedRow;
}

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

-(void)layoutSubviews
{
  [super layoutSubviews];
  CGFloat cellWidth = self.bounds.size.width / self.lastNumCols;
  CGFloat cellHeight = self.bounds.size.height / self.lastNumRows;
  self.cellSide = (cellWidth > cellHeight) ? cellHeight : cellWidth;
  self.yPadding = (cellWidth > cellHeight) ? 0.0f : (self.bounds.size.height - (self.lastNumRows * cellWidth)) / 2;
  self.xPadding = (cellWidth > cellHeight) ? (self.bounds.size.width - (self.lastNumCols * cellHeight)) / 2 : 0.0f;
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

@end
