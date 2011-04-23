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

@implementation SendViewController
@synthesize toField = _toField;
@synthesize amountField = _amountField;
@synthesize toaddress;
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
    [[TTNavigator navigator].URLMap removeURL:@"tt://send"];
    self.toField = nil;
    self.amountField = nil;
    self.toaddress=nil;
    [super dealloc];
}

- (void)send
{
    if (!_toField.text || [_toField.text isEqual:[NSNull null]] || [_toField.text isEqualToString:@""])
        return;
    if (!_amountField.text || [_amountField.text isEqual:[NSNull null]] || [_amountField.text isEqualToString:@""])
         return;
    
    TTURLRequest* _request = [TTURLRequest requestWithURL:GlobalSettings.url delegate:self];
    
    NSString *request_body = [NSString stringWithFormat:@"{\"jsonrpc\": \"1.0\", \"id\":\"send\", \"method\": \"sendtoaddress\", \"params\": [\"%@\", %.2f] }",_toField.text,[_amountField.text floatValue]];
    TTDPRINT(@"sending %@", request_body);
    _request.httpBody = [request_body dataUsingEncoding:NSUTF8StringEncoding]; // NSASCIIStringEncoding]; //
    
    _request.httpMethod = @"POST";
    _request.cachePolicy = TTURLRequestCachePolicyNone;
    _request.shouldHandleCookies = NO;
    
    _request.contentType = @"application/json"; // Content-Type:
    
    _request.response = [[[TTURLJSONResponse alloc] init] autorelease]; //TTURLDataResponse
    [_request send];
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
    _amountField.keyboardType = UIKeyboardTypeDefault;
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
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"  message:message delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [alert show];
    [alert release];
}
-(void)succeeded
{
    [self cancel:nil];
}

#pragma mark -
#pragma mark UITextFieldDelegate methods

#pragma mark -
#pragma mark TTURLRequestDelegate
- (void)requestDidFinishLoad:(TTURLRequest*)request {
	TTURLJSONResponse* response = request.response;
    id results = response.rootObject;
    TTDPRINT(@"result of send %@", results);
    if ([results isKindOfClass:[NSString class]] && [results length]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Warning"  message:results delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    } else
        [self cancel:nil];
}

- (void)request:(TTURLRequest *)request didFailLoadWithError:(NSError *)error {
    TTDPRINT(@"%@", [error localizedDescription]);
	TTURLJSONResponse* response = request.response;
    NSDictionary *results = response.rootObject;    
    NSString* message = [[results objectForKey:@"error"] objectForKey:@"message"];
    [self failed:message];   
}
#pragma mark -
#pragma mark UIAlertViewDelegate
- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    [self cancel:nil];
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
