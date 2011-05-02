//
//  RPCDataSource.h
//  BitCoin
//
//  Created by Ehud Ben-Reuven on 4/6/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Three20/Three20.h"

@interface RPCDataSource : TTSectionedDataSource {
	NSTimer *reloadTimer;
    BOOL repeatCmd;
    BOOL myMenu;
}
@property (nonatomic) BOOL myMenu;
- (id)initWithItemRepeat:(BOOL)repeat command:(NSString*)command params:(NSArray*)params;
@end
