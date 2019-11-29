//
//  GMURLNavgation.h
//  GMURLRouter
//
//  Created by Gome on 2019/3/4.
//  Copyright © 2019年 Gome. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "GMSingleton.h"
#import <UIKit/UIKit.h>

@interface GMURLNavgation : NSObject
GMSingletonH(GMURLNavgation);

/*获取当前的控制器*/
-(UIViewController*)getCurrentViewController;
/*获取当前的导航控制器*/
-(UINavigationController*)getCurrentNaviController;

/*推入 某一个页面*/
+ (void)pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
+ (void)presentViewController:(UIViewController *)viewController animated: (BOOL)flag completion:(void (^ __nullable)(void))completion;

/*推出 某一个页面*/
/** pop掉一层控制器 */
+(void)popViewControllerAnimated:(BOOL)animated;
+ (void)popTwiceViewControllerAnimated:(BOOL)animated;
+ (void)popViewControllerWithTimes:(NSUInteger)times animated:(BOOL)animated;
+ (void)popToRootViewControllerAnimated:(BOOL)animated;

/*dismiss 推出页面*/
+ (void)dismissTwiceViewControllerAnimated: (BOOL)flag completion: (void (^ __nullable)(void))completion;
/**/
+ (void)dismissViewControllerWithTimes:(NSUInteger)times animated: (BOOL)flag completion: (void (^ __nullable)(void))completion;
/*返回到对应的根控制器*/
+ (void)dismissToRootViewControllerAnimated: (BOOL)flag completion: (void (^ __nullable)(void))completion;
/*返回到对应的控制器*/
+(void)dismissToViewController:(NSString *)className animated:(BOOL)animated completion:(void(^ __nullable)(void))completion;

@end
