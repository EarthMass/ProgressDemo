#import "AppDelegate.h"
#import "ViewController.h"
#import "HXProgress.h"
@interface AppDelegate ()
@end
@implementation AppDelegate
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[UIScreen mainScreen].bounds];
    ViewController * viewC = [[ ViewController alloc] init];
    UINavigationController * nav = [[UINavigationController alloc] initWithRootViewController:viewC];
    [self.window setRootViewController:nav];
    [self.window makeKeyAndVisible];
    [HXProgress setProgressHUDStyle:^{
        [SVProgressHUD setDefaultStyle:SVProgressHUDStyleCustom];
        [SVProgressHUD setBackgroundColor:[UIColor colorWithWhite:0.0 alpha:1]];
        [SVProgressHUD setForegroundColor:[UIColor whiteColor]];
        [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeNone];
    }];
    CSToastStyle * toastStyle = [[CSToastStyle alloc] initWithDefaultStyle];
    toastStyle.backgroundColor = [[UIColor redColor] colorWithAlphaComponent:0.8];
    [HXProgress setToastPosition:CSToastPositionCenter style:toastStyle isTapDismiss:NO];
    return YES;
}
- (void)applicationWillResignActive:(UIApplication *)application {
}
- (void)applicationDidEnterBackground:(UIApplication *)application {
}
- (void)applicationWillEnterForeground:(UIApplication *)application {
}
- (void)applicationDidBecomeActive:(UIApplication *)application {
}
- (void)applicationWillTerminate:(UIApplication *)application {
}
@end
