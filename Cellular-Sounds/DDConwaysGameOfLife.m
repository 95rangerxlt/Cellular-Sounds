//
//  DDConwaysGameOfLife.m
//  Cellular-Sounds
//
//  Created by Vasco Orey on 7/13/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "DDConwaysGameOfLife.h"

@interface DDConwaysGameOfLife ()
@property (nonatomic) NSUInteger priorRow;
@property (nonatomic) NSUInteger priorCol;
@property (nonatomic, strong) NSMutableArray *grid;
@property (nonatomic, strong) NSMutableArray *neighbors;
@property (nonatomic, strong) NSMutableArray *dominantSpecies;
-(void)updateGrid;
-(void)countNeighborsAndDominantSpecies;
@end

@implementation DDConwaysGameOfLife

#pragma mark - Properties

-(NSMutableArray *)neighbors
{
  if(!_neighbors) _neighbors = [NSMutableArray arrayWithCapacity:self.rows];
  return _neighbors;
}

-(NSMutableArray *)dominantSpecies
{
  if(!_dominantSpecies) _dominantSpecies = [NSMutableArray arrayWithCapacity:self.rows];
  return _dominantSpecies;
}

-(NSMutableArray *)grid
{
  if(!_grid) _grid = [NSMutableArray arrayWithCapacity:self.rows];
  return _grid;
}

#pragma mark - Init

-(id)initWithRows:(NSUInteger)rows cols:(NSUInteger)cols
{
  if((self = [super initWithRows:rows cols:cols]))
  {
    self.status = On;
    [self reset];
  }
  return self;
}

#pragma mark - DDAbstractGameOfLife Overrides

-(NSArray *)state
{
  NSMutableArray *state = [NSMutableArray arrayWithCapacity:self.rows];
  for(NSArray *row in self.grid)
  {
    [state addObject:[row copy]];
  }
  return state;
}

-(void)reset
{
  DDLogVerbose(@"Resetting Conway...");
  self.neighbors = nil;
  self.dominantSpecies = nil;
  self.grid = nil;
  for(NSUInteger row = 0; row < self.rows; row ++)
  {
    NSMutableArray *line = [NSMutableArray arrayWithCapacity:self.cols];
    NSMutableArray *neighborsLine = [NSMutableArray arrayWithCapacity:self.cols];
    NSMutableArray *dominantSpeciesLine = [NSMutableArray arrayWithCapacity:self.cols];
    for(NSUInteger col = 0; col < self.cols; col ++)
    {
      line[col] = @(0);
      neighborsLine[col] = @(0);
      dominantSpeciesLine[col] = @(0);
    }
    self.grid[row] = line;
    self.neighbors[row] = neighborsLine;
    self.dominantSpecies[row] = dominantSpeciesLine;
  }
}

-(void)performStep
{
  if(self.status == On)
  {
    [self updateGrid];
  }
}

-(void)flipCellAtRow:(NSUInteger)row col:(NSUInteger)col species:(NSUInteger)species started:(BOOL)started
{
  if(started || self.priorRow != row || self.priorCol != col)
  {
    NSInteger previousValue = [self.grid[row][col] integerValue];
    self.grid[row][col] = previousValue && species && previousValue == species ? @(0) : @(species);
    self.priorCol = col;
    self.priorRow = row;
    if([self.delegate respondsToSelector:@selector(gameOfLife:didActivateCellAtRow:col:species:)])
    {
      [self.delegate gameOfLife:self didActivateCellAtRow:row col:col species:species];
    }
  }
}

#pragma mark - Private Methods

-(void)updateGrid
{
  [self countNeighborsAndDominantSpecies];
  for(NSUInteger row = 0; row < self.rows; row ++)
  {
    for(NSUInteger col = 0; col < self.cols; col ++)
    {
      NSInteger numberOfNeighbors = [self.neighbors[row][col] integerValue];
      if(numberOfNeighbors < 2 || numberOfNeighbors > 3)
      {
        self.grid[row][col] = @(0);
      }
      else if(numberOfNeighbors == 3 && ![self.grid[row][col] integerValue])
      {
        self.grid[row][col] = self.dominantSpecies[row][col];
//        if([self.delegate respondsToSelector:@selector(gameOfLife:didActivateCellAtRow:col:species:)])
//        {
//          [self.delegate gameOfLife:self didActivateCellAtRow:row col:col species:[self.dominantSpecies[row][col] unsignedIntegerValue]];
//        }
      }
    }
  }
}

//
// 1 2 3
// 4   5
// 6 7 8
//
-(void)countNeighborsAndDominantSpecies
{
  for(NSUInteger row = 0; row < self.rows; row ++)
  {
    for(NSUInteger col = 0; col < self.cols; col ++)
    {
      NSInteger previousRow = [self previousRow:row];
      NSInteger nextRow = [self nextRow:row];
      NSInteger previousCol = [self previousCol:col];
      NSInteger nextCol = [self nextCol:col];
      // Manhattan cells
      NSInteger one = [self.grid[previousRow][previousCol] integerValue];
      NSInteger two = [self.grid[previousRow][col] integerValue];
      NSInteger three = [self.grid[previousRow][nextCol] integerValue];
      NSInteger four = [self.grid[row][previousCol] integerValue];
      NSInteger five = [self.grid[row][nextCol] integerValue];
      NSInteger six = [self.grid[nextRow][previousCol] integerValue];
      NSInteger seven = [self.grid[nextRow][col] integerValue];
      NSInteger eight = [self.grid[nextRow][nextCol] integerValue];
      // Count neighbors
      self.neighbors[row][col] = @((one ? 1 : 0) + (two ? 1 : 0) +
      (three ? 1 : 0) + (four ? 1 : 0) + (five ? 1 : 0) +
      (six ? 1 : 0) + (seven ? 1 : 0) + (eight ? 1 : 0));
      // Check dominant species
      NSMutableArray *species = [NSMutableArray arrayWithArray:@[@(one), @(two), @(three), @(four), @(five), @(six), @(seven), @(eight)]];
      [species removeObject:@(0)];
      NSCountedSet *countedSpecies = [NSCountedSet setWithArray:species];
      __block NSNumber *dominant = @(0);
      __block NSInteger max = 0;
      [countedSpecies enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        NSInteger current = [countedSpecies countForObject:obj];
        if(current > max)
        {
          max = current;
          dominant = (NSNumber *)obj;
        }
      }];
      self.dominantSpecies[row][col] = dominant;
    }
  }
}

@end
