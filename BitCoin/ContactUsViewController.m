//
//  ContactUs.m
//  BitCoin
//
//  Created by Ehud Ben-Reuven on 4/15/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ContactUsViewController.h"

@implementation ContactUsViewController
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if  (![MFMailComposeViewController canSendMail]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't send email"  message:@"Configure device" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}

	MFMailComposeViewController *mailCtrl = [[MFMailComposeViewController alloc] init];
	mailCtrl.mailComposeDelegate = self;
    
    [mailCtrl setToRecipients:[NSArray arrayWithObject:@"symfi@benreuven.com"]];

  	[mailCtrl setSubject:@"BitCoin App feedback"];

    NSString* msg = [NSString stringWithFormat:@"\n\nVersion %@",
           (NSString*)CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(),kCFBundleVersionKey)];
	[mailCtrl setMessageBody:msg isHTML:NO];
    
	[self presentModalViewController:mailCtrl animated:YES];
	[mailCtrl release];
}

- (void) mailComposeController: (MFMailComposeViewController *)controller didFinishWithResult:(MFMailComposeResult)result error:(NSError *)error {
	
	//[self dismissModalViewControllerAnimated:YES];
	switch (result) {
		case MFMailComposeResultCancelled:
			break;
		case MFMailComposeResultSaved: {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mail Saved"    message :@"Message saved in your Drafts folder." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
			break;
		}
		case MFMailComposeResultSent:
			break;
		case MFMailComposeResultFailed: {
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Mail Error" message :[error  localizedDescription] delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
			[alert show];
			[alert release];
			break;
		}
	}
    [self dismissModalViewControllerAnimated:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,0.1*1000000000),dispatch_get_main_queue(),^{
        [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:@"bitcoin://launcher"]];
    });
}
#pragma mark -
#pragma UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:@"bitcoin://launcher"]];    
}
@end
