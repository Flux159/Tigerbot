//
//  trajectoryDriveViewController.m
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

#import "trajectoryDriveViewController.h"
#import "networking.h"
#import "EAGLView.h"
#import "TigerPoint.h"

// Uniform index.
enum {
    UNIFORM_TRANSLATE,
    NUM_UNIFORMS
};
GLint uniforms[NUM_UNIFORMS];

// Attribute index.
enum {
    ATTRIB_VERTEX,
    ATTRIB_COLOR,
    NUM_ATTRIBUTES
};

#pragma mark -
#pragma mark Interface

@interface trajectoryDriveViewController ()
@property (nonatomic, retain) EAGLContext *context;
- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

#pragma mark -
#pragma mark Implementation

@implementation trajectoryDriveViewController

@synthesize animating, context;

#pragma mark -
#pragma mark Set Socket Code

- (void)setsocket:(int)socket{
	tigersocket = socket;
}

#pragma mark -
#pragma mark Misc Animation Code

- (NSInteger)animationFrameInterval
{
    return animationFrameInterval;
}

- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
    /*
	 Frame interval defines how many display frames must pass between each time the display link fires.
	 The display link will only fire 30 times a second when the frame internal is two on a display that refreshes 60 times a second. The default frame interval setting of one will fire 60 times a second when the display refreshes at 60 times a second. A frame interval setting of less than one results in undefined behavior.
	 */
    if (frameInterval >= 1)
    {
        animationFrameInterval = frameInterval;
        
        if (animating)
        {
            [self stopAnimation];
            [self startAnimation];
        }
    }
}

- (void)startAnimation
{
	NSLog(@"Starting animation\n");
    if (!animating)
    {
        if (displayLinkSupported)
        {
            /*
			 CADisplayLink is API new in iOS 3.1. Compiling against earlier versions will result in a warning, but can be dismissed if the system version runtime check for CADisplayLink exists in -awakeFromNib. The runtime check ensures this code will not be called in system versions earlier than 3.1.
			 */
            displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(drawFrame)];
            [displayLink setFrameInterval:animationFrameInterval];
            
            // The run loop will retain the display link on add.
            [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
        else
            animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval) target:self selector:@selector(drawFrame) userInfo:nil repeats:TRUE];
        
        animating = TRUE;
    }
}

- (void)stopAnimation
{
    if (animating)
    {
        if (displayLinkSupported)
        {
            [displayLink invalidate];
            displayLink = nil;
        }
        else
        {
            [animationTimer invalidate];
            animationTimer = nil;
        }
        
        animating = FALSE;
    }
}

#pragma mark -
#pragma mark Shader Code

- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file
{
    GLint status;
    const GLchar *source;
    
    source = (GLchar *)[[NSString stringWithContentsOfFile:file encoding:NSUTF8StringEncoding error:nil] UTF8String];
    if (!source)
    {
        NSLog(@"Failed to load vertex shader");
        return FALSE;
    }
    
    *shader = glCreateShader(type);
    glShaderSource(*shader, 1, &source, NULL);
    glCompileShader(*shader);
    
#if defined(DEBUG)
    GLint logLength;
    glGetShaderiv(*shader, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetShaderInfoLog(*shader, logLength, &logLength, log);
        NSLog(@"Shader compile log:\n%s", log);
        free(log);
    }
#endif
    
    glGetShaderiv(*shader, GL_COMPILE_STATUS, &status);
    if (status == 0)
    {
        glDeleteShader(*shader);
        return FALSE;
    }
    
    return TRUE;
}

- (BOOL)linkProgram:(GLuint)prog
{
    GLint status;
    
    glLinkProgram(prog);
    
#if defined(DEBUG)
    GLint logLength;
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program link log:\n%s", log);
        free(log);
    }
#endif
    
    glGetProgramiv(prog, GL_LINK_STATUS, &status);
    if (status == 0)
        return FALSE;
    
    return TRUE;
}

- (BOOL)validateProgram:(GLuint)prog
{
    GLint logLength, status;
    
    glValidateProgram(prog);
    glGetProgramiv(prog, GL_INFO_LOG_LENGTH, &logLength);
    if (logLength > 0)
    {
        GLchar *log = (GLchar *)malloc(logLength);
        glGetProgramInfoLog(prog, logLength, &logLength, log);
        NSLog(@"Program validate log:\n%s", log);
        free(log);
    }
    
    glGetProgramiv(prog, GL_VALIDATE_STATUS, &status);
    if (status == 0)
        return FALSE;
    
    return TRUE;
}

- (BOOL)loadShaders
{
	NSLog(@"Loading Shaders\n");
    GLuint vertShader, fragShader;
    NSString *vertShaderPathname, *fragShaderPathname;
    
    // Create shader program.
    program = glCreateProgram();
    
    // Create and compile vertex shader.
    vertShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"];
	NSLog(@"Vertex Shader Pathname: %@\n",vertShaderPathname);
    if (![self compileShader:&vertShader type:GL_VERTEX_SHADER file:vertShaderPathname])
    {
        NSLog(@"Failed to compile vertex shader");
        return FALSE;
    }
    
    // Create and compile fragment shader.
    fragShaderPathname = [[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"];
	NSLog(@"Fragment Shader Pathname: %@\n",fragShaderPathname);
    if (![self compileShader:&fragShader type:GL_FRAGMENT_SHADER file:fragShaderPathname])
    {
        NSLog(@"Failed to compile fragment shader");
        return FALSE;
    }
    
    // Attach vertex shader to program.
    glAttachShader(program, vertShader);
    
    // Attach fragment shader to program.
    glAttachShader(program, fragShader);
    
    // Bind attribute locations.
    // This needs to be done prior to linking.
    glBindAttribLocation(program, ATTRIB_VERTEX, "position");
    glBindAttribLocation(program, ATTRIB_COLOR, "color");
    
    // Link program.
    if (![self linkProgram:program])
    {
        NSLog(@"Failed to link program: %d", program);
        
        if (vertShader)
        {
            glDeleteShader(vertShader);
            vertShader = 0;
        }
        if (fragShader)
        {
            glDeleteShader(fragShader);
            fragShader = 0;
        }
        if (program)
        {
            glDeleteProgram(program);
            program = 0;
        }
        
        return FALSE;
    }
    
    // Get uniform locations.
    uniforms[UNIFORM_TRANSLATE] = glGetUniformLocation(program, "translate");
    
    // Release vertex and fragment shaders.
    if (vertShader)
        glDeleteShader(vertShader);
    if (fragShader)
        glDeleteShader(fragShader);
    
    return TRUE;
}

#pragma mark -
#pragma mark Initialization Code

 // The designated initializer.  Override if you create the controller programmatically and want to perform customization that is not appropriate for viewDidLoad.
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if ((self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil])) {		
		//Initialize the currentx and currenty positions and the touch state.
		previousx = INFINITY;
		previousy = INFINITY;
		
		currentx = INFINITY;
		currenty = INFINITY;
		touchstate = 1;
		
		EAGLContext *aContext;
		
		aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		
        //I'm currently not using shaders in my program
        //Instead, I am using the fixed-function pipeline in OpenGL ES 1.1
        //Left this code in incase I decide to write the appropriate shader code at some point
        
		/*
		EAGLContext *aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
		
		if (!aContext)
		{
		aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		}
		*/
		
		if (!aContext)
		NSLog(@"Failed to create ES context");
		else if (![EAGLContext setCurrentContext:aContext])
		NSLog(@"Failed to set ES context current");
		 
		self.context = aContext;
		[aContext release];
		 		
		[(EAGLView *)self.view setContext:context];
		[(EAGLView *)self.view setFramebuffer];
		 
		if ([context API] == kEAGLRenderingAPIOpenGLES2)
		[self loadShaders];
		 		
		animating = FALSE;
		displayLinkSupported = FALSE;
		animationFrameInterval = 1;
		displayLink = nil;
		animationTimer = nil;
		 
		 // Use of CADisplayLink requires iOS version 3.1 or greater.
		 // The NSTimer object is used as fallback when it isn't available.
		NSString *reqSysVer = @"3.1";
		NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
		if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
		displayLinkSupported = TRUE;
    }
    return self;
}

#pragma mark -
#pragma mark Drawing Code

//Draw the path on screen by simply drawing circles where the person has touched.
//This is technically an inefficent method of drawing since each time touchesMoved is called, I am adding to the positionarray
//I am then redrawing all the points in position array each time the drawFrame method is called (OpenGL clears the working buffer each time).
- (void)drawFrame
{
    [(EAGLView *)self.view setFramebuffer];
	
	glClearColor(1.0, 1.0, 1.0, 1.0);
	glClear(GL_COLOR_BUFFER_BIT);
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	int totalvertices = 120;
	GLfloat position[2];
	GLfloat radius[2] = {30.0f,30.0f};
	GLfloat color[4];
	
	int i;
	for(i = 0; i < [positionarray count]; i++){
		
		TigerPoint *temp = [positionarray objectAtIndex:i];
		position[0] = [temp getx];
		position[1] = [temp gety];
		
		if(i == 0){
			color[0] = 1.0f;
			color[1] = 0.0f;
			color[2] = 0.0f;
			color[3] = 1.0f;
		}else if(i == ([positionarray count]-1)){
			color[0] = 0.0f;
			color[1] = 1.0f;
			color[2] = 0.0f;
			color[3] = 1.0f;
		}else{
			color[0] = 0.0f;
			color[1] = 0.0f;
			color[2] = 1.0f;
			color[3] = 1.0f;
		}
		
		[self drawEllipse:totalvertices atPosition:position withRadius:radius withColor:color];
		
	}
	 	 
    [(EAGLView *)self.view presentFramebuffer];
}

//Helper drawing function to estimate an ellipse with OpenGL coordinates
- (void)drawEllipse:(int)totalvertices atPosition:(GLfloat *)pos withRadius:(GLfloat *)radius withColor:(GLfloat *)color{
	GLfloat xpos,ypos;
	GLfloat xradius,yradius;
	GLfloat vertices[totalvertices];
	
	xpos = pos[0];
	ypos = pos[1];
	
	xradius = radius[0];
	yradius = radius[1];
	
	xpos = ((2*xpos)/(GLfloat)self.view.bounds.size.width)-1.0f;
	ypos = 1.0f-((2*ypos)/(GLfloat)self.view.bounds.size.height);
	xradius = xradius/(GLfloat)self.view.bounds.size.width;
	yradius = yradius/(GLfloat)self.view.bounds.size.height;
	
	int i;
	for(i = 0; i < totalvertices; i+=2){
		vertices[i] = xradius*cos((M_PI/180)*i*(360/totalvertices))+xpos;
		vertices[i+1] = yradius*sin((M_PI/180)*i*(360/totalvertices))+ypos;
	}
	
	glVertexPointer(2, GL_FLOAT, 0, vertices);
	glEnableClientState(GL_VERTEX_ARRAY);
	
	glColor4f(color[0], color[1], color[2], color[3]);
	
	glDrawArrays(GL_TRIANGLE_FAN, 0, (totalvertices/2));
}


/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView {
}
*/


#pragma mark -
#pragma mark View Will Appear/Disappear Code

- (void)viewWillAppear:(BOOL)animated
{
    [self startAnimation];
    
    [super viewWillAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self stopAnimation];
    
    [super viewWillDisappear:animated];
}

-(void)viewDidDisappear:(BOOL)animated{
	//This works for when I hit the back button (because the view is not being shown anymore).
	NSLog(@"Trajectory view disappeared.\n");
	close_socket(tigersocket);
	
	[super viewDidDisappear:(BOOL)animated];
	//Not that important
	
	 currentx = INFINITY;
	 currenty = INFINITY;
	 
}

#pragma mark -
#pragma mark View Did Load/Unload, Dealloc Code

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.title = @"Trajectory Drive";
	
	positionarray = [[NSMutableArray alloc] initWithCapacity:2000];
	
    [super viewDidLoad];
}

-(void)takeaction:(id)sender {
	
}

- (void)viewDidUnload
{	
    if (program)
    {
        glDeleteProgram(program);
        program = 0;
    }
	
    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
	self.context = nil;	
	
	[super viewDidUnload];
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


/*
- (void)viewDidUnload {
	close_socket(tigersocket);
	
	
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}
*/

- (void)dealloc {
	if (program)
    {
        glDeleteProgram(program);
        program = 0;
    }
    
    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
    
    [context release];
    
	//Should I keep this here? If dealloc is called, then yes.
	close_socket(tigersocket);
	
    [super dealloc];
}

#pragma mark -
#pragma mark Touch Capability Code

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
	[positionarray removeAllObjects];
	
    sprintf(linebuf,"begin\n");
    writeline(tigersocket, linebuf, strlen(linebuf));
    bzero(linebuf,MAXBUF);
    
	UITouch *t = [[touches allObjects] objectAtIndex:0];
	CGPoint touchPos = [t locationInView:t.view];
    
	TigerPoint *point = [[TigerPoint alloc] initWithX:(GLfloat)touchPos.x withY:(GLfloat)touchPos.y];
	
	[positionarray addObject:point];
    
    [point release];
	
	previousx = currentx;
	previousy = currenty;
	
	currentx = (GLfloat)touchPos.x;
	currenty = (GLfloat)touchPos.y;
	
    //Debug information:
	//NSLog(@"X-Pos: %f\t Y-Pos: %f\n",touchPos.x,touchPos.y);
	//NSLog(@"X-Vel: %f\t Y-Vel:%f\n",currentx-previousx,currenty-previousy);
	
	touchstate = 1;
    
    relativeposx = touchPos.x-[[positionarray objectAtIndex:0] getx];
    relativeposy = touchPos.y-[[positionarray objectAtIndex:0] gety];
    
    //Send first relative point to the robot (i.e. (0.0, 0.0))
	sprintf(linebuf,"%f %f\n",relativeposx, relativeposy);
	writeline(tigersocket, linebuf, strlen(linebuf));
	bzero(linebuf,MAXBUF);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
	UITouch *t = [[touches allObjects] objectAtIndex:0];
	CGPoint touchPos = [t locationInView:t.view];

	TigerPoint *point = [[TigerPoint alloc] initWithX:(GLfloat)touchPos.x withY:(GLfloat)touchPos.y];
	
	[positionarray addObject:point];
	
	[point release];
	
	previousx = currentx;
	previousy = currenty;
	
	currentx = (GLfloat)touchPos.x;
	currenty = (GLfloat)touchPos.y;
	
    //Debugging information on the "velocity" of different touch points
    //Currently not used, but left in for informational purposes
//	NSLog(@"X-Pos: %f\t Y-Pos:%f\n",touchPos.x,touchPos.y);
//	NSLog(@"X-Vel: %f\t Y-Vel:%f\n",currentx-previousx,currenty-previousy);
	
	touchstate = 2;
	
	relativeposx = touchPos.x-[[positionarray objectAtIndex:0] getx];
    relativeposy = touchPos.y-[[positionarray objectAtIndex:0] gety];
    
    //Send relative positions to robot
	sprintf(linebuf,"%f %f\n",relativeposx, relativeposy);
	writeline(tigersocket, linebuf, strlen(linebuf));
	bzero(linebuf,MAXBUF);
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
	touchstate = 3;
	
	NSLog(@"Touches ended.\n");
}

@end
