//
//  AppDelegate.m
//  OpenGL001
//
//  Created by 钟凡 on 2020/12/11.
//

#import "AppDelegate.h"
#import "OpenGLViewController.h"


@interface AppDelegate ()


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    _window = [[UIWindow alloc] initWithFrame:UIScreen.mainScreen.bounds];
    [_window makeKeyAndVisible];
    _window.rootViewController = [[OpenGLViewController alloc] init];
    return YES;
}


@end
