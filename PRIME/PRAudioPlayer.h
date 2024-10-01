//
//  PRAudioPlayer.h
//  PRIME
//
//  Created by Aram on 12/28/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PRAudioPlayer : NSObject

- (instancetype)initWithAudioFileName:(NSString*)audioFileName;

@property (nonatomic, strong) NSString* audioFileName;

- (void)stopPlaying;
- (void)pausePlaying;
- (void)play:(void (^)(void))didStartPlaying failedToPlay:(void (^)(void))failedToPlay didFinishPlaying:(void (^)(BOOL successfully))compilation;

- (void)recordAudio:(void (^)(NSData* audioFile))compilation;
- (void)stopRecording:(void (^)(NSData* audioFile))compilation;

- (NSString*)duration;
- (NSString*)recordingDuration;

+ (void)saveAudioDataInFile:(NSData*)audioData withIdentifier:(NSString*)identifier; // If already exist file with identifier,than nothing will be happened.
+ (void)createDirectoryInDocumentsWithName:(NSString*)directoryName;

@end
