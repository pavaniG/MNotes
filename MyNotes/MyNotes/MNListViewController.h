//
//  MNListViewController.h
//  MyNotes
//
//  Created by Pavani G on 19/09/15.
//  Copyright (c) 2015 Pavani. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface MNListViewController : UITableViewController

- (IBAction)createNewNotes:(id)sender;

@end

@protocol MNNotesDelegate <NSObject>

- (void)notesDidSavedToDropBox:(int)index withNotesTitle:(NSString *)title;

@end
