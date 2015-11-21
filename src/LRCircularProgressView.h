//
//   The MIT License (MIT)
//   Copyright (c) 2015 Lukas Riebel ( https://github.com/t4l0s )
//
//   Permission is hereby granted, free of charge, to any person obtaining a copy
//   of this software and associated documentation files (the "Software"), to deal
//   in the Software without restriction, including without limitation the rights
//   to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
//   copies of the Software, and to permit persons to whom the Software is
//   furnished to do so, subject to the following conditions:
//
//   The above copyright notice and this permission notice shall be included in
//   all copies or substantial portions of the Software.
//
//   THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
//   IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
//   FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT.  IN NO EVENT SHALL THE
//   AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
//   LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
//   OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
//   THE SOFTWARE.

#import <UIKit/UIKit.h>

#if __has_feature(nullability)
#   define __ASSUME_NONNULL_BEGIN      NS_ASSUME_NONNULL_BEGIN
#   define __ASSUME_NONNULL_END        NS_ASSUME_NONNULL_END
#   define __NULLABLE                  nullable
#else
#   define __ASSUME_NONNULL_BEGIN
#   define __ASSUME_NONNULL_END
#   define __NULLABLE
#endif

__ASSUME_NONNULL_BEGIN

IB_DESIGNABLE

/// LRCircularProgressView is a simple UIView subclass for displaying and animating progress.

@interface LRCircularProgressView : UIView

/// @name Customization

/// The color of the bar displaying the progress from 0. up to self.progress.
@property (nonatomic, strong, nullable) IBInspectable UIColor *progressTintColor;

/// The color of the bar displaying the progress from self.progress up to 1.
@property (nonatomic, strong, nullable) IBInspectable UIColor *progressTrackColor;

/// The color of the background bar. Defaults to nil.
@property (nonatomic, strong, nullable) IBInspectable UIColor *progressRemainderTintColor;

/// The duration to fully animate from 0. up to 1. Defaults to 2.
@property (nonatomic, assign) NSTimeInterval animationDuration;

/// The width of the tracking ring. Defaults to 7.5.
@property (nonatomic, assign) IBInspectable CGFloat progressTrackWidth;

/// Additional offset of the inner label from the outer circle. Defaults to 2.
@property (nonatomic, assign) IBInspectable CGFloat textInset;

@property (nonatomic, assign, getter=animatesText) IBInspectable BOOL animateText;

/// @name Update ratio

/// Sets the actual progress. The progress value will be clamped to [0,1].
@property (nonatomic, assign) IBInspectable float progress;

/// Sets the actual progress with an optional animation. The progress value will be clamped to [0,1].
- (void)setProgress:(float)progress animated:(BOOL)animated;

/// @name Title

/** The title to be displayed within the view. Nullable.
 
 The text to display within the view. The progress value of the view can be accessed by adding an attribute with the key LRCircularProgressPlaceholderKey with length 1.
 The value of the attribute will be used as format parameter.
 Example:
 
     LRCircularProgressView *progressView = ...;
     
     NSMutableAttributedString *attrString = [NSMutableAttributedString new];
     [attrString appendAttributedString: [[NSAttributedString alloc] initWithString: @"Loading\n"]];
     [attrString addAttribute: LRCircularProgressPlaceholderKey value: @"%.0f" range: NSMakeRange(attrString.length - 1, 1)];
     [attrString appendAttributedString: [[NSAttributedString alloc] initWithString: @"%"]];
     
     progressView.title = attrString;
     progressView.progress = 0.5f;
     
     // Will render as:
     // Loading
     // 50%
 
 */
@property (nonatomic, copy, nullable) NSAttributedString *title;

@end

/// @name Constants

/// Key intended to be used within an NSAttributedString to mark the position for a progress value being generated by an LRCircularProgressView. @see [LRCircularProgressView title]
extern NSString *const LRCircularProgressPlaceholderKey;

__ASSUME_NONNULL_END
