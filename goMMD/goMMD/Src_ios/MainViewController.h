//
//  MainViewController.h
//  goMMD
//
//  Created by Rocky on 2017/10/28.
//  Copyright (c) 2017 rockyappdev. All rights reserved.
//
//

#import <UIKit/UIKit.h>


@class ScenarioData;
@class ScenarioGroupViewController;
@class ModelGroupViewController;
@class MotionGroupViewController;

@interface MainViewController : UITableViewController {
    ScenarioData *scenarioData;
    UINavigationController *navigationController;
    UISplitViewController *splitViewController;
    ScenarioGroupViewController *scenarioGroupViewController;
    ModelGroupViewController *modelGroupViewController;
    MotionGroupViewController *motionGroupViewController;
    NSInteger deviceModel;
    NSMutableDictionary *paramDict;
}

@property (nonatomic,assign) NSInteger deviceModel;

// file
@property (nonatomic,retain) ScenarioData *scenarioData;
@property (nonatomic,retain) ScenarioGroupViewController *scenarioGroupViewController;
@property (nonatomic,retain) ModelGroupViewController *modelGroupViewController;
@property (nonatomic,retain) MotionGroupViewController *motionGroupViewController;

@property (nonatomic,retain) UINavigationController *navigationController;
@property (nonatomic,retain) NSMutableDictionary *paramDict;

// calll back from AppDelegate
- (void)applicationWillResignActive;
- (void)applicationDidEnterBackground;
- (void)applicationWillEnterForeground;
- (void)applicationDidBecomeActive;
- (void)applicationWillTerminate;

@end
