//
//  RPCModel.h
//  BitCoin
//
//  Created by Ehud Ben-Reuven on 4/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Three20/Three20.h"


@interface RPCModel : TTModel <TTURLRequestDelegate>
{
	BOOL _isLoading;
	BOOL _isLoaded;
    NSString* _command;
    NSArray* _params;
    TTURLRequest* _request;
    NSDictionary* _results;
}
@property (nonatomic, retain) NSString* command;
@property (nonatomic, retain) NSArray* params;
@property (nonatomic, retain) NSDictionary* results;
- (id)initWithCommand:(NSString*)command params:(NSArray*)params;
@property (nonatomic, retain) TTURLRequest* request;
@end
