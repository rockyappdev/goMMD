//
//  StartViewController.h
//  goMMD
//
//  Created by Rocky on 2017/10/28.
//  Copyright (c) 2017 rockyappdev. All rights reserved.
//
//

#import <UIKit/UIKit.h>

@class MainViewController;
@class DocumentController;

@interface StartViewController : UIViewController <UISplitViewControllerDelegate> {
    MainViewController *MainViewController;
    DocumentController *documentController;
}

@property (nonatomic, retain) MainViewController *mainViewController;
@property (nonatomic, retain) DocumentController *documentController;

- (IBAction)start:(id)sender;

// calll back from AppDelegate
- (void)applicationWillResignActive;
- (void)applicationDidEnterBackground;
- (void)applicationWillEnterForeground;
- (void)applicationDidBecomeActive;
- (void)applicationWillTerminate;

@end
