//
//  PasswordViewController.m
//  BitCoin
//
//  Created by Ehud Ben-Reuven on 4/26/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PasswordViewController.h"
#import "PasswordDataSource.h"
#import "BitCoinSettings.h"
#import "NSString+URLEncoding.h"


@implementation PasswordViewController

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
	if ([super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        self.title = @"Lock";
		self.variableHeightRows = YES;
        //        self.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        
		self.autoresizesForKeyboard = YES;
		self.tableViewStyle = UITableViewStyleGrouped;
        [[self navigationItem] setHidesBackButton:YES animated:NO];
        return self;
	}
	
	return nil;
}

#pragma mark -
#pragma mark TTModelViewController
- (void)createModel {
	self.dataSource = [[[PasswordDataSource alloc] init] autorelease];
}
@end
