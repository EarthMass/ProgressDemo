# ProgressDemo
对SVProgressHUD 以及 Toast 二次封装，便于使用

# 效果
![](https://github.com/EarthMass/ProgressDemo/blob/master/HXProgressGif.gif)

# IOS版本 8.0+
# 安装
```
pod 'HXProgressHUD'
```
# 使用
引入 头文件 #import <HXProgress/HXProgress.h>
## Toast使用
```
   [HXProgress showToastWithMsg:@"固定2秒的提示" title:@"标题" image:[UIImage imageNamed:@"LOGO.png"] tapBlock:^(BOOL didTap) {
                        NSLog(@"点击了 Toast");
                    }] ;
```
## ProgressHUD 使用
```
 [HXProgress showWithStatus:@"加载中..."];
```

## 配置

```
//提示框样式
    [HXProgress setProgressHUDStyle:^{
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
        [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:1]];
        [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
        
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];

    }];
    //toast 设置
    CSToastStyle * toastStyle = [[CSToastStyle alloc] initWithDefaultStyle];
    toastStyle.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.8];
    [HXProgress setToastPosition:CSToastPositionCenter style:toastStyle isTapDismiss:NO];

```

* 使用过程中有什么问题，可以联系我 627556038@qq.com
