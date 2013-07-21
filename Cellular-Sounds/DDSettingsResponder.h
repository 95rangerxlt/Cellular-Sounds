//
//  DDSettingsResponder.h
//  Cellular-Sounds
//
//  Created by Vasco Orey on 7/21/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef enum {
  ContinuousNumber,
  DiscreteOnOff,
  DiscreteChoices
} DDValueType;

@protocol DDSettingsResponder
// All keys for which we can set values
-(NSArray *)allKeys;
// Can we set this value for the given key ?
-(BOOL)canSetValue:(id)value forKey:(NSString *)key;
// Set the value.
-(void)setValue:(id)value forKey:(NSString *)key;
// What is the type of accepted value for this key ?
-(DDValueType)valueTypeForKey:(NSString *)key;
// If the values are discrete, what are they ?
-(NSArray *)acceptedValuesForDiscreteKey:(NSString *)key;
// If they are continuous, what is the lower bound ?
-(double)lowerBoundForKey:(NSString *)key;
// And what is the higher bound ?
-(double)higherBoundForKey:(NSString *)key;
@end
