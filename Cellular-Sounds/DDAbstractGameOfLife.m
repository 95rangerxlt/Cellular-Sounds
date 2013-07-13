//
//  DDAbstractGameOfLife.m
//  Cellular-Sounds
//
//  Created by Vasco Orey on 7/13/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "DDAbstractGameOfLife.h"

@implementation DDAbstractGameOfLife
{
  NSUInteger _numRows;
  NSUInteger _numCols;
}

-(id)initWithRows:(NSUInteger)rows cols:(NSUInteger)cols
{
  if((self = [super init]))
  {
    _numCols = cols;
    _numRows = rows;
  }
  return self;
}

-(void)reset
{
  NSAssert(false, @"%s", __PRETTY_FUNCTION__);
}

-(void)performStep
{
  NSAssert(false, @"%s", __PRETTY_FUNCTION__);
}

-(void)flipCellAtRow:(NSUInteger)row col:(NSUInteger)col species:(NSUInteger)species started:(BOOL)started
{
  NSAssert(false, @"%s", __PRETTY_FUNCTION__);
}


-(NSUInteger)previousRow:(NSUInteger)fromRow
{
  //Wrap around if row == 0
  if(!fromRow)
  {
    return _numRows - 1;
  }
  else
  {
    return (fromRow - 1) % _numRows;
  }
}

-(NSUInteger)previousCol:(NSUInteger)fromCol
{
  if(!fromCol)
  {
    return _numCols - 1;
  }
  else
  {
    return (fromCol - 1) % _numCols;
  }
}

-(NSUInteger)nextRow:(NSUInteger)fromRow
{
  if(fromRow == _numRows - 1)
  {
    return 0;
  }
  else
  {
    return (fromRow + 1) % _numRows;
  }
}

-(NSUInteger)nextCol:(NSUInteger)fromCol
{
  if(fromCol == _numCols - 1)
  {
    return 0;
  }
  else
  {
    return (fromCol + 1) % _numCols;
  }
}


@end
