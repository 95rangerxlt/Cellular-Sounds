//
//  DDReactiveGameOfLife.h
//  Cellular-Sounds
//
//  Created by Vasco Orey on 7/21/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "DDAbstractGameOfLife.h"

@interface DDReactiveGameOfLife : DDAbstractGameOfLife
@property (nonatomic) double cellSpawnProbability;
@property (nonatomic) double foodSpawnProbability;
-(id)initWithRows:(NSUInteger)rows cols:(NSUInteger)cols seed:(NSUInteger)seed;
@end
