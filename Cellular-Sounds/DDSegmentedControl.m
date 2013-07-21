//
//  DDSegmentedControl.m
//  Cellular-Sounds
//
//  Created by Vasco Orey on 7/14/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "DDSegmentedControl.h"

@implementation DDSegmentedControl

// Override to capture taps on currently selected index
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
  NSInteger current = self.selectedSegmentIndex;
  self.selectedSegmentIndex = UISegmentedControlNoSegment;
  [super touchesEnded:touches withEvent:event];
  if(self.selectedSegmentIndex == current)
  {
    [self sendActionsForControlEvents:UIControlEventTouchUpInside];
  }
}

@end
