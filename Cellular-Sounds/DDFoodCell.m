//
//  DDFoodCell.m
//  Cellular-Sounds
//
//  Created by Vasco Orey on 7/21/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "DDFoodCell.h"

#define kMaxFoodValue 24

@interface DDFoodCell ()
@property (nonatomic, readwrite) NSUInteger food;
@end

@implementation DDFoodCell
-(id)init
{
  if((self = [super init]))
  {
    self.food = rand() % kMaxFoodValue;
  }
  return self;
}
@end
