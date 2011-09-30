//
//  directDriveViewController.m
//  TIGERbot
//
//  Created by Suyog S Sonwalkar on 12/21/10.
//  Copyright 2010 Suyog S Sonwalkar. All rights reserved.
//

/*
 Direct Drive View Controller:
 
 View Controller for the Direct Drive view of the Tigerbot application. User controls robot by pressing d-pad like buttons and changing speed.
 
 */

#import "directDriveViewController.h"
#import "networking.h"

#pragma mark -
#pragma mark Implementation

@implementation directDriveViewController

@synthesize upbutton, downbutton, leftbutton, rightbutton;
@synthesize speedLabel, slider;

#pragma mark -
#pragma mark Set Socket Code

- (void)setsocket:(int)socket{
	tigersocket = socket;
}

#pragma mark -
#pragma mark Button Pressed Code

/*
 Variable buttonpressed changed as follows:
		Up				|		1
 Left			Right	|	4		2
		Down			|		3
 0 is used when no button is pressed.
 */
- (IBAction) upbuttondown{
	NSLog(@"UP\n");
	buttonpressed = 1;
	
	sprintf(linebuf,"%d %d\r\n",speed*leftspeedmult,speed*rightspeedmult);
	
	//Write line to server
	writeline(tigersocket, linebuf, strlen(linebuf));
	bzero(linebuf,MAXBUF);
}
- (IBAction) downbuttondown{
	NSLog(@"DOWN\n");
	buttonpressed = 3;
	
	sprintf(linebuf,"%d %d\r\n",-speed*leftspeedmult,-speed*rightspeedmult);
	writeline(tigersocket, linebuf, strlen(linebuf));
	bzero(linebuf,MAXBUF);
}
- (IBAction) leftbuttondown{
	NSLog(@"LEFT\n");
	buttonpressed = 4;
	
	sprintf(linebuf,"%d %d\r\n",-speed*leftspeedmult,speed*rightspeedmult);
	writeline(tigersocket, linebuf, strlen(linebuf));
	bzero(linebuf,MAXBUF);
}
- (IBAction) rightbuttondown{
	NSLog(@"RIGHT\n");
	buttonpressed = 2;
	
	sprintf(linebuf,"%d %d\r\n",speed*leftspeedmult,-speed*rightspeedmult);
	writeline(tigersocket, linebuf, strlen(linebuf));
	bzero(linebuf,MAXBUF);
}

- (IBAction) buttonup{
	NSLog(@"STOP\n");
	buttonpressed = 0;
	
	sprintf(linebuf,"%d %d\r\n",0,0);
	writeline(tigersocket, linebuf, strlen(linebuf));
	bzero(linebuf,MAXBUF);
}

#pragma mark -
#pragma mark Slider Changed Code

- (IBAction)changespeed:(id)sender{
	//slider = (UISlider*)sender;
	speed = (int)(slider.value+0.5f);
	NSString *sliderText = [[NSString alloc] initWithFormat:@"%d",speed];
	speedLabel.text = sliderText;
	[sliderText release];
	
	switch (buttonpressed) {
		case 1:
			
			sprintf(linebuf,"%d %d\r\n",speed*leftspeedmult,speed*rightspeedmult);
			writeline(tigersocket, linebuf, strlen(linebuf));
			bzero(linebuf,MAXBUF);
			
			break;
		case 2:
			
			sprintf(linebuf,"%d %d\r\n",speed*leftspeedmult,-speed*rightspeedmult);
			writeline(tigersocket, linebuf, strlen(linebuf));
			bzero(linebuf,MAXBUF);

			break;
		case 3:
			
			sprintf(linebuf,"%d %d\r\n",-speed*leftspeedmult,-speed*rightspeedmult);
			writeline(tigersocket, linebuf, strlen(linebuf));
			bzero(linebuf,MAXBUF);

			break;
		case 4:
			
			sprintf(linebuf,"%d %d\r\n",-speed*leftspeedmult,speed*rightspeedmult);
			writeline(tigersocket, linebuf, strlen(linebuf));
			bzero(linebuf,MAXBUF);
			
			break;
		case 0:
			//"Stop" doesn't need to be continuously updated.
			break;
		default:
			break;
	}
	
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

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/

#pragma mark -
#pragma mark View Loading, Unloading, and Dealloc Code

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.title = @"Direct Drive";
	speed = 50;
	
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
	
	self.upbutton = nil;
	self.downbutton = nil;
	self.rightbutton = nil;
	self.leftbutton = nil;
	
	self.speedLabel = nil;
	self.slider = nil;
	
    [super viewDidUnload];
}

-(void)viewDidDisappear:(BOOL)animated{
	//This works for when I hit the back button (because the view is not being shown anymore).
    //Debugging information:
	//NSLog(@"Direct Drive view disappeared.\n");
    
    //Close socket
	close_socket(tigersocket);
	[super viewDidDisappear:(BOOL)animated];
}


- (void)dealloc {
	close_socket(tigersocket);
	
	[upbutton release];
	[downbutton release];
	[leftbutton release];
	[rightbutton release];
	
	[speedLabel release];
	[slider release];
	
    [super dealloc];
}


@end
