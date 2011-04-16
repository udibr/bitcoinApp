#import "BitCoinLoginViewController.h"
#import "BitCoinLoginDataSource.h"
#import "BitCoinSettings.h"
#import "NSString+URLEncoding.h"
@implementation BitCoinLoginViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ([super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"Node";
		firstTimeToAppear=YES;
		self.variableHeightRows = YES;
        //        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
		self.autoresizesForKeyboard = YES;
		self.tableViewStyle = UITableViewStyleGrouped;
		[[TTNavigator navigator].URLMap from:@"bitcoin://logout"
                                    toObject:self selector:@selector(logout)];
		[[TTNavigator navigator].URLMap from:@"bitcoin://login/(server:)/(user:)/(password:)"
                                    toObject:self selector:@selector(server:user:password:)];
        return self;
	}
	
	return nil;
}
- (void)dealloc {
	[[TTNavigator navigator].URLMap removeURL:@"bitcoin://logout"];
	[[TTNavigator navigator].URLMap removeURL:@"bitcoin://login/(server:)/(user:)/(password:)"];
    self.tabBarItem = nil;
    [super dealloc];
}


- (void)server:(NSString*)server user:(NSString*)user password:(NSString*)password
{
    GlobalSettings.server = [server URLDecodedString];
    GlobalSettings.username = [user URLDecodedString];
    GlobalSettings.password = [password URLDecodedString];
    GlobalSettings.local = NO;
    [self refresh];
	//return [self initWithNibName:nil bundle:nil];
}

- (void)logout
{        
    GlobalSettings.local = YES;
    [self refresh];
	//return [self initWithNibName:nil bundle:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (!firstTimeToAppear)
        [self refresh];//this is required if a logout is performd from outside this VC
    firstTimeToAppear=NO;
}
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTModelViewController


///////////////////////////////////////////////////////////////////////////////////////////////////
- (void)createModel {
	self.dataSource = [[[BitCoinLoginDataSource alloc] init] autorelease];
}


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark NSNotifications

- (void)modelDidStartLoad:(id<TTModel>)model {
}

- (void)modelDidFinishLoad:(id<TTModel>)model {
}

- (void)modelDidCancelLoad:(id<TTModel>)model {}


- (void)model:(id<TTModel>)model didUpdateObject:(id)object atIndexPath:(NSIndexPath *)indexPath {
}

- (void)model:(id<TTModel>)model didFailLoadWithError:(NSError *)error {
    TTAlertViewController* alert = [[[TTAlertViewController alloc] initWithTitle:@"Login error" message:TTDescriptionForError(error)] autorelease];
    [alert addCancelButtonWithTitle:@"OK" URL:nil];
    [alert showInView:self.view animated:YES];
    
	[super model:model didFailLoadWithError:error];
}
@end
