#import "LauncherViewTestController.h"

///////////////////////////////////////////////////////////////////////////////////////////////////

@implementation LauncherViewTestController

///////////////////////////////////////////////////////////////////////////////////////////////////
// NSObject

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"BitCoin";
  }
  return self;
}

- (void)dealloc {
  [super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// UIViewController

- (void)loadView {
  [super loadView];

  _launcherView = [[TTLauncherView alloc] initWithFrame:self.view.bounds];
  _launcherView.backgroundColor = [UIColor blackColor];
  _launcherView.delegate = self;
  _launcherView.columnCount = 4;
  _launcherView.pages = [NSArray arrayWithObjects:
    [NSArray arrayWithObjects:
    // [[[TTLauncherItem alloc] initWithTitle:@"Accounts"
    //                                  image:@"bundle://Icon.png"
    //                                    URL:@"bitcoin://rpccommand/listaccounts" canDelete:NO] autorelease],
     [[[TTLauncherItem alloc] initWithTitle:@"My Address"
                                      image:@"bundle://Icon.png"
                                        URL:@"bitcoin://rpccommand/getaccountaddress/%20" canDelete:NO] autorelease], 
     [[[TTLauncherItem alloc] initWithTitle:@"Balance"
                                      image:@"bundle://Icon.png"
                                        URL:@"bitcoin://rpccommand/getbalance" canDelete:NO] autorelease], 
     [[[TTLauncherItem alloc] initWithTitle:@"Send"
                                      image:@"bundle://Icon.png"
                                        URL:@"bitcoin://sendto" canDelete:NO] autorelease], 
     [[[TTLauncherItem alloc] initWithTitle:@"Transactions"
                                      image:@"bundle://Icon.png"
                                        URL:@"bitcoin://rpccommand/listtransactions" canDelete:NO] autorelease], 
     [[[TTLauncherItem alloc] initWithTitle:@"Status"
                                      image:@"bundle://Icon.png"
                                        URL:@"bitcoin://rpccommand/getinfo" canDelete:NO] autorelease],
     [[[TTLauncherItem alloc] initWithTitle:@"About"
                                      image:@"bundle://Icon.png"
                                        URL:@"bitcoin://about" canDelete:YES] autorelease], 
     [[[TTLauncherItem alloc] initWithTitle:@"Whats New"
                                      image:@"bundle://Icon.png"
                                        URL:@"bitcoin://page/whatsnew" canDelete:YES] autorelease], 
     [[[TTLauncherItem alloc] initWithTitle:@"License"
                                      image:@"bundle://Icon.png"
                                        URL:@"bitcoin://page/license" canDelete:NO] autorelease], 
      nil],
      nil
    ];
  [self.view addSubview:_launcherView];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
// TTLauncherViewDelegate

- (void)launcherView:(TTLauncherView*)launcher didSelectItem:(TTLauncherItem*)item {
	TTNavigator* navigator = [TTNavigator navigator];
    [navigator openURLAction:[TTURLAction actionWithURLPath:item.URL]];   
}

- (void)launcherViewDidBeginEditing:(TTLauncherView*)launcher {
  [self.navigationItem setRightBarButtonItem:[[[UIBarButtonItem alloc]
    initWithBarButtonSystemItem:UIBarButtonSystemItemDone
    target:_launcherView action:@selector(endEditing)] autorelease] animated:YES];
}

- (void)launcherViewDidEndEditing:(TTLauncherView*)launcher {
  [self.navigationItem setRightBarButtonItem:nil animated:YES];
}

@end
