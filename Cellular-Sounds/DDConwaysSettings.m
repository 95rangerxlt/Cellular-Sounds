//
//  DDConwaysSettings.m
//  Cellular-Sounds
//
//  Created by Vasco Orey on 7/21/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "DDConwaysSettings.h"

@interface DDConwaysSettings ()
@property (nonatomic, strong) NSMutableDictionary *settings;
@property (nonatomic, strong) NSMutableDictionary *valueTypes;
@end

@implementation DDConwaysSettings

+(DDConwaysSettings *)settings
{
  static DDConwaysSettings *settings = nil;
  static dispatch_once_t onceToken;
  dispatch_once(&onceToken, ^{
    settings = [[self alloc] init];
  });
  return settings;
}

-(id)init
{
  if((self = [super init]))
  {
    self.settings = [NSMutableDictionary dictionary];
    self.valueTypes = [NSMutableDictionary dictionary];
  }
  return self;
}

@end
