//
//  DDLifeCell.m
//  Cellular-Sounds
//
//  Created by Vasco Orey on 7/21/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "DDReactiveLifeCell.h"

#define kNumberOfSpecies 4
#define kMaxLifeValue 100
#define kNumberOfOrientations 4
#define kMinAgeForReproduction 8
#define kMinTimeSinceLastReproduction 5

@interface DDReactiveLifeCell ()
@property (nonatomic, readwrite) NSUInteger species;
@property (nonatomic) NSInteger age;
@property (nonatomic) NSInteger timeSinceLastReproduction;
@end

@implementation DDReactiveLifeCell
-(id)init
{
  if((self = [super init]))
  {
    self.species = rand() % kNumberOfSpecies;
    self.startingLife = rand() % kMaxLifeValue + 1;
    self.currentLife = self.startingLife;
    self.orientation = (CellOrientation)(rand() % kNumberOfOrientations);
  }
  return self;
}

-(id)initWithSpecies:(NSUInteger)species
{
  if((self = [self init]))
  {
    self.species = species;
  }
  return self;
}

-(void)eat:(DDFoodCell *)food
{
  if(self.currentLife + food.food > self.startingLife)
  {
    self.currentLife = self.startingLife;
  }
  else
  {
    self.currentLife += food.food;
  }
}

-(void)fight:(DDReactiveLifeCell *)cell
{
  // The cell with highest current life deals some damage to the other
  if([self isDead] || [cell isDead])
  {
    DDLogVerbose(@"One of the cells is dead. No fight!");
    return;
  }
  // How to choose who attacks ?
  if(rand() % self.currentLife > rand() % cell.currentLife)
  {
    cell.currentLife -= rand() % self.currentLife;
  }
  else
  {
    self.currentLife -= rand() % cell.currentLife;
  }
}

-(BOOL)shouldMove
{
  // The lower the life the more willingness to move
//  return self.currentLife ? rand() % self.startingLife > self.currentLife : NO;
  return YES;
}

-(void)didMove
{
  self.orientation = (CellOrientation)(rand() % kNumberOfOrientations);
}

-(void)update
{
  self.currentLife --;
  self.age ++;
  self.timeSinceLastReproduction ++;
}

-(BOOL)isDead
{
  return (self.currentLife <= 0);
}

-(BOOL)canReproduceWith:(DDReactiveLifeCell *)otherCell
{
  return self.timeSinceLastReproduction >= kMinTimeSinceLastReproduction && otherCell.timeSinceLastReproduction >= kMinTimeSinceLastReproduction && self.age >= kMinAgeForReproduction && otherCell.age >= kMinAgeForReproduction;
}

-(NSMutableArray *)reproduceWith:(DDReactiveLifeCell *)otherCell freeSpace:(NSUInteger)freeSpace
{
  // Probability of using everything is proportional to both having a lot of life
  double spawnProbability = ((double)self.currentLife / self.startingLife) * ((double)otherCell.currentLife / otherCell.startingLife);
  NSMutableArray *spawnedCells = [NSMutableArray array];
  for(int i = 0; i < freeSpace; i ++)
  {
    if((double)rand() / RAND_MAX <= spawnProbability)
    {
      [spawnedCells addObject:[[DDReactiveLifeCell alloc] init]];
    }
  }
  self.timeSinceLastReproduction = 0;
  otherCell.timeSinceLastReproduction = 0;
  return spawnedCells;
}

@end
