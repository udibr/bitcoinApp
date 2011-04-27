#import "Three20/Three20.h"
#import "BitCoinSettings.h"
#import "SynthesizeSingleton.h"
#import "NSString+URLEncoding.h"


@implementation BitCoinSettings
SYNTHESIZE_SINGLETON_FOR_CLASS(BitCoinSettings);
- (BOOL)islock
{
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	NSNumber *s = [prefs objectForKey:@"islock"];
    if (!s) return NO;//default
	return [s boolValue];
}
- (NSString*)lockpassword
{
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	NSString *s = [prefs objectForKey:@"lockpassword"];	
	return s;
}

- (NSString*)username
{
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	NSString *s = [prefs objectForKey:@"BCUSERNAME"];	
	return s;
}

- (void)setUsername:(NSString*)s
{
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	
	[prefs setObject:s forKey:@"BCUSERNAME"];	
	[prefs synchronize];
}
- (NSString*)password
{
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	NSString *s = [prefs objectForKey:@"BCPASSWORD"];
	return s;
}
- (void)setPassword:(NSString*)s
{
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	
	[prefs setObject:s forKey:@"BCPASSWORD"];	
	[prefs synchronize];
}

- (NSString*)server
{
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	NSString *s = [prefs objectForKey:@"BCSERVER"];
    if (!s) return @"";
	return s;
}

- (void)setServer:(NSString*)s
{
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	
	[prefs setObject:s forKey:@"BCSERVER"];	
	[prefs synchronize];
}
- (void)setLocal:(BOOL)local
{
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];	
	[prefs setObject:[NSNumber numberWithBool:local] forKey:@"BCLOCAL"];	
	[prefs synchronize];
}
- (BOOL)local
{
	NSUserDefaults* prefs = [NSUserDefaults standardUserDefaults];
	NSNumber *s = [prefs objectForKey:@"BCLOCAL"];
    if (!s) return YES;//default
	return [s boolValue];
}
- (NSString*)url
{
    if ([self local]) {
        return @"http://get:smart@127.0.0.1:8332";
    } else {
        NSString* h=[self server];
        if (!h)
            h=@"127.0.0.1";
        if ([h rangeOfString:@"://"].location == NSNotFound)
            h = [@"http://" stringByAppendingString:h];
        NSURL* r = [NSURL URLWithString:h];
        NSString* scheme = [r scheme];
        if (!scheme)
            scheme=@"http";
        NSString* u = [r user];
        if (!u)
            u = [self username];
        NSString* p = [r password];
        if (!p)
            p = [self password];
        NSString* host = [r host];
        if (!host)
            host = @"127.0.0.1";
        NSNumber* port = [r port];
        if (!port)
            port = [NSNumber numberWithInt:8332];
        NSString* path = [r path];
        if (!path)
            path = @"";
        
        return [NSString stringWithFormat:@"%@://%@:%@@%@:%@/%@",scheme,u,p,host,port,path];
    }
}
@end
