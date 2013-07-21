//
//  DDReactiveSettings.h
//  Cellular-Sounds
//
//  Created by Vasco Orey on 7/21/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DDSettingsResponder.h"

@interface DDReactiveSettings : NSObject <DDSettingsResponder>
+(DDReactiveSettings *)settings;
@end
