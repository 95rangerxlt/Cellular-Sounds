//
//  DDSettingsViewController.h
//  Cellular-Sounds
//
//  Created by Vasco Orey on 7/14/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DDSettingsResponder.h"

typedef enum {
  Color,
  Grid
} DDSettingsType;

@interface DDSettingsViewController : UIViewController
@property (nonatomic) DDSettingsType settingsType;
@property (nonatomic, weak) id <DDSettingsResponder> objectToChange;
@end
