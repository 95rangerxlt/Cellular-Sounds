//
//  DDMainViewController.m
//  Cellular-Sounds
//
//  Created by Vasco Orey on 7/13/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import "DDMainViewController.h"
#import "DDGridView.h"
#import "DDConwaysGameOfLife.h"

@interface DDMainViewController () <DDGridViewDelegate>
@property (weak, nonatomic) IBOutlet DDGridView *gridView;
@property (nonatomic, strong) DDConwaysGameOfLife *conway;
@end

@implementation DDMainViewController

#pragma mark - Properties

-(DDConwaysGameOfLife *)conway
{
  if(!_conway) _conway = [[DDConwaysGameOfLife alloc] initWithRows:16 cols:21];
  return _conway;
}

#pragma mark - Init

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
  self.gridView.grid = self.conway.state;
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
