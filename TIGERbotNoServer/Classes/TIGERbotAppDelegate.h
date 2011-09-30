//
//  TIGERbotAppDelegate.h
//  TIGERbot
//
//  Created by Suyog S Sonwalkar on 12/17/10.
//  Copyright 2010 Suyog S Sonwalkar. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ipAddressViewController;
@interface TIGERbotAppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
	UINavigationController *navigationController;
	//ipAddressViewController *ipview;
}

@property (nonatomic, retain) IBOutlet UIWindow *window;
//@property (nonatomic, retain) IBOutlet ipAddressViewController *ipview;
@property (nonatomic, retain) IBOutlet UINavigationController *navigationController;


@end

