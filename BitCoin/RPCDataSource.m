//
//  RPCDataSource.m
//  BitCoin
//
//  Created by Ehud Ben-Reuven on 4/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RPCDataSource.h"
#import "RPCModel.h"

@implementation RPCDataSource
- (id)initWithItemCommand:(NSString*)command
{
    self = [super init];
	if (self) {
        self.items =  [[NSMutableArray alloc] init];
        _model = [[RPCModel alloc] initWithCommand:command];
        [_model.delegates addObject:self];
	}
	
	return self;
}

- (void)dealloc {
    self.items = nil;
	TT_RELEASE_SAFELY(_model);
	[super dealloc];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<TTModel>)model {
	return _model;
}

- (void)cancel {
    [super cancel];
    [_model cancel];
}

- (void)tableViewDidLoadModel:(UITableView*)tableView {
    NSDictionary *results = [(RPCModel*)_model results];
    NSMutableArray* items = [[NSMutableArray alloc] init];
	for (NSString *key in [results keyEnumerator]) {
        NSString *value = [[results valueForKeyPath:key] description];
        TTTableCaptionItem *r = [TTTableCaptionItem itemWithText:value caption:key];
        
        [items addObject:r];
	}
    
	self.items = items;
	
	TT_RELEASE_SAFELY(items);
}
@end
