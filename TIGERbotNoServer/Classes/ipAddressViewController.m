//
//  ipAddressViewController.m
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

#import "ipAddressViewController.h"
#import "directDriveViewController.h"
#import "trajectoryDriveViewController.h"
#import "differentialsliderViewController.h"
#import "gestureDriveViewController.h"
#import "accelerationdriveViewController.h"
#import "networking.h"


#pragma mark -
#pragma mark Implementation

@implementation ipAddressViewController

@synthesize ddriveview;
@synthesize tdriveview;
@synthesize gdriveview;
@synthesize adriveview;
@synthesize diffdriveview;

@synthesize ipField;
@synthesize portField;

@synthesize picker;
@synthesize pickerData;
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
#pragma mark Implementation Code

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	
	//The array used in the picker
	NSArray *array = [[NSArray alloc] initWithObjects:@"Direct Drive", @"Differential Slider", @"Trajectory", @"Gestures", 
					  @"Accelerometer", @"Video", nil];
	self.pickerData = array;
	[array release];
	
	[super viewDidLoad];
	
	
	
	
}


/*
// Override to allow orientations other than the default portrait orientation.
- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}
*/

-(IBAction) switchtodriveview:(id)sender {
	char* charipaddress, *charport;
	int intport;
	
	/*
	 //I don't need to allocate because the UTF8String method does that for me.
	charipaddress = malloc(20*sizeof(char));
	charport = malloc(20*sizeof(char));
	 */
	
	//Grab the ipaddress
	NSString *ipaddress = (NSString*) ipField.text;
	charipaddress = (char*)[ipaddress UTF8String];
	
	//Grab the port
	NSString *port = (NSString*) portField.text;
	charport = (char*)[port UTF8String];
	intport = atoi(charport);
	
	//Grab which row is selected by the picker (it decides which view we will move to)
	NSInteger row = [picker selectedRowInComponent:0];
	
	//Print to log for debugging
//    NSString *selected = [pickerData objectAtIndex:row];
//    NSLog(@"\n Row number: %d\n Row object: %@\n ipaddress: %@, %s\n port: %@, %s, %d\n",row,selected, ipaddress,charipaddress, port, charport, intport);
	
	//Connect to server (MODIFIED TO CONNECT REGARDLESS OF WHETHER SERVER EXISTS OR NOT - file descriptor 1 is std output, so there are no significant issues w/ this simple fix)
	sock = 1;
//	sock = serv_connect(charipaddress, intport);
	
//	NSLog(@"\n Socket number:%d\n",sock);
	
	if(sock < 0){
		//Display Alert Message indicating that client could not connect to server
		//Basically, currently it NEVER reaches here.
		NSLog(@"\n Error Connecting to ipaddress %@ on port %@\n",ipaddress,port);
		
		NSString *alertmsg = [[NSString alloc] 
							  initWithFormat:@"Error connecting to %@ on port %@",ipaddress,port];
		
		UIAlertView *alert = [[UIAlertView alloc]	initWithTitle:@"Connection Error" 
														message:alertmsg 
													   delegate:nil
											  cancelButtonTitle:@"Ok"
											  otherButtonTitles:nil];
		
		[alert show];
		[alert release];
		[alertmsg release];
		
		//close_socket(sock);
	}
	else{
		//Based on what the picker is located at (which row number and object)
		//Choose the correct view to go to and pass the socket connection there
		NSLog(@"\n Connected! Server at %@ on port %@\n",ipaddress,port);
		//Open the correct view based on what the picker is placed on
		switch (row) {
			case 0:
				NSLog(@"Direct Drive\n");
				
				if(self.ddriveview == nil){
					directDriveViewController *viewddrive = [[directDriveViewController alloc] initWithNibName:@"directDriveView" bundle:nil];
					//Need to pass the socket argument
					[viewddrive setsocket:sock];
					
					self.ddriveview = viewddrive;
					[viewddrive release];
				}
				
                sprintf(linebuf,"state: direct\n");
                writeline(sock, linebuf, strlen(linebuf));
                bzero(linebuf,MAXBUF);
                
				[self.navigationController pushViewController:self.ddriveview animated:YES];
				 
				break;
			case 1:
				NSLog(@"Differential Slider\n");
				
				if(self.diffdriveview == nil){
					differentialsliderViewController *viewdiffdrive = [[differentialsliderViewController alloc] initWithNibName:@"differentialsliderViewController" bundle:nil];
					
					[viewdiffdrive setsocket:sock];
					
					self.diffdriveview = viewdiffdrive;
					[viewdiffdrive release];
				}
				
                sprintf(linebuf,"state: direct\n");
                writeline(sock, linebuf, strlen(linebuf));
                bzero(linebuf,MAXBUF);
                
				[self.navigationController pushViewController:self.diffdriveview animated:YES];
				
				break;
			case 2:
				NSLog(@"Trajectory\n");
				
				if(self.tdriveview == nil){
					trajectoryDriveViewController *viewtraj = [[trajectoryDriveViewController alloc] initWithNibName:@"trajectoryDriveView" bundle:nil];
					[viewtraj setsocket:sock];
					
					self.tdriveview = viewtraj;
					[viewtraj release];
				}
                
                sprintf(linebuf,"state: trajectory\n");
                writeline(sock, linebuf, strlen(linebuf));
                bzero(linebuf,MAXBUF);
				
				[self.navigationController pushViewController:self.tdriveview animated:YES];
				 
				break;
			case 3:
				NSLog(@"Gestures\n");
				
				if(self.gdriveview == nil){
					gestureDriveViewController *viewgest = [[gestureDriveViewController alloc] initWithNibName:@"gestureDriveViewController" bundle:nil];
					[viewgest setsocket:sock];
					
					self.gdriveview = viewgest;
					[viewgest release];
				}
				
                sprintf(linebuf,"state: gesture\n");
                writeline(sock, linebuf, strlen(linebuf));
                bzero(linebuf,MAXBUF);
                
				[self.navigationController pushViewController:self.gdriveview animated:YES];
				//Remove this line (close_socket(sock)) when you add a view for Gestures
				//close_socket(sock);
				break;
			case 4:
				NSLog(@"Accelerometer\n");
				//Remove this line (close_socket(sock)) when you add a view for Accelerometer control
				//close_socket(sock);
				if(self.adriveview == nil){
					accelerationdriveViewController *viewaccel = [[accelerationdriveViewController alloc] initWithNibName:@"accelerationdriveViewController" bundle:nil];
					[viewaccel setsocket:sock];
				
                    sprintf(linebuf,"state: accelerometer\n");
                    writeline(sock, linebuf, strlen(linebuf));
                    bzero(linebuf,MAXBUF);
                    
					self.adriveview = viewaccel;
					[viewaccel release];
				}
				
				[self.navigationController pushViewController:self.adriveview animated:YES];
				 
				break;
			case 5:
				NSLog(@"Video\n");
				NSString *alertmsg = [[NSString alloc] 
									  initWithString:@"The video control is in development. The connection will be closed." ];
				
				UIAlertView *alert = [[UIAlertView alloc]	initWithTitle:@"Under Development" 
															message:alertmsg 
															delegate:nil
															cancelButtonTitle:@"Ok"
															otherButtonTitles:nil];
				
				[alert show];
				[alert release];
				[alertmsg release];
				
				//Remove this line and the alert when you add video
				close_socket(sock);
				break;
			default:
				NSLog(@"Random Error Happened\n");
				close_socket(sock);
				break;
		}
	}
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    [self.tdriveview stopAnimation];
	[self.gdriveview stopAnimation];
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [self.tdriveview startAnimation];
	[self.gdriveview startAnimation];
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    [self.tdriveview stopAnimation];
	[self.gdriveview stopAnimation];
}

#pragma mark -
#pragma mark keyboardMethods

-(IBAction) nextbutton:(id)sender{
	[portField becomeFirstResponder];
}

//When the user hits the UIControl View (the background), the keyboard will disappear
-(IBAction) backgroundtouch:(id)sender{
	[ipField resignFirstResponder];
	[portField resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark -
#pragma mark Unload and Dealloc Methods

- (void)viewDidUnload {	
	 //Do I need to do this? Yeah, read pg. 123-124 out of 586 in iPhone Development book
	self.picker = nil;
	self.pickerData = nil;
	self.ddriveview = nil;
	self.tdriveview = nil;
	self.adriveview = nil;
	self.gdriveview = nil;
	self.diffdriveview = nil;
	self.ipField = nil;
	self.portField = nil;
	
	 //Similarly for the ddriveView and tdriveView, do I need to do something here?
	[super viewDidUnload];
}


- (void)dealloc {
	[ddriveview dealloc];
	[tdriveview dealloc];
	[adriveview dealloc];
	[gdriveview dealloc];
	[diffdriveview dealloc];
	
	[ipField release];
	[portField release];
	
	[picker release];
	[pickerData release];
	
	close_socket(sock);
	
    [super dealloc];
}


//Adding the picker data and delegate methods (required for the picker)
#pragma mark -
#pragma mark Picker Data Source Methods

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView{
	return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component{
	return [pickerData count];
}
 
#pragma mark Picker Delegate Methods

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
	return [pickerData objectAtIndex:row];
}

@end
