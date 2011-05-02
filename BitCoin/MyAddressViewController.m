//
//  MyAddressViewController.m
//  BitCoin
//
//  Created by Ehud Ben-Reuven on 4/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "MyAddressViewController.h"
#import "RPCModel.h"
#import "AddAddressModel.h"
#define kAccountName    @""

@implementation MyAddressViewController
@synthesize address;
@synthesize addRequest;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ([super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"My Address";
        repeatCmd = NO;
        self.command = @"getaddressesbyaccount"; // @"getaccountaddress";
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
     UIBarButtonItem *rButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addActions:)];
    //rButton.enabled = NO;
     self.navigationItem.rightBarButtonItem = rButton;
     [rButton release];
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.addRequest cancel];
}
#pragma mark -
#pragma mark tap-menu
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
#pragma mark -
#pragma mark add
- (IBAction)addActions:(id)sender
{
    //stop pulling address list
    [self.dataSource cancel];
    
    self.addRequest =  [[[AddAddressModel alloc] initWithCommand:@"getnewaddress" params:[NSArray arrayWithObject:kAccountName]] autorelease];
    [self.addRequest.delegates addObject:self];
    [addRequest load:TTURLRequestCachePolicyDefault more:NO];
    self.navigationItem.rightBarButtonItem.enabled = NO;
}
- (void)modelDidFinishLoad:(id<TTModel>)model
{
    if ([model isKindOfClass:[AddAddressModel class]]) {
        self.addRequest = nil;
        [self reload];
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else
        [super modelDidFinishLoad:model];
}
- (void)model:(id<TTModel>)model didFailLoadWithError:(NSError*)error
{
    if ([model isKindOfClass:[AddAddressModel class]]) {
        self.addRequest = nil;
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else
        [super model:model didFailLoadWithError:error];
}
- (void)modelDidCancelLoad:(id<TTModel>)model
{
    if ([model isKindOfClass:[AddAddressModel class]]) {
        self.addRequest = nil;
        self.navigationItem.rightBarButtonItem.enabled = YES;
    } else
        [super modelDidCancelLoad:model];
}
#pragma mark -
#pragma mark send
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
