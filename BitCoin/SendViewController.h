//
//  SendViewController.h
//
//  Created by Ehud Ben-Reuven on 4/1/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import "Three20/Three20.h"

@interface SendViewController : TTTableViewController <TTURLRequestDelegate,UIAlertViewDelegate,UITextFieldDelegate>
{
    UITextField* _toField;
    UITextField* _amountField;
    NSString* toaddress;
    float   amount;
}
@property (nonatomic, retain) UITextField* toField;
@property (nonatomic, retain) UITextField* amountField;
@property (nonatomic, retain) NSString* toaddress;

@end
