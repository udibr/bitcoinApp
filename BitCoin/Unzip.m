//
//  Unzip.m
//  BitCoin
//
//  Created by Ehud Ben-Reuven on 4/13/11.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//
#import <zlib.h>

#import "Unzip.h"
#define CHUNK 16384

//NSString *zippedDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"foo.db.gz"];
//NSString *unzippedDBPath = [documentsDirectory stringByAppendingPathComponent:@"foo2.db"];

void Unzip(NSString *zippedDBPath,NSString *unzippedDBPath)
{
    gzFile file = gzopen([zippedDBPath UTF8String], "rb");
    FILE *dest = fopen([unzippedDBPath UTF8String], "w");
    unsigned char buffer[CHUNK];
    int uncompressedLength;
    while ((uncompressedLength = gzread(file, buffer, CHUNK))) {
        // got data out of our file
        if(fwrite(buffer, 1, uncompressedLength, dest) != uncompressedLength || ferror(dest)) {
            NSLog(@"error writing data");
        }
    }
    fclose(dest);
    gzclose(file);
    NSLog(@"Finished unzipping database");    
}
