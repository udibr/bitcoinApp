//
//  BitCoinAppDelegate.h
//  BitCoin
//
//  Created by Ehud Ben-Reuven on 2/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Three20/Three20.h>
enum {
    kDaemonNotRunning, // daemon not running
    kDaemonStopped, // daemon is running but a stop cmmand was sent (when going to background)
    kDaemonRestart,  // daemon is running but a stop command was sent and when the stop will be completed, restart the daemon
    kDaemonRunning, // daemon is running
};

@class RPCModel;
@interface BitCoinAppDelegate : NSObject <UIApplicationDelegate> {
	dispatch_queue_t serialQueue, logQueue;
    RPCModel *model;
    NSURL* backupURL;
    NSInteger daemonRunning;
    UIBackgroundTaskIdentifier backgroundTaskIdentifier; // background task used to get extended time to stop the daemon. It has the value UIBackgroundTaskInvalid when not in background anymore
}
@property (nonatomic, retain) RPCModel* model;
@property (nonatomic, retain) NSURL* backupURL;
@property NSInteger daemonRunning; // thread safe
@property UIBackgroundTaskIdentifier backgroundTaskIdentifier; // thread safe
@end
