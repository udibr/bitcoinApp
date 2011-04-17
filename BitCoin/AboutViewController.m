//
//  FirstViewController.m
//  tenbis
//
//  Created by Ehud Ben-Reuven on 2/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "AboutViewController.h"
#import "BitCoinAppDelegate.h"

@implementation AboutViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ([super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"About";
		self.variableHeightRows = YES;
		//self.autoresizesForKeyboard = YES;
		self.tableViewStyle = UITableViewStyleGrouped;
        
        return self;
	}
	
	return nil;
}

///////////////////////////////////////////////////////////////////////////////////////////////////
#pragma mark -
#pragma mark TTModelViewController

- (void)createModel {
    NSString *ver = (NSString*)CFBundleGetValueForInfoDictionaryKey(CFBundleGetMainBundle(),kCFBundleVersionKey);
   // NSString* path = [(BitCoinAppDelegate*)[[UIApplication sharedApplication] delegate] applicationDocumentsDirectory];
    self.dataSource = [TTSectionedDataSource dataSourceWithObjects:
                       @"",
                       [TTTableButton itemWithText:@"How to use this App" URL:@"bitcoin://page/howto"],
                       [TTTableButton itemWithText:[NSString stringWithFormat:@"Whats new in %@",ver] URL:@"bitcoin://page/whatsnew"],
                      // [TTTableTextItem itemWithText:path],
                       [TTTableButton itemWithText:@"More on BitCoin" URL:@"http://www.bitcoin.org"],
                       [TTTableButton itemWithText:@"More from Symfi" URL:@"http://www.symfi.mobi"],
                       [TTTableButton itemWithText:@"Credits" URL:@"bitcoin://page/credits"],
#if TARGET_IPHONE_SIMULATOR
                       [TTTableButton itemWithText:applicationDocumentsDirectory()],
#endif
                       nil];
}
@end
