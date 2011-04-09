//
//  FirstViewController.m
//  tenbis
//
//  Created by Ehud Ben-Reuven on 2/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "AboutViewController.h"

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
    self.dataSource = [TTSectionedDataSource dataSourceWithObjects:
                       @"",
                       [TTTableGrayTextItem itemWithText:[NSString stringWithFormat:@"Version %@",ver]],
                       [TTTableButton itemWithText:@"More from Symfi" URL:@"http://www.symfi.mobi"],
                       nil];
}
@end
