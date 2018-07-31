#if !__has_feature(objc_arc)
#error SVProgressHUD is ARC only. Either turn on ARC for the project or use -fobjc-arc flag
#endif
#import "SVProgressHUD.h"
#import "SVIndefiniteAnimatedView.h"
#import "SVProgressAnimatedView.h"
#import "SVRadialGradientLayer.h"
NSString * const SVProgressHUDDidReceiveTouchEventNotification = @"SVProgressHUDDidReceiveTouchEventNotification";
NSString * const SVProgressHUDDidTouchDownInsideNotification = @"SVProgressHUDDidTouchDownInsideNotification";
NSString * const SVProgressHUDWillDisappearNotification = @"SVProgressHUDWillDisappearNotification";
NSString * const SVProgressHUDDidDisappearNotification = @"SVProgressHUDDidDisappearNotification";
NSString * const SVProgressHUDWillAppearNotification = @"SVProgressHUDWillAppearNotification";
NSString * const SVProgressHUDDidAppearNotification = @"SVProgressHUDDidAppearNotification";
NSString * const SVProgressHUDStatusUserInfoKey = @"SVProgressHUDStatusUserInfoKey";
static const CGFloat SVProgressHUDParallaxDepthPoints = 10.0f;
static const CGFloat SVProgressHUDUndefinedProgress = -1;
static const CGFloat SVProgressHUDDefaultAnimationDuration = 0.15f;
static const CGFloat SVProgressHUDVerticalSpacing = 12.0f;
static const CGFloat SVProgressHUDHorizontalSpacing = 12.0f;
static const CGFloat SVProgressHUDLabelSpacing = 8.0f;
@interface SVProgressHUD ()
@property (nonatomic, strong) NSTimer *graceTimer;
@property (nonatomic, strong) NSTimer *fadeOutTimer;
@property (nonatomic, strong) UIControl *controlView;
@property (nonatomic, strong) UIView *backgroundView;
@property (nonatomic, strong) SVRadialGradientLayer *backgroundRadialGradientLayer;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
@property (nonatomic, strong) UIVisualEffectView *hudView;
#else
@property (nonatomic, strong) UIView *hudView;
#endif
@property (nonatomic, strong) UILabel *statusLabel;
@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) UIView *indefiniteAnimatedView;
@property (nonatomic, strong) SVProgressAnimatedView *ringView;
@property (nonatomic, strong) SVProgressAnimatedView *backgroundRingView;
@property (nonatomic, readwrite) CGFloat progress;
@property (nonatomic, readonly) CGFloat visibleKeyboardHeight;
@property (nonatomic, readonly) UIWindow *frontWindow;
#if TARGET_OS_IOS && __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
@property (nonatomic, strong) UINotificationFeedbackGenerator *hapticGenerator;
#endif
@end
@implementation SVProgressHUD {
    BOOL _isInitializing;
}
+ (SVProgressHUD*)sharedView {
    static dispatch_once_t once;
    static SVProgressHUD *sharedView;
#if !defined(SV_APP_EXTENSIONS)
    dispatch_once(&once, ^{ sharedView = [[self alloc] initWithFrame:[[[UIApplication sharedApplication] delegate] window].bounds]; });
#else
    dispatch_once(&once, ^{ sharedView = [[self alloc] initWithFrame:[[UIScreen mainScreen] bounds]]; });
#endif
    return sharedView;
}
#pragma mark - Setters
+ (void)setStatus:(NSString*)status {
    [[self sharedView] setStatus:status];
}
+ (void)setDefaultStyle:(SVProgressHUDStyle)style {
    [self sharedView].defaultStyle = style;
}
+ (void)setDefaultMaskType:(SVProgressHUDMaskType)maskType {
    [self sharedView].defaultMaskType = maskType;
}
+ (void)setDefaultAnimationType:(SVProgressHUDAnimationType)type {
    [self sharedView].defaultAnimationType = type;
}
+ (void)setContainerView:(nullable UIView*)containerView {
    [self sharedView].containerView = containerView;
}
+ (void)setMinimumSize:(CGSize)minimumSize {
    [self sharedView].minimumSize = minimumSize;
}
+ (void)setRingThickness:(CGFloat)ringThickness {
    [self sharedView].ringThickness = ringThickness;
}
+ (void)setRingRadius:(CGFloat)radius {
    [self sharedView].ringRadius = radius;
}
+ (void)setRingNoTextRadius:(CGFloat)radius {
    [self sharedView].ringNoTextRadius = radius;
}
+ (void)setCornerRadius:(CGFloat)cornerRadius {
    [self sharedView].cornerRadius = cornerRadius;
}
+ (void)setBorderColor:(nonnull UIColor*)color {
    [self sharedView].hudView.layer.borderColor = color.CGColor;
}
+ (void)setBorderWidth:(CGFloat)width {
    [self sharedView].hudView.layer.borderWidth = width;
}
+ (void)setFont:(UIFont*)font {
    [self sharedView].font = font;
}
+ (void)setForegroundColor:(UIColor*)color {
    [self sharedView].foregroundColor = color;
    [self setDefaultStyle:SVProgressHUDStyleCustom];
}
+ (void)setBackgroundColor:(UIColor*)color {
    [self sharedView].backgroundColor = color;
    [self setDefaultStyle:SVProgressHUDStyleCustom];
}
+ (void)setBackgroundLayerColor:(UIColor*)color {
    [self sharedView].backgroundLayerColor = color;
}
+ (void)setImageViewSize:(CGSize)size {
	[self sharedView].imageViewSize = size;
}
+ (void)setInfoImage:(UIImage*)image {
    [self sharedView].infoImage = image;
}
+ (void)setSuccessImage:(UIImage*)image {
    [self sharedView].successImage = image;
}
+ (void)setErrorImage:(UIImage*)image {
    [self sharedView].errorImage = image;
}
+ (void)setViewForExtension:(UIView*)view {
    [self sharedView].viewForExtension = view;
}
+ (void)setGraceTimeInterval:(NSTimeInterval)interval {
    [self sharedView].graceTimeInterval = interval;
}
+ (void)setMinimumDismissTimeInterval:(NSTimeInterval)interval {
    [self sharedView].minimumDismissTimeInterval = interval;
}
+ (void)setMaximumDismissTimeInterval:(NSTimeInterval)interval {
    [self sharedView].maximumDismissTimeInterval = interval;
}
+ (void)setFadeInAnimationDuration:(NSTimeInterval)duration {
    [self sharedView].fadeInAnimationDuration = duration;
}
+ (void)setFadeOutAnimationDuration:(NSTimeInterval)duration {
    [self sharedView].fadeOutAnimationDuration = duration;
}
+ (void)setMaxSupportedWindowLevel:(UIWindowLevel)windowLevel {
    [self sharedView].maxSupportedWindowLevel = windowLevel;
}
+ (void)setHapticsEnabled:(BOOL)hapticsEnabled {
    [self sharedView].hapticsEnabled = hapticsEnabled;
}
#pragma mark - Show Methods
+ (void)show {
    [self showWithStatus:nil];
}
+ (void)showWithMaskType:(SVProgressHUDMaskType)maskType {
    SVProgressHUDMaskType existingMaskType = [self sharedView].defaultMaskType;
    [self setDefaultMaskType:maskType];
    [self show];
    [self setDefaultMaskType:existingMaskType];
}
+ (void)showWithStatus:(NSString*)status {
    [self showProgress:SVProgressHUDUndefinedProgress status:status];
}
+ (void)showWithStatus:(NSString*)status maskType:(SVProgressHUDMaskType)maskType {
    SVProgressHUDMaskType existingMaskType = [self sharedView].defaultMaskType;
    [self setDefaultMaskType:maskType];
    [self showWithStatus:status];
    [self setDefaultMaskType:existingMaskType];
}
+ (void)showProgress:(float)progress {
    [self showProgress:progress status:nil];
}
+ (void)showProgress:(float)progress maskType:(SVProgressHUDMaskType)maskType {
    SVProgressHUDMaskType existingMaskType = [self sharedView].defaultMaskType;
    [self setDefaultMaskType:maskType];
    [self showProgress:progress];
    [self setDefaultMaskType:existingMaskType];
}
+ (void)showProgress:(float)progress status:(NSString*)status {
    [[self sharedView] showProgress:progress status:status];
}
+ (void)showProgress:(float)progress status:(NSString*)status maskType:(SVProgressHUDMaskType)maskType {
    SVProgressHUDMaskType existingMaskType = [self sharedView].defaultMaskType;
    [self setDefaultMaskType:maskType];
    [self showProgress:progress status:status];
    [self setDefaultMaskType:existingMaskType];
}
#pragma mark - Show, then automatically dismiss methods
+ (void)showInfoWithStatus:(NSString*)status {
    [self showImage:[self sharedView].infoImage status:status];
#if TARGET_OS_IOS && __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self sharedView].hapticGenerator notificationOccurred:UINotificationFeedbackTypeWarning];
    });
#endif
}
+ (void)showInfoWithStatus:(NSString*)status maskType:(SVProgressHUDMaskType)maskType {
    SVProgressHUDMaskType existingMaskType = [self sharedView].defaultMaskType;
    [self setDefaultMaskType:maskType];
    [self showInfoWithStatus:status];
    [self setDefaultMaskType:existingMaskType];
}
+ (void)showSuccessWithStatus:(NSString*)status {
    [self showImage:[self sharedView].successImage status:status];
#if TARGET_OS_IOS && __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self sharedView].hapticGenerator notificationOccurred:UINotificationFeedbackTypeSuccess];
    });
#endif
}
+ (void)showSuccessWithStatus:(NSString*)status maskType:(SVProgressHUDMaskType)maskType {
    SVProgressHUDMaskType existingMaskType = [self sharedView].defaultMaskType;
    [self setDefaultMaskType:maskType];
    [self showSuccessWithStatus:status];
    [self setDefaultMaskType:existingMaskType];
#if TARGET_OS_IOS && __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self sharedView].hapticGenerator notificationOccurred:UINotificationFeedbackTypeSuccess];
    });
#endif
}
+ (void)showErrorWithStatus:(NSString*)status {
    [self showImage:[self sharedView].errorImage status:status];
#if TARGET_OS_IOS && __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self sharedView].hapticGenerator notificationOccurred:UINotificationFeedbackTypeError];
    });
#endif
}
+ (void)showErrorWithStatus:(NSString*)status maskType:(SVProgressHUDMaskType)maskType {
    SVProgressHUDMaskType existingMaskType = [self sharedView].defaultMaskType;
    [self setDefaultMaskType:maskType];
    [self showErrorWithStatus:status];
    [self setDefaultMaskType:existingMaskType];
#if TARGET_OS_IOS && __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
    dispatch_async(dispatch_get_main_queue(), ^{
        [[self sharedView].hapticGenerator notificationOccurred:UINotificationFeedbackTypeError];
    });
#endif
}
+ (void)showImage:(UIImage*)image status:(NSString*)status {
    NSTimeInterval displayInterval = [self displayDurationForString:status];
    [[self sharedView] showImage:image status:status duration:displayInterval];
}
+ (void)showImage:(UIImage*)image status:(NSString*)status maskType:(SVProgressHUDMaskType)maskType {
    SVProgressHUDMaskType existingMaskType = [self sharedView].defaultMaskType;
    [self setDefaultMaskType:maskType];
    [self showImage:image status:status];
    [self setDefaultMaskType:existingMaskType];
}
#pragma mark - Dismiss Methods
+ (void)dismiss {
    [self dismissWithDelay:0.0 completion:nil];
}
+ (void)dismissWithCompletion:(SVProgressHUDDismissCompletion)completion {
    [self dismissWithDelay:0.0 completion:completion];
}
+ (void)dismissWithDelay:(NSTimeInterval)delay {
    [self dismissWithDelay:delay completion:nil];
}
+ (void)dismissWithDelay:(NSTimeInterval)delay completion:(SVProgressHUDDismissCompletion)completion {
    [[self sharedView] dismissWithDelay:delay completion:completion];
}
#pragma mark - Offset
+ (void)setOffsetFromCenter:(UIOffset)offset {
    [self sharedView].offsetFromCenter = offset;
}
+ (void)resetOffsetFromCenter {
    [self setOffsetFromCenter:UIOffsetZero];
}
#pragma mark - Instance Methods
- (instancetype)initWithFrame:(CGRect)frame {
    if((self = [super initWithFrame:frame])) {
        _isInitializing = YES;
        self.userInteractionEnabled = NO;
        self.backgroundView.alpha = 0.0f;
        self.imageView.alpha = 0.0f;
        self.statusLabel.alpha = 0.0f;
        self.indefiniteAnimatedView.alpha = 0.0f;
        self.ringView.alpha = self.backgroundRingView.alpha = 0.0f;
        _backgroundColor = [UIColor whiteColor];
        _foregroundColor = [UIColor blackColor];
        _backgroundLayerColor = [UIColor colorWithWhite:0 alpha:0.4];
        _defaultMaskType = SVProgressHUDMaskTypeNone;
        _defaultStyle = SVProgressHUDStyleLight;
        _defaultAnimationType = SVProgressHUDAnimationTypeFlat;
        _minimumSize = CGSizeZero;
        _font = [UIFont preferredFontForTextStyle:UIFontTextStyleSubheadline];
        NSBundle *bundle = [NSBundle bundleForClass:[SVProgressHUD class]];
        NSURL *url = [bundle URLForResource:@"SVProgressHUD" withExtension:@"bundle"];
        NSBundle *imageBundle = [NSBundle bundleWithURL:url];
        UIImage* infoImage = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"info" ofType:@"png"]];
        UIImage* successImage = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"success" ofType:@"png"]];
        UIImage* errorImage = [UIImage imageWithContentsOfFile:[imageBundle pathForResource:@"error" ofType:@"png"]];
        _infoImage = [infoImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _successImage = [successImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _errorImage = [errorImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _ringThickness = 2.0f;
        _ringRadius = 18.0f;
        _ringNoTextRadius = 24.0f;
        _cornerRadius = 14.0f;
        _imageViewSize = CGSizeMake(28.0f, 28.0f);
        _graceTimeInterval = 0.0f;
        _minimumDismissTimeInterval = 5.0;
        _maximumDismissTimeInterval = CGFLOAT_MAX;
        _fadeInAnimationDuration = SVProgressHUDDefaultAnimationDuration;
        _fadeOutAnimationDuration = SVProgressHUDDefaultAnimationDuration;
        _maxSupportedWindowLevel = UIWindowLevelNormal;
        _hapticsEnabled = NO;
        self.accessibilityIdentifier = @"SVProgressHUD";
        self.isAccessibilityElement = YES;
        _isInitializing = NO;
    }
    return self;
}
- (void)updateHUDFrame {
    BOOL imageUsed = (self.imageView.image) && !(self.imageView.hidden);
    BOOL progressUsed = self.imageView.hidden;
    CGRect labelRect = CGRectZero;
    CGFloat labelHeight = 0.0f;
    CGFloat labelWidth = 0.0f;
    if(self.statusLabel.text) {
        CGSize constraintSize = CGSizeMake(200.0f, 300.0f);
        labelRect = [self.statusLabel.text boundingRectWithSize:constraintSize
                                                        options:(NSStringDrawingOptions)(NSStringDrawingUsesFontLeading | NSStringDrawingTruncatesLastVisibleLine | NSStringDrawingUsesLineFragmentOrigin)
                                                     attributes:@{NSFontAttributeName: self.statusLabel.font}
                                                        context:NULL];
        labelHeight = ceilf(CGRectGetHeight(labelRect));
        labelWidth = ceilf(CGRectGetWidth(labelRect));
    }
    CGFloat hudWidth;
    CGFloat hudHeight;
    CGFloat contentWidth = 0.0f;
    CGFloat contentHeight = 0.0f;
    if(imageUsed || progressUsed) {
        contentWidth = CGRectGetWidth(imageUsed ? self.imageView.frame : self.indefiniteAnimatedView.frame);
        contentHeight = CGRectGetHeight(imageUsed ? self.imageView.frame : self.indefiniteAnimatedView.frame);
    }
    hudWidth = SVProgressHUDHorizontalSpacing + MAX(labelWidth, contentWidth) + SVProgressHUDHorizontalSpacing;
    hudHeight = SVProgressHUDVerticalSpacing + labelHeight + contentHeight + SVProgressHUDVerticalSpacing;
    if(self.statusLabel.text && (imageUsed || progressUsed)){
        hudHeight += SVProgressHUDLabelSpacing;
    }
    self.hudView.bounds = CGRectMake(0.0f, 0.0f, MAX(self.minimumSize.width, hudWidth), MAX(self.minimumSize.height, hudHeight));
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    CGFloat centerY;
    if(self.statusLabel.text) {
        CGFloat yOffset = MAX(SVProgressHUDVerticalSpacing, (self.minimumSize.height - contentHeight - SVProgressHUDLabelSpacing - labelHeight) / 2.0f);
        centerY = yOffset + contentHeight / 2.0f;
    } else {
        centerY = CGRectGetMidY(self.hudView.bounds);
    }
    self.indefiniteAnimatedView.center = CGPointMake(CGRectGetMidX(self.hudView.bounds), centerY);
    if(self.progress != SVProgressHUDUndefinedProgress) {
        self.backgroundRingView.center = self.ringView.center = CGPointMake(CGRectGetMidX(self.hudView.bounds), centerY);
    }
    self.imageView.center = CGPointMake(CGRectGetMidX(self.hudView.bounds), centerY);
    if(imageUsed || progressUsed) {
        centerY = CGRectGetMaxY(imageUsed ? self.imageView.frame : self.indefiniteAnimatedView.frame) + SVProgressHUDLabelSpacing + labelHeight / 2.0f;
    } else {
        centerY = CGRectGetMidY(self.hudView.bounds);
    }
    self.statusLabel.frame = labelRect;
    self.statusLabel.center = CGPointMake(CGRectGetMidX(self.hudView.bounds), centerY);
    [CATransaction commit];
}
#if TARGET_OS_IOS
- (void)updateMotionEffectForOrientation:(UIInterfaceOrientation)orientation {
    UIInterpolatingMotionEffectType xMotionEffectType = UIInterfaceOrientationIsPortrait(orientation) ? UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis : UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis;
    UIInterpolatingMotionEffectType yMotionEffectType = UIInterfaceOrientationIsPortrait(orientation) ? UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis : UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis;
    [self updateMotionEffectForXMotionEffectType:xMotionEffectType yMotionEffectType:yMotionEffectType];
}
#endif
- (void)updateMotionEffectForXMotionEffectType:(UIInterpolatingMotionEffectType)xMotionEffectType yMotionEffectType:(UIInterpolatingMotionEffectType)yMotionEffectType {
    UIInterpolatingMotionEffect *effectX = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.x" type:xMotionEffectType];
    effectX.minimumRelativeValue = @(-SVProgressHUDParallaxDepthPoints);
    effectX.maximumRelativeValue = @(SVProgressHUDParallaxDepthPoints);
    UIInterpolatingMotionEffect *effectY = [[UIInterpolatingMotionEffect alloc] initWithKeyPath:@"center.y" type:yMotionEffectType];
    effectY.minimumRelativeValue = @(-SVProgressHUDParallaxDepthPoints);
    effectY.maximumRelativeValue = @(SVProgressHUDParallaxDepthPoints);
    UIMotionEffectGroup *effectGroup = [UIMotionEffectGroup new];
    effectGroup.motionEffects = @[effectX, effectY];
    self.hudView.motionEffects = @[];
    [self.hudView addMotionEffect:effectGroup];
}
- (void)updateViewHierarchy {
    if(!self.controlView.superview) {
        if(self.containerView){
            [self.containerView addSubview:self.controlView];
        } else {
#if !defined(SV_APP_EXTENSIONS)
            [self.frontWindow addSubview:self.controlView];
#else
            if(self.viewForExtension) {
                [self.viewForExtension addSubview:self.controlView];
            }
#endif
        }
    } else {
        [self.controlView.superview bringSubviewToFront:self.controlView];
    }
    if(!self.superview) {
        [self.controlView addSubview:self];
    }
}
- (void)setStatus:(NSString*)status {
    self.statusLabel.text = status;
    [self updateHUDFrame];
}
- (void)setGraceTimer:(NSTimer*)timer {
    if(_graceTimer) {
        [_graceTimer invalidate];
        _graceTimer = nil;
    }
    if(timer) {
        _graceTimer = timer;
    }
}
- (void)setFadeOutTimer:(NSTimer*)timer {
    if(_fadeOutTimer) {
        [_fadeOutTimer invalidate];
        _fadeOutTimer = nil;
    }
    if(timer) {
        _fadeOutTimer = timer;
    }
}
#pragma mark - Notifications and their handling
- (void)registerNotifications {
#if TARGET_OS_IOS
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIApplicationDidChangeStatusBarOrientationNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIKeyboardDidHideNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIKeyboardWillShowNotification
                                               object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
#endif
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(positionHUD:)
                                                 name:UIApplicationDidBecomeActiveNotification
                                               object:nil];
}
- (NSDictionary*)notificationUserInfo {
    return (self.statusLabel.text ? @{SVProgressHUDStatusUserInfoKey : self.statusLabel.text} : nil);
}
- (void)positionHUD:(NSNotification*)notification {
    CGFloat keyboardHeight = 0.0f;
    double animationDuration = 0.0;
#if !defined(SV_APP_EXTENSIONS) && TARGET_OS_IOS
    self.frame = [[[UIApplication sharedApplication] delegate] window].bounds;
    UIInterfaceOrientation orientation = UIApplication.sharedApplication.statusBarOrientation;
#elif !defined(SV_APP_EXTENSIONS) && !TARGET_OS_IOS
    self.frame= [UIApplication sharedApplication].keyWindow.bounds;
#else
    if (self.viewForExtension) {
        self.frame = self.viewForExtension.frame;
    } else {
        self.frame = UIScreen.mainScreen.bounds;
    }
#if TARGET_OS_IOS
    UIInterfaceOrientation orientation = CGRectGetWidth(self.frame) > CGRectGetHeight(self.frame) ? UIInterfaceOrientationLandscapeLeft : UIInterfaceOrientationPortrait;
#endif
#endif
    BOOL ignoreOrientation = NO;
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if([[NSProcessInfo processInfo] respondsToSelector:@selector(operatingSystemVersion)]) {
        ignoreOrientation = YES;
    }
#endif
#if TARGET_OS_IOS
    if(notification) {
        NSDictionary* keyboardInfo = [notification userInfo];
        CGRect keyboardFrame = [keyboardInfo[UIKeyboardFrameBeginUserInfoKey] CGRectValue];
        animationDuration = [keyboardInfo[UIKeyboardAnimationDurationUserInfoKey] doubleValue];
        if(notification.name == UIKeyboardWillShowNotification || notification.name == UIKeyboardDidShowNotification) {
            keyboardHeight = CGRectGetWidth(keyboardFrame);
            if(ignoreOrientation || UIInterfaceOrientationIsPortrait(orientation)) {
                keyboardHeight = CGRectGetHeight(keyboardFrame);
            }
        }
    } else {
        keyboardHeight = self.visibleKeyboardHeight;
    }
#endif
    CGRect orientationFrame = self.bounds;
#if !defined(SV_APP_EXTENSIONS) && TARGET_OS_IOS
    CGRect statusBarFrame = UIApplication.sharedApplication.statusBarFrame;
#else
    CGRect statusBarFrame = CGRectZero;
#endif
#if TARGET_OS_IOS
    if(!ignoreOrientation && UIInterfaceOrientationIsLandscape(orientation)) {
        float temp = CGRectGetWidth(orientationFrame);
        orientationFrame.size.width = CGRectGetHeight(orientationFrame);
        orientationFrame.size.height = temp;
        temp = CGRectGetWidth(statusBarFrame);
        statusBarFrame.size.width = CGRectGetHeight(statusBarFrame);
        statusBarFrame.size.height = temp;
    }
    [self updateMotionEffectForOrientation:orientation];
#else
    [self updateMotionEffectForXMotionEffectType:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis yMotionEffectType:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
#endif
    CGFloat activeHeight = CGRectGetHeight(orientationFrame);
    if(keyboardHeight > 0) {
        activeHeight += CGRectGetHeight(statusBarFrame) * 2;
    }
    activeHeight -= keyboardHeight;
    CGFloat posX = CGRectGetMidX(orientationFrame);
    CGFloat posY = floorf(activeHeight*0.45f);
    CGFloat rotateAngle = 0.0;
    CGPoint newCenter = CGPointMake(posX, posY);
    if(notification) {
        [UIView animateWithDuration:animationDuration
                              delay:0
                            options:(UIViewAnimationOptions) (UIViewAnimationOptionAllowUserInteraction | UIViewAnimationOptionBeginFromCurrentState)
                         animations:^{
                             [self moveToPoint:newCenter rotateAngle:rotateAngle];
                             [self.hudView setNeedsDisplay];
                         } completion:nil];
    } else {
        [self moveToPoint:newCenter rotateAngle:rotateAngle];
    }
}
- (void)moveToPoint:(CGPoint)newCenter rotateAngle:(CGFloat)angle {
    self.hudView.transform = CGAffineTransformMakeRotation(angle);
    if (self.containerView) {
        self.hudView.center = CGPointMake(self.containerView.center.x + self.offsetFromCenter.horizontal, self.containerView.center.y + self.offsetFromCenter.vertical);
    } else {
        self.hudView.center = CGPointMake(newCenter.x + self.offsetFromCenter.horizontal, newCenter.y + self.offsetFromCenter.vertical);
    }
}
#pragma mark - Event handling
- (void)controlViewDidReceiveTouchEvent:(id)sender forEvent:(UIEvent*)event {
    [[NSNotificationCenter defaultCenter] postNotificationName:SVProgressHUDDidReceiveTouchEventNotification
                                                        object:self
                                                      userInfo:[self notificationUserInfo]];
    UITouch *touch = event.allTouches.anyObject;
    CGPoint touchLocation = [touch locationInView:self];
    if(CGRectContainsPoint(self.hudView.frame, touchLocation)) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SVProgressHUDDidTouchDownInsideNotification
                                                            object:self
                                                          userInfo:[self notificationUserInfo]];
    }
}
#pragma mark - Master show/dismiss methods
- (void)showProgress:(float)progress status:(NSString*)status {
    __weak SVProgressHUD *weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        __strong SVProgressHUD *strongSelf = weakSelf;
        if(strongSelf){
            strongSelf.fadeOutTimer = nil;
            strongSelf.graceTimer = nil;
            [strongSelf updateViewHierarchy];
            strongSelf.imageView.hidden = YES;
            strongSelf.imageView.image = nil;
            strongSelf.statusLabel.hidden = status.length == 0;
            strongSelf.statusLabel.text = status;
            strongSelf.progress = progress;
            if(progress >= 0) {
                [strongSelf cancelIndefiniteAnimatedViewAnimation];
                if(!strongSelf.ringView.superview){
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
                    [strongSelf.hudView.contentView addSubview:strongSelf.ringView];
#else
                    [strongSelf.hudView addSubview:strongSelf.ringView];
#endif
                }
                if(!strongSelf.backgroundRingView.superview){
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
                    [strongSelf.hudView.contentView addSubview:strongSelf.backgroundRingView];
#else
                    [strongSelf.hudView addSubview:strongSelf.backgroundRingView];
#endif
                }
                [CATransaction begin];
                [CATransaction setDisableActions:YES];
                strongSelf.ringView.strokeEnd = progress;
                [CATransaction commit];
            } else {
                [strongSelf cancelRingLayerAnimation];
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
                [strongSelf.hudView.contentView addSubview:strongSelf.indefiniteAnimatedView];
#else
                [strongSelf.hudView addSubview:strongSelf.indefiniteAnimatedView];
#endif
                if([strongSelf.indefiniteAnimatedView respondsToSelector:@selector(startAnimating)]) {
                    [(id)strongSelf.indefiniteAnimatedView startAnimating];
                }
            }
            if (self.graceTimeInterval > 0.0 && self.backgroundView.alpha == 0.0f) {
                strongSelf.graceTimer = [NSTimer timerWithTimeInterval:self.graceTimeInterval target:strongSelf selector:@selector(fadeIn:) userInfo:nil repeats:NO];
                [[NSRunLoop mainRunLoop] addTimer:strongSelf.graceTimer forMode:NSRunLoopCommonModes];
            } else {
                [strongSelf fadeIn:nil];
            }
#if TARGET_OS_IOS && __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
            [strongSelf.hapticGenerator prepare];
#endif
        }
    }];
}
- (void)showImage:(UIImage*)image status:(NSString*)status duration:(NSTimeInterval)duration {
    __weak SVProgressHUD *weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        __strong SVProgressHUD *strongSelf = weakSelf;
        if(strongSelf){
            strongSelf.fadeOutTimer = nil;
            strongSelf.graceTimer = nil;
            [strongSelf updateViewHierarchy];
            strongSelf.progress = SVProgressHUDUndefinedProgress;
            [strongSelf cancelRingLayerAnimation];
            [strongSelf cancelIndefiniteAnimatedViewAnimation];
            strongSelf.imageView.tintColor = strongSelf.foregroundColorForStyle;
            strongSelf.imageView.image = image;
            strongSelf.imageView.hidden = NO;
            strongSelf.statusLabel.hidden = status.length == 0;
            strongSelf.statusLabel.text = status;
            if (self.graceTimeInterval > 0.0 && self.backgroundView.alpha == 0.0f) {
                strongSelf.graceTimer = [NSTimer timerWithTimeInterval:self.graceTimeInterval target:strongSelf selector:@selector(fadeIn:) userInfo:@(duration) repeats:NO];
                [[NSRunLoop mainRunLoop] addTimer:strongSelf.graceTimer forMode:NSRunLoopCommonModes];
            } else {
                [strongSelf fadeIn:@(duration)];
            }
        }
    }];
}
- (void)fadeIn:(id)data {
    [self updateHUDFrame];
    [self positionHUD:nil];
    if(self.defaultMaskType != SVProgressHUDMaskTypeNone) {
        self.controlView.userInteractionEnabled = YES;
        self.accessibilityLabel = self.statusLabel.text ?: NSLocalizedString(@"Loading", nil);
        self.isAccessibilityElement = YES;
    } else {
        self.controlView.userInteractionEnabled = NO;
        self.hudView.accessibilityLabel = self.statusLabel.text ?: NSLocalizedString(@"Loading", nil);
        self.hudView.isAccessibilityElement = YES;
    }
    id duration = [data isKindOfClass:[NSTimer class]] ? ((NSTimer *)data).userInfo : data;
    if(self.backgroundView.alpha != 1.0f) {
        [[NSNotificationCenter defaultCenter] postNotificationName:SVProgressHUDWillAppearNotification
                                                            object:self
                                                          userInfo:[self notificationUserInfo]];
        self.hudView.transform = self.hudView.transform = CGAffineTransformScale(self.hudView.transform, 1/1.5f, 1/1.5f);
        __block void (^animationsBlock)(void) = ^{
            self.hudView.transform = CGAffineTransformIdentity;
            [self fadeInEffects];
        };
        __block void (^completionBlock)(void) = ^{
            if(self.backgroundView.alpha == 1.0f){
                [self registerNotifications];
                [[NSNotificationCenter defaultCenter] postNotificationName:SVProgressHUDDidAppearNotification
                                                                    object:self
                                                                  userInfo:[self notificationUserInfo]];
                UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
                UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, self.statusLabel.text);
                if(duration){
                    self.fadeOutTimer = [NSTimer timerWithTimeInterval:[(NSNumber *)duration doubleValue] target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
                    [[NSRunLoop mainRunLoop] addTimer:self.fadeOutTimer forMode:NSRunLoopCommonModes];
                }
            }
        };
        if (self.fadeInAnimationDuration > 0) {
            [UIView animateWithDuration:self.fadeInAnimationDuration
                                  delay:0
                                options:(UIViewAnimationOptions) (UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseIn | UIViewAnimationOptionBeginFromCurrentState)
                             animations:^{
                                 animationsBlock();
                             } completion:^(BOOL finished) {
                                 completionBlock();
                             }];
        } else {
            animationsBlock();
            completionBlock();
        }
        [self setNeedsDisplay];
    } else {
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, nil);
        UIAccessibilityPostNotification(UIAccessibilityAnnouncementNotification, self.statusLabel.text);
        if(duration){
            self.fadeOutTimer = [NSTimer timerWithTimeInterval:[(NSNumber *)duration doubleValue] target:self selector:@selector(dismiss) userInfo:nil repeats:NO];
            [[NSRunLoop mainRunLoop] addTimer:self.fadeOutTimer forMode:NSRunLoopCommonModes];
        }
    }
}
- (void)dismiss {
    [self dismissWithDelay:0.0 completion:nil];
}
- (void)dismissWithDelay:(NSTimeInterval)delay completion:(SVProgressHUDDismissCompletion)completion {
    __weak SVProgressHUD *weakSelf = self;
    [[NSOperationQueue mainQueue] addOperationWithBlock:^{
        __strong SVProgressHUD *strongSelf = weakSelf;
        if(strongSelf){
            strongSelf.graceTimer = nil;
            [[NSNotificationCenter defaultCenter] postNotificationName:SVProgressHUDWillDisappearNotification
                                                                object:nil
                                                              userInfo:[strongSelf notificationUserInfo]];
            __block void (^animationsBlock)(void) = ^{
                strongSelf.hudView.transform = CGAffineTransformScale(strongSelf.hudView.transform, 1/1.3f, 1/1.3f);
                [strongSelf fadeOutEffects];
            };
            __block void (^completionBlock)(void) = ^{
                if(self.backgroundView.alpha == 0.0f){
                    [strongSelf.controlView removeFromSuperview];
                    [strongSelf.backgroundView removeFromSuperview];
                    [strongSelf.hudView removeFromSuperview];
                    [strongSelf removeFromSuperview];
                    strongSelf.progress = SVProgressHUDUndefinedProgress;
                    [strongSelf cancelRingLayerAnimation];
                    [strongSelf cancelIndefiniteAnimatedViewAnimation];
                    [[NSNotificationCenter defaultCenter] removeObserver:strongSelf];
                    [[NSNotificationCenter defaultCenter] postNotificationName:SVProgressHUDDidDisappearNotification
                                                                        object:strongSelf
                                                                      userInfo:[strongSelf notificationUserInfo]];
#if !defined(SV_APP_EXTENSIONS) && TARGET_OS_IOS
                    UIViewController *rootController = [[UIApplication sharedApplication] keyWindow].rootViewController;
                    [rootController setNeedsStatusBarAppearanceUpdate];
#endif
                    if (completion) {
                        completion();
                    }
                }
            };
            dispatch_time_t dipatchTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay * NSEC_PER_SEC));
            dispatch_after(dipatchTime, dispatch_get_main_queue(), ^{
                if (strongSelf.fadeOutAnimationDuration > 0) {
                    [UIView animateWithDuration:strongSelf.fadeOutAnimationDuration
                                          delay:0
                                        options:(UIViewAnimationOptions) (UIViewAnimationOptionAllowUserInteraction | UIViewAnimationCurveEaseOut | UIViewAnimationOptionBeginFromCurrentState)
                                     animations:^{
                                         animationsBlock();
                                     } completion:^(BOOL finished) {
                                         completionBlock();
                                     }];
                } else {
                    animationsBlock();
                    completionBlock();
                }
            });
            [strongSelf setNeedsDisplay];
        }
    }];
}
#pragma mark - Ring progress animation
- (UIView*)indefiniteAnimatedView {
    if(self.defaultAnimationType == SVProgressHUDAnimationTypeFlat){
        if(_indefiniteAnimatedView && ![_indefiniteAnimatedView isKindOfClass:[SVIndefiniteAnimatedView class]]){
            [_indefiniteAnimatedView removeFromSuperview];
            _indefiniteAnimatedView = nil;
        }
        if(!_indefiniteAnimatedView){
            _indefiniteAnimatedView = [[SVIndefiniteAnimatedView alloc] initWithFrame:CGRectZero];
        }
        SVIndefiniteAnimatedView *indefiniteAnimatedView = (SVIndefiniteAnimatedView*)_indefiniteAnimatedView;
        indefiniteAnimatedView.strokeColor = self.foregroundColorForStyle;
        indefiniteAnimatedView.strokeThickness = self.ringThickness;
        indefiniteAnimatedView.radius = self.statusLabel.text ? self.ringRadius : self.ringNoTextRadius;
    } else {
        if(_indefiniteAnimatedView && ![_indefiniteAnimatedView isKindOfClass:[UIActivityIndicatorView class]]){
            [_indefiniteAnimatedView removeFromSuperview];
            _indefiniteAnimatedView = nil;
        }
        if(!_indefiniteAnimatedView){
            _indefiniteAnimatedView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        }
        UIActivityIndicatorView *activityIndicatorView = (UIActivityIndicatorView*)_indefiniteAnimatedView;
        activityIndicatorView.color = self.foregroundColorForStyle;
    }
    [_indefiniteAnimatedView sizeToFit];
    return _indefiniteAnimatedView;
}
- (SVProgressAnimatedView*)ringView {
    if(!_ringView) {
        _ringView = [[SVProgressAnimatedView alloc] initWithFrame:CGRectZero];
    }
    _ringView.strokeColor = self.foregroundColorForStyle;
    _ringView.strokeThickness = self.ringThickness;
    _ringView.radius = self.statusLabel.text ? self.ringRadius : self.ringNoTextRadius;
    return _ringView;
}
- (SVProgressAnimatedView*)backgroundRingView {
    if(!_backgroundRingView) {
        _backgroundRingView = [[SVProgressAnimatedView alloc] initWithFrame:CGRectZero];
        _backgroundRingView.strokeEnd = 1.0f;
    }
    _backgroundRingView.strokeColor = [self.foregroundColorForStyle colorWithAlphaComponent:0.1f];
    _backgroundRingView.strokeThickness = self.ringThickness;
    _backgroundRingView.radius = self.statusLabel.text ? self.ringRadius : self.ringNoTextRadius;
    return _backgroundRingView;
}
- (void)cancelRingLayerAnimation {
    [CATransaction begin];
    [CATransaction setDisableActions:YES];
    [self.hudView.layer removeAllAnimations];
    self.ringView.strokeEnd = 0.0f;
    [CATransaction commit];
    [self.ringView removeFromSuperview];
    [self.backgroundRingView removeFromSuperview];
}
- (void)cancelIndefiniteAnimatedViewAnimation {
    if([self.indefiniteAnimatedView respondsToSelector:@selector(stopAnimating)]) {
        [(id)self.indefiniteAnimatedView stopAnimating];
    }
    [self.indefiniteAnimatedView removeFromSuperview];
}
#pragma mark - Utilities
+ (BOOL)isVisible {
    return [self sharedView].backgroundView.alpha > 0.0f;
}
#pragma mark - Getters
+ (NSTimeInterval)displayDurationForString:(NSString*)string {
    CGFloat minimum = MAX((CGFloat)string.length * 0.06 + 0.5, [self sharedView].minimumDismissTimeInterval);
    return MIN(minimum, [self sharedView].maximumDismissTimeInterval);
}
- (UIColor*)foregroundColorForStyle {
    if(self.defaultStyle == SVProgressHUDStyleLight) {
        return [UIColor blackColor];
    } else if(self.defaultStyle == SVProgressHUDStyleDark) {
        return [UIColor whiteColor];
    } else {
        return self.foregroundColor;
    }
}
- (UIColor*)backgroundColorForStyle {
    if(self.defaultStyle == SVProgressHUDStyleLight) {
        return [UIColor whiteColor];
    } else if(self.defaultStyle == SVProgressHUDStyleDark) {
        return [UIColor blackColor];
    } else {
        return self.backgroundColor;
    }
}
- (UIControl*)controlView {
    if(!_controlView) {
        _controlView = [UIControl new];
        _controlView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        _controlView.backgroundColor = [UIColor clearColor];
        _controlView.userInteractionEnabled = YES;
        [_controlView addTarget:self action:@selector(controlViewDidReceiveTouchEvent:forEvent:) forControlEvents:UIControlEventTouchDown];
    }
#if !defined(SV_APP_EXTENSIONS)
    CGRect windowBounds = [[[UIApplication sharedApplication] delegate] window].bounds;
    _controlView.frame = windowBounds;
#else
    _controlView.frame = [UIScreen mainScreen].bounds;
#endif
    return _controlView;
}
-(UIView *)backgroundView {
    if(!_backgroundView){
        _backgroundView = [UIView new];
        _backgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    }
    if(!_backgroundView.superview){
        [self insertSubview:_backgroundView belowSubview:self.hudView];
    }
    if(self.defaultMaskType == SVProgressHUDMaskTypeGradient){
        if(!_backgroundRadialGradientLayer){
            _backgroundRadialGradientLayer = [SVRadialGradientLayer layer];
        }
        if(!_backgroundRadialGradientLayer.superlayer){
            [_backgroundView.layer insertSublayer:_backgroundRadialGradientLayer atIndex:0];
        }
        _backgroundView.backgroundColor = [UIColor clearColor];
    } else {
        if(_backgroundRadialGradientLayer && _backgroundRadialGradientLayer.superlayer){
            [_backgroundRadialGradientLayer removeFromSuperlayer];
        }
        if(self.defaultMaskType == SVProgressHUDMaskTypeBlack){
            _backgroundView.backgroundColor = [UIColor colorWithWhite:0 alpha:0.4];
        } else if(self.defaultMaskType == SVProgressHUDMaskTypeCustom){
            _backgroundView.backgroundColor = self.backgroundLayerColor;
        } else {
            _backgroundView.backgroundColor = [UIColor clearColor];
        }
    }
    if(_backgroundView){
        _backgroundView.frame = self.bounds;
    }
    if(_backgroundRadialGradientLayer){
        _backgroundRadialGradientLayer.frame = self.bounds;
        CGPoint gradientCenter = self.center;
        gradientCenter.y = (self.bounds.size.height - self.visibleKeyboardHeight)/2;
        _backgroundRadialGradientLayer.gradientCenter = gradientCenter;
        [_backgroundRadialGradientLayer setNeedsDisplay];
    }
    return _backgroundView;
}
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
- (UIVisualEffectView*)hudView {
#else
- (UIView*)hudView {
#endif
    if(!_hudView) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
        _hudView = [UIVisualEffectView new];
#else
        _hudView = [UIView new];
#endif
        _hudView.layer.masksToBounds = YES;
        _hudView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin;
    }
    if(!_hudView.superview) {
        [self addSubview:_hudView];
    }
    _hudView.layer.cornerRadius = self.cornerRadius;
    return _hudView;
}
- (UILabel*)statusLabel {
    if(!_statusLabel) {
        _statusLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        _statusLabel.backgroundColor = [UIColor clearColor];
        _statusLabel.adjustsFontSizeToFitWidth = YES;
        _statusLabel.textAlignment = NSTextAlignmentCenter;
        _statusLabel.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        _statusLabel.numberOfLines = 0;
    }
    if(!_statusLabel.superview) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
      [self.hudView.contentView addSubview:_statusLabel];
#else
      [self.hudView addSubview:_statusLabel];
#endif
    }
    _statusLabel.textColor = self.foregroundColorForStyle;
    _statusLabel.font = self.font;
    return _statusLabel;
}
- (UIImageView*)imageView {
    if(_imageView && !CGSizeEqualToSize(_imageView.bounds.size, _imageViewSize)) {
        [_imageView removeFromSuperview];
        _imageView = nil;
    }
    if(!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, _imageViewSize.width, _imageViewSize.height)];
    }
    if(!_imageView.superview) {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
        [self.hudView.contentView addSubview:_imageView];
#else
        [self.hudView addSubview:_imageView];
#endif
    }
    return _imageView;
}
#pragma mark - Helper
- (CGFloat)visibleKeyboardHeight {
#if !defined(SV_APP_EXTENSIONS)
    UIWindow *keyboardWindow = nil;
    for (UIWindow *testWindow in UIApplication.sharedApplication.windows) {
        if(![testWindow.class isEqual:UIWindow.class]) {
            keyboardWindow = testWindow;
            break;
        }
    }
    for (__strong UIView *possibleKeyboard in keyboardWindow.subviews) {
        NSString *viewName = NSStringFromClass(possibleKeyboard.class);
        if([viewName hasPrefix:@"UI"]){
            if([viewName hasSuffix:@"PeripheralHostView"] || [viewName hasSuffix:@"Keyboard"]){
                return CGRectGetHeight(possibleKeyboard.bounds);
            } else if ([viewName hasSuffix:@"InputSetContainerView"]){
                for (__strong UIView *possibleKeyboardSubview in possibleKeyboard.subviews) {
                    viewName = NSStringFromClass(possibleKeyboardSubview.class);
                    if([viewName hasPrefix:@"UI"] && [viewName hasSuffix:@"InputSetHostView"]) {
                        return CGRectGetHeight(possibleKeyboardSubview.bounds);
                    }
                }
            }
        }
    }
#endif
    return 0;
}
- (UIWindow *)frontWindow {
#if !defined(SV_APP_EXTENSIONS)
    NSEnumerator *frontToBackWindows = [UIApplication.sharedApplication.windows reverseObjectEnumerator];
    for (UIWindow *window in frontToBackWindows) {
        BOOL windowOnMainScreen = window.screen == UIScreen.mainScreen;
        BOOL windowIsVisible = !window.hidden && window.alpha > 0;
        BOOL windowLevelSupported = (window.windowLevel >= UIWindowLevelNormal && window.windowLevel <= self.maxSupportedWindowLevel);
        BOOL windowKeyWindow = window.isKeyWindow;
        if(windowOnMainScreen && windowIsVisible && windowLevelSupported && windowKeyWindow) {
            return window;
        }
    }
#endif
    return nil;
}
- (void)fadeInEffects {
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if(self.defaultStyle != SVProgressHUDStyleCustom) {
        UIBlurEffectStyle blurEffectStyle = self.defaultStyle == SVProgressHUDStyleDark ? UIBlurEffectStyleDark : UIBlurEffectStyleLight;
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:blurEffectStyle];
        self.hudView.effect = blurEffect;
        self.hudView.backgroundColor = [self.backgroundColorForStyle colorWithAlphaComponent:0.6f];
    } else {
        self.hudView.backgroundColor =  self.backgroundColorForStyle;
    }
#else
    self.hudView.backgroundColor =  self.backgroundColorForStyle;
#endif
    self.backgroundView.alpha = 1.0f;
    self.imageView.alpha = 1.0f;
    self.statusLabel.alpha = 1.0f;
    self.indefiniteAnimatedView.alpha = 1.0f;
    self.ringView.alpha = self.backgroundRingView.alpha = 1.0f;
}
- (void)fadeOutEffects
{
#if __IPHONE_OS_VERSION_MAX_ALLOWED >= 80000
    if(self.defaultStyle != SVProgressHUDStyleCustom) {
        self.hudView.effect = nil;
    }
#endif
    self.hudView.backgroundColor = [UIColor clearColor];
    self.backgroundView.alpha = 0.0f;
    self.imageView.alpha = 0.0f;
    self.statusLabel.alpha = 0.0f;
    self.indefiniteAnimatedView.alpha = 0.0f;
    self.ringView.alpha = self.backgroundRingView.alpha = 0.0f;
}
#if TARGET_OS_IOS && __IPHONE_OS_VERSION_MAX_ALLOWED >= 100000
- (UINotificationFeedbackGenerator *)hapticGenerator {
	if(!self.hapticsEnabled) {
		return nil;
	}
	if(!_hapticGenerator) {
		_hapticGenerator = [[UINotificationFeedbackGenerator alloc] init];
	}
	return _hapticGenerator;
}
#endif
#pragma mark - UIAppearance Setters
- (void)setDefaultStyle:(SVProgressHUDStyle)style {
    if (!_isInitializing) _defaultStyle = style;
}
- (void)setDefaultMaskType:(SVProgressHUDMaskType)maskType {
    if (!_isInitializing) _defaultMaskType = maskType;
}
- (void)setDefaultAnimationType:(SVProgressHUDAnimationType)animationType {
    if (!_isInitializing) _defaultAnimationType = animationType;
}
- (void)setContainerView:(UIView *)containerView {
    if (!_isInitializing) _containerView = containerView;
}
- (void)setMinimumSize:(CGSize)minimumSize {
    if (!_isInitializing) _minimumSize = minimumSize;
}
- (void)setRingThickness:(CGFloat)ringThickness {
    if (!_isInitializing) _ringThickness = ringThickness;
}
- (void)setRingRadius:(CGFloat)ringRadius {
    if (!_isInitializing) _ringRadius = ringRadius;
}
- (void)setRingNoTextRadius:(CGFloat)ringNoTextRadius {
    if (!_isInitializing) _ringNoTextRadius = ringNoTextRadius;
}
- (void)setCornerRadius:(CGFloat)cornerRadius {
    if (!_isInitializing) _cornerRadius = cornerRadius;
}
- (void)setFont:(UIFont*)font {
    if (!_isInitializing) _font = font;
}
- (void)setForegroundColor:(UIColor*)color {
    if (!_isInitializing) _foregroundColor = color;
}
- (void)setBackgroundColor:(UIColor*)color {
    if (!_isInitializing) _backgroundColor = color;
}
- (void)setBackgroundLayerColor:(UIColor*)color {
    if (!_isInitializing) _backgroundLayerColor = color;
}
- (void)setInfoImage:(UIImage*)image {
    if (!_isInitializing) _infoImage = image;
}
- (void)setSuccessImage:(UIImage*)image {
    if (!_isInitializing) _successImage = image;
}
- (void)setErrorImage:(UIImage*)image {
    if (!_isInitializing) _errorImage = image;
}
- (void)setViewForExtension:(UIView*)view {
    if (!_isInitializing) _viewForExtension = view;
}
- (void)setOffsetFromCenter:(UIOffset)offset {
    if (!_isInitializing) _offsetFromCenter = offset;
}
- (void)setMinimumDismissTimeInterval:(NSTimeInterval)minimumDismissTimeInterval {
    if (!_isInitializing) _minimumDismissTimeInterval = minimumDismissTimeInterval;
}
- (void)setFadeInAnimationDuration:(NSTimeInterval)duration {
    if (!_isInitializing) _fadeInAnimationDuration = duration;
}
- (void)setFadeOutAnimationDuration:(NSTimeInterval)duration {
    if (!_isInitializing) _fadeOutAnimationDuration = duration;
}
- (void)setMaxSupportedWindowLevel:(UIWindowLevel)maxSupportedWindowLevel {
    if (!_isInitializing) _maxSupportedWindowLevel = maxSupportedWindowLevel;
}
@end
