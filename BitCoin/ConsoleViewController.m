//
//  ConsoleViewController.m
//  BitCoin
//
//  Created by Ehud Ben-Reuven on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "ConsoleViewController.h"
#import "extThree20JSON/NSObject+YAJL.h"
#import "extThree20JSON/extThree20JSON.h"

@implementation ConsoleViewController
@synthesize cmdField = _cmdField;
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ([super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"Console";
        self.variableHeightRows = YES;
        
        self.autoresizesForKeyboard = YES;
        self.tableViewStyle = UITableViewStyleGrouped;
        
        return self;
    }
    
    return nil;
}

- (void)dealloc {
    self.cmdField = nil;
    [super dealloc];
}

- (void)createModel {
    self.cmdField = [[[UITextField alloc] init] autorelease];
    _cmdField.placeholder = @"Enter command manually";
    _cmdField.keyboardType = UIKeyboardTypeDefault;
    _cmdField.returnKeyType = UIReturnKeyNext;
    _cmdField.autocorrectionType = UITextAutocorrectionTypeNo;
    _cmdField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    _cmdField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _cmdField.clearsOnBeginEditing = NO;
    _cmdField.delegate = self;
    
    self.dataSource = [TTSectionedDataSource dataSourceWithObjects:
                       @"",
                       //[TTTableGrayTextItem itemWithText:@"Enter command:"],
                       [TTTableButton itemWithText:@"help" URL:@"bitcoin://rpccommand/0/help"],
                       [TTTableButton itemWithText:@"getinfo" URL:@"bitcoin://rpccommand/1/getinfo"],
                       [TTTableButton itemWithText:@"getaddressesbyaccount %20" URL:@"bitcoin://rpccommand/1/getaddressesbyaccount/%20"],
                       [TTTableButton itemWithText:@"listtransactions %20 5" URL:@"bitcoin://rpccommand/1/listtransactions/%20/5"],
                       [TTTableButton itemWithText:@"stop" URL:@"bitcoin://rpccommand/0/stop"],
                       [TTTableControlItem itemWithCaption:@">"
                                                   control:_cmdField],
                       nil];
}

// called when user hits enter
- (void)send
{
    if (!_cmdField.text || [_cmdField.text isEqual:[NSNull null]] || [_cmdField.text isEqualToString:@""])
        return;
    
    NSArray* commandLine = [_cmdField.text componentsSeparatedByString:@" "];
    if (![commandLine count]) {
        return;
    }
    NSString* url=@"bitcoin://rpccommand/0";
    for (NSString *s in commandLine) {
        if ([s length])
            url = [url stringByAppendingFormat:@"/%@",s];
    }
    TTDPRINT(@"Launching %@", url);
    // give time for the keyboard to close
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW,0.01*1000000000),dispatch_get_main_queue(),^{
        TTNavigator* navigator = [TTNavigator navigator];
        [navigator openURLAction:[TTURLAction actionWithURLPath:url]];   
    });
}

#pragma mark -
#pragma mark UITextFieldDelegate methods
- (BOOL)textFieldShouldReturn:(UITextField *)textField {    
    if (textField == _cmdField) {
        [_cmdField resignFirstResponder]; //close keyboard
        [self send];
    }
    return YES;
}

@end
