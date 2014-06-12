//
//  FileManager.m
//  enroute-app
//
//  Created by Stijn Heylen on 11/06/14.
//  Copyright (c) 2014 Stijn Heylen. All rights reserved.
//

#import "FileManager.h"

@implementation FileManager

- (NSString *)documentsDirectoryPath
{
    return NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES)[0];
}

- (NSString *)tempDirectoryPath
{
    return NSTemporaryDirectory();
}

#pragma mark - Destination URL
- (NSURL *)videoTmpURL
{
    NSString *filePath = [[self tempDirectoryPath] stringByAppendingPathComponent:VIDEO_FILE];
	return [NSURL fileURLWithPath:filePath];
}

- (NSURL *)audioTmpURL
{
    NSString *filePath = [[self tempDirectoryPath] stringByAppendingPathComponent:AUDIO_FILE];
	return [NSURL fileURLWithPath:filePath];
}

- (NSURL *)floorsTmpDirUrl
{
    NSString *filePath = [[self tempDirectoryPath] stringByAppendingPathComponent:FLOORS_DIR];
	return [NSURL fileURLWithPath:filePath];
}

#pragma mark - File management
- (void)removeFileOrDirectory:(NSURL *)fileURL
{
    NSError *error;
    if (![[NSFileManager defaultManager] removeItemAtURL:fileURL error:&error]) {
        if ([self.delegate respondsToSelector:@selector(fileManagerDidFailWithError:)]) {
            [self.delegate fileManagerDidFailWithError:error];
        }
    }
}

- (NSURL *)copyFileToDirectory:(NSString *)directoryPath fileUrl:(NSURL *)fileURL newFileName:(NSString *)fileName
{
    NSString *destinationPath = [directoryPath stringByAppendingFormat:@"/%@", fileName];
	NSError	*error;
	if (![[NSFileManager defaultManager] copyItemAtURL:fileURL toURL:[NSURL fileURLWithPath:destinationPath] error:&error]){
        if ([self.delegate respondsToSelector:@selector(fileManagerDidFailWithError:)]) {
            [self.delegate fileManagerDidFailWithError:error];
        }
	}
    return [NSURL fileURLWithPath:destinationPath];
}

#pragma mark - Directory management
- (NSURL *)createDirectoryAtDirectory:(NSString *)directoryPath withName:(NSString *)directoryName
{
    NSString *destinationPath = [directoryPath stringByAppendingFormat:@"/%@", directoryName];
    if (![[NSFileManager defaultManager] fileExistsAtPath:destinationPath]){
        NSError* error;
        if(![[NSFileManager defaultManager] createDirectoryAtPath:destinationPath withIntermediateDirectories:NO attributes:nil error:&error]){
            if ([self.delegate respondsToSelector:@selector(fileManagerDidFailWithError:)]) {
                [self.delegate fileManagerDidFailWithError:error];
            }
        }
        return [NSURL fileURLWithPath:destinationPath];
    }
    return nil;
}

@end
