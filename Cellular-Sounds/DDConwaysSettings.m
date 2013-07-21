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

// All keys for which we can set values
-(NSArray *)allKeys
{
  return [self.settings allKeys];
}

// Can we set this value for the given key ?
-(BOOL)canSetValue:(id)value forKey:(NSString *)key
{
#warning TODO
  return NO;
}

// Set the value.
-(void)setValue:(id)value forKey:(NSString *)key
{
#warning TODO
  self.settings[key] = value;
}

-(id)valueForKey:(NSString *)key
{
  return self.settings[key];
}

// What is the type of accepted value for this key ?
-(DDValueType)valueTypeForKey:(NSString *)key
{
  return (DDValueType)[self.valueTypes[key] intValue];
}

// If the values are discrete, what are they ?
-(NSArray *)acceptedValuesForDiscreteKey:(NSString *)key
{
  return nil;
}

// If they are continuous, what is the lower bound ?
-(double)lowerBoundForKey:(NSString *)key
{
  return 0.0f;
}

// And what is the higher bound ?
-(double)higherBoundForKey:(NSString *)key
{
  return 0.0f;
}

@end
