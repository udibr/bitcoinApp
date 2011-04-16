//
//  RPCModel.m
//  BitCoin
//
//  Created by Ehud Ben-Reuven on 4/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "extThree20JSON/extThree20JSON.h"
#import "BitCoinSettings.h"

#import "RPCModel.h"


@implementation RPCModel
@synthesize command = _command;
@synthesize params = _params;
@synthesize request = _request;
@synthesize results = _results;
- (id)initWithCommand:(NSString*)command params:(NSArray*)params
{
    self = [super init];
	if (self) {
        self.command = command;
        self.params = params;
	}
	
	return self;
}

- (void)dealloc {
    self.command = nil;
    self.params = nil;
    self.request = nil;
    self.results = nil;
	[super dealloc];
}
#pragma mark -
#pragma mark TTModel

///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoaded {
	return _isLoaded;
}


///////////////////////////////////////////////////////////////////////////////////////////////////
- (BOOL)isLoading {
	return _isLoading; //!!_loadingRequest;
}

-(void)loadedResutls:(NSDictionary*)results
{
    self.results = results;
	
	_isLoading = NO;
	_isLoaded = YES;
	
	[self didFinishLoad];    
}

-(void)failedToLoad
{
    [self didFailLoadWithError:nil];
	_isLoading = NO;
	_isLoaded = YES;
}

#pragma mark bitcoin command
- (void)load:(TTURLRequestCachePolicy)cachePolicy more:(BOOL)more {
    self.results = nil;
    
	_isLoading = YES;
	_isLoaded = NO;

    self.request = [TTURLRequest requestWithURL:GlobalSettings.url delegate:self];
    
    NSString *params = @"";
    for (id v in self.params) {
        NSString* sv=nil;
        if ([v isKindOfClass:[NSString class]] &&
            ![[[[NSNumberFormatter alloc] init] autorelease] numberFromString:v]) {
            sv = [NSString stringWithFormat:@"\"%@\"",v];
        } else {
            sv = [v description];
        }
        if (![params length])
            params = sv;
        else
            params = [params stringByAppendingFormat:@", %@",sv];
    }
    NSString *request_body = [NSString stringWithFormat:@"{\"jsonrpc\": \"1.0\", \"id\":\"rpc\", \"method\": \"%@\", \"params\": [%@] }",self.command,params];
    _request.httpBody = [request_body dataUsingEncoding:NSUTF8StringEncoding]; // NSASCIIStringEncoding]; //
    
    _request.httpMethod = @"POST";
    _request.cachePolicy = TTURLRequestCachePolicyNone;
    _request.shouldHandleCookies = NO;
    
    _request.contentType = @"application/json"; // Content-Type:
    
    _request.response = [[[TTURLJSONResponse alloc] init] autorelease]; //TTURLDataResponse
    
    //_request.userInfo = @"rpc";
    
    [_request send]; //sendSynchronously];
}
/**
 * The request has loaded data and been processed into a response.
 *
 * If the request is served from the cache, this is the only delegate method that will be called.
 */
- (void)requestDidFinishLoad:(TTURLRequest*)request
{
    self.request = nil;
    NSLog(@"Finished load");
    TTURLJSONResponse* response = request.response;
    NSDictionary *rootObject = response.rootObject;
    
    NSDictionary *result = [rootObject objectForKey:@"result"];
    if (!result) {
        [self failedToLoad];
    } else {
        [self loadedResutls:result];
    }
}
- (void)request:(TTURLRequest*)request didReceiveAuthenticationChallenge:(NSURLAuthenticationChallenge*)challenge
{
    self.request = nil;
    [self failedToLoad];
}

/**
 * The request failed to load.
 */
- (void)request:(TTURLRequest*)request didFailLoadWithError:(NSError*)error
{
    self.request = nil;
    TTDPRINT(@"Error: %@",[error localizedDescription]);
	_isLoading = NO;
	_isLoaded = YES;
    [self didFailLoadWithError:error];
}

/**
 * The request was canceled.
 */
- (void)requestDidCancelLoad:(TTURLRequest*)request
{
    self.request = nil;
    [self didCancelLoad];
}
- (void)cancel {
    [self.request cancel];
}

@end
