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
@synthesize params = _params;
-(id)initWithRepeat:(BOOL)repeat command:(NSString*)command
{
    self = [self init];
    if (self) {
        repeatCmd = repeat;
        self.command = command;
        self.title = command;

    }
    return  self;
}
-(id)initWithRepeat:(BOOL)repeat command:(NSString*)command param1:(NSString*)param1
{
    self = [self initWithRepeat:repeat command:command];
    if (self) {
        if ([param1 isEqualToString:@" "])
            param1 = @"";
        self.params = [NSArray arrayWithObject:param1];
    }
    return self; 
}
-(id)initWithRepeat:(BOOL)repeat command:(NSString*)command param1:(NSString*)param1 param2:(NSString*)param2
{
    self = [self initWithRepeat:repeat command:command];
    if (self) {
        if ([param1 isEqualToString:@" "])
            param1 = @"";
        if ([param2 isEqualToString:@" "])
            param2 = @"";
        self.params = [NSArray arrayWithObjects:param1,param2,nil];
    }
    return self; 
}
-(id)initWithRepeat:(BOOL)repeat command:(NSString*)command param1:(NSString*)param1 param2:(NSString*)param2 param3:(NSString*)param3
{
    self = [self initWithRepeat:repeat command:command];
    if (self) {
        if ([param1 isEqualToString:@" "])
            param1 = @"";
        if ([param2 isEqualToString:@" "])
            param2 = @"";
        if ([param3 isEqualToString:@" "])
            param3 = @"";
        self.params = [NSArray arrayWithObjects:param1,param2,param3,nil];
    }
    return self; 
}

-(void)dealloc
{
   // [self.dataSource cancel]; // this causes a crash in TTModelViewController dealloc (maybe this releases _model and then try to remove delegate
    self.params = nil;
    self.command = nil;
    [super dealloc];
}

- (void)createModel {
	self.dataSource = [[[RPCDataSource alloc] initWithItemRepeat:repeatCmd command:self.command params:self.params] autorelease];
}
- (id<UITableViewDelegate>)createDelegate {
	return [[[TTTableViewDragRefreshDelegate alloc] initWithController:self] autorelease];
}
- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    // force reload of list every time the VC appears (but not on first time)
    //if (alreadyAppeared)
    //    [self reload];
    alreadyAppeared=YES;
}
-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    [self.dataSource cancel];
}
@end
