//
//  UIViewAdditions.h
//  Weibo
//
//  Created by junmin liu on 10-9-29.
//  Copyright 2010 Openlab. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface UIView (Addtions)

- (id)roundCornersOnTopLeft:(BOOL)tl topRight:(BOOL)tr bottomLeft:(BOOL)bl bottomRight:(BOOL)br radius:(float)radius;

/**
 * Shortcut for frame.origin.x.
 *
 * Sets frame.origin.x = left
 */
@property (nonatomic) CGFloat left;

/**
 * Shortcut for frame.origin.y
 *
 * Sets frame.origin.y = top
 */
@property (nonatomic) CGFloat top;

/**
 * Shortcut for frame.origin.x + frame.size.width
 *
 * Sets frame.origin.x = right - frame.size.width
 */
@property (nonatomic) CGFloat right;

/**
 * Shortcut for frame.origin.y + frame.size.height
 *
 * Sets frame.origin.y = bottom - frame.size.height
 */
@property (nonatomic) CGFloat bottom;

/**
 * Shortcut for frame.size.width
 *
 * Sets frame.size.width = width
 */
@property (nonatomic) CGFloat width;

/**
 * Shortcut for frame.size.height
 *
 * Sets frame.size.height = height
 */
@property (nonatomic) CGFloat height;

/**
 * Shortcut for center.x
 *
 * Sets center.x = centerX
 */
@property (nonatomic) CGFloat centerX;

/**
 * Shortcut for center.y
 *
 * Sets center.y = centerY
 */
@property (nonatomic) CGFloat centerY;

/**
 * Return the x coordinate on the screen.
 */
@property (nonatomic, readonly) CGFloat ttScreenX;

/**
 * Return the y coordinate on the screen.
 */
@property (nonatomic, readonly) CGFloat ttScreenY;

/**
 * Return the x coordinate on the screen, taking into account scroll views.
 */
@property (nonatomic, readonly) CGFloat screenViewX;

/**
 * Return the y coordinate on the screen, taking into account scroll views.
 */
@property (nonatomic, readonly) CGFloat screenViewY;

/**
 * Return the view frame on the screen, taking into account scroll views.
 */
@property (nonatomic, readonly) CGRect screenFrame;

/**
 * Shortcut for frame.origin
 */
@property (nonatomic) CGPoint origin;

/**
 * Shortcut for frame.size
 */
@property (nonatomic) CGSize size;



- (UIView*)descendantOrSelfWithClass:(Class)cls;

- (UIView*)ancestorOrSelfWithClass:(Class)cls;

- (void)removeAllSubviews;

- (UIImage *)imageByRenderingView;

@end



//////////==============///////////
//        Keyboard
//////////==============///////////

//typedef void (^DAKeyboardDidMoveBlock) (CGRect keyboardFrameInView);
//
//static inline UIViewAnimationOptions AnimationOptionsForCurve(UIViewAnimationCurve curve);
//
///** DAKeyboardControl allows you to easily add keyboard awareness and scrolling
// dismissal (a receding keyboard ala iMessages app) to any UIView, UIScrollView
// or UITableView with only 1 line of code. DAKeyboardControl automatically
// extends UIView and provides a block callback with the keyboard's current origin.
// */
//
//@interface UIView (DAKeyboardControl)
//
///** The keyboardTriggerOffset property allows you to choose at what point the
// user's finger "engages" the keyboard.
// */
//@property (nonatomic) CGFloat keyboardTriggerOffset;
//@property (nonatomic, readonly) BOOL keyboardWillRecede;
//
///** Adding pan-to-dismiss (functionality introduced in iMessages)
// @param didMoveBlock called everytime the keyboard is moved so you can update
// the frames of your views
// @see addKeyboardNonpanningWithActionHandler:
// @see removeKeyboardControl
// */
//- (void)addKeyboardPanningWithActionHandler:(DAKeyboardDidMoveBlock)didMoveBlock;
//
///** Adding keyboard awareness (appearance and disappearance only)
// @param didMoveBlock called everytime the keyboard is moved so you can update
// the frames of your views
// @see addKeyboardPanningWithActionHandler:
// @see removeKeyboardControl
// */
//- (void)addKeyboardNonpanningWithActionHandler:(DAKeyboardDidMoveBlock)didMoveBlock;
//
///** Remove the keyboard action handler
// @note You MUST call this method to remove the keyboard handler before the view
// goes out of memory.
// */
//- (void)removeKeyboardControl;
//
///** Returns the keyboard frame in the view */
//- (CGRect)keyboardFrameInView;
//
///** Convenience method to dismiss the keyboard */
//- (void)hideKeyboard;
//
//@end
