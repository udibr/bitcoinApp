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
#import "NSString+URLEncoding.h"

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
                       [TTTableButton itemWithText:@"getaccountaddress \"\"" URL:@"bitcoin://rpccommand/1/getaccountaddress/%20"],
                       [TTTableButton itemWithText:@"listtransactions \"\" 5" URL:@"bitcoin://rpccommand/1/listtransactions/%20/5"],
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
    
    
    NSString *text = _cmdField.text;
    // Parse text to array of elements including quotes and back-slash
    NSMutableArray* commandLine = [[NSMutableArray alloc] init]; // [_cmdField.text componentsSeparatedByString:@" "];
    unsigned int state = 0;
    NSString* element = @"";
    NSCharacterSet *whitespaces = [NSCharacterSet whitespaceCharacterSet];

    for (int i = 0; i < [text length]; i++) {
        unichar c = [text characterAtIndex:i];
        //skip whiete space before element
        if (state==0 && [whitespaces characterIsMember:c]) {
            continue;
        }
        //handle element with quotes
        if (state==0 && c=='"') {
            state=2;
            continue;
        }
        //end of elemnt
        if ((state==2 && c=='"') || (state && !(state&2) && !(state&4) && [whitespaces characterIsMember:c])) {
            state=0;
            [commandLine addObject:element];
            element = @"";
            continue;
        }
        //handle element without quotes
        if (state==0) {
            state=1;
        }
        //halde back-slash
        if (!(state&4) && c=='\\') {
            state|=4;
            continue;
        }
        element = [element stringByAppendingString:[NSString stringWithCharacters:&c length:1]];
        //reset back-slash
        if (state&4) {
            state-=4;
        }
    }
    if (state) {
        [commandLine addObject:element];        
    }
    
    
    if (![commandLine count]) {
        return;
    }
    NSString* url=@"bitcoin://rpccommand/0";
    for (NSString *s in commandLine) {
        if (![s length])
            s=@" ";
        url = [url stringByAppendingFormat:@"/%@",[s URLEncodedString]];
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
