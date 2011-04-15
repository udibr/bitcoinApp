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
    BOOL repeatCmd;
}
@property (nonatomic, retain) NSString* command;
@property (nonatomic, retain) NSArray* params;
-(id)initWithRepeat:(BOOL)repeat command:(NSString*)command;
-(id)initWithRepeat:(BOOL)repeat command:(NSString*)command param1:(NSString*)param1;
-(id)initWithRepeat:(BOOL)repeat command:(NSString*)command param1:(NSString*)param1 param2:(NSString*)param2 param3:(NSString*)param3;
@end
