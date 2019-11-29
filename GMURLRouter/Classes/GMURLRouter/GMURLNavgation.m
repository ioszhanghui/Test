//
//  GMURLNavgation.m
//  GMURLRouter
//
//  Created by Gome on 2019/3/4.
//  Copyright © 2019年 Gome. All rights reserved.
//

#import "GMURLNavgation.h"

@implementation GMURLNavgation
GMSingletonM(GMURLNavgation);
/*推入 某一个页面*/
+(void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated{
    if(!viewController){
        NSLog(@"viewController 空对象");
    }else{
        if([viewController isKindOfClass:[UINavigationController class]]){
            [GMURLNavgation setRootViewController:viewController];
        }else{
            UINavigationController * nviController = [[GMURLNavgation sharedGMURLNavgation]getCurrentNaviController];
            if(nviController){
                [nviController pushViewController:viewController animated:animated];
            }else{
                [GMURLNavgation setRootViewController:[[UINavigationController alloc]initWithRootViewController:viewController]];
            }
        }
    }
}

+ (void)presentViewController:(UIViewController *)viewController animated: (BOOL)flag completion:(void (^ __nullable)(void))completion{
    if(!viewController){
        NSLog(@"viewController 空对象");
    }else{
        UIViewController * currentController = [[GMURLNavgation sharedGMURLNavgation]getCurrentViewController];
        if(currentController){
            [currentController presentViewController:viewController animated:flag completion:completion];
        }else{
            [GMURLNavgation setRootViewController:viewController];
        }
    }
}

/** pop掉一层控制器 */
+(void)popViewControllerAnimated:(BOOL)animated{
     UINavigationController * nviController = [GMURLNavgation sharedGMURLNavgation].getCurrentNaviController;
    if (nviController) {
        [nviController popViewControllerAnimated:animated];
    }
}

/*推出 某一个页面*/
+ (void)popTwiceViewControllerAnimated:(BOOL)animated{
    [GMURLNavgation popViewControllerWithTimes:2 animated:animated];
}
/*推出任一级页面*/
+ (void)popViewControllerWithTimes:(NSUInteger)times animated:(BOOL)animated{
    UINavigationController * nviController = [GMURLNavgation sharedGMURLNavgation].getCurrentNaviController;
    if(nviController){
        NSInteger count = nviController.viewControllers.count;
        if(count>times){
            [nviController popToViewController:[nviController.viewControllers objectAtIndex:count-1-times] animated:animated];
        }else{
            NSLog(@"推出页面有问题");
        }
    }
}

+ (void)popToRootViewControllerAnimated:(BOOL)animated{
   UINavigationController * nviController =  [[GMURLNavgation sharedGMURLNavgation]getCurrentNaviController];
    if(nviController){
        [nviController popToRootViewControllerAnimated:animated];
    }
}

/*dismiss 推出页面*/
+ (void)dismissTwiceViewControllerAnimated:(BOOL)flag completion:(void (^ __nullable)(void))completion{
    [GMURLNavgation dismissViewControllerWithTimes:2 animated:flag completion:completion];
}
/*推出任意层级的控制器*/
+ (void)dismissViewControllerWithTimes:(NSUInteger)times animated:(BOOL)flag completion:(void (^ __nullable)(void))completion{
    
    UIViewController * viewController =[[GMURLNavgation sharedGMURLNavgation]getCurrentViewController];
    if(viewController){
        while (times>0) {
            viewController = viewController.presentingViewController;
            times--;
        }
        [viewController dismissViewControllerAnimated:flag completion:completion];
    }
}

/*返回到对应的根控制器*/
+ (void)dismissToRootViewControllerAnimated:(BOOL)flag completion:(void(^ __nullable)(void))completion{
    UIViewController * viewController = [GMURLNavgation sharedGMURLNavgation].getCurrentViewController;
    if (viewController) {
        //当前控制器存在 推出的控制器存在
        while (viewController.presentingViewController) {
            viewController = viewController.presentingViewController;
        }
        [viewController dismissViewControllerAnimated:flag completion:completion];
    }
}

/*返回到对应的控制器*/
+(void)dismissToViewController:(NSString *)className animated:(BOOL)animated completion:(void(^ __nullable)(void))completion{
    UIViewController * viewController = [GMURLNavgation sharedGMURLNavgation].getCurrentViewController;
    if (viewController) {
        //当前控制器存在
        if (NSClassFromString(className)!= nil&&[NSClassFromString(className)isKindOfClass:[UIViewController class]]) {
            while (![viewController isMemberOfClass:NSClassFromString(className)]&&viewController) {
                viewController = viewController.presentingViewController;
            }
            [viewController dismissViewControllerAnimated:animated completion:completion];
        }
    }
}

// 设置为根控制器
+ (void)setRootViewController:(UIViewController *)viewController{
    [GMURLNavgation sharedGMURLNavgation].getApplicationDelegate.window.rootViewController = viewController;
}

/*获取当前的导航控制器*/
-(UINavigationController*)getCurrentNaviController{
    return [self getCurrentViewController].navigationController;
}
/*获取当前控制器*/
-(UIViewController *)getCurrentViewController{
    UIViewController * rootViewController = [self getApplicationDelegate].window.rootViewController;
    return [self getCurrentControllerFrom:rootViewController];
}

/*从一个控制器 当中拿到当前控制器啊*/
-(UIViewController*)getCurrentControllerFrom:(UIViewController*)viewController{

    if([viewController isKindOfClass:[UINavigationController class]]){
        //如果是导航控制器
        UINavigationController * nviController = (UINavigationController*)viewController;
        return [nviController.viewControllers lastObject];
    }else if ([viewController isKindOfClass:[UITabBarController class]]){
        //如果当前控制器是 Tabbar
        UITabBarController * tabbarController =(UITabBarController*)viewController;
        return [self getCurrentControllerFrom:tabbarController.selectedViewController];
    }else if (viewController.presentedViewController != nil){
        //如果当前是 普通的控制器
        return [self getCurrentControllerFrom:viewController.presentedViewController];
    }
    return viewController;
}


-(id<UIApplicationDelegate>)getApplicationDelegate{
    return [UIApplication sharedApplication].delegate;
}
@end
