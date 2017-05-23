//
//  SlideMenuController.m
//  btWeighBase
//
//  Created by ChipSea on 16/1/28.
//  Copyright © 2016年 Chipsea. All rights reserved.
//

#import "SlideMenuController.h"

typedef NS_ENUM(NSInteger, SlideAction) {
    SlideActionOpen,
    SlideActionClose
};

struct PanInfo {
    SlideAction action;
    BOOL shouldBounce;
    CGFloat velocity;
};

@implementation SlideMenuOption


- (instancetype)init {
    self = [super init];
    if (self) {
        _leftViewWidth = 270;
        _leftBezelWidth = 16.0;
        _contentViewScale = 0.96;
        _contentViewOpacity = 0.5;
        _shadowOpacity = 0.0;
        _shadowRadius = 0.0;
        _shadowOffset = CGSizeMake(0, 0);
        _panFromBezel = YES;
        _animationDuration = .4;
        _rightViewWidth = 270;
        _rightBezelWidth = 20.0f;
        _rightPanFromBezel = YES;
        _bottomPanFromBezel = YES;
        _bottomViewWidth = 270.f;
        _bottomBezelWidth = 200.f;
        _contentViewScale = 0.96f;
        _contentViewOpacity = 0.5f;
        _hideStatusBar = YES;
        _pointOfNoReturnWidth = 44;
        _simultaneousGestureRecognizers = YES;
        _opacityViewBackgroundColor = [UIColor blackColor];
    }
    return self;
}

@end

/**
 *  Instead of the struct static variables
 *  Instead of LeftPanState and RightPanState
 */
static CGRect LPSFrameAtStartOfPan = {0,0,0,0};
static CGPoint LPSStartPointOfPan = {0,0};
static BOOL LPSWasOpenAtStartOfPan = NO;
static BOOL LPSWasHiddenAtStartOfPan = NO;
static UIGestureRecognizerState LPSLastState = UIGestureRecognizerStateEnded;

static CGPoint RPSStartPointOfPan = {0,0};
static CGRect RPSFrameAtStartOfPan = {0,0,0,0};
static BOOL RPSWasOpenAtStartOfPan = NO;
static BOOL RPSWasHiddenAtStartOfPan = NO;
static UIGestureRecognizerState RPSLastState = UIGestureRecognizerStateEnded;

static CGRect BPSFrameAtStartOfPan = {0,0,0,0};
static CGPoint BPSStartPointOfPan = {0,0};
static BOOL BPSWasOpenAtStartOfPan = NO;
static BOOL BPSWasHiddenAtStartOfPan = NO;
static UIGestureRecognizerState BPSLastState = UIGestureRecognizerStateEnded;

@interface SlideMenuController () {
    SlideMenuOption *options;
}

@end

@implementation SlideMenuController

- (instancetype)init {
    self = [super init];
    if (self) {
        _mainContainerView = [UIView new];
        _leftContainerView = [UIView new];
        _rightContainerView = [UIView new];
        options = [[SlideMenuOption alloc] init];
    }
    return self;
}

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    return [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    return [super initWithCoder:aDecoder];
}

- (instancetype)initWithMainViewController:(UIViewController *)tMainController leftMenuViewController:(UIViewController *)tLeftMenuController {
    self = [self init];
    if (self) {
        _mainViewController = tMainController;
        _leftViewController = tLeftMenuController;
        [self initView];
    }
    return self;
}

- (instancetype)initWithMainViewController:(UIViewController *)tMainController bottomMenuViewController:(UIViewController *)tBottomMenuController {
    self = [self init];
    if (self) {
        _mainViewController = tMainController;
        _bottomViewController = tBottomMenuController;
        [self initView];
    }
    return self;
}

- (instancetype)initWithMainViewController:(UIViewController *)tMainController rightMenuViewController:(UIViewController *)tRightMenuController {
    self = [self init];
    if (self) {
        _mainViewController = tMainController;
        _rightViewController = tRightMenuController;
        [self initView];
    }
    return self;
}

- (instancetype)initWithMainViewController:(UIViewController *)tMainController leftMenuViewController:(UIViewController *)tLeftMenuController rightMenuViewController:(UIViewController *)tRightMenuController {
    self = [self init];
    if (self) {
        _mainViewController = tMainController;
        _leftViewController = tLeftMenuController;
        _rightViewController = tRightMenuController;
        [self initView];
    }
    return self;
}

- (instancetype)initWithMainViewController:(UIViewController *)tMainController leftMenuViewController:(UIViewController *)tLeftMenuController rightMenuViewController:(UIViewController *)tRightMenuController bottomMenuViewController:(UIViewController *)tBottomMenuController {
    self = [self init];
    if (self) {
        _mainViewController = tMainController;
        _leftViewController = tLeftMenuController;
        _rightViewController = tRightMenuController;
        _bottomViewController = tBottomMenuController;
        [self initView];
    }
    return self;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    [self initView];
}

- (void)initView {
    _mainContainerView = [[UIView alloc] initWithFrame:self.view.bounds];
    _mainContainerView.backgroundColor = [UIColor clearColor];
    _mainContainerView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    [self.view insertSubview:_mainContainerView atIndex:0];
    
    CGRect opacityFrame = self.view.bounds;
    CGFloat opacityOffset = 0;
    opacityFrame.origin.y = opacityFrame.origin.y + opacityOffset;
    opacityFrame.size.height = opacityFrame.size.height - opacityOffset;
    _opacityView = [[UIView alloc] initWithFrame:opacityFrame];
    _opacityView.backgroundColor = options.opacityViewBackgroundColor;
    _opacityView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    _opacityView.layer.opacity = 0.0;
    [self.view insertSubview:_opacityView atIndex:1];
    
    CGRect leftFrame = self.view.bounds;
    leftFrame.size.width = options.leftViewWidth;
    leftFrame.origin.x = [self leftMinOrigin];
    CGFloat leftOffset = 0;
    leftFrame.origin.y = leftFrame.origin.y + leftOffset;
    leftFrame.size.height = leftFrame.size.height - leftOffset;
    _leftContainerView = [[UIView alloc] initWithFrame:leftFrame];
    _leftContainerView.backgroundColor = [UIColor clearColor];
    _leftContainerView.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:_leftContainerView atIndex:2];
    
    CGRect rightFrame = self.view.bounds;
    rightFrame.size.width = options.rightViewWidth;
    rightFrame.origin.x = [self rightMinOrigin];
    CGFloat rightOffset = 0;
    rightFrame.origin.y = rightFrame.origin.y + rightOffset;
    rightFrame.size.height = rightFrame.size.height - rightOffset;
    _rightContainerView = [[UIView alloc] initWithFrame:rightFrame];
    _rightContainerView.backgroundColor = [UIColor clearColor];
    _rightContainerView.autoresizingMask = UIViewAutoresizingFlexibleHeight ;
    [self.view insertSubview:_rightContainerView atIndex:3];
    
    CGRect bottomFrame = self.view.bounds;
    bottomFrame.origin.y = 3*CGRectGetHeight(self.view.bounds)/4;
    bottomFrame.origin.x = 0.f;
    _bottomContainerView = [[UIView alloc] initWithFrame:bottomFrame];
    _bottomContainerView.backgroundColor = [UIColor clearColor];
    _bottomContainerView.autoresizingMask = UIViewAutoresizingFlexibleWidth ;
    [self.view insertSubview:_bottomContainerView atIndex:4];
    
    [self addBottomGestures];
    [self addLeftGestures];
    [self addRightGestures];
}

- (SlideMenuOption *)option {
    return options;
}

- (void)setOption:(SlideMenuOption *)option {
    options = option;
}

- (void)viewWillTransitionToSize:(CGSize)size withTransitionCoordinator:(id<UIViewControllerTransitionCoordinator>)coordinator {
    [super viewWillTransitionToSize:size withTransitionCoordinator:coordinator];
    _mainContainerView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    _leftContainerView.hidden = YES;
    _rightContainerView.hidden = YES;
    
    __block typeof(self) weakSelf = self;
    [coordinator animateAlongsideTransition:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        
    } completion:^(id<UIViewControllerTransitionCoordinatorContext>  _Nonnull context) {
        [weakSelf closeLeftNonAnimation];
        [weakSelf closeRightNonAnimation];
        weakSelf.leftContainerView.hidden = NO;
        weakSelf.rightContainerView.hidden = NO;
        
        if (weakSelf.leftPanGesture != nil && weakSelf.leftTapGesture != nil) {
            [weakSelf removeLeftGestures];
            [weakSelf addLeftGestures];
        }
        if (weakSelf.rightPanGesture != nil && weakSelf.rightTapGesture != nil) {
            [weakSelf removeRightGestures];
            [weakSelf addRightGestures];
        }
    }];
}

- (void)didRotateFromInterfaceOrientation:(UIInterfaceOrientation)fromInterfaceOrientation {
    [super didRotateFromInterfaceOrientation:fromInterfaceOrientation];
    [self closeLeftNonAnimation];
    [self closeRightNonAnimation];
    
    _leftContainerView.hidden = NO;
    _rightContainerView.hidden = NO;
    
    [self removeLeftGestures];
    [self removeRightGestures];
    [self addLeftGestures];
    [self addRightGestures];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations {
    if (_mainViewController != nil) {
        return [_mainViewController supportedInterfaceOrientations];
    }
    return UIInterfaceOrientationMaskAll;
}

- (void)viewWillLayoutSubviews {
    [self setUpViewController:_mainContainerView targetViewController:_mainViewController];
    [self setUpViewController:_leftContainerView targetViewController:_leftViewController];
    [self setUpViewController:_rightContainerView targetViewController:_rightViewController];
    [self setUpViewController:_bottomContainerView targetViewController:_bottomViewController];
}

- (void)openLeft {
    if (_leftViewController == nil) {
        return;
    }
    
    if (_delegate != nil && [_delegate respondsToSelector:@selector(leftWillOpen)]) {
        [_delegate leftWillOpen];
    }
    
    [self setOpenWindowLevel];
    
    if (_leftViewController != nil) {
        [_leftViewController beginAppearanceTransition:[self isLeftHidden] animated:YES];
    }
    
    [self openLeftWithVelocity:0.0];
    
    [self track:TrackActionLeftTapOpen];
}

- (void)openRight {
    if (_rightViewController == nil) {
        return;
    }
    
    if (_delegate != nil && [_delegate respondsToSelector:@selector(rightWillOpen)]) {
        [_delegate rightWillOpen];
    }
    
    [self setOpenWindowLevel];
    if (_rightViewController != nil) {
        [_rightViewController beginAppearanceTransition:[self isRightHidden] animated:YES];
    }
    [self openRightWithVelocity:0.0];
    
    [self track:TrackActionRightTapOpen];
}

- (void)openBottom {
    if (_bottomViewController == nil) {
        return;
    }
    
    if (_delegate != nil && [_delegate respondsToSelector:@selector(bottomWillOpen)]) {
        [_delegate bottomWillOpen];
    }
    
    [self setOpenWindowLevel];
    if (_bottomViewController != nil) {
        [_bottomViewController beginAppearanceTransition:[self isBottomHidden] animated:YES];
    }
    [self openBottomWithVelocity:0.0];
    
    [self track:TrackActionBottomTapOpen];
}

- (void)closeLeft {
    if (_leftViewController == nil) {
        return;
    }
    
    if (_delegate != nil && [_delegate respondsToSelector:@selector(leftWillClose)]) {
        [_delegate leftWillClose];
    }
    
    [_leftViewController beginAppearanceTransition:[self isLeftHidden]  animated:YES];
    [self closeLeftWithVelocity:0.0];
    [self setCloseWindowLebel];
}

- (void)closeRight {
    if (_rightViewController == nil) {
        return;
    }
    
    if (_delegate != nil && [_delegate respondsToSelector:@selector(rightWillClose)]) {
        [_delegate rightWillClose];
    }
    
    [_rightViewController beginAppearanceTransition:[self isRightHidden] animated:YES];
    [self closeRightWithVelocity:0.0];
    [self setCloseWindowLebel];
}

- (void)closeBottom {
    if (_bottomViewController == nil) {
        return;
    }
    
    if (_delegate != nil && [_delegate respondsToSelector:@selector(bottomWillClose)]) {
        [_delegate bottomWillClose];
    }
    
    [_bottomViewController beginAppearanceTransition:[self isBottomHidden] animated:YES];
    [self closeBottomWithVelocity:0.0];
    [self setCloseWindowLebel];
}

- (void)addLeftGestures {
    if (_leftViewController != nil) {
        if (self.leftPanGesture == nil) {
            self.leftPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleLeftPanGesture:)];
            self.leftPanGesture.delegate = self;
            [self.view addGestureRecognizer:self.leftPanGesture];
        }
        
        if (self.leftTapGesture == nil) {
            self.leftTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleLeft)];
            self.leftTapGesture.delegate = self;
            [self.view addGestureRecognizer:self.leftTapGesture];
        }
    }
}

- (void)addRightGestures {
    if (_rightViewController != nil) {
        if (self.rightPanGesture == nil) {
            self.rightPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleRightPanGesture:)];
            self.rightPanGesture.delegate = self;
            [self.view addGestureRecognizer:self.rightPanGesture];
        }
        
        if (self.rightTapGesture == nil) {
            self.rightTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleRight)];
            self.rightTapGesture.delegate = self;
            [self.view addGestureRecognizer:self.rightTapGesture];
        }
    }
}

- (void)addBottomGestures {
    if (_bottomViewController != nil) {
        if (self.bottomPanGesture == nil) {
            self.bottomPanGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleBottomPanGesture:)];
            self.bottomPanGesture.delegate = self;
            [self.view addGestureRecognizer:self.bottomPanGesture];
        }
        
        if (self.bottomTapGesture == nil) {
            self.bottomTapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(toggleBottom)];
            self.bottomTapGesture.delegate = self;
            [self.view addGestureRecognizer:self.bottomTapGesture];
        }
    }
}

- (void)removeLeftGestures {
    if (self.leftPanGesture != nil) {
        [self.view removeGestureRecognizer:self.leftPanGesture];
        self.leftPanGesture = nil;
    }
    
    if (self.leftTapGesture != nil) {
        [self.view removeGestureRecognizer:self.leftTapGesture];
        self.leftTapGesture = nil;
    }
}

- (void)removeRightGestures {
    if (self.rightPanGesture != nil) {
        [self.view removeGestureRecognizer:self.rightPanGesture];
        self.rightPanGesture = nil;
    }
    
    if (self.rightTapGesture != nil) {
        [self.view removeGestureRecognizer:self.rightTapGesture];
        self.rightTapGesture = nil;
    }
}

- (void)removeBttomGestures {
    if (self.bottomPanGesture != nil) {
        [self.view removeGestureRecognizer:self.bottomPanGesture];
        self.bottomPanGesture = nil;
    }
    
    if (self.bottomTapGesture != nil) {
        [self.view removeGestureRecognizer:self.bottomTapGesture];
        self.bottomTapGesture = nil;
    }
}

- (BOOL)isTagetViewController {
    // Function to determine the target ViewController
    // Please to override it if necessary
    return YES;
}

- (void)track:(TrackAction)action {
    // function is for tracking
    // Please to override it if necessary
}

- (void)handleLeftPanGesture:(UIPanGestureRecognizer *)panGesture {
    if (![self isTagetViewController]) {
        return;
    }
    
    if (![self isRightHidden]) {
        return;
    }
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            if (LPSLastState != UIGestureRecognizerStateEnded) {
                return;
            }
            
            if (_delegate != nil) {
                if ([self isLeftHidden]) {
                    if ([_delegate respondsToSelector:@selector(leftWillOpen)]) {
                        [_delegate leftWillOpen];
                    }
                } else {
                    if ([_delegate respondsToSelector:@selector(leftWillClose)]) {
                        [_delegate leftWillClose];
                    }
                }
            }
            
            LPSFrameAtStartOfPan = _leftContainerView.frame;
            LPSStartPointOfPan = [panGesture locationInView:self.view];
            LPSWasOpenAtStartOfPan = [self isLeftOpen];
            LPSWasHiddenAtStartOfPan = [self isLeftHidden];
            
            if (_leftViewController != nil) {
                [_leftViewController beginAppearanceTransition:LPSWasHiddenAtStartOfPan animated:YES];
            }
            [self addShadowToView:_leftContainerView];
            [self setOpenWindowLevel];
            
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (LPSLastState != UIGestureRecognizerStateBegan && LPSLastState != UIGestureRecognizerStateChanged) {
                return;
            }
            CGPoint translation = [panGesture translationInView:panGesture.view];
            _leftContainerView.frame = [self applyLeftTranslation:translation toFrame:LPSFrameAtStartOfPan];
            [self applyLeftOpacity];
            [self applyLeftContentViewScale];
            break;
        }
        case UIGestureRecognizerStateEnded: {
            if (LPSLastState != UIGestureRecognizerStateChanged) {
                return;
            }
            CGPoint velocity = [panGesture velocityInView:panGesture.view];
            struct PanInfo panInfo = [self panLeftResultInfoForVelocity:velocity];
            
            if (panInfo.action == SlideActionOpen) {
                if (LPSWasHiddenAtStartOfPan && _leftViewController != nil) {
                    [_leftViewController beginAppearanceTransition:YES animated:YES];
                }
                [self openLeftWithVelocity:panInfo.velocity];
                [self track:TrackActionLeftFlickOpen];
            } else {
                if (LPSWasHiddenAtStartOfPan && _leftViewController != nil) {
                    [_leftViewController beginAppearanceTransition:NO animated:YES];
                }
                [self closeLeftWithVelocity:panInfo.velocity];
                [self setCloseWindowLebel];
                [self track:TrackActionLeftTapClose];
            }
            break;
        }
        default:
            break;
    }
    LPSLastState = panGesture.state;
}

- (void)handleRightPanGesture:(UIPanGestureRecognizer *)panGesture {
    if (![self isTagetViewController]) {
        return;
    }
    
    if (![self isLeftHidden]) {
        return;
    }
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            if (RPSLastState != UIGestureRecognizerStateEnded) {
                return;
            }
            
            if (_delegate != nil) {
                if ([self isLeftHidden]) {
                    if ([_delegate respondsToSelector:@selector(rightWillOpen)]) {
                        [_delegate rightWillOpen];
                    }
                } else {
                    if ([_delegate respondsToSelector:@selector(rightWillClose)]) {
                        [_delegate rightWillClose];
                    }
                }
            }
            
            RPSFrameAtStartOfPan = _rightContainerView.frame;
            RPSStartPointOfPan = [panGesture locationInView:self.view];
            RPSWasOpenAtStartOfPan = [self isRightOpen];
            RPSWasHiddenAtStartOfPan = [self isRightHidden];
            
            if (_rightViewController != nil) {
                [_rightViewController beginAppearanceTransition:RPSWasHiddenAtStartOfPan animated:YES];
            }
            [self addShadowToView:_rightContainerView];
            [self setOpenWindowLevel];
            
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (RPSLastState != UIGestureRecognizerStateBegan && RPSLastState != UIGestureRecognizerStateChanged) {
                return;
            }
            CGPoint translation = [panGesture translationInView:panGesture.view];
            _rightContainerView.frame = [self applyRightTranslation:translation toFrame:RPSFrameAtStartOfPan];
            [self applyRightOpacity];
            [self applyRightContentViewScale];
            NSLog(@"handleRightPanGesture --> Changed frame:%@", NSStringFromCGRect(_rightContainerView.frame));
            break;
        }
        case UIGestureRecognizerStateEnded: {
            if (RPSLastState != UIGestureRecognizerStateChanged) {
                return;
            }
            CGPoint velocity = [panGesture velocityInView:panGesture.view];
            struct PanInfo panInfo = [self panRightResultInfoForVelocity:velocity];
            
            if (panInfo.action == SlideActionOpen) {
                if (RPSWasHiddenAtStartOfPan && _rightViewController != nil) {
                    [_rightViewController beginAppearanceTransition:YES animated:YES];
                }
                [self openRightWithVelocity:panInfo.velocity];
            } else {
                if (RPSWasHiddenAtStartOfPan && _rightViewController != nil) {
                    [_rightViewController beginAppearanceTransition:NO animated:YES];
                }
                [self closeRightWithVelocity:panInfo.velocity];
                [self setCloseWindowLebel];
            }
            NSLog(@"handleRightPanGesture --> Ended frame:%@", NSStringFromCGRect(_rightContainerView.frame));
            break;
        }
        default:
            break;
    }
    RPSLastState = panGesture.state;
}

- (void)handleBottomPanGesture:(UIPanGestureRecognizer *)panGesture {
    if (![self isTagetViewController]) {
        return;
    }
    
    switch (panGesture.state) {
        case UIGestureRecognizerStateBegan: {
            if (BPSLastState != UIGestureRecognizerStateEnded) {
                return;
            }
            
            
            if (_delegate != nil) {
                if ([self isLeftHidden]) {
                    if ([_delegate respondsToSelector:@selector(bottomWillOpen)]) {
                        [_delegate bottomWillOpen];
                    }
                } else {
                    if ([_delegate respondsToSelector:@selector(bottomWillClose)]) {
                        [_delegate bottomWillClose];
                    }
                }
            }
            
            BPSFrameAtStartOfPan = _bottomContainerView.frame;
            BPSStartPointOfPan = [panGesture locationInView:self.view];
            BPSWasOpenAtStartOfPan = [self isBottomOpen];
            BPSWasHiddenAtStartOfPan = [self isBottomHidden];
            
            if (_bottomViewController != nil) {
                [_bottomViewController beginAppearanceTransition:BPSWasHiddenAtStartOfPan animated:YES];
            }
            [self addShadowToView:_bottomContainerView];
            [self setOpenWindowLevel];
            
            break;
        }
        case UIGestureRecognizerStateChanged: {
            if (BPSLastState != UIGestureRecognizerStateBegan && BPSLastState != UIGestureRecognizerStateChanged) {
                return;
            }
            CGPoint translation = [panGesture translationInView:panGesture.view];
            _bottomContainerView.frame = [self applyBottomTranslation:translation toFrame:BPSFrameAtStartOfPan];
            NSLog(@"handleBottomPanGesture --> Changed frame:%@", NSStringFromCGRect(_bottomContainerView.frame));
            break;
        }
        case UIGestureRecognizerStateEnded: {
            if (BPSLastState != UIGestureRecognizerStateChanged) {
                return;
            }
            CGPoint velocity = [panGesture velocityInView:panGesture.view];
            struct PanInfo panInfo = [self panBottomResultInfoForVelocity:velocity];
            
            if (panInfo.action == SlideActionOpen) {
                if (BPSWasHiddenAtStartOfPan && _bottomViewController != nil) {
                    [_bottomViewController beginAppearanceTransition:YES animated:YES];
                }
                [self openBottomWithVelocity:panInfo.velocity];
            } else {
                if (BPSWasHiddenAtStartOfPan && _bottomViewController != nil) {
                    [_bottomViewController beginAppearanceTransition:NO animated:YES];
                }
                [self closeBottomWithVelocity:panInfo.velocity];
            }
            NSLog(@"handleBottomPanGesture --> Ended frame:%@", NSStringFromCGRect(_bottomContainerView.frame));
            break;
        }
        default:
            break;
    }
    BPSLastState = panGesture.state;
}

- (void)openLeftWithVelocity:(CGFloat)velocity {
    CGFloat xOrigin = _leftContainerView.frame.origin.x;
    
    CGFloat finalXOrigin = 0.0;
    
    CGRect frame = _leftContainerView.frame;
    frame.origin.x = finalXOrigin;
    
    NSTimeInterval duration = options.animationDuration;
    if (velocity != 0.0) {
        duration = fabs(xOrigin - finalXOrigin) / velocity;
        duration = fmax(0.1, fmin(1.0, duration));
    }
    
    [self addShadowToView:_leftContainerView];
    __block typeof(self) weakSelf = self;
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        weakSelf.leftContainerView.frame = frame;
        weakSelf.opacityView.layer.opacity = options.contentViewOpacity;
        weakSelf.mainContainerView.transform = CGAffineTransformMakeScale(options.contentViewScale, options.contentViewScale);
    } completion:^(BOOL finished) {
        [weakSelf disableContentInteraction];
        [weakSelf.leftViewController endAppearanceTransition];
        
        if (weakSelf.delegate != nil && [weakSelf.delegate respondsToSelector:@selector(leftDidOpen)]) {
            [weakSelf.delegate leftDidOpen];
        }
    }];
}

- (void)openBottomWithVelocity:(CGFloat)velocity {
    CGFloat xOrigin = _bottomContainerView.frame.origin.x;
    
    CGFloat finalYOrigin = 120.f;
    
    CGRect frame = _bottomContainerView.frame;
    frame.origin.y = finalYOrigin;
    
    NSTimeInterval duration = options.animationDuration;
    if (velocity != 0.0) {
        duration = fabs(xOrigin - CGRectGetWidth(self.view.bounds)) / velocity;
        duration = fmax(0.1, fmin(1.0, duration));
    }
    
    __block typeof(self) weakSelf = self;
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        weakSelf.bottomContainerView.frame = frame;
    } completion:^(BOOL finished) {
        [weakSelf disableContentInteraction];
        [weakSelf.bottomViewController endAppearanceTransition];
        
        if (weakSelf.delegate != nil && [weakSelf.delegate respondsToSelector:@selector(bottomDidOpen)]) {
            [weakSelf.delegate bottomDidOpen];
        }
    }];
}

- (void)openRightWithVelocity:(CGFloat)velocity {
    CGFloat xOrigin = _rightContainerView.frame.origin.x;
    
    CGFloat finalXOrigin = CGRectGetWidth(self.view.bounds) - _rightContainerView.frame.size.width;
    
    CGRect frame = _rightContainerView.frame;
    frame.origin.x = finalXOrigin;
    
    NSTimeInterval duration = options.animationDuration;
    if (velocity != 0.0) {
        duration = fabs(xOrigin - CGRectGetWidth(self.view.bounds)) / velocity;
        duration = fmax(0.1, fmin(1.0, duration));
    }
    
    [self addShadowToView:_rightContainerView];
    __block typeof(self) weakSelf = self;
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        weakSelf.rightContainerView.frame = frame;
        weakSelf.opacityView.layer.opacity = options.contentViewOpacity;
        weakSelf.mainContainerView.transform = CGAffineTransformMakeScale(options.contentViewScale, options.contentViewScale);
    } completion:^(BOOL finished) {
        [weakSelf disableContentInteraction];
        [weakSelf.rightViewController endAppearanceTransition];
        
        if (weakSelf.delegate != nil && [weakSelf.delegate respondsToSelector:@selector(rightDidOpen)]) {
            [weakSelf.delegate rightDidOpen];
        }
    }];
}

- (void)closeLeftWithVelocity:(CGFloat) velocity {
    CGFloat xOrigin = _leftContainerView.frame.origin.x;
    CGFloat finalXOrigin = [self leftMinOrigin];
    
    CGRect frame = _leftContainerView.frame;
    frame.origin.x = finalXOrigin;
    
    NSTimeInterval duration = options.animationDuration;
    if (velocity != 0.0) {
        duration = fabs(xOrigin - finalXOrigin) / velocity;
        duration = fmax(0.1, fmin(1.0, duration));
    }
    __block typeof(self) weakSelf = self;
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        weakSelf.leftContainerView.frame = frame;
        weakSelf.opacityView.layer.opacity = 0.0;
        weakSelf.mainContainerView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
        [weakSelf removeShadow:weakSelf.leftContainerView];
        [weakSelf enableContentInteraction];
        [weakSelf.leftViewController endAppearanceTransition];
        
        if (weakSelf.delegate != nil && [weakSelf.delegate respondsToSelector:@selector(leftDidClose)]) {
            [weakSelf.delegate leftDidClose];
        }
    }];
}

- (void)closeBottomWithVelocity:(CGFloat) velocity {
    CGFloat xOrigin = _bottomContainerView.frame.origin.x;
    CGFloat finalYOrigin = 3*CGRectGetHeight(self.view.bounds)/4.f;
    
    CGRect frame = _bottomContainerView.frame;
    frame.origin.y = finalYOrigin;
    
    NSTimeInterval duration = options.animationDuration;
    if (velocity != 0.0) {
        duration = fabs(xOrigin - CGRectGetWidth(self.view.bounds)) / velocity;
        duration = fmax(0.1, fmin(1.0, duration));
    }
    __block typeof(self) weakSelf = self;
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        weakSelf.bottomContainerView.frame = frame;
        weakSelf.opacityView.layer.opacity = 0.0;
        weakSelf.mainContainerView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
        [weakSelf removeShadow:weakSelf.bottomContainerView];
        [weakSelf enableContentInteraction];
        [weakSelf.bottomViewController endAppearanceTransition];
        
        if (weakSelf.delegate != nil && [weakSelf.delegate respondsToSelector:@selector(bottomDidClose)]) {
            [weakSelf.delegate bottomDidClose];
        }
    }];
}

- (void)closeRightWithVelocity:(CGFloat) velocity {
    CGFloat xOrigin = _rightContainerView.frame.origin.x;
    CGFloat finalXOrigin = CGRectGetWidth(self.view.bounds);
    
    CGRect frame = _rightContainerView.frame;
    frame.origin.x = finalXOrigin;
    
    NSTimeInterval duration = options.animationDuration;
    if (velocity != 0.0) {
        duration = fabs(xOrigin - CGRectGetWidth(self.view.bounds)) / velocity;
        duration = fmax(0.1, fmin(1.0, duration));
    }
    __block typeof(self) weakSelf = self;
    [UIView animateWithDuration:duration delay:0.0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
        weakSelf.rightContainerView.frame = frame;
        weakSelf.opacityView.layer.opacity = 0.0;
        weakSelf.mainContainerView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    } completion:^(BOOL finished) {
        [weakSelf removeShadow:weakSelf.rightContainerView];
        [weakSelf enableContentInteraction];
        [weakSelf.rightViewController endAppearanceTransition];
        
        if (weakSelf.delegate != nil && [weakSelf.delegate respondsToSelector:@selector(rightDidClose)]) {
            [weakSelf.delegate rightDidClose];
        }
    }];
}

- (void)toggleLeft {
    if ([self isLeftOpen]) {
        [self closeLeft];
        [self setCloseWindowLebel];
        [self track:TrackActionLeftTapClose];
    } else {
        [self openLeft];
    }
}

- (BOOL)isLeftOpen {
    return _leftViewController != nil && _leftContainerView.frame.origin.x == 0.0;
}

- (BOOL)isLeftHidden {
    return _leftContainerView.frame.origin.x <= [self leftMinOrigin];
}

- (void)toggleRight {
    if ([self isRightOpen]) {
        [self closeRight];
        [self setCloseWindowLebel];
        [self track:TrackActionRightTapClose];
    } else {
        [self openRight];
    }
}

- (void)toggleBottom {
    if ([self isBottomOpen]) {
        [self closeBottom];
        [self setCloseWindowLebel];
        [self track:TrackActionBottomTapClose];
    } else {
        [self openBottom];
    }
}

- (BOOL)isBottomOpen {
    return _bottomViewController != nil && _bottomContainerView.frame.origin.y == 120.f;
}

- (BOOL)isBottomHidden {
    return _bottomContainerView.frame.origin.y != 120.f;
}

- (BOOL)isRightOpen {
    return _rightViewController != nil && _rightContainerView.frame.origin.x == CGRectGetWidth(self.view.bounds) - _rightContainerView.frame.size.width;
}

- (BOOL)isRightHidden {
    return _rightContainerView.frame.origin.x >= CGRectGetWidth(self.view.bounds);
}

- (void)setPanFromBezel:(BOOL)panFromBezel {
    options.panFromBezel = panFromBezel;
}

- (void)changeMainViewController:(UIViewController *)newMainController close:(BOOL)close {
    [self removeViewController:_mainViewController];
    _mainViewController = newMainController;
    [self setUpViewController:_mainContainerView targetViewController:_mainViewController];
    if (close) {
        [self closeLeft];
        [self closeRight];
    }
}

- (void)changeLeftViewWidth:(CGFloat)width {
    options.leftViewWidth = width;
    CGRect leftFrame = self.view.bounds;
    leftFrame.size.width = width;
    leftFrame.origin.x = [self leftMinOrigin];
    CGFloat leftOffset = 0;
    leftFrame.origin.y = leftFrame.origin.y + leftOffset;
    leftFrame.size.height = leftFrame.size.height - leftOffset;
    _leftContainerView.frame = leftFrame;
}

- (void)changeBottomViewWidth:(CGFloat)width {
    options.bottomBezelWidth = width;
    CGRect rightFrame = self.view.bounds;
    rightFrame.origin.y -= width;
    _bottomContainerView.frame = rightFrame;
}

- (void)changeRightViewWidth:(CGFloat)width {
    options.rightBezelWidth = width;
    CGRect rightFrame = self.view.bounds;
    rightFrame.size.width = width;
    rightFrame.origin.x = [self rightMinOrigin];
    CGFloat rightOffset = 0;
    rightFrame.origin.y = rightFrame.origin.y + rightOffset;
    rightFrame.size.height = rightFrame.size.height - rightOffset;
    _rightContainerView.frame = rightFrame;
}

- (void)changeLeftViewController:(UIViewController *)newLeftController close:(BOOL) close {
    [self removeViewController:_leftViewController];
    _leftViewController = newLeftController;
    [self setUpViewController:_leftContainerView targetViewController:_leftViewController];
    if (close) {
        [self closeLeft];
    }
}

- (void)changeRightViewController:(UIViewController *)newRightController close:(BOOL) close {
    [self removeViewController:_rightViewController];
    _rightViewController = newRightController;
    [self setUpViewController:_rightContainerView targetViewController:_rightViewController];
    if (close) {
        [self closeRight];
    }
}

- (void)changeBottomViewController:(UIViewController *)newBottomController close:(BOOL) close {
    [self removeViewController:_bottomViewController];
    _bottomViewController = newBottomController;
    [self setUpViewController:_bottomContainerView targetViewController:_bottomViewController];
    if (close) {
        [self closeBottom];
    }
}

- (CGFloat)leftMinOrigin {
    return -options.leftViewWidth;
}

- (CGFloat)bottomMinOrigin {
    return 3.f*CGRectGetHeight(self.view.bounds)/4.f;
}

- (CGFloat)rightMinOrigin {
    return CGRectGetWidth(self.view.bounds);
}

- (struct PanInfo)panLeftResultInfoForVelocity:(CGPoint)velocity {
    CGFloat thresholdVelocity = 1000.0;
    CGFloat pointOfNoReturn = floor([self leftMinOrigin]) + options.pointOfNoReturnWidth;
    CGFloat leftOrigin = _leftContainerView.frame.origin.x;
    
    struct PanInfo panInfo = {SlideActionClose, NO, 0.0};
    panInfo.action = leftOrigin <= pointOfNoReturn ? SlideActionClose : SlideActionOpen;
    if (velocity.x >= thresholdVelocity) {
        panInfo.action = SlideActionOpen;
        panInfo.velocity = velocity.x;
    } else if (velocity.x <= (-1.0 * thresholdVelocity)) {
        panInfo.action = SlideActionClose;
        panInfo.velocity = velocity.x;
    }
    return panInfo;
}

- (struct PanInfo)panBottomResultInfoForVelocity:(CGPoint)velocity {
    CGFloat thresholdVelocity = -1000;
    CGFloat pointOfNoReturn = floor(CGRectGetWidth(self.view.bounds)) - options.pointOfNoReturnWidth;
    CGFloat bottomOrigin = _bottomContainerView.frame.origin.y;
    struct PanInfo panInfo = {SlideActionClose, NO, 0.0};
    panInfo.action = bottomOrigin >= pointOfNoReturn ? SlideActionClose : SlideActionOpen;
    if (velocity.y <= thresholdVelocity) {
        panInfo.action = SlideActionOpen;
        panInfo.velocity = velocity.y;
    } else if (velocity.y >= (-1.0 * thresholdVelocity)) {
        panInfo.action = SlideActionClose;
        panInfo.velocity = velocity.y;
    }
    return panInfo;
}

- (struct PanInfo)panRightResultInfoForVelocity:(CGPoint)velocity {
    CGFloat thresholdVelocity = -1000;
    CGFloat pointOfNoReturn = floor(CGRectGetWidth(self.view.bounds)) - options.pointOfNoReturnWidth;
    CGFloat rightOrigin = _rightContainerView.frame.origin.x;
    struct PanInfo panInfo = {SlideActionClose, NO, 0.0};
    panInfo.action = rightOrigin >= pointOfNoReturn ? SlideActionClose : SlideActionOpen;
    if (velocity.x <= thresholdVelocity) {
        panInfo.action = SlideActionOpen;
        panInfo.velocity = velocity.x;
    } else if (velocity.x >= (-1.0 * thresholdVelocity)) {
        panInfo.action = SlideActionClose;
        panInfo.velocity = velocity.x;
    }
    return panInfo;
}

- (CGRect)applyLeftTranslation:(CGPoint)translation toFrame:(CGRect)frame {
    CGFloat newOrigin = frame.origin.x;
    newOrigin += translation.x;
    CGFloat minOrigin = [self leftMinOrigin];
    CGFloat maxOrigin = 0.0;
    CGRect newFrame = frame;
    if (newOrigin < minOrigin) {
        newOrigin = minOrigin;
    } else if(newOrigin > maxOrigin) {
        newOrigin = maxOrigin;
    }
    newFrame.origin.x = newOrigin;
    return newFrame;
}

- (CGRect)applyBottomTranslation:(CGPoint)translation toFrame:(CGRect)frame {
    CGFloat newOrigin = frame.origin.y;
    newOrigin += translation.y;
    CGFloat minOrigin = [self bottomMinOrigin];
    CGFloat maxOrigin = 120.f;
    CGRect newFrame = frame;
    if (newOrigin > minOrigin) {
        newOrigin = minOrigin;
    } else if (newOrigin < maxOrigin) {
        newOrigin = maxOrigin;
    }
    newFrame.origin.y = newOrigin;
    return newFrame;
}

- (CGRect)applyRightTranslation:(CGPoint)translation toFrame:(CGRect)frame {
    CGFloat newOrigin = frame.origin.x;
    newOrigin += translation.x;
    CGFloat minOrigin = [self rightMinOrigin];
    CGFloat maxOrigin = [self rightMinOrigin] - _rightContainerView.frame.size.width;
    CGRect newFrame = frame;
    if (newOrigin > minOrigin) {
        newOrigin = minOrigin;
    } else if (newOrigin < maxOrigin) {
        newOrigin = maxOrigin;
    }
    newFrame.origin.x = newOrigin;
    return newFrame;
}

- (CGFloat)getOpenedLeftRatio {
    CGFloat width = _leftContainerView.frame.size.width;
    CGFloat currentPosition = _leftContainerView.frame.origin.x - [self leftMinOrigin];
    return currentPosition / width;
}

- (CGFloat)getOpenedBottomRatio {
    CGFloat width = _bottomContainerView.frame.size.width;
    CGFloat currentPosition = _bottomContainerView.frame.origin.y;
    return - (currentPosition - CGRectGetHeight(self.view.bounds))/width;
}

- (CGFloat)getOpenedRightRatio {
    CGFloat width = _rightContainerView.frame.size.width;
    CGFloat currentPosition = _rightContainerView.frame.origin.x;
    return - (currentPosition - CGRectGetWidth(self.view.bounds))/width;
}

- (void)applyLeftOpacity {
    CGFloat openedLeftRatio = [self getOpenedLeftRatio];
    CGFloat opacity = options.contentViewOpacity * openedLeftRatio;
    _opacityView.layer.opacity = opacity;
}

- (void)applyRightOpacity {
    CGFloat openedRightRatio = [self getOpenedRightRatio];
    CGFloat opacity = options.contentViewOpacity * openedRightRatio;
    _opacityView.layer.opacity = opacity;
}

- (void)applyBottomOpacity {
    CGFloat openedBottomRatio = [self getOpenedBottomRatio];
    CGFloat opacity = options.contentViewOpacity * openedBottomRatio;
    _opacityView.layer.opacity = opacity;
}

- (void)applyLeftContentViewScale {
    CGFloat openedLeftRadio = [self getOpenedLeftRatio];
    CGFloat scale = 1.0 - ((1.0 - options.contentViewScale) * openedLeftRadio);
    _mainContainerView.transform = CGAffineTransformMakeScale(scale, scale);
}

- (void)applyRightContentViewScale {
    CGFloat openedRightRatio = [self getOpenedRightRatio];
    CGFloat scale = 1.0 - ((1.0 - options.contentViewScale) * openedRightRatio);
    _mainContainerView.transform = CGAffineTransformMakeScale(scale, scale);
}

- (void)applyBottomContentViewScale {
    CGFloat openedBottomRatio = [self getOpenedBottomRatio];
    CGFloat scale = 1.0 - ((1.0 - options.contentViewScale) * openedBottomRatio);
    _mainContainerView.transform = CGAffineTransformMakeScale(scale, scale);
}

- (void)addShadowToView:(UIView *)targetContainerView {
    targetContainerView.layer.masksToBounds = NO;
    targetContainerView.layer.shadowOffset = options.shadowOffset;
    targetContainerView.layer.shadowOpacity = options.shadowOpacity;
    targetContainerView.layer.shadowRadius = options.shadowRadius;
    targetContainerView.layer.shadowPath = [UIBezierPath bezierPathWithRect:targetContainerView.bounds].CGPath;
    
}

- (void)removeShadow:(UIView *)targetContainerView {
    targetContainerView.layer.masksToBounds = YES;
    _mainContainerView.layer.opacity = 1.0;
}

- (void)removeContentOpacity {
    _opacityView.layer.opacity = 0.0;
}

- (void)addContentOpacity {
    _opacityView.layer.opacity = options.contentViewOpacity;
}

- (void)disableContentInteraction {
    _mainContainerView.userInteractionEnabled = NO;
}

- (void)enableContentInteraction {
    _mainContainerView.userInteractionEnabled = YES;
}

- (void)setOpenWindowLevel {
    if (options.hideStatusBar) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([UIApplication sharedApplication].keyWindow != nil) {
                [UIApplication sharedApplication].keyWindow.windowLevel = UIWindowLevelStatusBar + 1;
            }
        });
    }
}

- (void)setCloseWindowLebel {
    if (options.hideStatusBar) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if ([UIApplication sharedApplication].keyWindow != nil) {
                [UIApplication sharedApplication].keyWindow.windowLevel = UIWindowLevelNormal;
            }
        });
    }
}

- (void)setUpViewController:(UIView *)targetView targetViewController:(UIViewController *)targetViewController {
    if (targetViewController != nil) {
        [self addChildViewController:targetViewController];
        targetViewController.view.frame = targetView.bounds;
        [targetView addSubview:targetViewController.view];
        [targetViewController didMoveToParentViewController:self];
    }
}

- (void)removeViewController:(UIViewController *)viewController {
    if (viewController != nil) {
        [viewController willMoveToParentViewController:nil];
        [viewController.view removeFromSuperview];
        [viewController removeFromParentViewController];
    }
}

- (void)closeLeftNonAnimation {
    [self setCloseWindowLebel];
    CGFloat finalXOrigin = [self leftMinOrigin];
    CGRect frame = _leftContainerView.frame;
    frame.origin.x = finalXOrigin;
    _leftContainerView.frame = frame;
    _opacityView.layer.opacity = 0.0;
    _mainContainerView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    [self removeShadow:_leftContainerView];
    [self enableContentInteraction];
}

- (void)closeBottomNonAnimation {
    [self setCloseWindowLebel];
    CGFloat finalYOrigin = 3*CGRectGetHeight(self.view.bounds)/4;
    CGRect frame = _bottomContainerView.frame;
    frame.origin.y = finalYOrigin;
    _bottomContainerView.frame = frame;
    _opacityView.layer.opacity = 0.0;
    _mainContainerView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    [self removeShadow:_bottomContainerView];
    [self enableContentInteraction];
}

- (void)closeRightNonAnimation {
    [self setCloseWindowLebel];
    CGFloat finalXOrigin = CGRectGetWidth(self.view.bounds);
    CGRect frame = _rightContainerView.frame;
    frame.origin.x = finalXOrigin;
    _rightContainerView.frame = frame;
    _opacityView.layer.opacity = 0.0;
    _mainContainerView.transform = CGAffineTransformMakeScale(1.0, 1.0);
    [self removeShadow:_rightContainerView];
    [self enableContentInteraction];
}

#pragma mark - UIGestureRecognizerDelegate
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldReceiveTouch:(UITouch *)touch {
    CGPoint point = [touch locationInView:self.view];
    if (gestureRecognizer == _leftPanGesture) {
        return [self slideLeftForGestureRecognizer:gestureRecognizer inPoint:point];
    } else if (gestureRecognizer == _rightPanGesture) {
        return [self slideRightViewForGestureRecognizer:gestureRecognizer withTouchPoint:point];
    } else if (gestureRecognizer == _leftTapGesture) {
        return  [self isLeftOpen] && ![self isPointContainedWithinLeftRect:point];
    } else if (gestureRecognizer == _rightTapGesture) {
        return  [self isRightOpen] && ![self isPointContainedWithinRightRect:point];
    } else if (gestureRecognizer == _bottomTapGesture) {
        return  [self isBottomOpen] && ![self isPointContainedWithinBottomRect:point];
    } else if (gestureRecognizer == _bottomPanGesture) {
        return [self slideBottomViewForGestureRecognizer:gestureRecognizer withTouchPoint:point];
    }
    return YES;
}

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return options.simultaneousGestureRecognizers;
}

- (BOOL)slideLeftForGestureRecognizer:(UIGestureRecognizer *)gesture inPoint:(CGPoint)point {
    return [self isLeftOpen] || (options.panFromBezel && [self isLeftPointContainedWithinBezelRect:point]);
}

- (BOOL)isLeftPointContainedWithinBezelRect:(CGPoint)point {
    CGRect leftBezelRect = CGRectZero;
    CGRect tempRect = CGRectZero;
    CGFloat bezelWidth = CGRectGetWidth(self.view.bounds) - options.leftBezelWidth;
    CGRectDivide(self.view.bounds, &leftBezelRect, &tempRect, bezelWidth, CGRectMinXEdge);
    return CGRectContainsPoint(leftBezelRect, point);
}

- (BOOL)isPointContainedWithinLeftRect:(CGPoint)point {
    return CGRectContainsPoint(_leftContainerView.frame, point);;
}

- (BOOL)slideRightViewForGestureRecognizer:(UIGestureRecognizer *)gesture withTouchPoint:(CGPoint)point {
    return [self isRightOpen] || (options.rightPanFromBezel && [self isRightPointContainedWithinBezelRect:point]);
}

- (BOOL)slideBottomViewForGestureRecognizer:(UIGestureRecognizer *)gesture withTouchPoint:(CGPoint)point {
    return [self isBottomOpen] || (options.bottomPanFromBezel && [self isBottomPointContainedWithinBezelRect:point]);
}

- (BOOL)isRightPointContainedWithinBezelRect:(CGPoint)point {
    CGRect rightBezelRect = CGRectZero;
    CGRect tempRect = CGRectZero;
    CGFloat bezelWidth = CGRectGetWidth(self.view.bounds) - options.rightBezelWidth;
    CGRectDivide(self.view.bounds, &tempRect, &rightBezelRect, bezelWidth, CGRectMinXEdge);
    return CGRectContainsPoint(rightBezelRect, point);
}

- (BOOL)isBottomPointContainedWithinBezelRect:(CGPoint)point {
    CGRect rightBezelRect = CGRectZero;
    CGRect tempRect = CGRectZero;
    CGFloat bezelWidth = 3.f*CGRectGetHeight(self.view.bounds)/4.f;
    CGRectDivide(self.view.bounds, &tempRect, &rightBezelRect, bezelWidth, CGRectMinYEdge);
    return CGRectContainsPoint(rightBezelRect, point);
}

- (BOOL)isPointContainedWithinRightRect:(CGPoint)point {
    return CGRectContainsPoint(_rightContainerView.frame, point);
}

- (BOOL)isPointContainedWithinBottomRect:(CGPoint)point {
    return CGRectContainsPoint(_bottomContainerView.frame, point);
}

@end


@implementation UIViewController(SlideMenuVC)

- (SlideMenuController *)slideMenuController {
    UIViewController *controller = self;
    while (controller != nil) {
        if ([controller isKindOfClass:[SlideMenuController class]]) {
            return (SlideMenuController *)controller;
        }
        controller = [controller parentViewController];
    }
    return nil;
}

- (void)addLeftBarButtonWithImage:(UIImage *)buttonImage {
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:buttonImage style:UIBarButtonItemStylePlain target:self action:@selector(toggleLeft)];
    self.navigationItem.leftBarButtonItem = leftButton;
}

- (void)addRightBarButtonWithImage:(UIImage *)buttonImage {
    UIBarButtonItem *leftButton = [[UIBarButtonItem alloc] initWithImage:buttonImage style:UIBarButtonItemStylePlain target:self action:@selector(toggleRight)];
    self.navigationItem.rightBarButtonItem = leftButton;
}

- (void)toggleLeft {
    if (self.slideMenuController != nil) {
        [self.slideMenuController toggleLeft];
    }
}

- (void)toggleRight {
    if (self.slideMenuController != nil) {
        [self.slideMenuController toggleRight];
    }
}

- (void)toggleBottom {
    if (self.slideMenuController != nil) {
        [self.slideMenuController toggleBottom];
    }
}

- (void)openLeft {
    if (self.slideMenuController != nil) {
        [self.slideMenuController openLeft];
    }
}

- (void)openBottom {
    if (self.slideMenuController != nil) {
        [self.slideMenuController openBottom];
    }
}

- (void)openRight {
    if (self.slideMenuController != nil) {
        [self.slideMenuController openRight];
    }
}

- (void)closeLeft {
    if (self.slideMenuController != nil) {
        [self.slideMenuController closeLeft];
    }
}

- (void)closeRight {
    if (self.slideMenuController != nil) {
        [self.slideMenuController closeRight];
    }
}

- (void)closeBottom {
    if (self.slideMenuController != nil) {
        [self.slideMenuController closeBottom];
    }
}

- (void)addPriorityToMenuGesture:(UIScrollView *) targetScrollView {
    if (self.slideMenuController != nil) {
        NSArray *recognizers = self.slideMenuController.view.gestureRecognizers;
        for (UIGestureRecognizer *recognizer in recognizers) {
            if ([recognizer isKindOfClass:[UIPanGestureRecognizer class]]) {
                [targetScrollView.panGestureRecognizer requireGestureRecognizerToFail:recognizer];
            }
        }
    }
}

@end
