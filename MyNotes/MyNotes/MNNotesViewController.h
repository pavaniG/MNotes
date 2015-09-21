//
//  MNNotesViewController.h
//  MyNotes
//
//  Created by Pavani G on 19/09/15.
//  Copyright (c) 2015 Pavani. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <DropboxSDK/DropboxSDK.h>
#import "MNListViewController.h"

@interface MNNotesViewController : UIViewController

- (void)updateTextView:(NSString *)text;
@property (nonatomic, weak) DBRestClient* restClient;
@property (nonatomic, weak) NSString* fileName;
@property (nonatomic, weak) NSString* fileRev;
@property (nonatomic) int fileIndex;
@property(nonatomic,weak) id <MNNotesDelegate> delegate;


@end
