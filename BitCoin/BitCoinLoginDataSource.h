#import "Three20/Three20.h"

@interface BitCoinLoginDataSource : TTSectionedDataSource <UITextFieldDelegate> {
    UITextField* _serverField;
    UITextField* _usernameField;
    UITextField* _passwordField;
}
@end
