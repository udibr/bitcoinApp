//
//  BCTableTextItemCell.m
//  BitCoin
//
//  Created by Ehud Ben-Reuven on 4/8/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BCTableTextItemCell.h"


@implementation BCTableTextItemCell
- (void) attachTapHandler
{
    [self.textLabel setUserInteractionEnabled:YES];
    UIGestureRecognizer *touchy = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(handleTap:)];
    [self.textLabel addGestureRecognizer:touchy];
    [touchy release];
}


- (void) dealloc
{
    for (UIGestureRecognizer* gestureRecognizer in [NSArray arrayWithArray:[self.textLabel gestureRecognizers]])
        [self.textLabel removeGestureRecognizer:gestureRecognizer];
    [super dealloc];
}

- (void) handleTap: (UIGestureRecognizer*) recognizer
{
    [self.textLabel becomeFirstResponder];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setTargetRect:self.textLabel.frame inView:self.textLabel.superview];
    [menu setMenuVisible:YES animated:YES];
}

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString*)identifier {
    self = [super initWithStyle:style reuseIdentifier:identifier];
    if (self) {
        [self attachTapHandler];
    }
    
    return self;
}
@end
