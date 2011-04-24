//
//  BalanceViewController.m
//  BitCoin
//
//  Created by Ehud Ben-Reuven on 4/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BalanceViewController.h"
#import "BalanceDataSource.h"

@implementation BalanceViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        self.title = @"Balance";
    }
    return  self;
}

- (void)createModel {
	self.dataSource = [[[BalanceDataSource alloc] initWithItemRepeat:YES command:@"getinfo" params:nil] autorelease];
}
@end
