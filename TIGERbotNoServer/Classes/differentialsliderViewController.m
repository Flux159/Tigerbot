//
//  differentialsliderViewController.m
//  TIGERbot
//
//  Created by Suyog S Sonwalkar on 1/14/11.
//  Copyright 2011 Suyog S Sonwalkar. All rights reserved.
//

/*
 Differential Drive View Controller:
 
 View Controller for the Differential Drive view of the Tigerbot application. User controls robot by directly changing speed of left and right motors.
 
 */

#import "differentialsliderViewController.h"

#import "networking.h"

@implementation differentialsliderViewController

@synthesize speedLabel1, slider1, speedLabel2, slider2;

- (void)setsocket:(int)socket{
	tigersocket = socket;
}

//Action sent for changing slider 1 (left slider)
- (IBAction)changespeed1:(id)sender{
	slider = (UISlider*)sender;
	if(slider.value > 1){
		speed1 = (int)(slider.value+0.5f);
	}
	else if(slider.value < -1){
		speed1 = (int)(slider.value-0.5f);
	}
	else{
		speed1 = (int)(slider.value);
	}
	NSString *sliderText = [[NSString alloc] initWithFormat:@"%d",speed1];
	speedLabel1.text = sliderText;
	[sliderText release];
	
	sprintf(linebuf,"%d %d\r\n",speed1*leftspeedmultdif,speed2*rightspeedmultdif);
	writeline(tigersocket, linebuf, strlen(linebuf));
	bzero(linebuf,MAXBUF);
	
}

//Action sent for changing slider 2 (right slider)
- (IBAction)changespeed2:(id)sender{
	slider = (UISlider*)sender;
	if(slider.value > 1){
		speed2 = (int)(slider.value+0.5f);
	}
	else if(slider.value < -1){
		speed2 = (int)(slider.value-0.5f);
	}
	else{
		speed2 = (int)(slider.value);
	}
	NSString *sliderText = [[NSString alloc] initWithFormat:@"%d",speed2];
	speedLabel2.text = sliderText;
	[sliderText release];
	
	sprintf(linebuf,"%d %d\r\n",speed1*leftspeedmultdif,speed2*rightspeedmultdif);
	writeline(tigersocket, linebuf, strlen(linebuf));
	bzero(linebuf,MAXBUF);
	
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

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
 - (void)viewDidLoad {
	 self.title = @"Differential Slider Drive";
	 speed1 = 0;
	 speed2 = 0;
 
	 [super viewDidLoad];
 }

-(void)viewDidDisappear:(BOOL)animated{
	//This works for when I hit the back button (because the view is not being shown anymore).
	//NSLog(@"Direct Drive view disappeared.\n");
	close_socket(tigersocket);
	[super viewDidDisappear:(BOOL)animated];
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
	
	self.slider1 = nil;
	self.speedLabel1 = nil;
	
	self.slider2 = nil;
	self.speedLabel2 = nil;
	
    [super viewDidUnload];
}

- (void)dealloc {
	
	[slider1 release];
	[speedLabel1 release];
	
	[slider2 release];
	[speedLabel2 release];
	
    [super dealloc];
}


@end
