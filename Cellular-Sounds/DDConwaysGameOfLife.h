//
//  DDConwaysGameOfLife.h
//  Cellular-Sounds
//
//  Created by Vasco Orey on 7/13/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "DDAbstractGameOfLife.h"

typedef enum
{
  Off = 0,
  On
} ConwaysGameOfLifeStatus;

@interface DDConwaysGameOfLife : DDAbstractGameOfLife
// Setting the status to off will make the grid stay the same over time.
// Setting it to on will make the Conway's Game Of Life rules apply.
@property (nonatomic) ConwaysGameOfLifeStatus status;
@end
