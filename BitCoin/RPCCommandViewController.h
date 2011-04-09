//
//  BitCoin
//
//  Created by Ehud Ben-Reuven on 2/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Three20/Three20.h"


@interface RPCCommandViewController : TTTableViewController {
    NSString *_command;
    NSArray *_params;
    BOOL alreadyAppeared;
}
@property (nonatomic, retain) NSString* command;
@property (nonatomic, retain) NSArray* params;
-(id)initWithCommand:(NSString*)command;
-(id)initWithCommand:(NSString*)command param1:(NSString*)param1;
@end
