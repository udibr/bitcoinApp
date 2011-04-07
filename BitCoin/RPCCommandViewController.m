//
//  BitCoin
//
//  Created by Ehud Ben-Reuven on 2/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "RPCCommandViewController.h"
#import "RPCDataSource.h"
extern int bitcoinmain(int argc, char* argv[]);

@implementation RPCCommandViewController
@synthesize command = _command;
-(id)initWithCommand:(NSString*)command
{
    self = [self init];
    if (self)
        self.command = command;
    return  self;
}
-(void)dealloc
{
    self.command = nil;
    [super dealloc];
}

- (void)createModel {
	self.dataSource = [[[RPCDataSource alloc] initWithItemCommand:self.command] autorelease];
}
- (id<UITableViewDelegate>)createDelegate {
	return [[[TTTableViewDragRefreshDelegate alloc] initWithController:self] autorelease];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // force reload of list every time the VC appears (but not on first time)
    //if (alreadyAppeared)
        [self reload];
    alreadyAppeared=YES;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.dataSource cancel];
}
@end
