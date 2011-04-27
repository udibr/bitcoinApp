//
//  PasswordDataSource.m
//  BitCoin
//
//  Created by Ehud Ben-Reuven on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PasswordDataSource.h"

#import "BitCoinSettings.h"
#import "NSString+URLEncoding.h"

@implementation PasswordDataSource

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSObject


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
    if ([super init]) {				
		// password field
		_passwordField = [[UITextField alloc] init];
		_passwordField.placeholder = @"*****";
		_passwordField.returnKeyType = UIReturnKeyGo;
		_passwordField.secureTextEntry = YES;
		_passwordField.autocorrectionType = UITextAutocorrectionTypeNo;
		_passwordField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		_passwordField.clearButtonMode = UITextFieldViewModeWhileEditing;
		_passwordField.clearsOnBeginEditing = NO;
		_passwordField.delegate = self;
        
        
		return self;
    }
    return nil;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)dealloc {
    TT_RELEASE_SAFELY(_passwordField);
    [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITextFieldDelegate methods
-(void)enter
{
    if ([_passwordField.text isEqualToString:GlobalSettings.lockpassword]) {
        [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:@"bitcoin://launcher"]];    
    }    
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textFieldShouldReturn:(UITextField *)textField {    
    [self enter];
    return YES;
}

- (BOOL)isLoaded {
	return YES;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// This is called everytime the view controller is refreshed
//- (void)refresh
- (void)tableViewDidLoadModel:(UITableView*)tableView
{	
	NSMutableArray *items = [[NSMutableArray alloc] init];
	NSMutableArray *sections = [[NSMutableArray alloc] init];
    
	// section 1 will hold items for login details
	NSMutableArray *section1 = [[NSMutableArray alloc] init];
	
    _passwordField.text = @"";
    TTTableControlItem* cPasswordField = [TTTableControlItem itemWithCaption:@"Password"
                                                                     control:_passwordField];
    [section1 addObject:cPasswordField];
    [sections addObject:@""];
    [items addObject:section1];
    TT_RELEASE_SAFELY(section1);
    
	self.items = items;
	self.sections = sections;
	TT_RELEASE_SAFELY(sections);
	TT_RELEASE_SAFELY(items);
}
@end
