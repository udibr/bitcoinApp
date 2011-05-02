//
//  BCTableCaptionItemCell.m
//  BitCoin
//
//  Created by Ehud Ben-Reuven on 5/2/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BCTableCaptionItemCell.h"


@implementation BCTableCaptionItemCell
- (void) attachTapHandler
{
    [self.detailTextLabel setUserInteractionEnabled:YES];
    UIGestureRecognizer *touchy = [[UITapGestureRecognizer alloc]
                                   initWithTarget:self action:@selector(handleTap:)];
    [self.detailTextLabel addGestureRecognizer:touchy];
    [touchy release];
}


- (void) dealloc
{
    for (UIGestureRecognizer* gestureRecognizer in [NSArray arrayWithArray:[self.detailTextLabel gestureRecognizers]])
        [self.detailTextLabel removeGestureRecognizer:gestureRecognizer];
    [super dealloc];
}

- (void) handleTap: (UIGestureRecognizer*) recognizer
{
    [self.detailTextLabel becomeFirstResponder];
    UIMenuController *menu = [UIMenuController sharedMenuController];
    [menu setTargetRect:self.detailTextLabel.frame inView:self.detailTextLabel.superview];
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
