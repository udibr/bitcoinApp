//
// Copyright 2009-2010 Facebook
//
// Licensed under the Apache License, Version 2.0 (the "License");
// you may not use this file except in compliance with the License.
// You may obtain a copy of the License at
//
//    http://www.apache.org/licenses/LICENSE-2.0
//
// Unless required by applicable law or agreed to in writing, software
// distributed under the License is distributed on an "AS IS" BASIS,
// WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
// See the License for the specific language governing permissions and
// limitations under the License.
//

#import "StyleSheet.h"

#import "Three20/Three20.h"


///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
///////////////////////////////////////////////////////////////////////////////////////////////////
@implementation StyleSheet
- (UIColor*)navigationBarTintColor {
    return [UIColor colorWithRed:0x76/255. green:0xa4/255. blue:0x80/255. alpha:1.];
}
- (TTStyle*)launcherButton:(UIControlState)state {
    return
    [TTPartStyle styleWithName:@"image" style:TTSTYLESTATE(launcherButtonImage:, state) next:
     [TTTextStyle styleWithFont:[UIFont boldSystemFontOfSize:11] color:RGBCOLOR(255, 255, 255)
                minimumFontSize:11 shadowColor:nil
                   shadowOffset:CGSizeZero next:nil]];
}

@end
