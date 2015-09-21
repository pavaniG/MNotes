//
//  MNListViewController.m
//  MyNotes
//
//  Created by Pavani G on 19/09/15.
//  Copyright (c) 2015 Pavani. All rights reserved.
//

#import "MNListViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "MNNotesViewController.h"

@interface MNListViewController ()<DBRestClientDelegate,MNNotesDelegate>
{
    MNNotesViewController *notesViewController;
    BOOL _isCreatingNewNotes;
}

@property (nonatomic, strong) DBRestClient* restClient;
@property (nonatomic, strong) NSMutableArray* notesListArray;


@end

@implementation MNListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isCreatingNewNotes = false;
    [self fetchLocalContentOfNotesList];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh)
             forControlEvents:UIControlEventValueChanged];
    self.refreshControl = refreshControl;
}

- (void)viewWillAppear:(BOOL)animated{
    _isCreatingNewNotes = false;
}


#pragma mark - LOCAL FILE HANDLING

/*Retrieves the local content of file saved in cache folder*/
- (void)fetchLocalContentOfNotesList{
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [NSString stringWithFormat:@"%@/NotesContent.plist",directory];
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]){
        NSDictionary *fileContent = [NSDictionary dictionaryWithContentsOfFile:filePath];
        _notesListArray = [NSMutableArray arrayWithArray:[fileContent objectForKey:@"NotesArray"]];
         [self.tableView reloadData];
    }else{
        _notesListArray = [[NSMutableArray alloc]init];
        [self fetchNotesListFromDB];
    }
}

- (void)saveNotesContentToCacheFile{
    NSDictionary *aDict = [NSDictionary dictionaryWithObject:_notesListArray forKey:@"NotesArray"];
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *filePath = [NSString stringWithFormat:@"%@/NotesContent.plist",directory];
    [aDict writeToFile:filePath atomically:YES];
}

- (void)refresh {
    [self fetchNotesListFromDB];
}


/*Retrive Latest data from Dropbox flder*/
- (void)fetchNotesListFromDB{
    [_notesListArray removeAllObjects];
    [self.restClient loadMetadata:@"/"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [_notesListArray count];
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"listViewCell" forIndexPath:indexPath];
    NSDictionary *notesDict = [_notesListArray objectAtIndex:indexPath.row];
    NSString *filename = [notesDict objectForKey:@"fileName"];
    filename = [filename stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/.txt"]];
    cell.textLabel.text = filename;
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    return cell;
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        [self deleCellRowsAtIndexPath:indexPath];
    }
}

#pragma mark DBRestClientDelegate methods


- (DBRestClient*)restClient {
    if (_restClient == nil) {
        _restClient = [[DBRestClient alloc] initWithSession:[DBSession sharedSession]];
        _restClient.delegate = self;
    }
    return _restClient;
}

/*Calls when file uploading is sucessfull*/
- (void)restClient:(DBRestClient*)client uploadedFile:(NSString*)destPath from:(NSString*)srcPath
          metadata:(DBMetadata*)metadata
{
    // Update the latest content of DBMetaData to the _notesArray.
    [self fetchNotesListFromDB];
}

- (void)restClient:(DBRestClient*)client loadedMetadata:(DBMetadata*)metadata {
    
    /*Validation checking for only .txt files*/
    NSArray* validExtensions = [NSArray arrayWithObjects:@"txt", nil];
    for (DBMetadata* child in metadata.contents) {
        NSString* extension = [[child.path pathExtension] lowercaseString];
        if ([validExtensions indexOfObject:extension] != NSNotFound)
        {
            NSString *directory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
            [self.restClient loadFile:child.path intoPath:[NSString stringWithFormat:@"%@%@",directory,child.path]];
            
            NSDictionary *aNoteDetails = [NSDictionary dictionaryWithObjectsAndKeys:[child.path stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/.txt"]],@"fileName",child.rev,@"fileRev",nil];
            [_notesListArray addObject:aNoteDetails];
        }
    }
    
    [self.refreshControl endRefreshing];
    [self.tableView reloadData];
}


- (IBAction)createNewNotes:(id)sender {
    
    UIAlertController * view=   [UIAlertController
                                 alertControllerWithTitle:@"My Notes"
                                 message:@""
                                 preferredStyle:UIAlertControllerStyleActionSheet];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"Create New notes"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             _isCreatingNewNotes = true;
                             [view dismissViewControllerAnimated:YES completion:nil];
                            [self performSegueWithIdentifier:@"NotesView" sender:nil];
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    
    [view addAction:ok];
    [view addAction:cancel];
    [self presentViewController:view animated:YES completion:nil];

}

- (void)deleCellRowsAtIndexPath:(NSIndexPath*)indexPath{
    
    UIAlertController * view=   [UIAlertController
                                 alertControllerWithTitle:@"My Notes"
                                 message:@"Do you want to delete Notes?"
                                 preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction* ok = [UIAlertAction
                         actionWithTitle:@"OK"
                         style:UIAlertActionStyleDefault
                         handler:^(UIAlertAction * action)
                         {
                             [view dismissViewControllerAnimated:YES completion:nil];
                             NSDictionary *notesDict = [_notesListArray objectAtIndex:indexPath.row];
                             NSString *filePath = [notesDict objectForKey:@"fileName"];
                             [self.restClient deletePath:[NSString stringWithFormat:@"/%@.txt",filePath]];
                             
                             [_notesListArray removeObjectAtIndex:indexPath.row];
                             [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
                             [self saveNotesContentToCacheFile]; // Updates the local file here
                             
                         }];
    UIAlertAction* cancel = [UIAlertAction
                             actionWithTitle:@"Cancel"
                             style:UIAlertActionStyleDefault
                             handler:^(UIAlertAction * action)
                             {
                                 [view dismissViewControllerAnimated:YES completion:nil];
                                 
                             }];
    
    
    [view addAction:ok];
    [view addAction:cancel];
    [self presentViewController:view animated:YES completion:nil];
    
}

#pragma mark - NOTES_DELEGATE

- (void)notesDidSavedToDropBox:(int)index withNotesTitle:(NSString *)title
{
    if(index != -1){//  updates the title for the existing notes if changed
        NSMutableDictionary *aNotesContent = [NSMutableDictionary dictionaryWithDictionary:[_notesListArray objectAtIndex:index]];
        [aNotesContent setObject:title forKey:@"fileName"];
        [_notesListArray replaceObjectAtIndex:index withObject:aNotesContent];
    }
    else{// Adds a new notes to the lits view
        NSDictionary *aNoteDetails = [NSDictionary dictionaryWithObjectsAndKeys:title,@"fileName",@"",@"fileRev",nil];
        [_notesListArray addObject:aNoteDetails];
    }
    
    //Refreshing content on the screen
    [self.tableView reloadData];
    [self saveNotesContentToCacheFile];
}



//Preparing to send other data to the notes view.
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"NotesView"] && !_isCreatingNewNotes)
    {
        NSIndexPath *indexPath = [self.tableView indexPathForCell:(UITableViewCell *)sender];
        notesViewController = (MNNotesViewController *)segue.destinationViewController;
        notesViewController.restClient = self.restClient;
        if(_notesListArray.count > indexPath.row)
        {
            NSDictionary *notesDict = [_notesListArray objectAtIndex:indexPath.row];
            NSString *filePath = [notesDict objectForKey:@"fileName"];
            notesViewController.fileName = filePath;
            notesViewController.fileRev = [notesDict objectForKey:@"fileRev"];
            notesViewController.delegate = self;
            notesViewController.fileIndex = (int)indexPath.row;
        }
    }
    else if(_isCreatingNewNotes){
        notesViewController = (MNNotesViewController *)segue.destinationViewController;
        notesViewController.restClient = self.restClient;
        notesViewController.fileName = @"";
        notesViewController.fileRev = nil;
        notesViewController.delegate = self;
        notesViewController.fileIndex = -1;
    }
}




@end
