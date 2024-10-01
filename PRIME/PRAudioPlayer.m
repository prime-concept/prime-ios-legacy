//
//  PRAudioPlayer.m
//  PRIME
//
//  Created by Aram on 12/28/17.
//  Copyright © 2017 XNTrends. All rights reserved.
//

#import "PRAudioPlayer.h"
#import <AVFoundation/AVFoundation.h>

@interface PRAudioPlayer () <AVAudioRecorderDelegate, AVAudioPlayerDelegate>

@property (nonatomic, strong) AVAudioRecorder* audioRecorder;
@property (nonatomic, strong) AVAudioPlayer* audioPlayer;
@property (nonatomic, strong) NSString* audioFilePath;

@property (nonatomic, copy) void (^audioRecordingCompletionBlock)(NSData* audioFile);
@property (nonatomic, copy) void (^audioPlayingCompletionBlock)(BOOL successfully);

@end

static NSString* const kDidStartPlayingOrRecording = @"kDidStartPlayingOrRecording";
static const CGFloat kRecordingMaxDuration = 600.0f;

@implementation PRAudioPlayer

- (instancetype)initWithAudioFileName:(NSString*)audioFileName
{
    self = [super init];

    if (self) {
        _audioFileName = audioFileName;
        [self setupAudioPlayer];
    }

    return self;
}

- (instancetype)init
{
    self = [super init];

    if (self) {
        [self setupAudioRecorder];
    }

    return self;
}

#pragma mark - Helpers

- (void)setupAudioPlayer
{
    if (!_audioFileName) {
        return;
    }

    _audioFilePath = [self.class pathOfFileWithName:_audioFileName];
    NSURL* fileURL = [NSURL fileURLWithPath:_audioFilePath];

    _audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
    [_audioPlayer setDelegate:self];

    UInt32 volumeLevel = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(volumeLevel), &volumeLevel);

    [self registerForNotifications];
}

- (void)setupAudioRecorder
{
    // File path where the recording will be saved on the iOS device.
    NSString* audioFilePath = [[self.class applicationDocumentsDirectory].path stringByAppendingPathComponent:@"reportAudio.m4a"];
    NSURL* outputFileURL = [NSURL fileURLWithPath:audioFilePath];

    // Setup audio session
    AVAudioSession* session = [AVAudioSession sharedInstance];
    [session setCategory:AVAudioSessionCategoryPlayAndRecord error:nil];

    // Define the recorder setting.
    NSMutableDictionary* recordSetting = [[NSMutableDictionary alloc] init];

    [recordSetting setValue:[NSNumber numberWithInt:kAudioFormatMPEG4AAC] forKey:AVFormatIDKey];
    [recordSetting setValue:[NSNumber numberWithFloat:44100.0] forKey:AVSampleRateKey];
    [recordSetting setValue:[NSNumber numberWithInt:2] forKey:AVNumberOfChannelsKey];

    // Initiate and prepare the recorder.
    NSError* error = nil;
    _audioRecorder = [[AVAudioRecorder alloc] initWithURL:outputFileURL settings:recordSetting error:&error];
    _audioRecorder.delegate = self;
    _audioRecorder.meteringEnabled = YES;

    // Deal with any errors.
    if (error) {
        NSLog(@"error: %@", [error localizedDescription]);
    }

    [self registerForNotifications];
}

+ (NSURL*)applicationDocumentsDirectory
{
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory
                                                   inDomains:NSUserDomainMask] lastObject];
}

+ (NSString*)pathOfFileWithName:(NSString*)fileName
{
    NSString* docDirPath = [[self.class applicationDocumentsDirectory] path];
    NSString* filePath = [NSString stringWithFormat:@"%@/%@", docDirPath, fileName];

    return filePath;
}

+ (NSString*)timeInMinutesAndSeconds:(NSTimeInterval)duration
{
    NSInteger minutes = floor(duration / 60);
    NSInteger seconds = trunc(duration - minutes * 60);

    NSString* result = [NSString stringWithFormat:@"%ld:%02ld", (long)minutes, (long)seconds];

    return result;
}

- (void)setAudioFileName:(NSString*)audioFileName
{
    _audioFileName = audioFileName;
    [self setupAudioPlayer];
}

#pragma mark - Notifications

- (void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didStartPlayingAudioFile:)
                                                 name:kDidStartPlayingOrRecording
                                               object:nil];
}

- (void)unregisterForNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:kDidStartPlayingOrRecording
                                                  object:nil];
}

#pragma mark - Notification Handler

- (void)didStartPlayingAudioFile:(NSNotification*)notification
{
    if (notification.object != self && [_audioPlayer isPlaying]) {
        [_audioPlayer pause];
        [self audioPlayerDidFinishPlaying:_audioPlayer successfully:YES];
    }
}

#pragma mark - Public Functions

+ (void)saveAudioDataInFile:(NSData*)audioData withIdentifier:(NSString*)identifier
{
    if(!audioData)
    {
        return;
    }
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* filePath = [self.class pathOfFileWithName:identifier];

    if (![fileManager fileExistsAtPath:filePath]) {
        [audioData writeToFile:filePath atomically:YES];
    }
}

+ (void)createDirectoryInDocumentsWithName:(NSString*)directoryName
{
    NSFileManager* fileManager = [NSFileManager defaultManager];
    NSString* directoryPath = [self.class pathOfFileWithName:directoryName];
    [fileManager createDirectoryAtPath:directoryPath
                              withIntermediateDirectories:YES
                                               attributes:nil
                                                    error:nil];
}

- (void)recordAudio:(void (^)(NSData* audioFile))compilation
{
    if (!_audioRecorder) {
        [self setupAudioRecorder];
    }

    if (!_audioRecorder.recording) {
        _audioRecordingCompletionBlock = compilation;

        [[NSNotificationCenter defaultCenter] postNotificationName:kDidStartPlayingOrRecording object:_audioPlayer];

        if ([_audioPlayer isPlaying]) {
            [_audioPlayer stop];
        }

        AVAudioSession* session = [AVAudioSession sharedInstance];
        [session setActive:YES error:nil];

        [_audioRecorder recordForDuration:kRecordingMaxDuration];
    }
}

- (void)stopRecording:(void (^)(NSData* audioFile))compilation
{
    if ([_audioRecorder isRecording]) {
        _audioRecordingCompletionBlock = compilation;

        [_audioRecorder stop];

        AVAudioSession* audioSession = [AVAudioSession sharedInstance];
        [audioSession setActive:NO error:nil];
    }
}

- (void)stopPlaying
{
    if ([_audioPlayer isPlaying]) {
        [_audioPlayer stop];
    }
}

- (void)pausePlaying
{
    if ([_audioPlayer isPlaying]) {
        [_audioPlayer pause];
    }
}

- (void)play:(void (^)(void))didStartPlaying
        failedToPlay:(void (^)(void))failedToPlay
    didFinishPlaying:(void (^)(BOOL successfully))compilation
{
    if (!_audioPlayer && _audioFileName) {
        [self setupAudioPlayer];
    }

    if (![_audioRecorder isRecording]) {

        [[NSNotificationCenter defaultCenter] postNotificationName:kDidStartPlayingOrRecording object:_audioPlayer];

        if (!_audioPlayer) {
            failedToPlay();
        } else {
            [_audioPlayer play];

            didStartPlaying();
            _audioPlayingCompletionBlock = compilation;
        }
    }
}

- (NSString*)duration
{
    NSString* result = _audioPlayer ? [self.class timeInMinutesAndSeconds:_audioPlayer.duration] : @"";

    return result;
}

- (NSString*)recordingDuration
{
    NSTimeInterval currentTime = _audioRecorder.currentTime;
    NSString* result = [self.class timeInMinutesAndSeconds:currentTime];

    return result;
}

#pragma mark - AVAudioRecorderDelegate

- (void)audioRecorderDidFinishRecording:(AVAudioRecorder*)recorder successfully:(BOOL)flag
{
    if (_audioRecordingCompletionBlock) {
        NSData* audioFile = [NSData dataWithContentsOfFile:recorder.url.path];

        _audioRecordingCompletionBlock(audioFile);
        _audioRecordingCompletionBlock = nil;
    }
}

#pragma mark - AVAudioPlayerDelegate

- (void)audioPlayerDidFinishPlaying:(AVAudioPlayer*)player successfully:(BOOL)flag
{
    if (_audioPlayingCompletionBlock) {

        _audioPlayingCompletionBlock(flag);
        _audioPlayingCompletionBlock = nil;
    }
}

#pragma mark - Dealloc

- (void)dealloc
{
    [self unregisterForNotifications];
}

@end
