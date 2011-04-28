//
//  SendViewController.m
//
//  Created by Ehud Ben-Reuven on 4/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//           
#import "SendViewController.h"
#import "extThree20JSON/NSObject+YAJL.h"
#import "extThree20JSON/extThree20JSON.h"
#import "BitCoinSettings.h"
#import "ProgressAlert.h"

enum {AlertError, AlertValidation, AlertOK};

@implementation SendViewController
@synthesize toField = _toField;
@synthesize amountField = _amountField;
@synthesize toaddress;
@synthesize progressAlert;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ([super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"Send";
        self.variableHeightRows = YES;
        
        self.autoresizesForKeyboard = YES;
        self.tableViewStyle = UITableViewStyleGrouped;
        
        [[TTNavigator navigator].URLMap from:@"tt://send"
                                    toObject:self selector:@selector(send)];
#ifdef MODALSEND     
        // Configure the cancel button.
        UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancel:)];
        self.navigationItem.leftBarButtonItem = cancelButton;
        [cancelButton release];
#endif
        return self;
    }
    
    return nil;
}
-(id)initWithAddress:(NSString*)to
{
    self = [self init];
    if (self) {
        self.toaddress=to;
    }
    return self; 
}

- (void)dealloc {
    self.progressAlert = nil;
    [[TTNavigator navigator].URLMap removeURL:@"tt://send"];
    self.toField = nil;
    self.amountField = nil;
    self.toaddress=nil;
    [super dealloc];
}

- (void)send:(BOOL)check
{
    if (!_toField.text || [_toField.text isEqual:[NSNull null]] || [_toField.text isEqualToString:@""])
        return;
    if (!_amountField.text || [_amountField.text isEqual:[NSNull null]] || [_amountField.text isEqualToString:@""])
         return;
    
    TTURLRequest* _request = [TTURLRequest requestWithURL:GlobalSettings.url delegate:self];
    
    NSString* rpcmethod = check ? @"checksendtoaddress" : @"sendtoaddress";
    NSString *request_body = [NSString stringWithFormat:@"{\"jsonrpc\": \"1.0\", \"id\":\"send\", \"method\": \"%@\", \"params\": [\"%@\", %.2f] }",rpcmethod,_toField.text,[_amountField.text floatValue]];
    TTDPRINT(@"sending %@", request_body);
    _request.httpBody = [request_body dataUsingEncoding:NSUTF8StringEncoding]; // NSASCIIStringEncoding]; //
    
    _request.httpMethod = @"POST";
    _request.cachePolicy = TTURLRequestCachePolicyNone;
    _request.shouldHandleCookies = NO;
    
    _request.contentType = @"application/json"; // Content-Type:
    _request.userInfo = check ? @"check" : @"send";
    
    _request.response = [[[TTURLJSONResponse alloc] init] autorelease]; //TTURLDataResponse
    [_request send];
    self.progressAlert = [[ProgressAlert alloc] initWithMessage:@"Sending..." withActivity:NO];
    //[[self navigationItem] setHidesBackButton:YES animated:YES];
}
- (void)send
{
    if (GlobalSettings.local) {
        [self send:YES];
    } else {
        [self send:NO];
    }
}
- (void)createModel {
    self.toField = [[[UITextField alloc] init] autorelease];
    _toField.placeholder = @"1JsHXZRoqoPkwpZajy1VmnSmmvxqy1eux2";
    if (self.toaddress) {
        _toField.text = toaddress;
    }
    _toField.keyboardType = UIKeyboardTypeDefault;
    _toField.returnKeyType = UIReturnKeyNext;
    _toField.autocorrectionType = UITextAutocorrectionTypeNo;
    _toField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _toField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _toField.clearsOnBeginEditing = NO;
    _toField.delegate = self;
    
    self.amountField = [[[UITextField alloc] init] autorelease];
    _amountField.placeholder = @"0.99";
    if (amount>0.) {
        _amountField.text = [NSString stringWithFormat:@"%.2f",amount];
    }
    _amountField.keyboardType = UIKeyboardTypeDecimalPad;
    _amountField.returnKeyType = UIReturnKeyNext;
    _amountField.autocorrectionType = UITextAutocorrectionTypeNo;
    _amountField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _amountField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _amountField.clearsOnBeginEditing = NO;
    _amountField.delegate = self;
    
    self.dataSource = [TTSectionedDataSource dataSourceWithObjects:
                       @"",
                       [TTTableControlItem itemWithCaption:@"to"
                                                   control:_toField],
                       [TTTableControlItem itemWithCaption:@"amount"
                                                   control:_amountField],
                       @"",
                       [TTTableButton itemWithText:@"SEND" URL:@"tt://send"],
                       nil];
}

// left button
- (IBAction)cancel:(id)sender
{
#ifdef MODALSEND
    [self dismissModalViewControllerAnimated:YES];
#else
    //[[TTNavigator navigator].visibleViewController.navigationController popViewControllerAnimated:YES];
    [[self navigationController] popViewControllerAnimated:YES];
#endif
}
-(void)failed:(NSString*)message
{
    if (!message)
        message = @"Try again or cancel";
    NSString* title=@"Error";
    if ([message hasPrefix:@"The transaction was"]) {
        title = @"Warning";
    }
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:title  message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alert.tag = AlertError;
    [alert show];
    [alert release];
}
-(void)succeeded
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Send"  message:@"Successful transmission" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    alert.tag = AlertOK;
    [alert show];
    [alert release];
}

#pragma mark -
#pragma mark posting
-(void)dismissProgressAlert
{
    //[[self navigationItem] setHidesBackButton:NO animated:YES];
    if (self.progressAlert)
        [self.progressAlert.progressAlert dismissWithClickedButtonIndex:0 animated:YES];
    self.progressAlert = nil;
}
-(void)pauseProgressAlert
{
    //[[self navigationItem] setHidesBackButton:NO animated:YES];
    [self.progressAlert dismiss];
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

#pragma mark -
#pragma mark TTURLRequestDelegate
- (void)requestDidFinishLoad:(TTURLRequest*)request {
    [self dismissProgressAlert];
	TTURLJSONResponse* response = request.response;
    NSDictionary *results = response.rootObject;
    TTDPRINT(@"result of send %@", results);
    
    if ([request.userInfo isEqualToString:@"check"]) {
        [self send:NO];
    } else
        [self succeeded];
}

- (void)request:(TTURLRequest *)request didFailLoadWithError:(NSError *)error {
    [self dismissProgressAlert];
    TTDPRINT(@"%@", [error localizedDescription]);
	TTURLJSONResponse* response = request.response;
    NSDictionary *results = response.rootObject;    
    NSString* message = [[results objectForKey:@"error"] objectForKey:@"message"];
    
    if ([request.userInfo isEqualToString:@"check"]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Validation problem"  message:message delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Try to send",nil];
        alert.tag = AlertValidation;
        [alert show];
        [alert release];
    } else
        [self failed:message];   
}
#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    switch (alertView.tag) {
        case AlertValidation:
            if (buttonIndex == [alertView cancelButtonIndex])
                [self cancel:nil];
            else
                [self send:NO];
            break;
        //case AlertError:
        //case AlertOK:
        default:
            [self cancel:nil];
            break;
    }
}
#pragma mark -
#pragma mark UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {    
    if (textField == _toField) {
        [_amountField becomeFirstResponder];
    }
    else {
        [_amountField resignFirstResponder];
        [self send];
    }
    return YES;
}
@end
