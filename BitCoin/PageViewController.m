//
//  PageViewController.m
//  BitCoin
//
//  Created by Ehud Ben-Reuven on 4/9/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "PageViewController.h"


@implementation PageViewController
- (id)initWithPage:(NSString*)page
{
    return [self initWithNavigatorURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] pathForResource:page ofType:@"html"]] query:nil];
}
@end
