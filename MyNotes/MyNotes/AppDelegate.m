//
//  AppDelegate.m
//  MyNotes
//
//  Created by Pavani G on 19/09/15.
//  Copyright (c) 2015 Pavani. All rights reserved.
//

#import "AppDelegate.h"
#import <DropboxSDK/DropboxSDK.h>
#import "MNLoginViewController.h"
#import "MNListViewController.h"

@interface AppDelegate ()<DBSessionDelegate, DBNetworkRequestDelegate>
{
    
}
@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    // Set these variables before launching the app
    NSString* appKey = @"n8nvt4zc04iop0d";
    NSString* appSecret = @"lfn6o28bzr2ciqs";
    NSString *root = kDBRootAppFolder;

    DBSession* session =
    [[DBSession alloc] initWithAppKey:appKey appSecret:appSecret root:root];
    session.delegate = self;
    [DBSession setSharedSession:session];
    [DBRequest setNetworkRequestDelegate:self];
    
    if ([[DBSession sharedSession] isLinked]) {
        MNListViewController *listViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"listViewController"];
        [self.window.rootViewController showViewController:listViewController sender:nil];
    }
    [_window makeKeyAndVisible];
    
    return YES;
}



- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url {
    if ([[DBSession sharedSession] handleOpenURL:url]) {
        if ([[DBSession sharedSession] isLinked]) {
            MNListViewController *listViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"listViewController"];
            [self.window.rootViewController showViewController:listViewController sender:nil];
        }
        return YES;
    }
    return NO;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - DB_PROTOCOLS

- (void)sessionDidReceiveAuthorizationFailure:(DBSession *)session userId:(NSString *)userId
{
    
}

- (void)networkRequestStarted
{
}
- (void)networkRequestStopped
{
}


@end
