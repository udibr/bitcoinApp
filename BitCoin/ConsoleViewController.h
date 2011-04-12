//
//  ConsoleViewController.h
//  BitCoin
//
//  Created by Ehud Ben-Reuven on 4/11/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Three20/Three20.h"

@interface ConsoleViewController : TTTableViewController <UITextFieldDelegate>
{
    UITextField* _cmdField;
}
@property (nonatomic, retain) UITextField* cmdField;

@end
