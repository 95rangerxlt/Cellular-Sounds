//
//  DDReactiveGameOfLife.m
//  Cellular-Sounds
//
//  Created by Vasco Orey on 7/21/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "DDReactiveGameOfLife.h"
#import "DDCell.h"
#import "DDLifeCell.h"
#import "DDFoodCell.h"
#import "NSMutableArray+Counting.h"

@interface DDReactiveGameOfLife ()
@property (nonatomic, strong) NSMutableArray *grid;
@property (nonatomic) NSUInteger seed;
@property (nonatomic) NSUInteger lastRow;
@property (nonatomic) NSUInteger lastCol;
@end

@implementation DDReactiveGameOfLife

-(void)setCellSpawnProbability:(double)cellSpawnProbability
{
  if(cellSpawnProbability >= _foodSpawnProbability)
  {
    _cellSpawnProbability = _foodSpawnProbability + cellSpawnProbability;
  }
  else
  {
    _cellSpawnProbability = cellSpawnProbability;
  }
  DDLogVerbose(@"Cell spawn: %g", _cellSpawnProbability);
}

-(void)setFoodSpawnProbability:(double)foodSpawnProbability
{
  if(foodSpawnProbability >= _cellSpawnProbability)
  {
    _foodSpawnProbability = _cellSpawnProbability + foodSpawnProbability;
  }
  else
  {
    _foodSpawnProbability = foodSpawnProbability;
  }
  DDLogVerbose(@"Food spawn: %g", _foodSpawnProbability);
}

-(id)initWithRows:(NSUInteger)rows cols:(NSUInteger)cols seed:(NSUInteger)seed
{
  if((self = [super initWithRows:rows cols:cols]))
  {
    self.seed = seed;
    [self reset];
  }
  return self;
}

-(void)reset
{
  // Seed the RNG
  srand(self.seed);
  // Build the grid
  self.grid = [NSMutableArray arrayWithCapacity:self.rows];
  for(NSUInteger i = 0; i < self.rows; i ++)
  {
    NSMutableArray *row = [NSMutableArray arrayWithCapacity:self.cols];
    for(NSUInteger j = 0; j < self.cols; j ++)
    {
      double spawn = ((double)rand()) / RAND_MAX;
      if(spawn < self.cellSpawnProbability &&
         (self.cellSpawnProbability < self.foodSpawnProbability ||
          (self.cellSpawnProbability > self.foodSpawnProbability && spawn > self.foodSpawnProbability)))
      {
        DDLifeCell *cell =[[DDLifeCell alloc] init];
        cell.row = i;
        cell.col = j;
        row[j] = cell;
      }
      else if(spawn < self.foodSpawnProbability &&
              (self.foodSpawnProbability < self.cellSpawnProbability ||
               (self.foodSpawnProbability > self.cellSpawnProbability && spawn > self.cellSpawnProbability)))
      {
        DDFoodCell *cell = [[DDFoodCell alloc] init];
        cell.row = i;
        cell.col = j;
        row[j] = cell;
      }
      else
      {
        DDCell *cell = [[DDCell alloc] init];
        cell.row = i;
        cell.col = j;
        row[j] = cell;
      }
    }
    self.grid[i] = row;
  }
}

-(void)performStep
{
  if(!self.isOn)
  {
    return;
  }
  NSMutableArray *allRows = [NSMutableArray numbersUpToAndIncluding:self.rows];
  NSInteger numberOfRows = [allRows count];
  while(numberOfRows)
  {
    NSUInteger currentRowIndex = rand() % numberOfRows;
    NSUInteger row = [allRows[currentRowIndex] unsignedIntegerValue];
    NSMutableArray *allCols = [NSMutableArray numbersUpToAndIncluding:self.cols];
    NSInteger numberOfCols = [allCols count];
    while(numberOfCols)
    {
      NSUInteger currentColIndex = rand() % numberOfCols;
      NSUInteger col = [allCols[currentColIndex] unsignedIntegerValue];
      // Check if this row, col is a DDLifeCell
      id cell = self.grid[row][col];
      if([cell isKindOfClass:[DDLifeCell class]])
      {
        DDLifeCell *lifeCell = (DDLifeCell *)cell;
        if([lifeCell shouldMove])
        {
          NSUInteger rowToCheck = row;
          NSUInteger colToCheck = col;
          if(lifeCell.orientation == Up)
          {
            rowToCheck = [self previousRow:row];
          }
          else if(lifeCell.orientation == Down)
          {
            rowToCheck = [self nextRow:row];
          }
          else if(lifeCell.orientation == Left)
          {
            colToCheck = [self previousCol:col];
          }
          else if(lifeCell.orientation == Right)
          {
            colToCheck = [self nextCol:col];
          }
          id cellToCheck = self.grid[rowToCheck][colToCheck];
          if([cellToCheck isKindOfClass:[DDFoodCell class]])
          {
            DDLogVerbose(@"Eating food!");
            // If its a food cell then eat it :)
            [lifeCell didMove];
            [lifeCell eat:cellToCheck];
            lifeCell.row = rowToCheck;
            lifeCell.col = colToCheck;
            self.grid[rowToCheck][colToCheck] = lifeCell;
            self.grid[row][col] = [[DDCell alloc] init];
          }
          else if([cellToCheck isKindOfClass:[DDLifeCell class]])
          {
            DDLifeCell *otherCell = (DDLifeCell *)cellToCheck;
            if(lifeCell.species == otherCell.species)
            {
//              if(lifeCell.age >= kMinAgeForReproduction && otherCell.age >= kMinAgeForReproduction)
              if([lifeCell canReproduceWith:otherCell])
              {
                // Check how much free space we have (around lifeCell)
                NSMutableArray *freeCells = [self freeCellsAtRow:row col:col];
                NSMutableArray *spawnedCells = [lifeCell reproduceWith:otherCell freeSpace:[freeCells count]];
                DDLogVerbose(@"Reproducing from (%d,%d) and (%d,%d), species: %d. Got %d new cells to put in %d free space!", row, col, rowToCheck, colToCheck, lifeCell.species, [spawnedCells count], [freeCells count]);
                for(DDLifeCell *spawned in spawnedCells)
                {
                  NSUInteger index = rand() % [freeCells count];
                  if([freeCells[index] isKindOfClass:[DDFoodCell class]])
                  {
                    // Bump up the cells life and place it here
                    DDFoodCell *foodCell = freeCells[index];
                    spawned.startingLife += foodCell.food;
                    spawned.currentLife += foodCell.food;
                    spawned.row = foodCell.row;
                    spawned.col = foodCell.col;
                  }
                  else
                  {
                    DDCell *freeCell = freeCells[index];
                    spawned.row = freeCell.row;
                    spawned.col = freeCell.col;
                  }
                  self.grid[spawned.row][spawned.col] = spawned;
                  [freeCells removeObjectAtIndex:index];
                }
              }
            }
            else
            {
              DDLogVerbose(@"Fight! Fight! Fight!");
              [lifeCell didMove];
              [lifeCell fight:cellToCheck];
              if([otherCell isDead] && ![lifeCell isDead])
              {
                lifeCell.row = rowToCheck;
                lifeCell.col = colToCheck;
                self.grid[rowToCheck][colToCheck] = lifeCell;
              }
            }
          }
          else
          {
            [lifeCell didMove];
            lifeCell.row = rowToCheck;
            lifeCell.col = colToCheck;
            self.grid[rowToCheck][colToCheck] = lifeCell;
            self.grid[row][col] = [[DDCell alloc] init];
          }
        }
        else
        {
          DDLogVerbose(@"Cell at (%d,%d) doens't want to move.", row, col);
        }
        if([lifeCell isDead])
        {
          DDLogVerbose(@"Cell at (%d,%d) is dead (life: %d). Deleting.", row, col, lifeCell.currentLife);
          self.grid[row][col] = [[DDCell alloc] init];
        }
        else
        {
          [lifeCell update];
        }
      }
      else if([cell isMemberOfClass:[DDCell class]])
      {
        double spawn = (double)rand() / RAND_MAX;
        DDCell *newCell = nil;
        if(spawn < self.cellSpawnProbability &&
           (self.cellSpawnProbability < self.foodSpawnProbability ||
            (self.cellSpawnProbability > self.foodSpawnProbability && spawn > self.foodSpawnProbability)))
        {
          newCell = [[DDLifeCell alloc] init];
        }
        else if(spawn < self.foodSpawnProbability &&
                (self.foodSpawnProbability < self.cellSpawnProbability ||
                 (self.foodSpawnProbability > self.cellSpawnProbability && spawn > self.cellSpawnProbability)))
        {
          newCell = [[DDFoodCell alloc] init];
        }
        if(newCell)
        {
          newCell.row = currentRowIndex;
          newCell.col = currentColIndex;
          self.grid[currentRowIndex][currentColIndex] = newCell;
          DDLogVerbose(@"Spawned a new %@ cell at %d,%d", NSStringFromClass([newCell class]), currentRowIndex, currentColIndex);
        }
      }
      [allCols removeObjectAtIndex:currentColIndex];
      numberOfCols --;
    }
    [allRows removeObjectAtIndex:currentRowIndex];
    numberOfRows --;
  }
}

-(NSMutableArray *)freeCellsAtRow:(NSUInteger)row col:(NSUInteger)col
{
  NSUInteger previousRow = [self previousRow:row];
  NSUInteger nextRow = [self nextRow:row];
  NSUInteger previousCol = [self previousCol:col];
  NSUInteger nextCol = [self nextCol:col];
  NSMutableArray *freeCells = [NSMutableArray array];
  if(![self.grid[previousRow][previousCol] isKindOfClass:[DDLifeCell class]])
  {
    [freeCells addObject:self.grid[previousRow][previousCol]];
  }
  if(![self.grid[previousRow][col] isKindOfClass:[DDLifeCell class]])
  {
    [freeCells addObject:self.grid[previousRow][col]];
  }
  if(![self.grid[previousRow][nextCol] isKindOfClass:[DDLifeCell class]])
  {
    [freeCells addObject:self.grid[previousRow][nextCol]];
  }
  if(![self.grid[row][previousCol] isKindOfClass:[DDLifeCell class]])
  {
    [freeCells addObject:self.grid[row][previousCol]];
  }
  if(![self.grid[row][nextCol] isKindOfClass:[DDLifeCell class]])
  {
    [freeCells addObject:self.grid[row][nextCol]];
  }
  if(![self.grid[nextRow][previousCol] isKindOfClass:[DDLifeCell class]])
  {
    [freeCells addObject:self.grid[nextRow][previousCol]];
  }
  if(![self.grid[nextRow][col] isKindOfClass:[DDLifeCell class]])
  {
    [freeCells addObject:self.grid[nextRow][col]];
  }
  if(![self.grid[nextRow][nextCol] isKindOfClass:[DDLifeCell class]])
  {
    [freeCells addObject:self.grid[nextRow][nextCol]];
  }
  return freeCells;
}

-(void)flipCellAtRow:(NSUInteger)row col:(NSUInteger)col species:(NSUInteger)species started:(BOOL)started
{
  if(started || row != self.lastRow || col != self.lastCol)
  {
    self.lastRow = row;
    self.lastCol = col;
    if([self.grid[row][col] isKindOfClass:[DDLifeCell class]] && ((DDLifeCell *)self.grid[row][col]).species == species)
    {
      DDCell *cell = [[DDCell alloc] init];
      cell.row = row;
      cell.col = col;
      self.grid[row][col] = cell;
    }
    else
    {
      DDLifeCell *cell = [[DDLifeCell alloc] initWithSpecies:species];
      cell.row = row;
      cell.col = col;
      self.grid[row][col] = cell;
    }
    [self.delegate gameOfLife:self didActivateCellAtRow:row col:col species:species];
  }
}

-(NSArray *)state
{
  NSMutableArray *state = [NSMutableArray arrayWithCapacity:self.rows];
  for(NSArray *row in self.grid)
  {
    [state addObject:[row copy]];
  }
  return state;
}

@end
