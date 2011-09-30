//
//  directDriveViewController.h
//  TIGERbot
//
//  Created by Suyog S Sonwalkar on 12/21/10.
//  Copyright 2010 Suyog S Sonwalkar. All rights reserved.
//

/*
 Direct Drive View Controller:
 
 View Controller for the Direct Drive view of the Tigerbot application. User controls robot by pressing d-pad like buttons and changing speed.
 
 */

#import <UIKit/UIKit.h>

#define MAXBUF 1024

#define leftspeedmult 160
#define rightspeedmult 160

@interface directDriveViewController : UIViewController {
	int tigersocket;
	char linebuf[MAXBUF];
	int speed;
	int buttonpressed;
	
	//Buttons
	UIButton *upbutton;
	UIButton *downbutton;
	UIButton *rightbutton;
	UIButton *leftbutton;
	
	//Slider and associated Label
	UILabel *speedLabel;
	UISlider *slider;
}

@property (nonatomic, retain) IBOutlet UIButton *upbutton;
@property (nonatomic, retain) IBOutlet UIButton *downbutton;
@property (nonatomic, retain) IBOutlet UIButton *leftbutton;
@property (nonatomic, retain) IBOutlet UIButton *rightbutton;
@property (nonatomic, retain) IBOutlet UILabel *speedLabel;
@property (nonatomic, retain) IBOutlet UISlider *slider;

//Sets socket.
- (void)setsocket:(int)socket;

//Action taken when each of the buttons is pressed.
- (IBAction) upbuttondown;
- (IBAction) downbuttondown;
- (IBAction) leftbuttondown;
- (IBAction) rightbuttondown;

//Action taken when any button is released.
- (IBAction) buttonup;

//Action taken when slider is changed.
- (IBAction) changespeed:(id)sender;

//@property (nonatomic, retain) IBOutlet UIView view;

@end
