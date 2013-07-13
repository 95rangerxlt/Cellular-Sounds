//
//  DDGridView.h
//  Cellular-Sounds
//
//  Created by Vasco Orey on 7/13/13.
//  Copyright (c) 2013 Delta Dog Studios. All rights reserved.
//

#import <UIKit/UIKit.h>

@class DDGridView;
@protocol DDGridViewDelegate <NSObject>
@required
// Sent to the delegate when a touch at the give (row, col) has been detected. justStarted = YES if the touch just started, NO if not.
-(void)gridView:(DDGridView *)gridView didDetectTouchAtRow:(NSUInteger)row col:(NSUInteger)col justStarted:(BOOL)justStarted;
// Sent to the delegate to figure out the color for the given cell's contents.
-(UIColor *)gridView:(DDGridView *)gridView colorForCellContents:(id)cellContents;
@optional
// Sent to the delegate to figure out if the given touch event should be handled.
-(BOOL)shouldHandleTouchEvent:(UITouch *)touch;
@end

@interface DDGridView : UIView
// grid needs to be an NSArray of NSArrays which all have exactly the same number of items. Behavior is undefined otherwise.
@property (nonatomic, strong) NSArray *grid;
// The delegate
@property (nonatomic, weak) id <DDGridViewDelegate> delegate;
// Activates the given (row, col)
-(void)activateRow:(NSUInteger)row col:(NSUInteger)col color:(UIColor *)color;
@end
