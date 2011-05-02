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
#import "BCTableCaptionItemCell.h"

@interface RPCDataSource ()
@property (nonatomic, assign) NSTimer *reloadTimer;
@end


@implementation RPCDataSource
@synthesize reloadTimer;
@synthesize myMenu;
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
         selector: @selector(willResignActiveNotification:)
         name: UIApplicationWillResignActiveNotification
         object: nil];
        [[NSNotificationCenter defaultCenter]
         addObserver: self
         selector: @selector(didBecomeActiveNotification:)
         name: UIApplicationDidBecomeActiveNotification
         object: nil];
	}
	
	return self;
}
//UIApplicationWillEnterForegroundNotification
- (void)dealloc {
    [_model.delegates removeObject:self];

    [[NSNotificationCenter defaultCenter]
     removeObserver: self
     name: UIApplicationWillResignActiveNotification
     object: nil];
    [[NSNotificationCenter defaultCenter]
     removeObserver: self
     name: UIApplicationDidBecomeActiveNotification
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

- (void)willResignActiveNotification:(void*)object {
    [self cancel];
}
-(void)didBecomeActiveNotification:(NSNotification*)notification
{
    [self reloadModel];
}

///////////////////////////////////////////////////////////////////////////////////////////////////
//- (id<TTModel>)model { // already implemented in TTTableViewDataSource
//	return _model;
//}

- (void)cancel {
    self.reloadTimer = nil;
    [_model cancel];
    [super cancel];
}

- (void)tableViewDidLoadModel:(UITableView*)tableView {
    NSMutableArray *sections = [[NSMutableArray alloc] init];
    NSMutableArray* items = [[NSMutableArray alloc] init];
    
    id results = [(RPCModel*)_model results];
    if ([results isKindOfClass:[NSDictionary class]]) {
        NSMutableArray *section = [[NSMutableArray alloc] init];
        
        for (NSString *key in [results keyEnumerator]) {
            NSString *value = [[results valueForKeyPath:key] description];
            TTTableCaptionItem *r = [TTTableCaptionItem itemWithText:value caption:key];
            
            [section addObject:r];
        }
        
        [sections addObject:@""];
        [items addObject:section];
        TT_RELEASE_SAFELY(section);        
    } else if ([results isKindOfClass:[NSArray class]]) {
        BOOL isDictionary = YES;
        for (id item in results) {
            if (![item isKindOfClass:[NSDictionary class]]) {
                isDictionary = NO;
                break;
            }
        }
        
        if (isDictionary) {
            for (id item in results) {
                NSMutableArray *section = [[NSMutableArray alloc] init];
                
                for (NSString *key in [item keyEnumerator]) {
                    NSString *value = [[item valueForKeyPath:key] description];
                    TTTableCaptionItem *r = [TTTableCaptionItem itemWithText:value caption:key];
                    
                    [section addObject:r];
                }
                
                [sections addObject:@" "];
                [items addObject:section];
                TT_RELEASE_SAFELY(section);
            }
        } else {
            NSMutableArray *section = [[NSMutableArray alloc] init];
            
            for (id item in results) {
                TTTableTextItem *r = [TTTableTextItem itemWithText:[item description]];
                [section addObject:r];
            }
            
            [sections addObject:@""];
            [items addObject:section];
            TT_RELEASE_SAFELY(section);
        }
    } else {
        NSMutableArray *section = [[NSMutableArray alloc] init];
        
        TTTableTextItem *r = [TTTableTextItem itemWithText:[results description]];
        [section addObject:r];
        
        [sections addObject:@""];
        [items addObject:section];
        TT_RELEASE_SAFELY(section);
    }
    
    self.sections = sections;
    TT_RELEASE_SAFELY(sections);
	self.items = items;	
	TT_RELEASE_SAFELY(items);
}

- (Class)tableView:(UITableView*)tableView cellClassForObject:(id) object
{	
    if (!myMenu) {
        if ([object isMemberOfClass:[TTTableCaptionItem class]])
            return [BCTableCaptionItemCell class];
        if ([object isMemberOfClass:[TTTableTextItem class]])
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
