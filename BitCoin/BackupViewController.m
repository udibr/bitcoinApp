//
//  BackupViewController.m
//  BitCoin
//
//  Created by Ehud Ben-Reuven on 4/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BackupViewController.h"
#import "BackupDataSource.h"
#import "BCFileSystem.h"


@implementation BackupViewController
-(void)dealloc
{
    [self.dataSource cancel];
    [super dealloc];
}
- (void)createModel {
    NSString* documentsDir=applicationDocumentsDirectory();
    NSString* backupPath = [documentsDir stringByAppendingPathComponent:@"backupwallet.dat"];

    NSArray* params = [NSArray arrayWithObject:backupPath];
	self.dataSource = [[[BackupDataSource alloc] initWithItemRepeat:NO command:@"backupwallet" params:params] autorelease];
   //[self.dataSource.model.delegates addObject:self];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if  (![MFMailComposeViewController canSendMail]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't send email"  message:@"Configure device" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}

}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.dataSource cancel];
}
#pragma mark -
#pragma MFMailComposeViewController
- (void)send
{	
	MFMailComposeViewController *mailCtrl = [[MFMailComposeViewController alloc] init];
	mailCtrl.mailComposeDelegate = self;
  	[mailCtrl setSubject:@"bitcoin wallet"];
  
    NSData* attachment = [NSData dataWithContentsOfFile:backupwalletPath()];
    [mailCtrl addAttachmentData:attachment mimeType:@"binary/octet-stream" fileName:@"wallet.dat"];
    
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
#pragma TTModelDelegate
- (void)modelDidFinishLoad:(id<TTModel>)model
{
    [self send];
}
#pragma mark -
#pragma UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:@"bitcoin://launcher"]];    
}
@end
