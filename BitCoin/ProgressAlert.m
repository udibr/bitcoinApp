//
//  ProgressAlert.m
//  TenBis
//
//  Created by Ehud Ben-Reuven on 3/20/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ProgressAlert.h"


@implementation ProgressAlert
@synthesize progressAlert,activityView,progressView,progress;    
-(void)dealloc
{
    [self dismiss];
    [progressAlert release];
    [activityView release];
    [progressView release];
    [super dealloc];
}

- (void) createProgressionAlertWithMessage:(NSString *)message withActivity:(BOOL)activity
{
	self.progressAlert = [[[UIAlertView alloc] initWithTitle: message
                                                 message: @"Please wait..."
                                                delegate: self
                                       cancelButtonTitle: nil
                                       otherButtonTitles: nil] autorelease];
	
	// Create the progress bar and add it to the alert
	if (activity) {
		self.activityView = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite] autorelease];
		self.activityView.frame = CGRectMake(139.0f-18.0f, 80.0f, 37.0f, 37.0f);
		[self.progressAlert addSubview:self.activityView];
		[self.activityView startAnimating];
	} else {
		self.progressView = [[[UIProgressView alloc] initWithFrame:CGRectMake(30.0f, 80.0f, 225.0f, 90.0f)] autorelease];
		[self.progressAlert addSubview:self.progressView];
		[self.progressView setProgressViewStyle: UIProgressViewStyleBar];
	}
	[self.progressAlert show];
}

-(id)initWithMessage:(NSString *)message withActivity:(BOOL)activity
{
    self = [super init];
    if (self) {
        [self createProgressionAlertWithMessage:message withActivity:activity];
    }
    return self;
}
-(void)dismiss
{
    if (!dismissed)
        [self.progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    dismissed=YES;
}
-(void)setProgress:(float)level
{
    if (!dismissed)
        self.progressView.progress = level;
}
@end
