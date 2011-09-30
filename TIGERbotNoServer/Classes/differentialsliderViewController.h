//
//  differentialsliderViewController.h
//  TIGERbot
//
//  Created by Suyog S Sonwalkar on 1/14/11.
//  Copyright 2011 Suyog S Sonwalkar. All rights reserved.
//

/*
 Differential Drive View Controller:
 
 View Controller for the Differential Drive view of the Tigerbot application. User controls robot by directly changing speed of left and right motors.
 
 */


#import <UIKit/UIKit.h>

#define MAXBUF 1024

#define leftspeedmultdif 1600
#define rightspeedmultdif 1600

@interface differentialsliderViewController : UIViewController {
	int tigersocket;
	char linebuf[MAXBUF];
	int speed1, speed2;
	
	UISlider* slider;
	
	UILabel *speedLabel1;
	UISlider *slider1;
	
	UILabel *speedLabel2;
	UISlider *slider2;
}

@property (nonatomic, retain) IBOutlet UILabel *speedLabel1;
@property (nonatomic, retain) IBOutlet UISlider *slider1;

@property (nonatomic, retain) IBOutlet UILabel *speedLabel2;
@property (nonatomic, retain) IBOutlet UISlider *slider2;

- (void)setsocket:(int)socket;

- (IBAction) changespeed1:(id)sender;
- (IBAction) changespeed2:(id)sender;

@end
