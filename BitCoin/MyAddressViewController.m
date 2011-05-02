//
//  MyAddressViewController.m
//  BitCoin
//
//  Created by Ehud Ben-Reuven on 4/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyAddressViewController.h"
#import "RPCModel.h"

#define kAccountName    @""

@implementation MyAddressViewController
@synthesize address;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ([super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"My Address";
        repeatCmd = NO;
        self.command = @"getaccountaddress";
        self.params = [NSArray arrayWithObject:kAccountName];

        return self;
	}
	
	return nil;
}
-(void)dealloc
{
    self.address=nil;
    [super dealloc];
}
-(void)viewDidLoad
{
    [super viewDidLoad];
     // Configure the send button.
#if 0
     UIBarButtonItem *sendButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(sendActions:)];
    sendButton.enabled = NO;
     self.navigationItem.rightBarButtonItem = sendButton;
     [sendButton release];
#endif
}
- (BOOL) canBecomeFirstResponder
{
    return YES;
}
- (BOOL) canPerformAction: (SEL) action withSender: (id) sender
{
    return (action == @selector(copy:)) || (action == @selector(emailBitCoin:));
}
- (void) copy:(id)sender {
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = self.address;  
}
- (void) emailBitCoin:(id)sender {
    [self sendActions:sender];
}
- (void)didSelectObject:(id)object atIndexPath:(NSIndexPath*)indexPath
{
    TTTableTextItemCell *cell = (TTTableTextItemCell*)[self.dataSource tableView:self.tableView cellForRowAtIndexPath:indexPath];
    self.address = cell.textLabel.text;

    [self becomeFirstResponder];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    menu.menuItems = [NSArray arrayWithObject:[[[UIMenuItem alloc] initWithTitle:@"email" action:@selector(emailBitCoin:)] autorelease]];
    CGRect frame = [self.tableView rectForRowAtIndexPath:indexPath];
    [menu setTargetRect:frame inView:_tableView];
    [menu setMenuVisible:YES animated:YES];
}
- (IBAction)sendActions:(id)sender
{
    if (!address) {
        return;
    }
    if  (![MFMailComposeViewController canSendMail]) {
		UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Can't send email"  message:@"Configure device" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
		[alert show];
		[alert release];
		return;
	}
    
	MFMailComposeViewController *mailCtrl = [[MFMailComposeViewController alloc] init];
	mailCtrl.mailComposeDelegate = self;
        
  	[mailCtrl setSubject:@"My BitCoin Address"];
    
    NSString* msg = [NSString stringWithFormat:@"My BitCoin Address is %@",address];
    msg=[msg stringByAppendingFormat:@"\n<div><a href=\"bitcoin://sendto/%@\">Use BitCoin App to send BitCoins to this address</a> (requires BitCoin App to be already installed on this device.)</div>", address];
	[mailCtrl setMessageBody:msg isHTML:YES];
    
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
}
@end
