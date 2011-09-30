//
//  TIGERbotAppDelegate.m
//  TIGERbot
//
//  Created by Suyog S Sonwalkar on 12/17/10.
//  Copyright 2010 Suyog S Sonwalkar. All rights reserved.
//

#import "TIGERbotAppDelegate.h"
#import "ipAddressViewController.h"

#pragma mark -
#pragma mark Implementation

@implementation TIGERbotAppDelegate

@synthesize window;
//@synthesize ipview;
@synthesize navigationController;

#pragma mark -
#pragma mark Application lifecycle

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {    
    
    // Override point for customization after application launch.
    
	//[window addSubview:ipview.view];
	
	[window addSubview:[navigationController view]];
	
    [window makeKeyAndVisible];
    
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    /*
     Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
     Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
     */
	//[[(ipAddressViewController*)[navigationController view] tdriveview] stopAnimation];
	//[(ipAddressViewController*)[navigationController view] applicationWillResignActive:application];
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    /*
     Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
     If your application supports background execution, called instead of applicationWillTerminate: when the user quits.
     */
	//[(ipAddressViewController*)[navigationController view] applicationWillResignActive:application];
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    /*
     Called as part of  transition from the background to the inactive state: here you can undo many of the changes made on entering the background.
     */
	//[(ipAddressViewController*)[navigationController view] applicationDidBecomeActive:application];
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    /*
     Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
     */
	//[(ipAddressViewController*)[navigationController view] applicationDidBecomeActive:application];
}


- (void)applicationWillTerminate:(UIApplication *)application {
    /*
     Called when the application is about to terminate.
     See also applicationDidEnterBackground:.
     */
	//[(ipAddressViewController*)[navigationController view] applicationWillTerminate:application];
}


#pragma mark -
#pragma mark Memory management

- (void)applicationDidReceiveMemoryWarning:(UIApplication *)application {
    /*
     Free up as much memory as possible by purging cached data objects that can be recreated (or reloaded from disk) later.
     */
}


- (void)dealloc {
    [window release];
	//[ipview release];
	[navigationController release];
    [super dealloc];
}


@end
