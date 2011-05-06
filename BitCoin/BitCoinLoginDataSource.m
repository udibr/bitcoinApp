#import "BitCoinLoginDataSource.h"
#import "BitCoinSettings.h"
#import "NSString+URLEncoding.h"

@implementation BitCoinLoginDataSource

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark NSObject


///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)init {
    if ([super init]) {		
		// server field
		_serverField = [[UITextField alloc] init];
		_serverField.placeholder = @"127.0.0.1:8331";
		_serverField.keyboardType = UIKeyboardTypeEmailAddress;
		_serverField.returnKeyType = UIReturnKeyNext;
		_serverField.autocorrectionType = UITextAutocorrectionTypeNo;
		_serverField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		_serverField.clearButtonMode = UITextFieldViewModeWhileEditing;
		_serverField.clearsOnBeginEditing = NO;
		_serverField.delegate = self;
		
		// username field
		_usernameField = [[UITextField alloc] init];
		_usernameField.placeholder = @"*****";
		_usernameField.keyboardType = UIKeyboardTypeEmailAddress;
		_usernameField.returnKeyType = UIReturnKeyNext;
		_usernameField.autocorrectionType = UITextAutocorrectionTypeNo;
		_usernameField.autocapitalizationType = UITextAutocapitalizationTypeNone;
		_usernameField.clearButtonMode = UITextFieldViewModeWhileEditing;
		_usernameField.clearsOnBeginEditing = NO;
		_usernameField.delegate = self;
		
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
    TT_RELEASE_SAFELY(_serverField);
    TT_RELEASE_SAFELY(_usernameField);
    TT_RELEASE_SAFELY(_passwordField);
    [super dealloc];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark UITextFieldDelegate methods
// Allow editing only when logout
- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    if (textField == _serverField || textField == _usernameField || textField == _passwordField)
        return GlobalSettings.local;
    else
        return YES;
}

-(void)login
{
    
    if ([_serverField.text isEqualToString:@""]) {
        [_serverField becomeFirstResponder];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"  message:@"Server missing" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    } else if ([_usernameField.text isEqualToString:@""]) {
        [_usernameField becomeFirstResponder];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"  message:@"User name missing" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alert show];
        [alert release];
    } else if ([_passwordField.text isEqualToString:@""]) {
        [_passwordField becomeFirstResponder];
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"  message:@"Password missing" delegate:nil cancelButtonTitle:@"OK"otherButtonTitles:nil];
        [alert show];
        [alert release];
    } else {
        NSString* url = @"bitcoin://login";
        url = [url stringByAppendingFormat:@"/%@",[[_serverField.text URLEncodedString] stringByReplacingOccurrencesOfString:@"%" withString:@"bitcoinpercent"]];
        url = [url stringByAppendingFormat:@"/%@",[_usernameField.text URLEncodedString]];
        url = [url stringByAppendingFormat:@"/%@",[_passwordField.text URLEncodedString]];
        _passwordField.text = @"";
        TTDPRINT(@"%@", url);
        NSURL* URL=[NSURL URLWithString:url];
        NSArray* pathComponents = URL.path.pathComponents;
        TTDPRINT(@"%@", pathComponents);
        [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:url]];
        
    }    
}
///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)textFieldShouldReturn:(UITextField *)textField {    
    if (textField == _serverField) {
        [_usernameField becomeFirstResponder];
    }
    else
    if (textField == _usernameField) {
        [_passwordField becomeFirstResponder];
    }
    else {
        [_passwordField resignFirstResponder];
        [self login];
    }
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
	
    _serverField.text = GlobalSettings.server;
    TTTableControlItem* cServerField = [TTTableControlItem itemWithCaption:@"Server"
																	 control:_serverField];
    [section1 addObject:cServerField];

    _usernameField.text = GlobalSettings.username;
    TTTableControlItem* cUsernameField = [TTTableControlItem itemWithCaption:@"Username"
																	 control:_usernameField];
    [section1 addObject:cUsernameField];

    _passwordField.text = @"";
    if (GlobalSettings.local) {
        TTTableControlItem* cPasswordField = [TTTableControlItem itemWithCaption:@"Password"
                                                                         control:_passwordField];
        [section1 addObject:cPasswordField];
    }
    [sections addObject:@""];
    [items addObject:section1];
    TT_RELEASE_SAFELY(section1);

    //section 2
    NSMutableArray *section2 = [[NSMutableArray alloc] init];
    if (GlobalSettings.local) {	
        TTTableButton *loginButon = [TTTableButton itemWithText:@"Connect to remote Node" delegate:self selector:@selector(login)];
        //TTTableButton *loginButon = [TTTableButton itemWithText:@"Connect to remote Node" URL:@"bitcoin://login/1/2/3"];
        [section2 addObject:loginButon];
    } else {
        TTTableButton *logOutButon = [TTTableButton itemWithText:@"Use local Node" URL:@"bitcoin://logout"];
        [section2 addObject:logOutButon];
    }
    [sections addObject:@""];
    [items addObject:section2];
    TT_RELEASE_SAFELY(section2);

    
	self.items = items;
	self.sections = sections;
	TT_RELEASE_SAFELY(sections);
	TT_RELEASE_SAFELY(items);
}
@end
