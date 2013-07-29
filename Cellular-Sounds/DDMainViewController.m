//
//  DDMainViewController.m
//  Cellular-Sounds
//
//  Created by Vasco Orey on 7/13/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

@import AudioToolbox;
@import AVFoundation;
@import OpenAL;

#import "DDMainViewController.h"
#import "DDGridView.h"
#import "DDConwaysGameOfLife.h"
#import "AudioManager.h"
#import "AQSound.h"
#import "BSequencePlayer.h"
#import "DDSegmentedControl.h"
#import "DDSettingsViewController.h"
#import "DDSettingsResponder.h"
#import "DDReactiveGameOfLife.h"
#import "DDCell.h"
#import "DDReactiveLifeCell.h"
#import "DDFoodCell.h"

#define kDodgerBlueColor [UIColor colorWithRed:0 green:0.478431f blue:1.0f alpha:1.0f]
#define kDarkOrangeColor [UIColor colorWithRed:1.0f green:0.478431f blue:0 alpha:1.0f]
#define kDarkViolet [UIColor colorWithRed:0.478431f green:0 blue:1.0f alpha:1.0f]
#define kDeepPinkColor [UIColor colorWithRed:1.0f green:0 blue:0.478431f alpha:1.0f]

@interface DDMainViewController () <DDGridViewDelegate, DDGameOfLifeDelegate>
@property (weak, nonatomic) IBOutlet UIButton *playPauseButton;
@property (weak, nonatomic) IBOutlet UIButton *resetButton;
@property (weak, nonatomic) IBOutlet DDGridView *gridView;
@property (weak, nonatomic) IBOutlet DDSegmentedControl *gameSegmentedControl;
@property (weak, nonatomic) IBOutlet DDSegmentedControl *colorSegmentedControl;
@property (weak, nonatomic) IBOutlet UISwitch *playingSwitch;
@property (nonatomic, strong) NSMutableArray *games;
@property (nonatomic) NSUInteger currentGame;
@property (nonatomic) NSUInteger currentColor;
@property (nonatomic, readonly) DDAbstractGameOfLife *currentGameOfLife;
@property (nonatomic) NSUInteger numRows;
@property (nonatomic) NSUInteger numCols;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) UIPopoverController *popover;
//
@property (nonatomic, strong) NSMutableArray *scales;
@property (nonatomic, strong) NSMutableArray *roots;
@property (atomic, strong) NSMutableArray *sequence;
@property (nonatomic, strong) NSMutableArray *completeSong;
@property (nonatomic, strong) AudioManager *audioManager;
@property (nonatomic, strong) AQSound *synthManager;
@property (nonatomic, strong) BSequencePlayer *sequencePlayer;
@property (nonatomic, strong) BMidiClock *midiClock;
@property (nonatomic) NSUInteger metronomeTicks;
@property (nonatomic) CFTimeInterval timeOfLastBeat;
@property (nonatomic) CFTimeInterval timeForNextUpdate;
@property (nonatomic) CFTimeInterval lineDeltaTime;
@property (nonatomic) CFTimeInterval timeLastUpdated;
@property (nonatomic) CFTimeInterval startTimeForNextBar;
@property (nonatomic) CFTimeInterval lastGridUpdateTime;
//
-(void)setup;
-(void)setupAudio;
-(void)handleNoteEvent:(BMidiNote *)event;
-(void)handleTempoEvent:(BTempoEvent *)event;
-(void)audioLoop;
-(void)updateSequence:(NSUInteger)timeInPulses;
-(void)updatePool;
-(NSUInteger)convertToMidiNoteNumber:(NSUInteger)note game:(NSUInteger)game voice:(NSInteger)voice;
@end

@implementation DDMainViewController

#pragma mark - Properties

-(NSMutableArray *)games
{
  if(!_games)
  {
    _games = [NSMutableArray arrayWithCapacity:4];
    DDReactiveGameOfLife *game = [[DDReactiveGameOfLife alloc] initWithRows:self.numRows cols:self.numCols seed:29];
    game.on = NO;
    game.delegate = self;
    game.cellSpawnProbability = 0.04f;
    game.foodSpawnProbability = 0.04f;
    _games[0] = game;
    DDReactiveGameOfLife *otherGame = [[DDReactiveGameOfLife alloc] initWithRows:self.numRows cols:self.numCols seed:58];
    otherGame.on = NO;
    otherGame.delegate = self;
    otherGame.cellSpawnProbability = 0.04f;
    otherGame.foodSpawnProbability = 0.04f;
    _games[1] = otherGame;
    for(int i = 2; i < 4; i ++)
    {
      _games[i] = [[DDConwaysGameOfLife alloc] initWithRows:self.numRows cols:self.numCols];
      ((DDConwaysGameOfLife *)_games[i]).delegate = self;
    }
  }
  return _games;
}

-(DDAbstractGameOfLife *)currentGameOfLife
{
  return self.games[self.currentGame];
}

#pragma mark - IBActions

- (IBAction)gameSelectionSegmentedControlPressed:(DDSegmentedControl *)sender
{
  DDLogVerbose(@"Value changed: %d to %d", self.currentGame, sender.selectedSegmentIndex);
  if(self.currentGame != sender.selectedSegmentIndex)
  {
    DDLogVerbose(@"Changing game to: %d", sender.selectedSegmentIndex);
    self.currentGame = sender.selectedSegmentIndex;
    self.gridView.grid = self.currentGameOfLife.state;
  }
  else
  {
    [self popoverFromSegmentedControl:sender];
  }
}

- (IBAction)colorSegmentedControlPressed:(DDSegmentedControl *)sender
{
  if(self.currentColor != sender.selectedSegmentIndex)
  {
    self.currentColor = sender.selectedSegmentIndex;
  }
  else
  {
    [self popoverFromSegmentedControl:sender];
  }
}

-(void)popoverFromSegmentedControl:(DDSegmentedControl *)sender
{
  DDSettingsViewController *colorVC = [[DDSettingsViewController alloc] init];
  UIPopoverController *popover = [[UIPopoverController alloc] initWithContentViewController:colorVC];
  NSInteger selected = sender.selectedSegmentIndex;
  CGFloat x = (sender.frame.origin.x + (sender.frame.size.width / 4) * selected);
  CGRect selectedRect = CGRectMake(x, sender.frame.origin.y, (sender.frame.size.width / 4), sender.frame.size.height);
  [popover presentPopoverFromRect:selectedRect inView:self.view permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
  self.popover = popover;
}

- (IBAction)resetPressed
{
  [self.currentGameOfLife clearGrid];
}

- (IBAction)stopPressed
{
  self.currentGameOfLife.on = !self.currentGameOfLife.on;
}


#pragma mark - Init

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
  self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
  if (self) {
    [self setup];
  }
  return self;
}

-(void)awakeFromNib
{
  [self setup];
}

-(void)setup
{
  self.numCols = 21;
  self.numRows = 16;
}

- (void)viewDidLoad
{
  [super viewDidLoad];
	// Do any additional setup after loading the view.
  // Define actions for the segmented controls
  self.gridView.delegate = self;
  self.gridView.grid = self.currentGameOfLife.state;
  self.colorSegmentedControl.selectedSegmentIndex = 0;
  NSArray *subviews = self.colorSegmentedControl.subviews;
  [subviews[3] setTintColor:kDodgerBlueColor];
  [subviews[2] setTintColor:kDarkOrangeColor];
  [subviews[1] setTintColor:kDarkViolet];
  [subviews[0] setTintColor:kDeepPinkColor];
  self.colors = @[kDodgerBlueColor, kDarkOrangeColor, kDarkViolet, kDeepPinkColor];
  self.roots = [@[@(32), @(48), @(48), @(48), @(72), @(48), @(48), @(48)] mutableCopy];
  self.scales = [@[@(0), @(0), @(0), @(0)] mutableCopy];
  [self setupAudio];
}

-(void)viewWillDisappear:(BOOL)animated
{
  [super viewWillDisappear:animated];
  self.gridView.delegate = nil;
}

- (void)didReceiveMemoryWarning
{
  [super didReceiveMemoryWarning];
  // Dispose of any resources that can be recreated.
}

-(void)willRotateToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration
{
  [super willRotateToInterfaceOrientation:toInterfaceOrientation duration:duration];
}

-(void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation
{
  [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
  [self.gridView setNeedsLayout];
}

#pragma mark - DDGridViewDelegate

-(UIColor *)gridView:(DDGridView *)gridView colorForCellContents:(id)cellContents
{
  if([cellContents isKindOfClass:[NSNumber class]])
  {
    NSInteger cell = [cellContents integerValue];
    if(cell)
    {
      return self.colors[cell - 1];
    }
  }
  else if([cellContents isKindOfClass:[DDReactiveLifeCell class]])
  {
    DDReactiveLifeCell *cell = (DDReactiveLifeCell *)cellContents;
    UIColor *cellColor = self.colors[cell.species];
    return [cellColor colorWithAlphaComponent:((float)cell.currentLife / cell.startingLife)];
  }
  return [UIColor lightGrayColor];
}

-(void)gridView:(DDGridView *)gridView didDetectTouchAtRow:(NSUInteger)row col:(NSUInteger)col justStarted:(BOOL)justStarted
{
  NSUInteger species = [self.currentGameOfLife isKindOfClass:[DDConwaysGameOfLife class]] ? (self.colorSegmentedControl.selectedSegmentIndex + 1) : self.colorSegmentedControl.selectedSegmentIndex;
  id cell = [self.currentGameOfLife cellForRow:row col:col];
  DDLogVerbose(@"%@", cell);
  [self.currentGameOfLife flipCellAtRow:row col:col species:species started:justStarted];
}

#pragma mark - DDGameOfLifeDelegate

-(void)gameOfLife:(DDAbstractGameOfLife *)gameOfLife didActivateCellAtRow:(NSUInteger)row col:(NSUInteger)col species:(NSUInteger)species
{
  self.gridView.grid = self.currentGameOfLife.state;
}

#pragma mark - Audio

-(void)setupAudio
{
  self.midiClock = [[BMidiClock alloc] init];
  self.midiClock.tickResolution = 1;
  
  self.audioManager = [[AudioManager alloc] init];
  
  // First grid
  [self.audioManager addVoice:@"c0" withSound:@"doublebass pibox v2" withPatch:0 withVolume:5];
  [self.audioManager addVoice:@"c1" withSound:@"campbells_grand_xylophone" withPatch:0 withVolume:1];
  [self.audioManager addVoice:@"c2" withSound:@"moog collection 2" withPatch:0 withVolume:1];
  [self.audioManager addVoice:@"c3" withSound:@"xylophone esmart" withPatch:0 withVolume:1];
  // Second grid
  [self.audioManager addVoice:@"c4" withSound:@"music box" withPatch:1 withVolume:1];
  [self.audioManager addVoice:@"c5" withSound:@"bdlutes_musicbox" withPatch:0 withVolume:1];
  [self.audioManager addVoice:@"c6" withSound:@"campbells_grand_xylophone" withPatch:0 withVolume:1];
  [self.audioManager addVoice:@"c7" withSound:@"xylophone esmart" withPatch:0 withVolume:1];
  
  [self.audioManager startAudioGraph];
  
  self.synthManager = [[AQSound alloc] init];
  [self.synthManager newAQ];
  [self.synthManager start];
  
  self.lineDeltaTime = (self.midiClock.PPQN / 2);
  
  @synchronized(self.sequence)
  {
    self.sequence = [NSMutableArray array];
  }
  self.completeSong = [NSMutableArray array];
  
  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
    [self audioLoop];
  });
}

// What to do when a new note is activated - be very careful!! We're
// multi-threading
-(void) handleNoteEvent:(BMidiNote *)note
{
  // Play the note in the audio manager
  [self.audioManager playNote:note];
//  [self.synthManager midiNoteOn:note.note atVoiceIndex:note.channel velocity:note.velocity];
}

// Handle any tempo events which occur
-(void) handleTempoEvent:(BTempoEvent *)tempoEvent
{
  // Set the midi clock PPNQ
  if(tempoEvent.type == BPPNQ) {
    self.midiClock.PPQN = tempoEvent.PPNQ;
    NSLog(@"Set PPQN: %i", tempoEvent.PPNQ);
  }
  // Set the midi clock BPM
  if (tempoEvent.type == BTempo) {
    self.midiClock.BPM = tempoEvent.BPM;
    NSLog(@"Set BPM: %f", tempoEvent.BPM);
  }
  
  // Set the metronome rate
  if (tempoEvent.type == BTimeSignature) {
    // Set metronome rate. The metronome figure is measured as a fraction
    // over 24. So, a value of 24 means once per quarter note. 12 means
    // once every 1/8 note etc...
    float metronomeRate = (float) tempoEvent.ticksPerQtr / 24.0;
    // Work out how many pulses this represents
    self.midiClock.metronomeFreq = (int) roundf(metronomeRate * self.midiClock.PPQN);
    
  }
}


-(void)audioLoop
{
  while(true)
  {
    // Update the midi clock every loop
    [self.midiClock update];
    
    // Only check for events if the required number of ticks
    // has elapsed - determined by _midiClock.tickResolution
    NSInteger discreteTime = [self.midiClock getDiscreteTime];
    if([self.midiClock requiredTicksElapsed]) {
      //[self.sequencePlayer update:[self.midiClock getDiscreteTime]];
      [self updateSequence:discreteTime];
      [self.audioManager update:discreteTime];
      
      // We need to check if the metronome has ticked from within the
      // audio loop because it might be missed by the slower render loop
      if([self.midiClock isMetronomeTick]) {
        dispatch_async(dispatch_get_main_queue(), ^{
          if(!(self.metronomeTicks % 4))
          {
            //NSLog(@"Setting the new grid (%d ticks)", self.metronomeTicks);
            self.gridView.grid = self.currentGameOfLife.state;
          }
          if(!self.timeOfLastBeat)
          {
            self.timeOfLastBeat = [self.midiClock getCurrentTimeMillis] / 1000.0;
          }
          else
          {
            CFTimeInterval currentBeat = [self.midiClock getCurrentTimeMillis] / 1000.0;
            
            if(currentBeat - self.timeOfLastBeat > (self.midiClock.BPM / 60.0))
            {
              DDLogWarn(@"*** MIDI Clock skew detected! ***");
              DDLogWarn(@"*** Last Beat: %g ms, Current Beat: %g ms ***", self.timeOfLastBeat, currentBeat);
              DDLogWarn(@"*** Beat Durations: %g ***", (self.midiClock.BPM / 60.0));
            }
            self.timeOfLastBeat = currentBeat;
          }
          self.metronomeTicks ++;
        });
      }
    }
    //Always perform the update on the last eigth note
    if((self.timeForNextUpdate - self.lineDeltaTime) < discreteTime)
    {
      //Update the pool
      dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self updatePool];
      });
      self.timeLastUpdated = discreteTime;
      //Each row is a 8th note
      self.timeForNextUpdate += self.lineDeltaTime * self.numRows;
    }

  }
}

// Play the next notes in the sequence
-(void) updateSequence: (NSUInteger) timeInPulses
{
  // Other pointers we setup to improve efficiency
  BMidiEvent * midiEvent;
  NSMutableArray *toDelete = [[NSMutableArray alloc] init];
  NSMutableArray *sequence;
  @synchronized(self.sequence)
  {
    sequence = [self.sequence mutableCopy];
  }
  NSUInteger count = [sequence count];
  // Loop over sequence and work out if the note should be played
  for(int j=0; j<count; j++) {
    
    // Get a pointer to the current event
    midiEvent = sequence[j];
    
    // If the time is greater than the current time then skip the note
    // and add one to the relaxation counter
    if([midiEvent getStartTime] > timeInPulses) {
      continue;
    }
    
    // Add the note for deleting
    [toDelete addObject:midiEvent];
    [self.completeSong addObject:midiEvent];
    
    if(midiEvent.eventType == Note) {
      [self handleNoteEvent:(BMidiNote *) midiEvent];
    }
    else if(midiEvent.eventType == Tempo ) {
      [self handleTempoEvent:(BTempoEvent *) midiEvent];
    }
  }
  
  // Clean up by deleting used notes
  [sequence removeObjectsInArray:toDelete];
  @synchronized(self.sequence)
  {
    self.sequence = sequence;
  }
}

-(void)updatePool
{
  //NSLog(@"%g: working!", CACurrentMediaTime());
  [self.games makeObjectsPerformSelector:@selector(performStep)];
  NSMutableArray *grids = [NSMutableArray array];
  for(DDConwaysGameOfLife *game in self.games)
  {
    [grids addObject:game.state];
  }
  CFTimeInterval startTime = self.startTimeForNextBar;
  if(!startTime)
  {
    startTime = self.timeLastUpdated;
    self.startTimeForNextBar = startTime;
  }
  NSInteger channel = 0;
  NSMutableDictionary *notes = [[NSMutableDictionary alloc] init];
  NSMutableArray *finalNotes = [[NSMutableArray alloc] init];
  for(NSInteger grid = 0; grid < 4; grid ++)
  {
    for(int row = 0; row < self.numRows; row ++)
    {
      for(int col = 0; col < self.numCols; col ++)
      {
        NSNumber *currentCol = @(col);
        NSInteger dt = row * self.lineDeltaTime;
        if([[notes allKeys] containsObject:currentCol])
        {
          id cell = grids[grid][row][col];
          NSInteger cellValue = 0;
          if([cell isKindOfClass:[NSNumber class]])
          {
            cellValue = [cell integerValue];
          }
          else if([cell isKindOfClass:[DDReactiveLifeCell class]])
          {
            cellValue = ((DDReactiveLifeCell *)cell).species + 1;
          }
          if(cellValue)
          {
            //Update the note in the dictionary
            BMidiNote *note = notes[currentCol];
            [note setDuration:([note getDuration] + self.lineDeltaTime)];
          }
          else
          {
            //Remove the note from the dictionary and insert it into finalNotes
            BMidiNote *noteToAdd = notes[currentCol];
            //                        BMidiNote *noteOff = [[BMidiNote alloc] init];
            //                        noteOff.note = noteToAdd.note;
            //                        noteOff.channel = 0;
            //                        noteOff.velocity = 0;
            //                        [noteOff setStartTime:[noteToAdd getStartTime] + [noteToAdd getDuration]];
            //                        [finalNotes addObject:noteOff];
            [finalNotes addObject:noteToAdd];
            [notes removeObjectForKey:currentCol];
          }
        }
        else
        {
          id cell = grids[grid][row][col];
          UInt8 velocity = 127;
          if([cell isKindOfClass:[DDReactiveLifeCell class]])
          {
            DDReactiveLifeCell *lifeCell = (DDReactiveLifeCell *)cell;
            channel = lifeCell.species + 1;
            velocity = (UInt8)(velocity * (float)lifeCell.currentLife / lifeCell.startingLife);
            if(!velocity)
            {
              DDLogVerbose(@"Not playing (%d,%d): %d / %d = 0?", row, col, lifeCell.currentLife, lifeCell.startingLife);
            }
          }
          else if([cell isKindOfClass:[NSNumber class]])
          {
            channel = [cell integerValue];
          }
          else
          {
            channel = 0;
          }
          if(channel)
          {
            channel += grid * 4;
            //Create a new note and insert it into the dictionary
            BMidiNote *note = [[BMidiNote alloc] init];
            note.channel = (channel - 1);
            note.velocity = velocity;
            note.note = [self convertToMidiNoteNumber:col game:grid voice:(channel - 1)];
            [note setStartTime:(startTime + dt)];
            [note setDuration:self.lineDeltaTime];
            notes[currentCol] = note;
          }
        }
      }
    }
  }
  [finalNotes addObjectsFromArray:[notes allValues]];
  [self.completeSong addObjectsFromArray:[notes allValues]];
  NSLog(@"Song: %d notes", [self.completeSong count]);
  NSInteger deltaTime = self.numRows * self.lineDeltaTime;
  self.startTimeForNextBar += deltaTime;
  @synchronized(self.sequence)
  {
    self.sequence = finalNotes;
  }
}

#warning TODO: multiple scales
-(NSUInteger)convertToMidiNoteNumber:(NSUInteger)note game:(NSUInteger)game voice:(NSInteger)voice
{
  NSInteger currentRoot = [self.roots[voice] integerValue];
  NSInteger currentScale = [self.scales[game] integerValue];
  static NSArray *major = nil;
  if(!major) major = @[@(0), @(2), @(4), @(5), @(7), @(9), @(11)];
  // Major 0 -> 2 -> 4 -> 5 -> 7 -> 9 -> 11
  // Minor 0 -> 2 -> 3 -> 5 -> 7 -> 8 -> 11
  NSInteger octaves = 0;
  while(note > 7)
  {
    octaves ++;
    note -= 7;
  }
  return currentRoot + (octaves * 12) + [major[note % 7] integerValue];
}

@end
