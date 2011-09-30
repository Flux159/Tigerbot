//
//  gestureDriveViewController.h
//  TIGERbot
//
//  Created by Suyog S Sonwalkar on 12/28/10.
//  Copyright 2010 Suyog S Sonwalkar. All rights reserved.
//

/*
 Gesture Drive View Controller:
 
 View Controller for the Gesture Drive view of the Tigerbot application. User controls robot by using predefined multi-touch or single touch gestures, such as swiping up, two finger swipe, etc.
 
 Not completed iphone side or robot side (not user tested either). Currently a placeholder.
 
 */

#import <UIKit/UIKit.h>

//OpenGL imports
#import <QuartzCore/QuartzCore.h>

#import <OpenGLES/EAGL.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

#define MAXBUF 1024

//Gesture Defines

#define MINGESTURELENGTH 35
#define MAXVARIANCE 10

//Gesture enum
typedef enum {
	noSwipe = 0,
	horizontalSwipeRight,
	horizontalSwipeLeft,
	verticalSwipeUp,
	verticalSwipeDown,
	rotationRight,
	rotationLeft
} SwipeType;

@interface gestureDriveViewController : UIViewController {
	//Networking Variables
	int tigersocket;
	char linebuf[MAXBUF];
	
	//OpenGL variables
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
	
	//Drawing Variables
	GLfloat currentx,currenty;
	GLfloat currentx2,currenty2;
	
	//Labels
	UILabel *messageLabel;
	UILabel *tapsLabel;
	UILabel *touchesLabel;
	UILabel *gestureLabel;
	
	//Gesture variables
	CGPoint gesturestartpoint;
	//CGPoint gesturestartpoint2;
	
	//Used in 2 finger gestures
	GLfloat currentpos1x, currentpos1y, currentpos2x, currentpos2y;
	GLfloat prevpos1x, prevpos1y, prevpos2x, prevpos2y;
	
	//BOOL gesturerestart;
}

- (void)setsocket:(int)socket;

@property (nonatomic, retain) IBOutlet UILabel *messageLabel;
@property (nonatomic, retain) IBOutlet UILabel *tapsLabel;
@property (nonatomic, retain) IBOutlet UILabel *touchesLabel;
@property (nonatomic, retain) IBOutlet UILabel *gestureLabel;

//OpenGL propetries
@property (readonly, nonatomic, getter=isAnimating) BOOL animating;
@property (nonatomic) NSInteger animationFrameInterval;

//Gesture detection functions
- (void) updateLabels:(NSSet*) touches;
- (void) updatePoints:(NSSet*) touches;
- (void) detectGestures:(NSSet*) touches;
- (void) eraseGestureLabel;

//OpenGL animation and drawing functions
- (void)startAnimation;
- (void)stopAnimation;

//Drawing Functions
- (void)drawEllipse:(int)totalvertices atPosition:(GLfloat *)pos withRadius:(GLfloat *)radius withColor:(GLfloat *)color;

@end
