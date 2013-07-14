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
#import "BSequencePlayer.h"

#define kDodgerBlueColor [UIColor colorWithRed:0 green:0.478431f blue:1.0f alpha:1.0f]
#define kDarkOrangeColor [UIColor colorWithRed:1.0f green:0.478431f blue:0 alpha:1.0f]
#define kDarkViolet [UIColor colorWithRed:0.478431f green:0 blue:1.0f alpha:1.0f]
#define kDeepPinkColor [UIColor colorWithRed:1.0f green:0 blue:0.478431f alpha:1.0f]

@interface DDMainViewController () <DDGridViewDelegate, DDGameOfLifeDelegate>
@property (weak, nonatomic) IBOutlet DDGridView *gridView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *gameSegmentedControl;
@property (weak, nonatomic) IBOutlet UISegmentedControl *colorSegmentedControl;
@property (weak, nonatomic) IBOutlet UISwitch *playingSwitch;
@property (nonatomic, strong) DDConwaysGameOfLife *conway;
@property (nonatomic) NSUInteger numRows;
@property (nonatomic) NSUInteger numCols;
@property (nonatomic, strong) NSArray *colors;
//
@property (nonatomic, strong) NSMutableArray *scales;
@property (nonatomic, strong) NSMutableArray *roots;
@property (atomic, strong) NSMutableArray *sequence;
@property (nonatomic, strong) NSMutableArray *completeSong;
@property (nonatomic, strong) AudioManager *audioManager;
@property (nonatomic, strong) BSequencePlayer *sequencePlayer;
@property (nonatomic, strong) BMidiClock *midiClock;
@property (nonatomic) NSUInteger metronomeTicks;
@property (nonatomic) CFTimeInterval timeOfLastBeat;
@property (nonatomic) CFTimeInterval timeForNextUpdate;
@property (nonatomic) CFTimeInterval lineDeltaTime;
@property (nonatomic) CFTimeInterval timeLastUpdated;
@property (nonatomic) CFTimeInterval startTimeForNextBar;
//
-(void)setup;
-(void)setupAudio;
-(void)handleNoteEvent:(BMidiNote *)event;
-(void)handleTempoEvent:(BTempoEvent *)event;
-(void)audioLoop;
-(void)updateSequence:(NSUInteger)timeInPulses;
-(void)updatePool;
-(NSUInteger)convertToMidiNoteNumber:(NSUInteger)note game:(NSUInteger)game;
@end

@implementation DDMainViewController

#pragma mark - Properties

-(DDConwaysGameOfLife *)conway
{
  if(!_conway) {
    _conway = [[DDConwaysGameOfLife alloc] initWithRows:self.numRows cols:self.numCols];
    _conway.delegate = self;
  }
  return _conway;
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
  self.gridView.delegate = self;
  self.gridView.grid = self.conway.state;
  self.colorSegmentedControl.selectedSegmentIndex = 0;
  NSArray *subviews = self.colorSegmentedControl.subviews;
  [subviews[3] setTintColor:kDodgerBlueColor];
  [subviews[2] setTintColor:kDarkOrangeColor];
  [subviews[1] setTintColor:kDarkViolet];
  [subviews[0] setTintColor:kDeepPinkColor];
  self.colors = @[kDodgerBlueColor, kDarkOrangeColor, kDarkViolet, kDeepPinkColor];
  self.roots = [@[@(5)] mutableCopy];
  self.scales = [@[@(0)] mutableCopy];
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

#pragma mark - DDGridViewDelegate

-(UIColor *)gridView:(DDGridView *)gridView colorForCellContents:(id)cellContents
{
  NSInteger cell = [cellContents integerValue];
  if(cell)
  {
    return self.colors[cell - 1];
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

#pragma mark - Audio

-(void)setupAudio
{
  self.midiClock = [[BMidiClock alloc] init];
  self.midiClock.tickResolution = 1;
  
  self.audioManager = [[AudioManager alloc] init];
  [self.audioManager addVoice:@"c0" withSound:@"alex glockenspiel" withPatch:0 withVolume:1];
  [self.audioManager addVoice:@"c1" withSound:@"bdlutes_musicbox" withPatch:0 withVolume:1];
  [self.audioManager addVoice:@"c2" withSound:@"xylophone esmart" withPatch:0 withVolume:1];
  [self.audioManager addVoice:@"c3" withSound:@"music box" withPatch:1 withVolume:1];
  [self.audioManager startAudioGraph];
  
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
  //NSLog(@"Note: %d, Channel: %d, Velocity: %d, Start: %d, Duration: %d", note.note, note.channel, note.velocity, [note getStartTime], [note getDuration]);
  //[self.sound triggerMidiNoteAtFirstAvailableVoice:note.note velocity:127];
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
            self.gridView.grid = self.conway.state;
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
//  [self.pools makeObjectsPerformSelector:@selector(performStep)];
//  NSMutableArray *grids = [NSMutableArray arrayWithCapacity:self.numPools];
//  for(PoolOfLife *pool in self.pools)
//  {
//    [grids addObject:pool.state];
//  }
  [self.conway performStep];
  CFTimeInterval startTime = self.startTimeForNextBar;
  if(!startTime)
  {
    startTime = self.timeLastUpdated;
    self.startTimeForNextBar = startTime;
  }
  NSInteger channel = 0;
  NSMutableDictionary *notes = [[NSMutableDictionary alloc] init];
  NSMutableArray *finalNotes = [[NSMutableArray alloc] init];
//  for(NSArray *currentGrid in grids)
//  {
  NSArray *currentGrid = self.conway.state;
  for(int row = 0; row < self.numRows; row ++)
  {
    for(int col = 0; col < self.numCols; col ++)
    {
      NSNumber *currentCol = @(col);
      NSInteger dt = row * self.lineDeltaTime;
      if([[notes allKeys] containsObject:currentCol])
      {
        if([currentGrid[row][col] intValue])
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
        if((channel = [currentGrid[row][col] intValue]))
        {
          //Create a new note and insert it into the dictionary
          BMidiNote *note = [[BMidiNote alloc] init];
          note.channel = (channel - 1);
          note.velocity = 127;
#warning TODO: multiple games
          note.note = [self convertToMidiNoteNumber:col game:0];
          [note setStartTime:(startTime + dt)];
          [note setDuration:self.lineDeltaTime];
          notes[currentCol] = note;
        }
      }
    }
  }
//  }
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
-(NSUInteger)convertToMidiNoteNumber:(NSUInteger)note game:(NSUInteger)game
{
  NSInteger currentRoot = [self.roots[game] integerValue];
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
