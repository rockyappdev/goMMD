//
//  AppDelegate.h
//  goMMD
//
//  Created by Rocky on 2017/10/28.
//  Copyright (c) 2017 rockyappdev. All rights reserved.
//
//

#import <UIKit/UIKit.h>

@class DBFilesystem;
@class StartViewController;
@class SettingsController;
@class DocumentController;

@interface AppDelegate : UIResponder <UIApplicationDelegate> {
    UIWindow *window;
    StartViewController *startViewController;
    
    SettingsController *settingsController;
    DocumentController *documentControler;
    
}

//+ (AppDelegate *)sharedDelegate;

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) StartViewController *startViewController;

@property (readonly, strong, nonatomic) SettingsController *settingsController;
@property (readonly, strong, nonatomic) DocumentController *documentControler;

- (void)saveContext;
- (NSURL *)applicationDocumentsDirectory;

@end
