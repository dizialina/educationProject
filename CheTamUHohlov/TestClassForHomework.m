//
//  TestClassForHomework.m
//  CheTamUHohlov
//
//  Created by Admin on 08.01.16.
//  Copyright © 2016 Roman.Safin. All rights reserved.
//

#import "TestClassForHomework.h"
#import "Constants.h"

@implementation TestClassForHomework {
    NSString* pathToTempFolder;
}

- (void)testMethodCreateDBInTemp {
    
    pathToTempFolder = NSTemporaryDirectory();
    NSLog(@"Path to temp folder: \n%@", pathToTempFolder);
    
    NSFileManager *manager = [NSFileManager defaultManager];
    for (int i = 0; i < 10; i++) {
        NSString *pathDBInBundle = [NSString stringWithFormat:@"%@/%@", [NSBundle mainBundle].resourcePath, DBName];
        NSString *pathDBinTemp = [NSString stringWithFormat:@"%@DiziDB%d.sqlite", pathToTempFolder, i];
        //NSLog(@"%@", pathDBinTemp);
        BOOL success = [manager copyItemAtPath:pathDBInBundle toPath:pathDBinTemp error:nil];
        if (!success) {
            NSLog(@"Error copy file to Temp");
        }
    }
    
    [self checkingContentInFolderTemp];

}

- (void)testMethodCleanTempFolder {
    
    pathToTempFolder = NSTemporaryDirectory();
    //NSLog(@"%@", pathToTempFolder);
    NSFileManager *manager = [NSFileManager defaultManager];
    
    NSArray *listFilesInTemp = [manager contentsOfDirectoryAtPath:pathToTempFolder error:nil];
    for (NSString *file in listFilesInTemp) {
        BOOL success = [manager removeItemAtPath:[pathToTempFolder stringByAppendingString:file] error:nil];
        NSLog(@"Deleting file %@", file);
        if (!success) {
            NSLog(@"Error deleting files from Temp");
        }
    }
    
    [self checkingContentInFolderTemp];
    
}

- (void)checkingContentInFolderTemp {
    
    NSFileManager *manager = [NSFileManager defaultManager];
    NSArray* listFilesInTemp = [manager contentsOfDirectoryAtPath:pathToTempFolder error:nil];
    NSLog(@"Checking list of files in Temp:");
    if ([listFilesInTemp count] == 0) {
        NSLog(@"folder is empty");
    } else {
        NSLog(@"%@", listFilesInTemp);
    }
    
}


@end
