//
//  trajectoryDriveViewController.h
//  TIGERbot
//
//  Created by Suyog S Sonwalkar on 12/21/10.
//  Copyright 2010 Suyog S Sonwalkar. All rights reserved.
//

/*
 Trajectory Drive View Controller:
 
 View Controller for the Trajectory Drive view of the Tigerbot application. User controls robot by drawing on the screen.
 
 Each time te user draws a path, the iphone first converts the pixel coordinates to relative pixel coordinates (relative to the starting point of the path).
 The iphone then transmits these relative pixel coordinates to the robot, which converts the pixel coordinates into real-world coordinates (empirically determined).
 Finally, the robot runs two control loops in order to move in the appropriate path on the ground.
 First, the robot must run a PID control loop on the motor speeds, ensuring that a command of "Run left-motor at 6000 encoder ticks per second" actually makes the robot run at that speed.
 Second, the robot runs a PID control loop on the trajectory path given. To do this, the robot first determines its current location using dead reckoning (determining robot position (x,y) in meters through how much the motors have moved). The robot then asks what point should it be at at the current time (using the trajectory path). If the robot is not at or near the trajectory path, the PID control loop runs in order to reduce the error between the desired position and the current position.
 
 */

#import <UIKit/UIKit.h>

#import <QuartzCore/QuartzCore.h>

#import <OpenGLES/EAGL.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#define MAXBUF 1024

@interface trajectoryDriveViewController : UIViewController {
	//Networking variables
	int tigersocket;
	char linebuf[MAXBUF];
	
	//OpenGL Drawing variables
	EAGLContext *context;
    GLuint program;
    
    BOOL animating;
    BOOL displayLinkSupported;
    NSInteger animationFrameInterval;
    /*
	 Use of the CADisplayLink class is the preferred method for controlling your animation timing.
	 CADisplayLink will link to the main display and fire every vsync when added to a given run-loop.
	 The NSTimer object is used only as fallback when running on a pre-3.1 device where CADisplayLink isn't available.
	 */
    id displayLink;
    NSTimer *animationTimer;
	
	
	//Trajectory Related Variables
	int touchstate;
	
	GLfloat currentx,currenty;
	GLfloat previousx,previousy;
	//NSTimer *timer;
	
	NSMutableArray *positionarray;
    
    float relativeposx, relativeposy;
    
    //clock_t starttime;
}

@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

- (void)startAnimation;
- (void)stopAnimation;

//Sets socket.
- (void)setsocket:(int)socket;

//Drawing Functions
- (void)drawEllipse:(int)totalvertices atPosition:(GLfloat *)pos withRadius:(GLfloat *)radius withColor:(GLfloat *)color;

@end
