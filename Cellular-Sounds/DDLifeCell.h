//
//  DDLifeCell.h
//  Cellular-Sounds
//
//  Created by Vasco Orey on 7/21/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "DDCell.h"
#import "DDFoodCell.h"

typedef enum {
  Up = 0,
  Down,
  Left,
  Right
} CellOrientation;

@interface DDLifeCell : DDCell
@property (nonatomic, readonly) NSUInteger species;
@property (nonatomic) NSInteger currentLife;
@property (nonatomic) NSInteger startingLife;
@property (nonatomic) CellOrientation orientation;
-(id)init;
-(id)initWithSpecies:(NSUInteger)species;
-(void)eat:(DDFoodCell *)food;
-(void)fight:(DDLifeCell *)cell;
-(BOOL)shouldMove;
-(void)didMove;
-(BOOL)isDead;
-(void)update;
-(BOOL)canReproduceWith:(DDLifeCell *)otherCell;
-(NSMutableArray *)reproduceWith:(DDLifeCell *)otherCell freeSpace:(NSUInteger)freeSpace;
@end
