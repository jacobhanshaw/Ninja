//
//  AppDelegate.h
//  ProjectReal
//
//  Created by Jacob Hanshaw on 10/19/12.
//  Copyright (c) 2012 Jacob Hanshaw. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate, AVAudioPlayerDelegate>{
    AVAudioPlayer *player;
}

@property (strong, nonatomic) UIWindow *window;
@property (nonatomic, strong) AVAudioPlayer *player;

@property (readonly, strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (readonly, strong, nonatomic) NSManagedObjectModel *managedObjectModel;
@property (readonly, strong, nonatomic) NSPersistentStoreCoordinator *persistentStoreCoordinator;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

- (void) vibrate;
- (void) playAudio:(NSString*)wavFileName;
- (void) stopAudio;

@end
