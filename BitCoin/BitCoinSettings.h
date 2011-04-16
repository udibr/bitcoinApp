#import <Foundation/Foundation.h>

#define GlobalSettings \
((BitCoinSettings *)[BitCoinSettings sharedBitCoinSettings])

@interface BitCoinSettings : NSObject {
}

+ (BitCoinSettings *)sharedBitCoinSettings;
@property(nonatomic, retain) NSString* username;
@property(nonatomic, retain) NSString* password;
@property(nonatomic, retain) NSString* server;
@property(nonatomic) BOOL local;
@property(nonatomic, readonly) NSString* url;

@end
