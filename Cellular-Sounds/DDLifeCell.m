//
//  DDLifeCell.m
//  Cellular-Sounds
//
//  Created by Vasco Orey on 7/21/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "DDLifeCell.h"

#define kNumberOfSpecies 4
#define kMaxLifeValue 100
#define kNumberOfOrientations 4
#define kMinAgeForReproduction 8
#define kMinTimeSinceLastReproduction 5

@interface DDLifeCell ()
@property (nonatomic, readwrite) NSUInteger species;
@property (nonatomic) NSInteger age;
@property (nonatomic) NSInteger timeSinceLastReproduction;
@end

@implementation DDLifeCell
-(id)init
{
  if((self = [super init]))
  {
    self.species = rand() % kNumberOfSpecies;
    self.startingLife = rand() % kMaxLifeValue;
    self.currentLife = self.startingLife;
    self.orientation = (CellOrientation)(rand() % kNumberOfOrientations);
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

-(void)fight:(DDLifeCell *)cell
{
  // The cell with highest current life deals some damage to the other
  if(self.currentLife >= cell.currentLife)
  {
    cell.currentLife -= rand() % self.currentLife;
  }
  else
  {
    self.currentLife -= rand() % self.currentLife;
  }
}

-(BOOL)shouldMove
{
  // The lower the life the more willingness to move
  return self.currentLife ? rand() % self.startingLife > self.currentLife : NO;
}

-(void)didMove
{
  self.orientation = (CellOrientation)(rand() % kNumberOfOrientations);
}

-(void)update
{
  self.currentLife --;
  self.age ++;
}

-(BOOL)isDead
{
  return !self.currentLife;
}

-(BOOL)canReproduceWith:(DDLifeCell *)otherCell
{
  return self.timeSinceLastReproduction >= kMinTimeSinceLastReproduction && otherCell.timeSinceLastReproduction >= kMinTimeSinceLastReproduction && self.age >= kMinAgeForReproduction && otherCell.age >= kMinAgeForReproduction;
}

-(NSMutableArray *)reproduceWith:(DDLifeCell *)otherCell freeSpace:(NSUInteger)freeSpace
{
  // Probability of using everything is proportional to both having a lot of life
  double spawnProbability = ((double)self.currentLife / self.startingLife) * ((double)otherCell.currentLife / otherCell.startingLife);
  NSMutableArray *spawnedCells = [NSMutableArray array];
  for(int i = 0; i < freeSpace; i ++)
  {
    if((double)rand() / RAND_MAX <= spawnProbability)
    {
      [spawnedCells addObject:[[DDLifeCell alloc] init]];
    }
  }
  return spawnedCells;
}

@end
