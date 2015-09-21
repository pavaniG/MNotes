//
//  MNNotesViewController.m
//  MyNotes
//
//  Created by Pavani G on 19/09/15.
//  Copyright (c) 2015 Pavani. All rights reserved.
//

#import "MNNotesViewController.h"

@interface MNNotesViewController ()<UITextViewDelegate>
{
    BOOL   _isEditingStarted;
}
@property (strong, nonatomic) UITextView *textViewField;

@end

@implementation MNNotesViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _isEditingStarted = false;
    
    self.textViewField = [[UITextView alloc] initWithFrame:self.view.bounds];
    self.textViewField.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.textViewField.delegate = self;
    [self.textViewField setFont:[UIFont fontWithName:@"ArialMT" size:16]];
    [self.view addSubview:self.textViewField];
    
    if(_fileName.length){
        NSString *directory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
        NSString *notesContent = [NSString stringWithContentsOfFile:[NSString stringWithFormat:@"%@/%@.txt",directory,_fileName] encoding:NSUTF8StringEncoding error:NULL];
        [self updateTextView:notesContent];
        self.title = _fileName;
    }
}


-(void)viewWillAppear:(BOOL)animated {
    [self registerForKeyboardNotifications];
}

- (void)viewWillDisappear:(BOOL)animated {
    if(_textViewField.text.length == 0)
        _isEditingStarted = false;
    [self saveNotesToDb];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [super viewWillDisappear:animated];
}

- (void)updateTextView:(NSString *)text{
    _textViewField.text = text;
}

- (void)textViewDidChange:(UITextView *)textView
{
    _isEditingStarted = true;
        self.title = [self getTitleOfNotesFromTextInput];
}

- (void)saveNotesToDb{
    if(_isEditingStarted == false || !self.delegate) return;
    
    NSString *directory = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    NSString *newTitle = [NSString stringWithFormat:@"/%@.txt",[self getTitleOfNotesFromTextInput]];
    if(_fileName.length && [_fileName compare:newTitle] != NSOrderedSame){
        [[NSFileManager defaultManager] removeItemAtPath:[NSString stringWithFormat:@"%@/%@.txt",directory,_fileName] error:NULL];
        [self.restClient deletePath:[NSString stringWithFormat:@"/%@.txt",_fileName]];
    }
    
    [_textViewField.text writeToFile:[NSString stringWithFormat:@"%@%@",directory,newTitle] atomically:YES encoding:NSUTF8StringEncoding error:NULL];
    [self.restClient uploadFile:newTitle toPath:@"/" withParentRev:_fileRev fromPath:[NSString stringWithFormat:@"%@%@",directory,newTitle]];
    
    if(self.delegate){
        [self.delegate notesDidSavedToDropBox:_fileIndex withNotesTitle:[newTitle stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"/.txt"]]];
    }
}



- (void)registerForKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasHidden:)
                                                 name:UIKeyboardDidHideNotification object:nil];
}

-(void)keyboardWasShown:(NSNotification*)aNotification {

    NSDictionary *info = [aNotification userInfo];
    NSValue *aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
    
    // Resize the scroll view (which is the root view of the window)
    CGRect viewFrame = [self.textViewField frame];
    viewFrame.size.height -= keyboardSize.height;
    self.textViewField.frame = viewFrame;
    [self.textViewField scrollRectToVisible:viewFrame animated:YES];
    
}

-(void)keyboardWasHidden:(NSNotification*)aNotification {

    NSDictionary *info = [aNotification userInfo];
    NSValue *aValue = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [aValue CGRectValue].size;
    CGRect viewFrame = [self.textViewField frame];
    viewFrame.size.height += keyboardSize.height;
    self.textViewField.frame = viewFrame;
}

- (NSString *)getTitleOfNotesFromTextInput{
    NSString *title = _textViewField.text;
    NSRange range = [title rangeOfString:@"."];
    if (NSNotFound != range.location) {
        title = [title stringByReplacingCharactersInRange:range withString:@"\n"];
        NSArray *arr = [title componentsSeparatedByString:@"\n"];
        return [arr objectAtIndex:0];
    }
    else{
        NSArray *arr = [title componentsSeparatedByString:@"\n"];
        if(arr.count)
            return  [arr objectAtIndex:0];
    }
    return title;
}

@end
