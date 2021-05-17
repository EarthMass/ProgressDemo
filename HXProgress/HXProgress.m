//
//  HXProgress.m
//  ProgressDemo
//
//  Created by 郭海祥 on 2017/10/11.
//  Copyright © 2017年 ghx. All rights reserved.
//

#import "HXProgress.h"

@interface HXProgress()

@property (nonatomic, assign)  BOOL canShow;

@end


@implementation HXProgress


+ (id)sharedInstance{
    static HXProgress * instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[HXProgress alloc] init];
        instance.canShow = YES;
    });
    return instance;
}

+ (UIView *)currView {
    return [self getCurrentActivityViewController].view;
}

+ (UIViewController *)getCurrentActivityViewController {
    UIWindow *window = [UIApplication sharedApplication].delegate.window;
    NSLog(@"window level: %.0f", window.windowLevel);
    if (window.windowLevel != UIWindowLevelNormal) {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for (UIWindow * tmpWin in windows) {
            if (tmpWin.windowLevel == UIWindowLevelNormal) {
                window = tmpWin;
                break;
            }
        }
    }

    //从根控制器开始查找
    UIViewController *rootVC = window.rootViewController;
    UIViewController *activityVC = nil;

    while (true) {
        if ([rootVC isKindOfClass:[UINavigationController class]]) {
            activityVC = [(UINavigationController *)rootVC visibleViewController];
        } else if ([rootVC isKindOfClass:[UITabBarController class]]) {
            activityVC = [(UITabBarController *)rootVC selectedViewController];
        } else if (rootVC.presentedViewController) {
            activityVC = rootVC.presentedViewController;
        }else {
            break;
        }

        rootVC = activityVC;
    }

    return activityVC;
}


#pragma mark- init
+ (void)initialize {
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
    [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:0.3]];
    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
    
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeClear];
    [CSToastManager setDefaultPosition:CSToastPositionCenter];

}

#pragma mark - Toast
+ (void)setToastPosition:(id)position style:(CSToastStyle *)style isTapDismiss:(BOOL)isTapDismiss {
    
    if ([position isKindOfClass:[NSString class]] || [position isKindOfClass:[NSValue class]]) {
        [CSToastManager setDefaultPosition:position];
    }
    if (style !=nil) {
        [CSToastManager setSharedStyle:style];
    }
    [CSToastManager setTapToDismissEnabled:isTapDismiss];
}

+ (void)showToastWithMsg:(NSString *)msg inView:(UIView *)view {
     [self showToastWithMsg:msg showTime:ShowToastTime inView:view];
}

+ (void)showToastWithMsg:(NSString *)msg {
    [self showToastWithMsg:msg showTime:ShowToastTime inView:[self currView]];
}

+ (void)showToastWithMsg:(NSString *)msg showTime:(CGFloat)showTime inView:(UIView *)view {
    if (msg == nil || msg.length == 0) {
        return;
    }
    if (view == nil) {
        view = [self currView];
    }
    
    if ([[HXProgress sharedInstance] canShow]) {
        [[HXProgress sharedInstance] setCanShow:NO];
        [view makeToast:msg
                          duration:showTime
                          position:[CSToastManager defaultPosition]
                             title:nil
                             image:nil
                             style:nil
                        completion:^(BOOL didTap) {
                            if (didTap) {
                                NSLog(@"completion from tap");
                            } else {
                                NSLog(@"completion without tap");
                            }
                            [[HXProgress sharedInstance] setCanShow:YES];
                        }];
        
    }
}
+ (void)showToastWithMsg:(NSString *)msg title:(NSString *)title image:(UIImage *)image tapBlock:(void(^)(BOOL didTap))tapBlock {
    [self showToastWithMsg:msg title:title image:image tapBlock:tapBlock showTime:ShowToastTime];
}
+ (void)showToastWithMsg:(NSString *)msg title:(NSString *)title image:(UIImage *)image tapBlock:(void(^)(BOOL didTap))tapBlock showTime:(CGFloat)showTime {
    
    if (msg == nil || msg.length == 0) {
        return;
    }
    
    if ([[HXProgress sharedInstance] canShow]) {
        [[HXProgress sharedInstance] setCanShow:NO];
        [[self currView] makeToast:msg
               duration:showTime
               position:[CSToastManager defaultPosition]
                  title:title
                  image:image
                  style:nil
             completion:^(BOOL didTap) {
                 if (didTap) {
                     NSLog(@"completion from tap");
                 } else {
                     NSLog(@"completion without tap");
                 }
                 [[HXProgress sharedInstance] setCanShow:YES];
             }];
        
    }
}
+ (void)showToastWithCustomView:(UIView *)customView {
    [self showToastWithCustomView:customView showTime:ShowToastTime];
}
+ (void)showToastWithCustomView:(UIView *)customView showTime:(CGFloat)showTime {
 
    if ([[HXProgress sharedInstance] canShow]) {
        [[HXProgress sharedInstance] setCanShow:NO];
        [[self currView] showToast:customView duration:showTime position:[CSToastManager defaultPosition] completion:^(BOOL didTap) {
            [[HXProgress sharedInstance] setCanShow:YES];
        }];
    }
}


#pragma mark - ProgressHUD


#pragma mark style
+ (void)setProgressHUDStyle:(void(^)(void))style {
//    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
//    [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:1]];
//    [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
//    
//    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    style();
}

#pragma mark  需要dismiss
+ (void)showHUD {
    
    [SVProgressHUD show];
}

+ (void)showHUDDefault {
    
    [SVProgressHUD showWithStatus:msg];
}

+ (void)showWithStatus:(NSString*)string {
    
    [SVProgressHUD showWithStatus:string];
}

+ (void)showProgress:(CGFloat)progress status:(NSString *)status {
    [SVProgressHUD showProgress:progress status:status];
}


#pragma mark  不需要dismiss
+ (void)showImage:(UIImage*)image status:(NSString*)string {
    
    [SVProgressHUD showImage:image status:string];
}

+ (void)showWithStatus:(NSString*)string duration:(NSTimeInterval)duration {
    
    [SVProgressHUD showWithStatus:msg];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(duration * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [SVProgressHUD dismiss];
    });
}



#pragma mark  dismiss
+ (void)dismissHUD {
    [SVProgressHUD dismiss];
}


+ (void)dismissHUD:(UIImage *)image status:(NSString*)string {
    [SVProgressHUD showImage:image status:string];
    [SVProgressHUD dismissWithDelay:1.0];
}

+ (void)dismissHUD:(UIImage *)image {
    [SVProgressHUD showImage:image status:nil];
    [SVProgressHUD dismissWithDelay:1.0];
}





@end
