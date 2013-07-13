//
//  DDMainViewController.m
//  Cellular-Sounds
//
//  Created by Vasco Orey on 7/13/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "DDMainViewController.h"
#import "DDGridView.h"

@interface DDMainViewController () <DDGridViewDelegate>
@property (weak, nonatomic) IBOutlet DDGridView *gridView;
@end

@implementation DDMainViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    // Custom initialization
  }
  return self;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view.
  self.gridView.delegate = self;
  NSArray *row1 = @[@(0),@(1),@(2),@(1),@(0)];
  NSArray *row2 = @[@(1),@(0),@(1),@(2),@(1)];
  NSArray *row3 = @[@(2),@(1),@(0),@(1),@(2)];
  self.gridView.grid = @[row1, row2, row3];
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

#pragma mark - DDGridViewDelegate

-(UIColor *)gridView:(DDGridView *)gridView colorForCellContents:(id)cellContents
{
  NSInteger cell = [cellContents integerValue];
  return !cell ? [UIColor greenColor] : (cell == 1 ? [UIColor redColor] : [UIColor blueColor]);
}

-(void)gridView:(DDGridView *)gridView didDetectTouchAtRow:(NSUInteger)row col:(NSUInteger)col justStarted:(BOOL)justStarted
{
  DDLogVerbose(@"Cell clicked: %d,%d", row, col);
}

@end
