//
//  DDAbstractGameOfLife.m
//  Cellular-Sounds
//
//  Created by Vasco Orey on 7/13/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "DDAbstractGameOfLife.h"

@interface DDAbstractGameOfLife ()
@property (nonatomic, readwrite) NSUInteger rows;
@property (nonatomic, readwrite) NSUInteger cols;
@end

@implementation DDAbstractGameOfLife

-(id)initWithRows:(NSUInteger)rows cols:(NSUInteger)cols
{
  if((self = [super init]))
  {
    self.cols = cols;
    self.rows = rows;
  }
  return self;
}

-(void)reset
{
  NSAssert(false, @"%s should be overidden.", __PRETTY_FUNCTION__);
}

-(void)clearGrid
{
  NSAssert(false, @"%s should be overidden.", __PRETTY_FUNCTION__);
}

-(void)performStep
{
  NSAssert(false, @"%s should be overidden.", __PRETTY_FUNCTION__);
}

-(void)flipCellAtRow:(NSUInteger)row col:(NSUInteger)col species:(NSUInteger)species started:(BOOL)started
{
  NSAssert(false, @"%s should be overidden.", __PRETTY_FUNCTION__);
}

-(NSArray *)state
{
  NSAssert(false, @"%s should be overidden.", __PRETTY_FUNCTION__);
  return nil;
}

-(id)cellForRow:(NSUInteger)row col:(NSUInteger)col
{
  NSAssert(false, @"%s should be overidden.", __PRETTY_FUNCTION__);
  return nil;
}

-(NSUInteger)previousRow:(NSUInteger)fromRow
{
  //Wrap around if row == 0
  if(!fromRow)
  {
    return self.rows - 1;
  }
  else
  {
    return (fromRow - 1) % self.rows;
  }
}

-(NSUInteger)previousCol:(NSUInteger)fromCol
{
  if(!fromCol)
  {
    return self.cols - 1;
  }
  else
  {
    return (fromCol - 1) % self.cols;
  }
}

-(NSUInteger)nextRow:(NSUInteger)fromRow
{
  if(fromRow == self.rows - 1)
  {
    return 0;
  }
  else
  {
    return (fromRow + 1) % self.rows;
  }
}

-(NSUInteger)nextCol:(NSUInteger)fromCol
{
  if(fromCol == self.cols - 1)
  {
    return 0;
  }
  else
  {
    return (fromCol + 1) % self.cols;
  }
}


@end
