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

#define kDodgerBlueColor [UIColor colorWithRed:0 green:0.478431f blue:1.0f alpha:1.0f]
#define kDarkOrangeColor [UIColor colorWithRed:1.0f green:0.478431f blue:0 alpha:1.0f]
#define kDarkViolet [UIColor colorWithRed:0.478431f green:0 blue:1.0f alpha:1.0f]
#define kDeepPinkColor [UIColor colorWithRed:1.0f green:0 blue:0.478431f alpha:1.0f]

@interface DDMainViewController () <DDGridViewDelegate, DDGameOfLifeDelegate>
@property (weak, nonatomic) IBOutlet DDGridView *gridView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *gameSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *colorSegmentedControl;
@property (nonatomic, strong) DDConwaysGameOfLife *conway;
@end

@implementation DDMainViewController
{
  NSArray *_colors;
}

#pragma mark - Properties

-(DDConwaysGameOfLife *)conway
{
  if(!_conway) {
    _conway = [[DDConwaysGameOfLife alloc] initWithRows:16 cols:21];
    _conway.delegate = self;
  }
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
  self.colorSegmentedControl.selectedSegmentIndex = 0;
  NSArray *subviews = self.colorSegmentedControl.subviews;
  [subviews[3] setTintColor:kDodgerBlueColor];
  [subviews[2] setTintColor:kDarkOrangeColor];
  [subviews[1] setTintColor:kDarkViolet];
  [subviews[0] setTintColor:kDeepPinkColor];
  _colors = @[kDodgerBlueColor, kDarkOrangeColor, kDarkViolet, kDeepPinkColor];
}

-(void)viewWillAppear:(BOOL)animated
{
  [super viewWillAppear:animated];
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
  if(cell)
  {
    DDLogVerbose(@"%d", self.colorSegmentedControl.selectedSegmentIndex);
    return _colors[cell - 1];
  }
  return [UIColor clearColor];
}

-(void)gridView:(DDGridView *)gridView didDetectTouchAtRow:(NSUInteger)row col:(NSUInteger)col justStarted:(BOOL)justStarted
{
  [self.conway flipCellAtRow:row col:col species:(self.colorSegmentedControl.selectedSegmentIndex + 1) started:justStarted];
}

#pragma mark - DDGameOfLifeDelegate

-(void)gameOfLife:(DDAbstractGameOfLife *)gameOfLife didActivateCellAtRow:(NSUInteger)row col:(NSUInteger)col species:(NSUInteger)species
{
  self.gridView.grid = self.conway.state;
}

@end
