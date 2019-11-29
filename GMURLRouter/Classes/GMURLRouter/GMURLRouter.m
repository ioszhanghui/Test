//
//  GMURLRouter.m
//  GMURLRouter
//
//  Created by Gome on 2019/3/4.
//  Copyright © 2019年 Gome. All rights reserved.
//

#import "GMURLRouter.h"
#import "GMURLNavgation.h"
#import "GMRouterConfig.h"
#import "UIViewController+GMURLRouter.h"


@interface GMURLRouter()
/*保存 缓存路由数据*/
@property(nonatomic,strong)NSMutableDictionary * cacheConfigDict;
/*保存 模块注册的路由*/
@property(nonatomic,strong)NSMutableDictionary * moduleConfigDict;

@end

@implementation GMURLRouter
GMSingletonM(GMURLRouter);

#pragma mark --------  模块之间方法调用 --------
+ (id)postModuleWithTarget:(NSString*)moduleStr action:(SEL)aSelector withObject:(id)obj callBackBlock:(void (^)(id blockParam))block{
    
    id manager = [[GMURLRouter sharedGMURLRouter].moduleConfigDict objectForKey:moduleStr];
    SEL customSelector = aSelector;
    if (!obj) {
        obj = @"";
    }
    NSAssert1(customSelector, @"不存在方法%@", NSStringFromSelector(aSelector));
    id result;//函数的返回值
    if ([manager respondsToSelector:customSelector]) {
        IMP imp = [manager methodForSelector:customSelector];
        id (*func)(id, SEL ,id ,id) = (void *)imp;
        result = func(manager, customSelector,obj,block);
    }
    return result;
}

#pragma mark --------  根据URL 获取附加 --------
/**
 * 查找谁对某个 URL 感兴趣，如果有的话，返回一个 object
 *
 *  @param URL 带 Scheme，如 mgj://beauty/3
 */
+ (id)objectForURL:(NSString *)URL{
    // 支持对中文字符的编码
    NSString *encodeStr = [GMURLRouter cutOffAllowedCharacters:URL];
    NSURL * urlPattern = [NSURL URLWithString:encodeStr];//转成网络字符串
    NSString * scheme = urlPattern.scheme;//scheme协议
    NSString * host = urlPattern.host==nil? @"":urlPattern.host;//host域
    NSString * path = urlPattern.path==nil? @"":urlPattern.path;//域之后的路径
    NSString * home = nil;//拼接的路径
    if(urlPattern.path == nil){ // 处理url,去掉有可能会拼接的参数
        home = [NSString stringWithFormat:@"%@://%@", scheme, host];
    }else{
        home = [NSString stringWithFormat:@"%@://%@%@",scheme, host,path];
    }
    NSDictionary * routers = [GMURLRouter getAllURLPattern];
    if ([[routers allKeys]containsObject:scheme]) {
        NSDictionary * subRouters = [routers objectForKey:scheme];
        if ([[subRouters allKeys]containsObject:home]) {
            return [NSClassFromString([[subRouters objectForKey:home] objectForKey:GMRouterParamterClass]) new];
        }
    }
    return nil;
}

#pragma mark 取消各个路由

/**
 *  取消注册某个 URL Pattern
 *
 *  @param URLPattern URLPattern
 */
+ (void)deregisterURLPattern:(NSString *)URLPattern{
    [[GMURLRouter sharedGMURLRouter]removeURLPattern:URLPattern];
}

-(void)removeURLPattern:(NSString *)URLPattern{
    // 支持对中文字符的编码
    NSString *encodeStr = [GMURLRouter cutOffAllowedCharacters:URLPattern];
    NSURL * urlPattern = [NSURL URLWithString:encodeStr];//转成网络字符串
    NSString * scheme = urlPattern.scheme;//scheme协议
    NSString * host = urlPattern.host==nil? @"":urlPattern.host;//host域
    NSString * path = urlPattern.path==nil? @"":urlPattern.path;//域之后的路径
    NSString * home = nil;//拼接的路径
    if(urlPattern.path == nil){ // 处理url,去掉有可能会拼接的参数
        home = [NSString stringWithFormat:@"%@://%@", scheme, host];
    }else{
        home = [NSString stringWithFormat:@"%@://%@%@",scheme, host,path];
    }
    NSMutableDictionary * routers = self.cacheConfigDict;
    if ([[routers allKeys]containsObject:scheme]) {
        //如果包含当前scheme的 删除 当前home的 路由配置
        NSMutableDictionary * subRouters = [routers objectForKey:scheme];
        [subRouters removeObjectForKey:home];
    }
}

/**
 *  取消所有的路由 URL Pattern
 */
+ (void)deregisterAllURLPattern{
    //移除所有的路由配置
    [[GMURLRouter sharedGMURLRouter].cacheConfigDict removeAllObjects];
}

#pragma mark 注册各个路由
/**
 *  注册 URLPattern 对应的 Handler，在 handler 中可以初始化 VC，然后对 VC 做各种操作
 *  @param URLPattern URLPattern
 *  @param routerclass routerclass 路由的类
 */

+ (void)registerURLPattern:(NSString *)URLPattern class:(NSString*)routerclass{
    [[GMURLRouter sharedGMURLRouter]addURLPattern:URLPattern class:routerclass];
}

- (void)addURLPattern:(NSString *)URLPattern class:(NSString*)class{
    NSMutableDictionary *subRoutes = [self addURLPattern:URLPattern];
    if (class !=nil) {
        subRoutes[GMRouterParamterClass] = class;
    }
}

/*获取所有注册URLPattern*/
+(NSDictionary*)getAllURLPattern{
   return [GMURLRouter sharedGMURLRouter].cacheConfigDict;
}

/*获取所有注册的模块*/
+(NSDictionary*)getAllRegisteredModule{
    return [GMURLRouter sharedGMURLRouter].moduleConfigDict;
}
/*对字符串进行编码*/
+(NSString*)cutOffAllowedCharacters:(NSString*)originString{
    
  return  [originString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]];
}

-(NSMutableDictionary*)addURLPattern:(NSString*)URLPattern{
    // 支持对中文字符的编码
    NSString *encodeStr = [GMURLRouter cutOffAllowedCharacters:URLPattern];
    NSURL * urlPattern = [NSURL URLWithString:encodeStr];//转成网络字符串
    NSString * scheme = urlPattern.scheme;//scheme协议
    NSString * host = urlPattern.host==nil? @"":urlPattern.host;//host域
    NSString * path = urlPattern.path==nil? @"":urlPattern.path;//域之后的路径
    NSString * home = nil;//拼接的路径
    if(urlPattern.path == nil){ // 处理url,去掉有可能会拼接的参数
        home = [NSString stringWithFormat:@"%@://%@", scheme, host];
    }else{
        home = [NSString stringWithFormat:@"%@://%@%@",scheme, host,path];
    }
    NSMutableDictionary * routerDictionary = self.cacheConfigDict;
   
    if ([[routerDictionary allKeys]containsObject:scheme]) {
        //是否包含当前域
        routerDictionary = [routerDictionary objectForKey:scheme];//取出当前scheme的路径地址
        if (![[routerDictionary allKeys]containsObject:home]) {
            //没有存储过
            routerDictionary[home] = [NSMutableDictionary dictionary];
            routerDictionary = routerDictionary[home];
        }else{
            /*已经包含了 当前路径*/
            routerDictionary = routerDictionary[home];
        }
    }else{
        //当前不包含这个scheme
        routerDictionary[scheme] = [NSMutableDictionary dictionary];
        routerDictionary = routerDictionary[scheme];//s给scheme设置一组数据
        
        routerDictionary[home] = [NSMutableDictionary dictionary];
        routerDictionary = routerDictionary[home];
    }
    //存储路径 不包含参数
    routerDictionary[GMRouterParamterPath] = home;
    //存储 原始路径
    routerDictionary[GMRouterParamterOriginUrl] = URLPattern;
    return routerDictionary;
}

-(void)registerModules:(NSArray*)moduleArray{
    if (moduleArray) {
        for(NSString * moduleName in moduleArray){
            //保存注册的模块
            [self.moduleConfigDict setObject:createModule(moduleName) forKey:moduleName];
            //调用注册的 路由方法
            registerUrlwithModuleString(moduleName);
        }
    }
}

#pragma warning
static void registerUrlwithModuleString(NSString *moduleString) {
    Class class = NSClassFromString(moduleString);
    SEL sel = NSSelectorFromString(@"registerURL");
    IMP imp = [class methodForSelector:sel];
    if (imp) {
        void (*func)(id, SEL) = (void *)imp;
        func(class, sel);
    }
}
static id createModule(NSString *moduleString) {
    Class class = NSClassFromString(moduleString);
    id module = [[class alloc]init];
    return module;
}

/*获取当前控制器*/
-(UIViewController*)getCurrentController{
    return [[GMURLNavgation sharedGMURLNavgation]getCurrentViewController];
}
/*获取当前的导航控制器*/
-(UINavigationController*)getCurrentNaviController{
    return [GMURLNavgation sharedGMURLNavgation].getCurrentNaviController;
}

/*导航push*/
+(void)pushViewController:(UIViewController*)VC Animated:(BOOL)animated{
    [GMURLNavgation pushViewController:VC animated:animated];
}
/*导航push 传递一个 控制器名字*/
+(void)pushViewControllerWithName:(NSString*)VCName Animated:(BOOL)animated{
    [GMURLRouter pushViewController:[NSClassFromString(VCName) new] Animated:animated];
}

/**
 *  push控制器
 *
 *  @param urlString 自定义URL,也可以拼接参数,但会被下面的query替换掉
 *  @param query     存放参数
 *  @param completion   存放回调
 */
+ (void)pushURLString:(NSString *)urlString query:(NSDictionary *)query animated:(BOOL)animated completion:(void (^)(id result))completion{
    UIViewController * viewController = [UIViewController initFromString:urlString withQuery:query fromConfig:[GMURLRouter sharedGMURLRouter].cacheConfigDict];
    //拿到回调
//    NSMutableDictionary * subRouters = [[GMURLRouter sharedGMURLRouter]addURLPattern:urlString];
//    GMRouterHandler completionHandler = [subRouters objectForKey:GMRouterParmterCompletion];
//    completionHandler(subRouters[GMRouterParamterParams]);
    [GMURLNavgation pushViewController:viewController animated:animated];
}

/**
 *  modal控制器
 *
 *  @param urlString 自定义URL,也可以拼接参数,但会被下面的query替换掉
 *  @param query     存放参数
 */
+ (void)presentURLString:(NSString *)urlString query:(NSDictionary *)query animated:(BOOL)animated completion:(void (^ __nullable)(void))completion{
    UIViewController * viewController = [UIViewController initFromString:urlString withQuery:query fromConfig:[GMURLRouter sharedGMURLRouter].cacheConfigDict];
    [GMURLRouter presentViewController:viewController animated:animated completion:completion];
}

/** pop掉一层控制器 */
+(void)popViewControllerAnimated:(BOOL)animated{
    [GMURLNavgation popViewControllerAnimated:animated];
}
/** pop掉两层控制器 */
+(void)popTwiceViewControllerAnimated:(BOOL)animated{
    [GMURLNavgation popViewControllerWithTimes:2 animated:animated];
}
/** pop掉times层控制器 */
+(void)popViewControllerWithTimes:(NSUInteger)times animated:(BOOL)animated{
    [GMURLNavgation popViewControllerWithTimes:times animated:animated];
}
/** pop到根层控制器 */
+(void)popToRootViewControllerAnimated:(BOOL)animated{
    [GMURLNavgation popToRootViewControllerAnimated:animated];
}

#pragma mark --------  modal控制器 --------
+ (void)presentViewController:(UIViewController *)viewControllerToPresent animated:(BOOL)flag completion:(void (^ __nullable)(void))completion{
    [GMURLNavgation presentViewController:viewControllerToPresent animated:flag completion:completion];
}

/**
 *  modal控制器
 *
 *  @param VCName 目标控制器名字
 */
+ (void)presentViewControllerWithName:(NSString *)VCName animated:(BOOL)flag completion:(void (^ __nullable)(void))completion{
    [GMURLNavgation presentViewController:[NSClassFromString(VCName) new] animated:flag completion:completion];
}

#pragma mark --------  dismiss控制器 --------
/** dismiss掉1层控制器 */
+ (void)dismissViewControllerAnimated:(BOOL)flag completion: (void (^ __nullable)(void))completion{
    [GMURLNavgation dismissViewControllerWithTimes:1 animated:flag completion:completion];
}
/** dismiss掉2层控制器 */
+ (void)dismissTwiceViewControllerAnimated: (BOOL)flag completion: (void (^ __nullable)(void))completion{
    [GMURLNavgation dismissTwiceViewControllerAnimated:flag completion:completion];
}
/** dismiss掉times层控制器 */
+ (void)dismissViewControllerWithTimes:(NSUInteger)times animated: (BOOL)flag completion: (void (^ __nullable)(void))completion{
    [GMURLNavgation dismissViewControllerWithTimes:times animated:flag completion:completion];
}
/** dismiss到根层控制器 */
+ (void)dismissToRootViewControllerAnimated:(BOOL)flag completion: (void (^ __nullable)(void))completion{
    [GMURLRouter dismissToRootViewControllerAnimated:flag completion:completion];
}
/*返回到对应的控制器*/
+(void)dismissToViewController:(NSString *)className animated:(BOOL)animated completion:(void(^ __nullable)(void))completion{
    [GMURLNavgation dismissToViewController:className animated:animated completion:completion];
}

/*保存配置的路由路径*/
-(NSMutableDictionary*)cacheConfigDict{
    if (!_cacheConfigDict) {
        _cacheConfigDict = [NSMutableDictionary dictionary];
    }
    return _cacheConfigDict;
}

/*保存 模块注册的路由*/
-(NSMutableDictionary*)moduleConfigDict{
    if (!_moduleConfigDict) {
        _moduleConfigDict = [NSMutableDictionary dictionary];
    }
    return _moduleConfigDict;
}
@end
