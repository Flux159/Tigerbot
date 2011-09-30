//
//  ipAddressViewController.h
//  TIGERbot
//
//  Created by Suyog S Sonwalkar on 12/21/10.
//  Copyright 2010 Suyog S Sonwalkar. All rights reserved.
//

/*
 IP View Controller:
 
 View Controller for the primary view of the Tigerbot application. User inputs ipadress and port number and chooses from a variety of control methods.
 Based on control method chosen by the picker, IP View Controller will push the corresponding view controller to the navigation controller.
 
 */

#import <UIKit/UIKit.h>

@class directDriveViewController;
@class trajectoryDriveViewController;
@class gestureDriveViewController;
@class accelerationdriveViewController;
@class differentialsliderViewController;

#define MAXBUF 1024

@interface ipAddressViewController : UIViewController 
//This line is required for the Picker View
< UIPickerViewDelegate, UIPickerViewDataSource > 
{
	//The picker delegate (UIPickerView) and data source (NSArray)
	UIPickerView *picker;
	NSArray *pickerData;
    
    char linebuf[MAXBUF];
	
	//The view controllers loaded from this view
	directDriveViewController *ddriveview;
	trajectoryDriveViewController *tdriveview;
	gestureDriveViewController *gdriveview;
	accelerationdriveViewController *adriveview;
	differentialsliderViewController *diffdriveview;
	
	//The text fields input into this view
	UITextField *ipField;
	UITextField *portField;
	
	//Create a socket connection (in this view or in the others, doesn't really matter).
	int sock;
}

@property (retain, nonatomic) directDriveViewController *ddriveview;
@property (retain, nonatomic) trajectoryDriveViewController *tdriveview;
@property (retain, nonatomic) gestureDriveViewController *gdriveview;
@property (retain, nonatomic) accelerationdriveViewController *adriveview;
@property (retain, nonatomic) differentialsliderViewController *diffdriveview;

@property (nonatomic, retain) IBOutlet UITextField *ipField;
@property (nonatomic, retain) IBOutlet UITextField *portField;

@property (nonatomic, retain) IBOutlet UIPickerView *picker;
@property (nonatomic, retain) NSArray *pickerData;

-(IBAction) switchtodriveview:(id)sender;
-(IBAction) backgroundtouch:(id)sender;
-(IBAction) nextbutton:(id)sender;

@end