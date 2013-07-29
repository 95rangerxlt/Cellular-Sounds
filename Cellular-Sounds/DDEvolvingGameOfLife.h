//
//  DDEvolvingGameOfLife.h
//  Cellular-Sounds
//
//  Created by Vasco Orey on 7/29/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "DDAbstractGameOfLife.h"

@interface DDEvolvingGameOfLife : DDAbstractGameOfLife
@property (nonatomic) double cellSpawnProbability;
@property (nonatomic) double foodSpawnProbability;
-(id)initWithRows:(NSUInteger)rows cols:(NSUInteger)cols seed:(NSUInteger)seed;
@end
