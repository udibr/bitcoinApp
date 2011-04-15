//
//  RPCDataSource.m
//  BitCoin
//
//  Created by Ehud Ben-Reuven on 4/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RPCDataSource.h"
#import "RPCModel.h"
#import "BCTableTextItemCell.h"

@interface RPCDataSource ()
@property (nonatomic, assign) NSTimer *reloadTimer;
@end


@implementation RPCDataSource
@synthesize reloadTimer;

- (id)initWithItemRepeat:(BOOL)repeat command:(NSString*)command params:(NSArray*)params
{
    self = [super init];
	if (self) {
        repeatCmd = repeat;
        self.items =  [[NSMutableArray alloc] init];
        _model = [[RPCModel alloc] initWithCommand:command params:params];
        [_model.delegates addObject:self];
        
        [[NSNotificationCenter defaultCenter]
         addObserver: self
         selector: @selector(didEnterBackgroundNotification:)
         name: UIApplicationDidEnterBackgroundNotification
         object: nil];
	}
	
	return self;
}
//UIApplicationWillEnterForegroundNotification
- (void)dealloc {
    [[NSNotificationCenter defaultCenter]
     removeObserver: self
     name: UIApplicationDidEnterBackgroundNotification
     object: nil];

    self.reloadTimer = nil;
    
    self.items = nil;
	TT_RELEASE_SAFELY(_model);
	[super dealloc];
}

-(void)reloadModel
{
    reloadTimer = nil;//necessary because repeats:NO in startReloads
    [self.model cancel];
    [self.model load:TTURLRequestCachePolicyDefault more:NO];
}

- (void)setReloadTimer:(NSTimer *)newTimer {
    [reloadTimer invalidate];
    reloadTimer = newTimer;
}

- (void)startReload:(NSTimeInterval)animationInterval
{
	self.reloadTimer = [NSTimer scheduledTimerWithTimeInterval:animationInterval target:self selector:@selector(reloadModel) userInfo:nil repeats:NO];
}

- (void)didEnterBackgroundNotification:(void*)object {
    [self cancel];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
- (id<TTModel>)model {
	return _model;
}

- (void)cancel {
    self.reloadTimer = nil;
    [_model cancel];
    [super cancel];
}

- (void)tableViewDidLoadModel:(UITableView*)tableView {
    NSMutableArray* items = [[NSMutableArray alloc] init];
    id results = [(RPCModel*)_model results];
    if ([results isKindOfClass:[NSDictionary class]]) {
        for (NSString *key in [results keyEnumerator]) {
            NSString *value = [[results valueForKeyPath:key] description];
            TTTableCaptionItem *r = [TTTableCaptionItem itemWithText:value caption:key];
            
            [items addObject:r];
        }
    } else {
        TTTableTextItem *r = [TTTableTextItem itemWithText:[results description]];
        [items addObject:r];
    }
    
	self.items = items;
	
	TT_RELEASE_SAFELY(items);
}

- (Class)tableView:(UITableView*)tableView cellClassForObject:(id) object {
	
    if ([object isKindOfClass:[TTTableCaptionItem class]]) {
	} else if ([object isKindOfClass:[TTTableTextItem class]]) {
        return [BCTableTextItemCell class];
	}
	
	return [super tableView:tableView
	     cellClassForObject:object];
}

- (NSString*)titleForError:(NSError*)error
{
    if ([error.domain isEqual:@"NSURLErrorDomain"] && error.code == -1004) {
        return @"BitCoin starting";
    } else
        return @"Error";
}

- (NSString*)subtitleForError:(NSError*)error
{
    if ([error.domain isEqual:@"NSURLErrorDomain"] && error.code == -1004) {
       return @"Please wait...";
    } else {
        return [error localizedDescription];
    }
}

- (void)model:(id<TTModel>)model didFailLoadWithError:(NSError*)error
{
    TTDPRINT(@"error domain %@ code %d", error.domain, error.code);
    if ([error.domain isEqual:@"NSURLErrorDomain"] && error.code == -1004) {
        [self startReload:1.];
    }
}
- (void)modelDidFinishLoad:(id<TTModel>)model
{
    if (repeatCmd)
        [self startReload:2.];
}
@end
