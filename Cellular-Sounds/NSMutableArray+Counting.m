//
//  NSMutableArray+Counting.m
//  Cellular-Sounds
//
//  Created by Vasco Orey on 7/21/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "NSMutableArray+Counting.h"

@implementation NSMutableArray (Counting)
+(NSMutableArray *)numbersUpToAndIncluding:(NSUInteger)value
{
  NSMutableArray *array = [NSMutableArray array];
  for(int i = 0; i < value; i ++)
  {
    array[i] = @(i);
  }
  return array;
}
@end
