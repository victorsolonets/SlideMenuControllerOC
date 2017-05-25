//
//  SlideMenuController.h
//  btWeighBase
//
//  Created by ChipSea on 16/1/28.
//  Copyright © 2016年 Chipsea. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSInteger, TrackAction) {
    TrackActionLeftTapOpen,
    TrackActionLeftTapClose,
    TrackActionLeftFlickOpen,
    TrackActionLeftFlickClose,
    TrackActionRightTapOpen,
    TrackActionRightTapClose,
    TrackActionRightFlickOpen,
    TrackActionRightFlickClose,
    TrackActionBottomTapOpen,
    TrackActionBottomTapClose,
    TrackActionBottomFlickOpen,
    TrackActionBottomFlickClose,
};

@protocol SlideMenuControllerDelegate <NSObject>

@optional
- (void)leftWillOpen;
- (void)leftDidOpen;
- (void)leftWillClose;
- (void)leftDidClose;
- (void)rightWillOpen;
- (void)rightDidOpen;
- (void)rightWillClose;
- (void)rightDidClose;
- (void)bottomWillOpen;
- (void)bottomDidOpen;
- (void)bottomWillClose;
- (void)bottomDidClose;

@end

@interface SlideMenuOption : NSObject

@property (nonatomic, assign) CGFloat leftViewWidth;
@property (nonatomic, assign) CGFloat leftBezelWidth;
@property (nonatomic, assign) CGFloat bottomViewY;
@property (nonatomic, assign) CGFloat bottomBezelWidth;
@property (nonatomic, assign) CGFloat contentViewScale;
@property (nonatomic, assign) CGFloat contentViewOpacity;
@property (nonatomic, assign) CGFloat shadowOpacity;
@property (nonatomic, assign) CGFloat shadowRadius;
@property (nonatomic, assign) CGSize shadowOffset;
@property (nonatomic, assign) BOOL panFromBezel;
@property (nonatomic, assign) CGFloat animationDuration;
@property (nonatomic, assign) CGFloat rightViewWidth;
@property (nonatomic, assign) CGFloat rightBezelWidth;
@property (nonatomic, assign) BOOL rightPanFromBezel;
@property (nonatomic, assign) BOOL bottomPanFromBezel;
@property (nonatomic, assign) BOOL hideStatusBar;
@property (nonatomic, assign) CGFloat pointOfNoReturnWidth;
@property (nonatomic, assign) BOOL simultaneousGestureRecognizers;
@property (nonatomic, retain) UIColor *opacityViewBackgroundColor;

@end

@interface SlideMenuController : UIViewController<UIGestureRecognizerDelegate>

@property (nonatomic, weak) id<SlideMenuControllerDelegate> delegate;

@property (nonatomic, retain) SlideMenuOption *option;

@property (nonatomic, retain) UIView *opacityView;
@property (nonatomic, retain) UIView *mainContainerView;
@property (nonatomic, retain) UIView *leftContainerView;
@property (nonatomic, retain) UIView *rightContainerView;
@property (nonatomic, retain) UIView *bottomContainerView;
@property (nonatomic, retain) UIPanGestureRecognizer *leftPanGesture;
@property (nonatomic, retain) UITapGestureRecognizer *leftTapGesture;
@property (nonatomic, retain) UIPanGestureRecognizer *rightPanGesture;
@property (nonatomic, retain) UITapGestureRecognizer *rightTapGesture;
@property (nonatomic, retain) UITapGestureRecognizer *bottomTapGesture;
@property (nonatomic, retain) UIPanGestureRecognizer *bottomPanGesture;
@property (nonatomic, retain) UIViewController *mainViewController;
@property (nonatomic, retain) UIViewController *leftViewController;
@property (nonatomic, retain) UIViewController *rightViewController;
@property (nonatomic, retain) UIViewController *bottomViewController;


- (instancetype)initWithMainViewController:(UIViewController *)tMainController leftMenuViewController:(UIViewController *)tLeftMenuController;

- (instancetype)initWithMainViewController:(UIViewController *)tMainController rightMenuViewController:(UIViewController *)tRightMenuController;

- (instancetype)initWithMainViewController:(UIViewController *)tMainController leftMenuViewController:(UIViewController *)tLeftMenuController rightMenuViewController:(UIViewController *)tRightMenuController;

- (instancetype)initWithMainViewController:(UIViewController *)tMainController bottomMenuViewController:(UIViewController *)tBottomMenuController;

- (instancetype)initWithMainViewController:(UIViewController *)tMainController leftMenuViewController:(UIViewController *)tLeftMenuController rightMenuViewController:(UIViewController *)tRightMenuController bottomMenuViewController:(UIViewController *)tBottomMenuController;

- (BOOL)isTagetViewController;

- (void)addLeftGestures;

- (void)addBottomGestures;

- (void)addRightGestures;

- (void)removeLeftGestures;

- (void)removeBottomGestures;

- (void)removeRightGestures;

- (void)track:(TrackAction)action;

- (void)openLeftWithVelocity:(CGFloat) velocity;

- (void)openBottomWithVelocity:(CGFloat) velocity;

- (void)openRightWithVelocity:(CGFloat) velocity;

- (void)closeLeftWithVelocity:(CGFloat) velocity;

- (void)closeBottomWithVelocity:(CGFloat) velocity;

- (void)closeRightWithVelocity:(CGFloat) velocity;

- (BOOL)isLeftOpen;

- (BOOL)isLeftHidden;

- (BOOL)isBottomOpen;

- (BOOL)isBottomHidden;

- (BOOL)isRightOpen;

- (BOOL)isRightHidden;

- (void)changeMainViewController:(UIViewController *)newMainController close:(BOOL)close;

- (void)changeLeftViewWidth:(CGFloat) width;

- (void)changeBottomViewY:(CGFloat) originY;

- (void)changeRightViewWidth:(CGFloat) width;

- (void)changeLeftViewController:(UIViewController *)newLeftController close:(BOOL) close;

- (void)changeBottomViewController:(UIViewController *)newBottomController close:(BOOL) close;

- (void)changeRightViewController:(UIViewController *)newRightController close:(BOOL) close;

- (void)closeLeftNonAnimation;

- (void)closeBottomNonAnimation;

- (void)closeRightNonAnimation;

@end


@interface UIViewController(SlideMenuVC)

@property (nonatomic, retain, readonly) SlideMenuController *slideMenuController;

- (void)addLeftBarButtonWithImage:(UIImage *)buttonImage;

- (void)addRightBarButtonWithImage:(UIImage *)buttonImage;

- (void)toggleLeft;

- (void)toggleBottom;

- (void)toggleRight;

- (void)openLeft;

- (void)openBottom;

- (void)openRight;

- (void)closeLeft;

- (void)closeBottom;

- (void)closeRight;

- (void)addPriorityToMenuGesture:(UIScrollView *) targetScrollView;

@end
