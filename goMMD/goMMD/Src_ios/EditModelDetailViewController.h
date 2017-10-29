//
//  EditModelDetailViewController.h
//  goMMD
//
//  Created by Rocky on 2017/10/28.
//  Copyright (c) 2017 rockyappdev. All rights reserved.
//
//

#import <UIKit/UIKit.h>

#import <CoreData/CoreData.h>


@class DocumentController;
@class MMDViewController;
@class EditViewController;
@class ScenarioData;

@interface EditModelDetailViewController : UITableViewController {
    NSManagedObjectContext *managedObjectContext;
    ScenarioData *scenarioData;
    DocumentController *documentController;
    EditViewController *editViewController;
    UINavigationController *navigationController;
    UISplitViewController *splitViewController;
    bool editMode;
    NSInteger deviceModel;
    NSMutableDictionary *paraDict;

}


// CoreDB
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (nonatomic,retain) ScenarioData *scenarioData;
@property (nonatomic,assign) NSInteger deviceModel;

@property (nonatomic,retain) DocumentController *documentController;

// Navibar Controller
@property (nonatomic,retain) UINavigationController *navigationController;
@property (nonatomic,retain) UISplitViewController *splitViewController;
@property (nonatomic,retain) EditViewController *editViewController;
@property (nonatomic,assign) bool editMode;
@property (nonatomic,retain) NSMutableDictionary *paramDict;

// calll back from AppDelegate
- (void)applicationWillResignActive;
- (void)applicationDidEnterBackground;
- (void)applicationWillEnterForeground;
- (void)applicationDidBecomeActive;
- (void)applicationWillTerminate;

@end
