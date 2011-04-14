//
//  FileSystem.m
//  BitCoin
//
//  Created by Ehud Ben-Reuven on 4/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "BCFileSystem.h"


NSString *applicationDocumentsDirectory()
{	
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *basePath = ([paths count] > 0) ? [paths objectAtIndex:0] : nil;
    return basePath;
}

NSString* backupwalletPath()
{
    NSString* documentsDir=applicationDocumentsDirectory();
    return [documentsDir stringByAppendingPathComponent:@"backupwallet.dat"];
}