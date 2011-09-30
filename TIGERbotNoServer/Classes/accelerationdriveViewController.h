//
//  accelerationdriveViewController.h
//  TIGERbot
//
//  Created by Suyog S Sonwalkar on 12/28/10.
//  Copyright 2010 Suyog S Sonwalkar. All rights reserved.
//

/*
 Acceleration Drive View Controller:
 
 View Controller for the Acceleration Drive view of the Tigerbot application. User controls robot by tilting phone.
 
 Not completed iphone side or robot side (not user tested either). Currently a placeholder.
 
 */

#import <UIKit/UIKit.h>

#define MAXBUF 1024
#define kupdateInterval (1.0f/30.0f)

@interface accelerationdriveViewController : UIViewController <UIAccelerometerDelegate> {
	//Networking variables
	int tigersocket;
	char linebuf[MAXBUF];
	
	//Labels for displaying accelerometer data on screen.
	UILabel *xlabel;
	UILabel *ylabel;
	UILabel *zlabel;
}

@property (nonatomic, retain) IBOutlet UILabel *xlabel;
@property (nonatomic, retain) IBOutlet UILabel *ylabel;
@property (nonatomic, retain) IBOutlet UILabel *zlabel;

//Sets Socket.
- (void)setsocket:(int)socket;
-(void)computeMovement:(UIAcceleration *)acceleration;

@end
