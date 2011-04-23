//
//  ProgressAlert.h
//  TenBis
//
//  Created by Ehud Ben-Reuven on 3/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface ProgressAlert : NSObject {
	UIAlertView* progressAlert;
	UIActivityIndicatorView* activityView;
	UIProgressView* progressView;
    BOOL dismissed;
}
@property(nonatomic, retain) UIAlertView* progressAlert;
@property(nonatomic, retain) UIActivityIndicatorView* activityView;
@property(nonatomic, retain) UIProgressView* progressView;
@property(nonatomic, assign) float progress;
-(id)initWithMessage:(NSString *)message withActivity:(BOOL)activity;
-(void)dismiss;
@end
