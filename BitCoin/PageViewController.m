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
- (BOOL)webView:(UIWebView*)webView shouldStartLoadWithRequest:(NSURLRequest*)request
 navigationType:(UIWebViewNavigationType)navigationType {
    if ([[TTNavigator navigator].URLMap isSchemeSupported:request.URL.scheme]) {
        [_loadingURL release];
        _loadingURL = [[NSURL URLWithString:@"about:blank"] retain];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW,0.01*1000000000),dispatch_get_main_queue(),^{
            [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:request.URL.absoluteString]];
        });
        [[TTNavigator navigator] openURLAction:[TTURLAction actionWithURLPath:@"bitcoin://launcher"]];
        return NO;
    }
    return [super webView:webView shouldStartLoadWithRequest:request
           navigationType:navigationType];
}
@end
