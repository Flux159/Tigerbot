//
//  accelerationdriveViewController.m
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

#import "accelerationdriveViewController.h"
#import "networking.h"

#pragma mark -
#pragma mark Implementation

@implementation accelerationdriveViewController

@synthesize xlabel, ylabel, zlabel;

#pragma mark -
#pragma mark Set Socket Code

- (void)setsocket:(int)socket{
	tigersocket = socket;
}

/*
 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {
        // Custom initialization
    }
    return self;
}
*/

#pragma mark -
#pragma mark View Did Load/Unload, Dealloc Code

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.title = @"Accelerometer Drive";
	
	UIAccelerometer *accelerometer = [UIAccelerometer sharedAccelerometer];
	accelerometer.delegate = self;
	accelerometer.updateInterval = kupdateInterval;
	
    [super viewDidLoad];
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

-(void)viewDidDisappear:(BOOL)animated{
	//This works for when I hit the back button (because the view is not being shown anymore).
	//NSLog(@"Direct Drive view disappeared.\n");
	close_socket(tigersocket);
	
	//Need to set the delegate to nil so that accelerometer didAccelerate is not called after
	//this view disappears.
	UIAccelerometer *accelerometer = [UIAccelerometer sharedAccelerometer];
	accelerometer.delegate = nil;
	
	[super viewDidDisappear:(BOOL)animated];
}

//Need to reassign the accelerometer delegate and update interval when the view is loaded again.
-(void)viewDidAppear:(BOOL)animated{
	UIAccelerometer *accelerometer = [UIAccelerometer sharedAccelerometer];
	accelerometer.delegate = self;
	accelerometer.updateInterval = kupdateInterval;
	
	[super viewDidAppear:(BOOL)animated];
}

- (void)dealloc {
	[xlabel release];
	[ylabel release];
	[zlabel release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark Accerometer Code

-(void)accelerometer:(UIAccelerometer *)accelerometer didAccelerate:(UIAcceleration *)acceleration{
	[self computeMovement:acceleration];
}

//Incomplete method. Currently only displays acceleration on screen. Currently a placeholder.
-(void)computeMovement:(UIAcceleration *)acceleration{
	float rawx,rawy,rawz;
	rawx = acceleration.x;
	rawy = acceleration.y;
	rawz = acceleration.z;
	
	sprintf(linebuf,"X-Acc: %f\tY-Acc: %f\tZ-Acc: %f\n",rawx,rawy,rawz);
	writeline(tigersocket, linebuf, strlen(linebuf));
	bzero(linebuf,MAXBUF);
	
	NSString *xstring = [[NSString alloc] initWithFormat:@"X-Acc: %f",rawx];
	NSString *ystring = [[NSString alloc] initWithFormat:@"Y-Acc: %f",rawy];
	NSString *zstring = [[NSString alloc] initWithFormat:@"Z-Acc: %f",rawz];
	
	xlabel.text = xstring;
	ylabel.text = ystring;
	zlabel.text = zstring;
	
	[xstring release];
	[ystring release];
	[zstring release];
	
    //Print debugging values to log
//	NSLog(@"Float values: %f %f %f",rawx,rawy,rawz);
	
}

@end
