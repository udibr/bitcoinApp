//
//  UILabel+Clipboard.m
//  BitCoin
//
//  Created by Ehud Ben-Reuven on 4/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "UILabel+Clipboard.h"
//https://github.com/zoul/UILabel-Clipboard-Sample.git

@implementation UILabel (Clipboard)
#pragma mark Initialization
- (BOOL) canPerformAction: (SEL) action withSender: (id) sender
{
    return (action == @selector(copy:));
}

- (BOOL) canBecomeFirstResponder
{
    return YES;
}
- (void) copy:(id)sender {
    UIPasteboard *pboard = [UIPasteboard generalPasteboard];
    pboard.string = self.text;  
}

@end
