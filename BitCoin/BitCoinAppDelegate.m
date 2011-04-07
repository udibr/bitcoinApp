//
//  BitCoinAppDelegate.m
//  BitCoin
//
//  Created by Ehud Ben-Reuven on 2/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "BitCoinAppDelegate.h"

#import "LauncherViewTestController.h"
#import "RPCCommandViewController.h"

extern int bitcoinmain(int argc, char* argv[]);

@implementation BitCoinAppDelegate
/**
 Returns the path to the application's documents directory.
 */
//http://stackoverflow.com/questions/2094376/create-subfolder-in-nsdocumentdirectory
//NSDocumentDirectory - Analogous to you own Documents folder, the contents of this folder is backed up when you synch the device.
//NSCachesDirectory - This one resides in /Library/Caches/ and is not backed up when synching the device.
- (NSString *)applicationDocumentsDirectory {
	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    //int fd[2];
    //pipe(fd);
    //int fd0=fd[0];
    //int fd1=fd[1];
    
    NSString *confPath = [[NSBundle mainBundle] pathForResource:@"bitcoin" ofType:@"conf"]; // resourcePath];
    serialQueue = dispatch_queue_create("BITCOIND",NULL);
    dispatch_async(serialQueue,^{
        //dup2(fd1, stderr);
#define MAXARGC    30
        int argc=0;
        char *argv[MAXARGC];
        argv[0] = "bitcoind";
        argc++;
        argv[1] = (char*)[[NSString stringWithFormat:@"-datadir=%@",[self applicationDocumentsDirectory]] cString];
        argc++;
        argv[2] = (char*)[[NSString stringWithFormat:@"-conf=%@",confPath] cString];
        argc++;
        argv[3] = "-printtoconsole";
        argc++;
        TTDPRINT(@"starting bitcoin thread");

        bitcoinmain(argc,argv);
    });
#if 0
    logQueue = dispatch_queue_create("LOGD",NULL);
    dispatch_async(logQueue,^{
        NSLog(@"starting log thread");
        
        char buffer[1024];
        while (read(fd0, buffer, 1024) >= 0) {
         //   NSLog(@"%s", buffer); 
        }
    });
#endif
    
    
	// configure ttnavigator
	TTNavigator* navigator = [TTNavigator navigator];
	navigator.supportsShakeToReload = YES;
	navigator.persistenceMode = TTNavigatorPersistenceModeAll;
    navigator.window = [[[UIWindow alloc] initWithFrame:TTScreenBounds()] autorelease];
    
	// !!! IMPORTANT: create urlmaps !!!
	TTURLMap* map = navigator.URLMap;
    
    // Any URL that doesn't match will fall back on this one, and open in the web browser
    [map from:@"*" toViewController:[TTWebController class]];
	[map from:@"bitcoin://rpccommand/(initWithCommand:)" toViewController:[RPCCommandViewController class]];
    [map from:@"bitcoin://launcher" toSharedViewController: [LauncherViewTestController class]];

    
    if (![navigator restoreViewControllers])
        [navigator openURLAction:[TTURLAction actionWithURLPath:@"bitcoin://launcher"]];

    return YES;
}

- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)URL {
    [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:URL.absoluteString]];
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
     */
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    /*
     Called when the application is about to terminate.
     Save data if appropriate.
     See also applicationDidEnterBackground:.
     */
}

- (void)dealloc
{
    if (serialQueue) {
		dispatch_release(serialQueue);
		serialQueue=NULL;
	}

    [super dealloc];
}

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController
{
}
*/

/*
// Optional UITabBarControllerDelegate method.
- (void)tabBarController:(UITabBarController *)tabBarController didEndCustomizingViewControllers:(NSArray *)viewControllers changed:(BOOL)changed
{
}
*/

@end
