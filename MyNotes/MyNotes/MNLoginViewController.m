//
//  MNLoginViewController.m
//  MyNotes
//
//  Created by Pavani G on 19/09/15.
//  Copyright (c) 2015 Pavani. All rights reserved.
//

#import "MNLoginViewController.h"
#import <DropboxSDK/DropboxSDK.h>
#import "MNListViewController.h"

@interface MNLoginViewController ()

@property (weak, nonatomic) IBOutlet UIButton *dbLoginBtn;

- (IBAction)loadNotesListView:(id)sender;

@end

@implementation MNLoginViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    if ([[DBSession sharedSession] isLinked]) {
        [_dbLoginBtn setTitle: @"Unlink" forState: UIControlStateNormal];
    }

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)synToDropBox:(UIButton *)sender {
    if (![[DBSession sharedSession] isLinked]) {
        [[DBSession sharedSession] linkFromController:self];
        [_dbLoginBtn setTitle: @"Unlink" forState: UIControlStateNormal];
    } else {
        [[DBSession sharedSession] unlinkAll];
        [[[UIAlertView alloc]
           initWithTitle:@"Account Unlinked!" message:@"Your dropbox account has been unlinked"
           delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil]
         show];
        [_dbLoginBtn setTitle: @"Login to Drop Box" forState: UIControlStateNormal];
    }
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Make sure your segue name in storyboard is the same as this line
    if ([[segue identifier] isEqualToString:@"listViewController"])
    {
        //NSLog(@"ADDING NOTES VIEW");
    }
}

- (IBAction)loadNotesListView:(id)sender {
    [self performSegueWithIdentifier:@"listViewController" sender:self];
}

@end
