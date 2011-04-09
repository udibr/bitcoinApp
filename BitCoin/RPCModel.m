//
//  RPCModel.m
//  BitCoin
//
//  Created by Ehud Ben-Reuven on 4/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "extThree20JSON/extThree20JSON.h"

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

    self.request = [TTURLRequest requestWithURL:@"http://get:smart@127.0.0.1:8332" delegate:self];
    
    NSString *params = @"";
    for (int i = 0; i < [self.params count]; i++) {
        if (i < [self.params count]-1)
            params = [params stringByAppendingFormat:@"\"%@\",",[self.params objectAtIndex:i]];
        else
            params = [params stringByAppendingFormat:@"\"%@\"",[self.params objectAtIndex:i]];
    }
    NSString *request_body = [NSString stringWithFormat:@"{\"jsonrpc\": \"1.0\", \"id\":\"curltest\", \"method\": \"%@\", \"params\": [%@] }",self.command,params];
    _request.httpBody = [request_body dataUsingEncoding:NSUTF8StringEncoding]; // NSASCIIStringEncoding]; //
    
    _request.httpMethod = @"POST";
    _request.cachePolicy = TTURLRequestCachePolicyNone;
    _request.shouldHandleCookies = NO;
    
    _request.contentType = @"application/json"; // Content-Type:
    
    _request.response = [[[TTURLJSONResponse alloc] init] autorelease]; //TTURLDataResponse
    
    //_request.userInfo = @"curltest";
    
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
