//
//  TTRequestLoader+BC.m
//  BitCoin
//
//  Created by Ehud Ben-Reuven on 4/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "Three20Network/private/TTRequestLoader.h"

// Network
#import "Three20Network/TTGlobalNetwork.h"
#import "Three20Network/TTURLRequest.h"
#import "Three20Network/TTURLRequestDelegate.h"
#import "Three20Network/TTURLRequestQueue.h"
#import "Three20Network/TTURLResponse.h"

// Network (private)
#import "Three20Network/private/TTURLRequestQueueInternal.h"

// Core
#import "Three20Core/NSObjectAdditions.h"
#import "Three20Core/TTDebug.h"
#import "Three20Core/TTDebugFlags.h"


@implementation TTRequestLoader (BC)
- (void)connectionDidFinishLoading:(NSURLConnection *)connection {
    TTNetworkRequestStopped();
    
    TTDCONDITIONLOG(TTDFLAG_ETAGS, @"Response status code: %d", _response.statusCode);
    
    // We need to accept valid HTTP status codes, not only 200.
    if (_response.statusCode >= 200 && _response.statusCode < 300) {
        [_queue loader:self didLoadResponse:_response data:_responseData];
        
    } else if (_response.statusCode == 304) {
        [self processResponse:_response data:_responseData]; //TTUDI
        [_queue loader:self didLoadUnmodifiedResponse:_response];
        
    } else {
        [self processResponse:_response data:_responseData]; //TTUDI
        TTDCONDITIONLOG(TTDFLAG_URLREQUEST, @"  FAILED LOADING (%d) %@",
                        _response.statusCode, _urlPath);
        NSError* error = [NSError errorWithDomain:NSURLErrorDomain code:_response.statusCode
                                         userInfo:nil];
        [_queue loader:self didFailLoadWithError:error];
    }
    
    TT_RELEASE_SAFELY(_responseData);
    TT_RELEASE_SAFELY(_connection);
}

@end
