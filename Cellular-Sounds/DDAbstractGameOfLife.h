//
//  DDAbstractGameOfLife.h
//  Cellular-Sounds
//
//  Created by Vasco Orey on 7/13/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <Foundation/Foundation.h>
@class DDAbstractGameOfLife;
@protocol DDGameOfLifeDelegate <NSObject>
// Is sent to the delegate when the state of the cell in question goes from dead to alive.
-(void)gameOfLife:(DDAbstractGameOfLife *)gameOfLife didActivateCellAtRow:(NSUInteger)row col:(NSUInteger)col species:(NSUInteger)species;
@end

@interface DDAbstractGameOfLife : NSObject
@property (nonatomic, weak) id <DDGameOfLifeDelegate> delegate;
// Returns the current state
@property (nonatomic, readonly) NSArray *state;
// Number of rows
@property (nonatomic, readonly) NSUInteger rows;
// Number of columns
@property (nonatomic, readonly) NSUInteger cols;
//
// Designated initializer
//
-(id)initWithRows:(NSUInteger)rows cols:(NSUInteger)cols;
//
// Provided methods
//
-(NSUInteger)previousRow:(NSUInteger)fromRow;
-(NSUInteger)nextRow:(NSUInteger)fromRow;
-(NSUInteger)previousCol:(NSUInteger)fromCol;
-(NSUInteger)nextCol:(NSUInteger)fromCol;
//
// Abstract methods
//
// Resets the current state.
-(void)reset;
// Performs a step over the whole grid.
-(void)performStep;
// Flips the cell at the given row,col to either the desired species or dead if it was already alive with the give species.
-(void)flipCellAtRow:(NSUInteger)row col:(NSUInteger)col species:(NSUInteger)species started:(BOOL)started;
@end
