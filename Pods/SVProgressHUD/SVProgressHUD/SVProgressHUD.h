#import <UIKit/UIKit.h>
#import <AvailabilityMacros.h>
#if __IPHONE_OS_VERSION_MAX_ALLOWED < 70000
#define UI_APPEARANCE_SELECTOR
#endif
extern NSString * _Nonnull const SVProgressHUDDidReceiveTouchEventNotification;
extern NSString * _Nonnull const SVProgressHUDDidTouchDownInsideNotification;
extern NSString * _Nonnull const SVProgressHUDWillDisappearNotification;
extern NSString * _Nonnull const SVProgressHUDDidDisappearNotification;
extern NSString * _Nonnull const SVProgressHUDWillAppearNotification;
extern NSString * _Nonnull const SVProgressHUDDidAppearNotification;
extern NSString * _Nonnull const SVProgressHUDStatusUserInfoKey;
typedef NS_ENUM(NSInteger, SVProgressHUDStyle) {
    SVProgressHUDStyleLight,        
    SVProgressHUDStyleDark,         
    SVProgressHUDStyleCustom        
};
typedef NS_ENUM(NSUInteger, SVProgressHUDMaskType) {
    SVProgressHUDMaskTypeNone = 1,  
    SVProgressHUDMaskTypeClear,     
    SVProgressHUDMaskTypeBlack,     
    SVProgressHUDMaskTypeGradient,  
    SVProgressHUDMaskTypeCustom     
};
typedef NS_ENUM(NSUInteger, SVProgressHUDAnimationType) {
    SVProgressHUDAnimationTypeFlat,     
    SVProgressHUDAnimationTypeNative    
};
typedef void (^SVProgressHUDShowCompletion)(void);
typedef void (^SVProgressHUDDismissCompletion)(void);
@interface SVProgressHUD : UIView
#pragma mark - Customization
@property (assign, nonatomic) SVProgressHUDStyle defaultStyle UI_APPEARANCE_SELECTOR;                   
@property (assign, nonatomic) SVProgressHUDMaskType defaultMaskType UI_APPEARANCE_SELECTOR;             
@property (assign, nonatomic) SVProgressHUDAnimationType defaultAnimationType UI_APPEARANCE_SELECTOR;   
@property (strong, nonatomic, nullable) UIView *containerView;                              
@property (assign, nonatomic) CGSize minimumSize UI_APPEARANCE_SELECTOR;                    
@property (assign, nonatomic) CGFloat ringThickness UI_APPEARANCE_SELECTOR;                 
@property (assign, nonatomic) CGFloat ringRadius UI_APPEARANCE_SELECTOR;                    
@property (assign, nonatomic) CGFloat ringNoTextRadius UI_APPEARANCE_SELECTOR;              
@property (assign, nonatomic) CGFloat cornerRadius UI_APPEARANCE_SELECTOR;                  
@property (strong, nonatomic, nonnull) UIFont *font UI_APPEARANCE_SELECTOR;                 
@property (strong, nonatomic, nonnull) UIColor *backgroundColor UI_APPEARANCE_SELECTOR;     
@property (strong, nonatomic, nonnull) UIColor *foregroundColor UI_APPEARANCE_SELECTOR;     
@property (strong, nonatomic, nonnull) UIColor *backgroundLayerColor UI_APPEARANCE_SELECTOR;
@property (assign, nonatomic) CGSize imageViewSize UI_APPEARANCE_SELECTOR;                  
@property (strong, nonatomic, nonnull) UIImage *infoImage UI_APPEARANCE_SELECTOR;           
@property (strong, nonatomic, nonnull) UIImage *successImage UI_APPEARANCE_SELECTOR;        
@property (strong, nonatomic, nonnull) UIImage *errorImage UI_APPEARANCE_SELECTOR;          
@property (strong, nonatomic, nonnull) UIView *viewForExtension UI_APPEARANCE_SELECTOR;     
@property (assign, nonatomic) NSTimeInterval graceTimeInterval;                             
@property (assign, nonatomic) NSTimeInterval minimumDismissTimeInterval;                    
@property (assign, nonatomic) NSTimeInterval maximumDismissTimeInterval;                    
@property (assign, nonatomic) UIOffset offsetFromCenter UI_APPEARANCE_SELECTOR; 
@property (assign, nonatomic) NSTimeInterval fadeInAnimationDuration UI_APPEARANCE_SELECTOR;    
@property (assign, nonatomic) NSTimeInterval fadeOutAnimationDuration UI_APPEARANCE_SELECTOR;   
@property (assign, nonatomic) UIWindowLevel maxSupportedWindowLevel; 
@property (assign, nonatomic) BOOL hapticsEnabled;	
+ (void)setDefaultStyle:(SVProgressHUDStyle)style;                  
+ (void)setDefaultMaskType:(SVProgressHUDMaskType)maskType;         
+ (void)setDefaultAnimationType:(SVProgressHUDAnimationType)type;   
+ (void)setContainerView:(nullable UIView*)containerView;           
+ (void)setMinimumSize:(CGSize)minimumSize;                         
+ (void)setRingThickness:(CGFloat)ringThickness;                    
+ (void)setRingRadius:(CGFloat)radius;                              
+ (void)setRingNoTextRadius:(CGFloat)radius;                        
+ (void)setCornerRadius:(CGFloat)cornerRadius;                      
+ (void)setBorderColor:(nonnull UIColor*)color;                     
+ (void)setBorderWidth:(CGFloat)width;                              
+ (void)setFont:(nonnull UIFont*)font;                              
+ (void)setForegroundColor:(nonnull UIColor*)color;                 
+ (void)setBackgroundColor:(nonnull UIColor*)color;                 
+ (void)setBackgroundLayerColor:(nonnull UIColor*)color;            
+ (void)setImageViewSize:(CGSize)size;                              
+ (void)setInfoImage:(nonnull UIImage*)image;                       
+ (void)setSuccessImage:(nonnull UIImage*)image;                    
+ (void)setErrorImage:(nonnull UIImage*)image;                      
+ (void)setViewForExtension:(nonnull UIView*)view;                  
+ (void)setGraceTimeInterval:(NSTimeInterval)interval;              
+ (void)setMinimumDismissTimeInterval:(NSTimeInterval)interval;     
+ (void)setMaximumDismissTimeInterval:(NSTimeInterval)interval;     
+ (void)setFadeInAnimationDuration:(NSTimeInterval)duration;        
+ (void)setFadeOutAnimationDuration:(NSTimeInterval)duration;       
+ (void)setMaxSupportedWindowLevel:(UIWindowLevel)windowLevel;      
+ (void)setHapticsEnabled:(BOOL)hapticsEnabled;						
#pragma mark - Show Methods
+ (void)show;
+ (void)showWithMaskType:(SVProgressHUDMaskType)maskType __attribute__((deprecated("Use show and setDefaultMaskType: instead.")));
+ (void)showWithStatus:(nullable NSString*)status;
+ (void)showWithStatus:(nullable NSString*)status maskType:(SVProgressHUDMaskType)maskType __attribute__((deprecated("Use showWithStatus: and setDefaultMaskType: instead.")));
+ (void)showProgress:(float)progress;
+ (void)showProgress:(float)progress maskType:(SVProgressHUDMaskType)maskType __attribute__((deprecated("Use showProgress: and setDefaultMaskType: instead.")));
+ (void)showProgress:(float)progress status:(nullable NSString*)status;
+ (void)showProgress:(float)progress status:(nullable NSString*)status maskType:(SVProgressHUDMaskType)maskType __attribute__((deprecated("Use showProgress:status: and setDefaultMaskType: instead.")));
+ (void)setStatus:(nullable NSString*)status; 
+ (void)showInfoWithStatus:(nullable NSString*)status;
+ (void)showInfoWithStatus:(nullable NSString*)status maskType:(SVProgressHUDMaskType)maskType __attribute__((deprecated("Use showInfoWithStatus: and setDefaultMaskType: instead.")));
+ (void)showSuccessWithStatus:(nullable NSString*)status;
+ (void)showSuccessWithStatus:(nullable NSString*)status maskType:(SVProgressHUDMaskType)maskType __attribute__((deprecated("Use showSuccessWithStatus: and setDefaultMaskType: instead.")));
+ (void)showErrorWithStatus:(nullable NSString*)status;
+ (void)showErrorWithStatus:(nullable NSString*)status maskType:(SVProgressHUDMaskType)maskType __attribute__((deprecated("Use showErrorWithStatus: and setDefaultMaskType: instead.")));
+ (void)showImage:(nonnull UIImage*)image status:(nullable NSString*)status;
+ (void)showImage:(nonnull UIImage*)image status:(nullable NSString*)status maskType:(SVProgressHUDMaskType)maskType __attribute__((deprecated("Use showImage:status: and setDefaultMaskType: instead.")));
+ (void)setOffsetFromCenter:(UIOffset)offset;
+ (void)resetOffsetFromCenter;
+ (void)dismiss;
+ (void)dismissWithCompletion:(nullable SVProgressHUDDismissCompletion)completion;
+ (void)dismissWithDelay:(NSTimeInterval)delay;
+ (void)dismissWithDelay:(NSTimeInterval)delay completion:(nullable SVProgressHUDDismissCompletion)completion;
+ (BOOL)isVisible;
+ (NSTimeInterval)displayDurationForString:(nullable NSString*)string;
@end
