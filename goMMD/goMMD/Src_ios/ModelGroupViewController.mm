//
//  MasterViewController.m
//  MMD4U
//
//  Created by Rocky on 2013/03/21.
//  Copyright (c) 2013年 twincle4u. All rights reserved.
//

#import "ModelGroupViewController.h"
#import "ModelViewController.h"
#import "TextEditViewController.h"
#import "EditModelDetailViewController.h"

#import "ScenarioData.h"

@interface ModelGroupViewController ()

@property (strong, nonatomic) NSFetchedResultsController *fetchedResultsController;

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath;
- (void)addNewGroup:(id)sender;

@end


@implementation ModelGroupViewController

@synthesize navigationController = _navigationController;
@synthesize scenarioData = _scenarioData;
@synthesize splitViewController = _splitViewController;
@synthesize deviceModel = _deviceModel;
@synthesize viewMode = _viewMode;
@synthesize parentGroupDict = _parentGroupDict;
@synthesize groupDict = _groupDict;
@synthesize groupList = _groupList;
@synthesize groupName = _groupName;
@synthesize groupLevel = _groupLevel;
@synthesize paramDict = _paramDict;
@synthesize selectedIndexPathList = _selectedIndexPathList;
@synthesize editModelDetailViewController = _editModelDetailViewController;
@synthesize modelViewControllerAll = _modelViewControllerAll;
@synthesize modelViewControllerGrp = _modelViewControllerGrp;


- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];

    _selectedIndexPathList = [NSMutableArray array];

    return self;
}

- (void)setGroupDict:(NSMutableDictionary*)aGroupDict name:(NSString *)name
{
    NSLog(@"... ModelGroupViewController: setGroupDict");

    _groupName = name;
    _groupDict = aGroupDict;

    NSMutableDictionary *listDict = [_groupDict valueForKey:@"listDict"];
    
    _groupList = [[listDict allKeys] sortedArrayUsingComparator:^(id obj1, id obj2) {
        return [(NSString*)obj1 compare:(NSString*)obj2];
    }];
    
    NSLog(@"... setGroupDict: name[%@], _groupList[%ld]", name, (unsigned long)[_groupList count]);
}

- (void)viewDidLoad
{
    NSLog(@"... ModelGroupViewController: viewDidLoad called");

    NSLog(@"... paramDict count[%ld]", (unsigned long)[_paramDict count]);

    if (_selectedIndexPathList == nil) {
        _selectedIndexPathList = [NSMutableArray array];
    }

    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        _deviceModel = 5;
    } else {
        _deviceModel = 14;
    }

    if (_viewMode != 1) {
        // Not Edit mode
        [self setEditing:YES];
        
    }

    if (_viewMode == 1) {
        // Edit mode
        // Top Navigation bar
        //self.navigationItem.rightBarButtonItem = [self editButtonItem];
        
        UIBarButtonItem *buttonAddGroup = [[UIBarButtonItem alloc] initWithTitle:@"AddGroup"
                                                                           style:UIBarButtonItemStylePlain
                                                                          target:self
                                                                          action:@selector(addNewGroup:)];
        UIBarButtonItem *buttonAddScenario = [[UIBarButtonItem alloc] initWithTitle:@"AddModel"
                                                                              style:UIBarButtonItemStylePlain
                                                                             target:self
                                                                             action:@selector(addModelToGroup:)];
        NSArray *topButtons = [NSArray arrayWithObjects:buttonAddGroup, buttonAddScenario, nil];
        [self.navigationItem setRightBarButtonItems:topButtons animated:YES];
    
        
        // Bottom Menu bar
        UIBarButtonItem *spacer = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
        UIBarButtonItem *buttonTrush = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:@selector(deleteObject:)];
        //UIBarButtonItem *buttonDel = [[[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemTrash target:self action:nil] autorelease];
        NSArray *bottomButtons = [NSArray arrayWithObjects:spacer, buttonTrush, spacer, nil];
        [self setToolbarItems:bottomButtons animated:YES];

    }
    
}

- (void)setEditing:(BOOL)editing animated:(BOOL)animated
{
    NSIndexPath *indexPath;
    NSInteger numRow = [_groupList count];

    if (editing) {
        // Editing mode
        indexPath = [NSIndexPath indexPathForRow:numRow inSection:0];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        /*
        indexPath = [NSIndexPath indexPathForRow:numRow inSection:0];
        [self.tableView insertRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
        */
        
    } else {
        // end of editing mode
        indexPath = [NSIndexPath indexPathForRow:numRow inSection:0];
        [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationTop];
    }

    [super setEditing:editing animated:animated];
}

- (void)viewWillAppear:(BOOL)animated {
    NSLog(@"... ModelGroupViewController: viewWillAppear");
    
    NSLog(@"... paramDict count[%lu]", (unsigned long)[_paramDict count]);

    if (_paramDict != nil) {
        NSString *paramFrom = [_paramDict valueForKey:@"paramFrom"];
        NSLog(@"... paramDict from [%@]", paramFrom);
        if ([paramFrom isEqualToString:@"parent"]) {
            _groupDict = [_paramDict valueForKey:@"groupDict"];
            _groupName = [_paramDict valueForKey:@"groupName"];
            _parentGroupDict = [_paramDict valueForKey:@"parentGroupDict"];
            
        } else if ([paramFrom isEqualToString:@"TextEditViewController"]) {
            NSString *fieldName = [_paramDict valueForKey:@"fieldName"];
            if ([fieldName isEqualToString:@"groupName"]) {
                NSString *oldName = [_paramDict valueForKey:@"oldTextValue"];
                NSString *newName = [_paramDict valueForKey:@"newTextValue"];
                if (![newName isEqualToString:oldName]) {
                    NSString *oldPath = [_groupDict valueForKey:@"path"];
                    NSString *targetName = [_scenarioData getTargetNameForDictionary:_parentGroupDict name:newName device:nil];
                    [_scenarioData renameObjectInDictionary:_parentGroupDict key:oldName toName:newName];
                    NSString *newPath = [_groupDict valueForKey:@"path"];
                    NSMutableDictionary *pathDict = [[_scenarioData getModelGroupListDict] valueForKey:@"pathDict"];
                    [pathDict setValue:_groupDict forKeyPath:newPath];
                    [pathDict removeObjectForKey:oldPath];
                    [_scenarioData saveModelGroupListFile];
                    // do not reload groupList, will be broke the reference
                    _groupName = targetName;
                }
            }
        }
    } else {
        
        if (_parentGroupDict == nil) {
            _groupName = @"Top";
        }
        
    }

    [_paramDict setObject:@"" forKey:@"paramFrom"];

    // reload groupDict to groupList for any changes
    [self setGroupDict:_groupDict name:_groupName];
    
    if (_viewMode == 0) {
        self.title = [NSString stringWithFormat:@"Select Model Group"];
    } else  if (_viewMode == 1) {
        self.title = [NSString stringWithFormat:@"Edit Model Group"];
    }

    if (0) {
        NSLog(@"... selectedIndexPathList count[%lu]", (unsigned long)[_selectedIndexPathList count]);
        if (_selectedIndexPathList != nil) {
            for (NSIndexPath *indexPath in _selectedIndexPathList) {
                UITableViewCell *cell = [self.tableView cellForRowAtIndexPath:indexPath];
                cell.selected = YES;
                //cell.accessoryType = UITableViewCellAccessoryCheckmark;
            }
        }
    }

    if (_viewMode == 1) {
        // Edit mode
        self.navigationController.toolbarHidden = NO;
    } else {
        self.navigationController.toolbarHidden = YES;
    }

    [self.tableView reloadData];
	[super viewWillAppear:animated];

}

- (void)viewWillDisappear:(BOOL)animated
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)insertNewObject:(id)sender
{
    NSLog(@"... ModelGroupViewController: insertNewObject called");
    
}

- (void)removeAddedNewEntryObject
{
    NSLog(@"... ModelGroupViewController: removeNewObject called");
    
}

- (void)addNewGroup:(id)sender
{
    NSLog(@"... ModelGroupViewController: addNewGropu called");
    
    [_scenarioData addNewGroupToModelGroupDict:_groupDict];
    [_scenarioData saveModelGroupListFile];
    // do not reload groupList, will be broke the reference

    [self setGroupDict:_groupDict name:_groupName];

    [self.tableView reloadData];
}

- (void)deleteObject:(id)sender
{
    NSLog(@"... ModelGroupViewController: deleteObject");
    
    NSArray *selectedArr = [self.tableView indexPathsForSelectedRows];
    if ([selectedArr count] > 0) {
        // delete scenario items
        NSMutableDictionary *listDict = [_groupDict valueForKey:@"listDict"];
        
        for (NSIndexPath *indexPath in selectedArr) {
            NSString *key = _groupList[indexPath.row];
            if ([listDict valueForKey:key]) {
                [listDict removeObjectForKey:key];
                NSLog(@"... removed model[%@] from group[%@]", key, _groupName);

            }
        }
        
        [_scenarioData saveModelGroupListFile];

        [self setGroupDict:_groupDict name:_groupName];
        
        [self.tableView reloadData];

    } else {
        // delete current group
        
        // show alert and get confirmation
        UIAlertView *alert = [[UIAlertView alloc] init];
        alert.delegate = self;
        alert.title = @"Delete this group";
        alert.message = @"Would you like to delete this group?";
        [alert addButtonWithTitle:@"No"];
        [alert addButtonWithTitle:@"Yes"];
        alert.cancelButtonIndex = 0;
        [alert show];
        
    }
    
}

- (void) alertView:(UIAlertView*)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex != alertView.cancelButtonIndex) {
        if ([alertView.title isEqualToString:@"Delete this group"]) {
            if (_parentGroupDict == nil) {
                [[_parentGroupDict valueForKey:@"listDict"] removeAllObjects];
            }
            
            [[_parentGroupDict valueForKey:@"listDict"] removeObjectForKey:_groupName];
            
            NSLog(@"... removed group[%@]", _groupName);
            
            [_scenarioData saveModelGroupListFile];
            
            [_navigationController popViewControllerAnimated:YES];
            
        }
    }
    
}

- (void)addModelToGroup:(id)sender
{
    NSLog(@"... ModelGroupViewController: addModelToGroup called");
    
    // Play List for All Scenario
    if (_modelViewControllerGrp == nil) {
        if (_deviceModel < 10) {
            _modelViewControllerGrp = [[ModelViewController alloc] initWithNibName:@"TableViewController_iPhone" bundle:nil];
        } else {
            _modelViewControllerGrp = [[ModelViewController alloc] initWithNibName:@"TableViewController_iPad" bundle:nil];
        }
    }

    [_paramDict setValue:_groupName forKey:@"groupName"];
    [_paramDict setValue:_groupDict forKey:@"groupDict"];
    [_paramDict setValue:@"parent" forKey:@"paramFrom"];
    
    _modelViewControllerGrp.paramDict = _paramDict;
    _modelViewControllerGrp.viewMode = 2;
    _modelViewControllerGrp.scenarioData = _scenarioData;
    _modelViewControllerGrp.navigationController = self.navigationController;
    
    NSLog(@"... ModelGroupViewController -> ModelViewController");
    
    [self.navigationController pushViewController:_modelViewControllerGrp animated:YES];
    
}

- (void)showModelDetail:(UIButton*)button
{
    NSLog(@"... ModelGroupViewController: showModelDetail");
    // show text files
    
}

#pragma mark - Table View

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    int n = 2;

    // _viewMode:0 == selection mode
    //   section:0 -- All Model
    //   section:1 -- Group and Model list
    // _viewMode:1 == Edit mode
    //   section:0 -- Group Name for amend
    //   section:1 -- Group and Model list
    
    return n;
}

-(NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSString *title = nil;
    
    if (_viewMode == 0) {
        if (section == 0) {
            title = @"All Model";
        } else {
            title = @"Group and Model";
        }
    } else if (_viewMode == 1) {
        if (section == 0) {
            title = @"Name";
        } else {
            title = @"Group and Model";
        }
    }
    
    return title;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSInteger n;
    
    if (_viewMode == 1 && section == 0) {
            n = 1;
    } else {
        if (section == 0) {
            // section 0
            n = 1;
        } else {
            // section 1
            n = [_groupList count];
        }
        
    }
    
    return n;
}

// Customize the appearance of table view cells.
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
        cell.textLabel.numberOfLines = 0;
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }

    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSString *title;
    
    NSLog(@"... tableView configureCell= viewMode[%ld] section[%ld], row[%ld]", (long)_viewMode, (long)indexPath.section, (long)indexPath.row);
    
    cell.accessoryType = UITableViewCellAccessoryNone;
    
    //cell.textLabel.numberOfLines = 0;
    if (_viewMode == 1 && indexPath.section == 0) {
        title = _groupName;
    } else {
        if (indexPath.section == 0) {
            // Section 0
            title = @"All Model List";
        } else {
            NSString *key = _groupList[indexPath.row];
            NSLog(@"... key=[%@]", key);
            
            NSMutableDictionary *dictInfo = [[_groupDict valueForKey:@"listDict"] valueForKey:key];
            NSString *kind = [dictInfo valueForKey:@"kind"];
            if ([kind isEqualToString:@"group"]) {
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            } else {
                UIButton *infoButton = [UIButton buttonWithType:UIButtonTypeInfoDark];
                [infoButton addTarget:self action:@selector(showModelDetail:) forControlEvents:UIControlEventTouchUpInside];
                infoButton.tag = indexPath.row;
                cell.accessoryView = infoButton;
            }
            title = key;
            
        }
    }
    
    cell.textLabel.text = title;
    
    if (_deviceModel > 10) {
        cell.textLabel.font = [UIFont systemFontOfSize:16.0];
    } else {
        cell.textLabel.font = [UIFont systemFontOfSize:[UIFont smallSystemFontSize]];
    }
    
    NSLog(@"... tableView configureCell finished");
    
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL ret = YES;
    // Return NO if you do not want the specified item to be editable.
    if (_viewMode == 1 && indexPath.section == 0) {
        ret = NO;
    } else if (indexPath.section == 0) {
        ret = NO;
    } else {
        NSString *key = _groupList[indexPath.row];
        NSMutableDictionary *dictInfo = [_groupDict valueForKey:key];
        NSString *kind = [dictInfo valueForKey:@"kind"];
        if ([kind isEqualToString:@"group"]) {
            ret = NO;
        }
    }

    return ret;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        ;
    }
}

- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // The table view should not be re-orderable.
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"... ModelGroupViewController: tableView didSelectRowAtIndexPath called");
    NSLog(@"... indexPath.section[%ld] indexPath.row[%ld]", (long)indexPath.section, (long)indexPath.row);
    NSLog(@"... viewMode[%ld]", (long)_viewMode);
    
    if (_viewMode == 1 && indexPath.section == 0) {
        if ([_groupName isEqualToString:@"Top"]) {
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            cell.selected = NO;
            cell.accessoryType = UITableViewCellAccessoryNone;
        } else {
            TextEditViewController *textEditViewController;
            
            if (_deviceModel < 10) {
                textEditViewController = [[TextEditViewController alloc] initWithNibName:@"TextEditViewController_iPhone" bundle:nil];
            } else {
                textEditViewController = [[TextEditViewController alloc] initWithNibName:@"TextEditViewController_iPad" bundle:nil];
            }

            [_paramDict setValue:@"groupName" forKey:@"fieldName"];
            [_paramDict setValue:_groupName forKey:@"oldTextValue"];
            [_paramDict setValue:@"parent" forKey:@"paramFrom"];
            
            NSLog(@"... _paramDict[%ld]", (unsigned long)[_paramDict count]);
            
            textEditViewController.paramDict = _paramDict;
            textEditViewController.navigationController = _navigationController;
            
            [self.navigationController pushViewController:textEditViewController animated:YES];
        }

    } else {
        
        if (indexPath.section == 0) {
            // Section 0
            if (_modelViewControllerAll == nil) {
                if (_deviceModel < 10) {
                    _modelViewControllerAll = [[ModelViewController alloc] initWithNibName:@"TableViewController_iPhone" bundle:nil];
                } else {
                    _modelViewControllerAll = [[ModelViewController alloc] initWithNibName:@"TableViewController_iPad" bundle:nil];
                }
            }
            
            [_paramDict setValue:_groupDict forKey:@"groupDict"];
            [_paramDict setValue:_groupName forKey:@"groupName"];
            [_paramDict setValue:@"parent" forKey:@"paramFrom"];
            
            _modelViewControllerAll.viewMode = 0;
            _modelViewControllerAll.paramDict = _paramDict;
            _modelViewControllerAll.scenarioData = _scenarioData;
            _modelViewControllerAll.navigationController = self.navigationController;
            _modelViewControllerAll.editModelDetailViewController = _editModelDetailViewController;
            
            NSLog(@"... ModelGroupViewController -> ModelViewController");
            
            [self.navigationController pushViewController:_modelViewControllerAll animated:YES];
            
        } else {
            // Group List

            ModelGroupViewController *modelGroupViewController;
            
            if (_deviceModel < 10) {
                modelGroupViewController = [[ModelGroupViewController alloc] initWithNibName:@"TableViewController_iPhone" bundle:nil];
            } else {
                modelGroupViewController = [[ModelGroupViewController alloc] initWithNibName:@"TableViewController_iPad" bundle:nil];
            }
            
            UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            
            NSString *key = _groupList[indexPath.row];
            NSMutableDictionary *dictInfo = [[_groupDict valueForKey:@"listDict"] valueForKey:key];
            NSString *kind = [dictInfo valueForKey:@"kind"];
            if ([kind isEqualToString:@"group"]) {
                // Group Dict
                
                [_paramDict setValue:dictInfo forKey:@"groupDict"];
                [_paramDict setValue:key forKey:@"groupName"];
                [_paramDict setValue:_groupDict forKey:@"parentGroupDict"];
                [_paramDict setValue:@"parent" forKey:@"paramFrom"];
                
                NSLog(@"... _paramDict[%lu]", (unsigned long)[_paramDict count]);
                
                modelGroupViewController.paramDict = _paramDict;
                modelGroupViewController.scenarioData = _scenarioData;
                modelGroupViewController.navigationController = self.navigationController;
                modelGroupViewController.editModelDetailViewController = _editModelDetailViewController;
                modelGroupViewController.groupLevel = _groupLevel+1;
                modelGroupViewController.viewMode = self.viewMode;
                
                NSLog(@"... ModelGroupViewController -> ModelGroupViewController");
                
                cell.accessoryType = UITableViewCellAccessoryNone;
                cell.selected = NO;
                
                [self.navigationController pushViewController:modelGroupViewController animated:YES];
            } else {
                // Scenario Item
                //[_selectedIndexPathList addObject:[indexPath copy]];
                //cell.accessoryType = UITableViewCellAccessoryCheckmark;
                
                if (_viewMode == 0) {
                    NSString *path = _groupList[indexPath.row];
                    NSString *name = [path lastPathComponent];
                    NSString *zipPath = [_scenarioData getZipPathOfModelPath:path];
                    
                    [_scenarioData setModelForScenarioInfoIndexPath:name path:path zipPath:zipPath];
                    // skip GroupViewController and back to EditDetailViewController
                    [_navigationController popToViewController:_editModelDetailViewController animated:YES];
                }
            }
            
        }
        
    }

}

- (void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    //[_selectedIndexPathList removeObject:indexPath];
    
    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    cell.accessoryType = UITableViewCellAccessoryNone;
}

// call back from AppDelegagte
- (void)applicationWillResignActive
{
    [_editModelDetailViewController applicationWillResignActive];
}

- (void)applicationDidEnterBackground
{
    [_editModelDetailViewController applicationDidEnterBackground];
}

- (void)applicationWillEnterForeground
{
    [_editModelDetailViewController applicationWillEnterForeground];
}

- (void)applicationDidBecomeActive
{
    [_editModelDetailViewController applicationDidBecomeActive];
}

- (void)applicationWillTerminate
{
    [_editModelDetailViewController applicationWillTerminate];
}


@end
