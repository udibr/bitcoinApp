//
//  BalanceDataSource.m
//  BitCoin
//
//  Created by Ehud Ben-Reuven on 4/23/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BalanceDataSource.h"
#import "RPCModel.h"
#import "Three20Core/NSDateAdditions.h"

@implementation BalanceDataSource
- (void)tableViewDidLoadModel:(UITableView*)tableView {
    id results = [(RPCModel*)_model results];
    if ([results isKindOfClass:[NSDictionary class]]) {
        NSMutableArray* items = [[NSMutableArray alloc] init];
        TTTableCaptionItem *r = nil;
        NSString *key = nil;
        NSString *value = nil;
        
        key = @"balance";
        value = [[results valueForKeyPath:key] description];
        r = [TTTableCaptionItem itemWithText:value caption:key];
        [items addObject:r];
        self.items = items;
        
        key = @"blocks";
        value = [[results valueForKeyPath:key] description];
        r = [TTTableCaptionItem itemWithText:value caption:@"As of block"];
        [items addObject:r];
        self.items = items;
        
        key = @"bestblocktime";
        NSNumber* t = [results valueForKeyPath:key];
        if (t && ![t isEqual:[NSNull null]]) {
            NSDate* date = [NSDate dateWithTimeIntervalSince1970:[t doubleValue]];
            value = [date formatShortTime];
            r = [TTTableCaptionItem itemWithText:value caption:@"Block's time"];
            [items addObject:r];
            self.items = items;
        }
        
        TT_RELEASE_SAFELY(items);
    } else {
        [super tableViewDidLoadModel:tableView];
    }
    
}
@end
