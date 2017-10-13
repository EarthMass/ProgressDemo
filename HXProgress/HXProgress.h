//
//  HXProgress.h
//  ProgressDemo
//
//  Created by 郭海祥 on 2017/10/11.
//  Copyright © 2017年 ghx. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <SVProgressHUD/SVProgressHUD.h>
#import <Toast/UIView+Toast.h>


static NSTimeInterval ShowToastTime = 2;

static NSString * msg = @"加载中..."; //hud msg

@interface HXProgress : NSObject

#pragma mark - Toast
/*
 NSString * CSToastPositionTop       = @"CSToastPositionTop";
 NSString * CSToastPositionCenter    = @"CSToastPositionCenter";
 NSString * CSToastPositionBottom    = @"CSToastPositionBottom";
 */


/**
 Toast提示框
 */
+ (void)setToastPosition:(id)position style:(CSToastStyle *)style isTapDismiss:(BOOL)isTapDismiss;
+ (void)showToastWithMsg:(NSString *)msg;
+ (void)showToastWithMsg:(NSString *)msg showTime:(CGFloat)showTime;

+ (void)showToastWithMsg:(NSString *)msg title:(NSString *)title image:(UIImage *)image tapBlock:(void(^)(BOOL didTap))tapBlock;
+ (void)showToastWithMsg:(NSString *)msg title:(NSString *)title image:(UIImage *)image tapBlock:(void(^)(BOOL didTap))tapBlock showTime:(CGFloat)showTime;

+ (void)showToastWithCustomView:(UIView *)customView;
+ (void)showToastWithCustomView:(UIView *)customView showTime:(CGFloat)showTime;


#pragma mark - ProgressHUD
/**
 无文字的HUD
 */
+ (void)showHUD;

/**
 默认文字 加载中...
 */
+ (void)showHUDDefault;

/**
 自定义文字
 
 @param string 文字内容
 */
+ (void)showWithStatus:(NSString*)string;

/**
 自定义文字 自定义消失时间
 
 @param string 文字内容
 @param duration 持续时间
 */
+ (void)showWithStatus:(NSString*)string duration:(NSTimeInterval)duration;

/**
 上传等长时间操作

 @param progress 进度
 @param status 描述
 */
+ (void)showProgress:(CGFloat)progress status:(NSString *)status;

/**
 消失
 */
+ (void)dismissHUD;

+ (void)showImage:(UIImage*)image status:(NSString*)string;

/**
 消失 带图片
 
 @param image 图片
 */
+ (void)dismissHUD:(UIImage *)image;
+ (void)dismissHUD:(UIImage *)image status:(NSString*)string;


+ (void)setProgressHUDStyle:(void(^)(void))style;

@end
