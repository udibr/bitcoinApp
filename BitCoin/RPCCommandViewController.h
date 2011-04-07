//
//  BitCoin
//
//  Created by Ehud Ben-Reuven on 2/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Three20/Three20.h"


@interface RPCCommandViewController : TTTableViewController {
    NSString *_command;
    BOOL alreadyAppeared;
}
@property (nonatomic, retain) NSString* command;
-(id)initWithCommand:(NSString*)command;
@end
