//
//  MyAddressViewController.h
//  BitCoin
//
//  Created by Ehud Ben-Reuven on 4/16/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import <MessageUI/MessageUI.h>
#import "RPCCommandViewController.h"

@class AddAddressModel;
@interface MyAddressViewController : RPCCommandViewController <MFMailComposeViewControllerDelegate>
{
    NSString *address;
    AddAddressModel* addRequest;
}
@property (nonatomic, retain) NSString *address;
@property (nonatomic, retain) AddAddressModel* addRequest;
- (IBAction)sendActions:(id)sender;
@end
