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
#import "SendViewController.h"
#import "AboutViewController.h"
#import "RPCModel.h"
#import "PageViewController.h"
#import "ConsoleViewController.h"
#import "Unzip.h"
#import "StyleSheet.h"
#import "BackupViewController.h"
#import "BCFileSystem.h"
#import "ContactUsViewController.h"
#import "BitCoinLoginViewController.h"
#import "MyAddressViewController.h"
#import "BalanceViewController.h"
#import "PasswordViewController.h"
#import "BitCoinSettings.h"
extern int bitcoinmain(int argc, char* argv[]);

@implementation BitCoinAppDelegate
@synthesize model;
@synthesize backupURL;
@synthesize daemonRunning;
@synthesize backgroundTaskIdentifier;
/**
 Returns the path to the application's documents directory.
 */
//http://stackoverflow.com/questions/2094376/create-subfolder-in-nsdocumentdirectory
//NSDocumentDirectory - Analogous to you own Documents folder, the contents of this folder is backed up when you synch the device.
//NSCachesDirectory - This one resides in /Library/Caches/ and is not backed up when synching the device.
-(void)startDaemon:(BOOL)rescan
{
    if (!serialQueue) {
        // start bitcoin daemon on a different thread
        serialQueue = dispatch_queue_create("BITCOIND",NULL);
    }
    
    NSString* documentsDir=applicationDocumentsDirectory();
    
    NSString *storedDBconfPath = [[NSBundle mainBundle] pathForResource:@"DB_CONFIG" ofType:@""];
    if (storedDBconfPath) {
        NSString* dbconfPath = [documentsDir stringByAppendingPathComponent:@"DB_CONFIG"];
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        if ([fileMgr fileExistsAtPath:storedDBconfPath]) {
            NSError* error;
            if ([fileMgr fileExistsAtPath:dbconfPath]) {
                if ([fileMgr removeItemAtPath:dbconfPath error:&error] != YES)
                    TTDPRINT(@"Unable to remove DB_CONFIG: %@", [error localizedDescription]);
            }
            if ([fileMgr copyItemAtPath:storedDBconfPath toPath:dbconfPath error:&error] != YES)
                TTDPRINT(@"Unable to copy DB_CONFIG: %@", [error localizedDescription]);
        }
    }
    
    // On first run, copy blocks stored in the package
    NSString *storedBlkPath = [[NSBundle mainBundle] pathForResource:@"blkindex.dat" ofType:@"gz"];
    NSString *storedBlk1Path = [[NSBundle mainBundle] pathForResource:@"blk0001.dat" ofType:@"gz"];
#if TARGET_IPHONE_SIMULATOR
    storedBlkPath = @"/tmp/blkindex.dat.gz";
    storedBlk1Path = @"/tmp/blk0001.dat.gz";
#endif
    if (storedBlkPath && storedBlk1Path) {
        NSString* blkPath = [documentsDir stringByAppendingPathComponent:@"blkindex.dat"];
        TTDPRINT(@"blkPath=%@", blkPath);
        NSString* blk1Path = [documentsDir stringByAppendingPathComponent:@"blk0001.dat"];
        NSFileManager *fileMgr = [NSFileManager defaultManager];
        if ([fileMgr fileExistsAtPath:storedBlkPath] &&
            [fileMgr fileExistsAtPath:storedBlk1Path] &&
            ![fileMgr fileExistsAtPath:blkPath] &&
            ![fileMgr fileExistsAtPath:blk1Path]) {
#if 0
            NSError* error;
            if ([fileMgr copyItemAtPath:storedBlkPath toPath:blkPath error:&error] != YES)
                TTDPRINT(@"Unable to copy blkindex: %@", [error localizedDescription]);
            if ([fileMgr copyItemAtPath:storedBlk1Path toPath:blk1Path error:&error] != YES)
                TTDPRINT(@"Unable to copy blk1index: %@", [error localizedDescription]);
#endif
            dispatch_async(serialQueue,^{
                Unzip(storedBlkPath, blkPath);
                Unzip(storedBlk1Path, blk1Path);
            });
            rescan = YES;
        }
    }
    
    // run the bitcoin daemon
    self.daemonRunning = kDaemonRunning;
    NSString *confPath = [[NSBundle mainBundle] pathForResource:@"bitcoin" ofType:@"conf"]; // resourcePath];
    dispatch_async(serialQueue,^{
        //dup2(fd1, stderr);
#define MAXARGC    30
        int argc=0;
        char *argv[MAXARGC];
        argv[argc] = "bitcoind";
        argc++;
        argv[argc] = (char*)[[NSString stringWithFormat:@"-datadir=%@",documentsDir] cString];
        argc++;
        argv[argc] = (char*)[[NSString stringWithFormat:@"-conf=%@",confPath] cString];
        argc++;
        argv[argc] = "-printtoconsole";
        argc++;
        argv[argc] = "-nolisten";
        argc++;
        if (rescan) {
            argv[argc] = "-rescan";
            argc++;
        }
        TTDPRINT(@"starting bitcoin thread");
        
        bitcoinmain(argc,argv);
        
        //If we are running in the background and managed to stop the daemon then notify OS that it can kill the App.
        if (backgroundTaskIdentifier != UIBackgroundTaskInvalid) {
            [[UIApplication sharedApplication] endBackgroundTask:self.backgroundTaskIdentifier];
        } else if (self.daemonRunning == kDaemonRestart) {
            dispatch_async(dispatch_get_main_queue(),^{
                [self startDaemon:NO];
            });           
        }
        self.daemonRunning = kDaemonNotRunning;
    });    
}

//file://localhost/private/var/mobile/Applications/89BAB803-9B12-422E-A01D-C2C4707B169F/Documents/Inbox/wallet.dat
-(BOOL)isBackupURL:(NSURL*)_backupURL
{
    if (![[_backupURL scheme] isEqualToString:@"file"])
        return NO;
    if (![[_backupURL pathExtension] isEqualToString:@"dat"])
        return NO;
    return YES;
}

- (BOOL)restoreBackup
{
    NSFileManager *fileMgr = [NSFileManager defaultManager];
    NSString* backupPath = [backupURL path];
    NSError* error;
    if (![fileMgr removeItemAtPath:walletPath() error:&error] ||
        ![fileMgr copyItemAtPath:backupPath toPath:walletPath() error:&error]) {
        NSString *msg = [NSString stringWithFormat:@"%@ %@ %@",[error localizedDescription],backupPath,walletPath()];
        TTDPRINT(@"%@", msg);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Restore was not performed"
                                                        message:msg
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
		[alert show];
		[alert release];
        return NO;
    }
    return YES;
}
- (void)handlelock
{
    if (GlobalSettings.islock) {
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,0.01*1000000000),dispatch_get_main_queue(),^{
            [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:@"bitcoin://password"]];
        });
    }
}
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // we started "fresh", no daemon running and no background process taking place
    self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
    self.daemonRunning = kDaemonNotRunning;
    
    self.backupURL = [launchOptions objectForKey:UIApplicationLaunchOptionsURLKey];
    if (self.backupURL && [self isBackupURL:backupURL]) {
    } else
        [self startDaemon:NO]; // will be called in didBecomeActive   
    
	// set stylesheet
	[TTStyleSheet setGlobalStyleSheet:[[[StyleSheet alloc] init] autorelease]];
	[[TTURLRequestQueue mainQueue] setMaxContentLength:0];
	
    // configure ttnavigator
	TTNavigator* navigator = [TTNavigator navigator];
	navigator.supportsShakeToReload = YES;
	navigator.persistenceMode = TTNavigatorPersistenceModeAll;
    navigator.window = [[[UIWindow alloc] initWithFrame:TTScreenBounds()] autorelease];
    
	// !!! IMPORTANT: create urlmaps !!!
	TTURLMap* map = navigator.URLMap;
    
    // Any URL that doesn't match will fall back on this one, and open in the web browser
    [map from:@"*" toViewController:[TTWebController class]];
	[map from:@"bitcoin://rpccommand/(initWithRepeat:)/(command:)" toViewController:[RPCCommandViewController class]];
	[map from:@"bitcoin://rpccommand/(initWithRepeat:)/(command:)/(param1:)" toViewController:[RPCCommandViewController class]];
	[map from:@"bitcoin://rpccommand/(initWithRepeat:)/(command:)/(param1:)/(param2:)" toViewController:[RPCCommandViewController class]];
	[map from:@"bitcoin://rpccommand/(initWithRepeat:)/(command:)/(param1:)/(param2:)/(param3:)" toViewController:[RPCCommandViewController class]];
#ifdef MODALSEND     
	[map from:@"bitcoin://sendto" toModalViewController:[SendViewController class]];
#else
	[map from:@"bitcoin://sendto" toViewController:[SendViewController class]];
#endif
	[map from:@"bitcoin://sendto/(initWithAddress:)" toViewController:[SendViewController class]];
	[map from:@"bitcoin://sendto/(initWithAddress:)/(amount:)" toViewController:[SendViewController class]];
	[map from:@"bitcoin://backup" toViewController:[BackupViewController class]];
	[map from:@"bitcoin://about" toViewController:[AboutViewController class]];
	[map from:@"bitcoin://console" toViewController:[ConsoleViewController class]];
    [map from:@"bitcoin://launcher" toSharedViewController: [LauncherViewTestController class]];
    [map from:@"bitcoin://page/(initWithPage:)" toViewController: [PageViewController class]];
    [map from:@"bitcoin://contactus" toViewController: [ContactUsViewController class]];
	[map from:@"bitcoin://login" toViewController:[BitCoinLoginViewController class]];
	//[map from:@"bitcoin://login/(server:)/(user:)/(password:)" parent:@"bitcoin://launcher" toSharedViewController:[BitCoinLoginViewController class]];
	//[map from:@"bitcoin://logout" parent:@"bitcoin://launcher" toSharedViewController:[BitCoinLoginViewController class] selector:@selector(logout)];
	[map from:@"bitcoin://myaddress" toViewController:[MyAddressViewController class]];
	[map from:@"bitcoin://balance" toViewController:[BalanceViewController class]];
	[map from:@"bitcoin://password" toViewController:[PasswordViewController class]];

    // Build an RPC client to send a stop command to the daemon
    self.model = [[RPCModel alloc] initWithCommand:@"stop" params:nil];
    [self.model.delegates addObject:self];

    
    if (![navigator restoreViewControllers])
        [navigator openURLAction:[TTURLAction actionWithURLPath:@"bitcoin://launcher"]];

    NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
    NSNumber *showlicense = [prefs objectForKey:@"SHOWLICENSE"];
#define LICENSE_VERSION 1
    if (!showlicense || [showlicense intValue] < LICENSE_VERSION) {
        [prefs setObject:[NSNumber numberWithInt:LICENSE_VERSION] forKey:@"SHOWLICENSE"];	
        [prefs synchronize];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,0.01*1000000000),dispatch_get_main_queue(),^{
            [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:@"bitcoin://page/license"]];
        });
    }
    [self handlelock];
    return YES;
}

- (BOOL)application:(UIApplication*)application handleOpenURL:(NSURL*)URL {
    if ([self isBackupURL:URL]) {
        UIAlertView *alert = nil;
        if (serialQueue) {
            alert = [[UIAlertView alloc] initWithTitle:@"Cant restore now"  message:@"You must first completely exit BitCoin. Click on Home button once, wait, then double click on it. Do a long press on the BitCoin icon AT THE BOTTOM of the screen and delete it. Try again to click on the wallet.dat file." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        } else {
            alert = [[UIAlertView alloc] initWithTitle:@"Wallet restore"  message:@"Your current wallet on the App will be erased. Any bitcoin balance you have on it will be forever lost unless you have made another backup of it first. Do you want to continue?" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"OK",nil];
        }
		[alert show];
		[alert release];
    } else
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
    if (self.daemonRunning != kDaemonRunning)
        return;
    self.backgroundTaskIdentifier = [[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
            //self.daemonRunning = kDaemonStopped;
            self.backgroundTaskIdentifier = UIBackgroundTaskInvalid;
        }];
    //[self applicationWillTerminate:application];
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    /*
     Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
     */
    [self handlelock];

    self.backgroundTaskIdentifier = UIBackgroundTaskInvalid; // No need to end background task (if started).
    if (self.daemonRunning == kDaemonNotRunning) { // If we full stopped the daemon then restart it
        //[self startDaemon:NO];
    } else if(self.daemonRunning == kDaemonStopped) {
        //self.daemonRunning = kDaemonRestart;
    }
    
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
    self.daemonRunning = kDaemonStopped;
    [self.model load:TTURLRequestCachePolicyDefault more:NO];
}

- (void)dealloc
{
    if (serialQueue) {
		dispatch_release(serialQueue);
		serialQueue=NULL;
	}

    [self.model.delegates removeObject:self];
    self.model = nil;
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
#pragma mark -
#pragma UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    BOOL rescan = NO;
    if ([alertView cancelButtonIndex] != buttonIndex) {
        rescan = [self restoreBackup];
    } 
    [self startDaemon:rescan];
}

@end
