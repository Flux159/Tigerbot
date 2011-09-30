//
//  gestureDriveViewController.m
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

#import "gestureDriveViewController.h"
#import "networking.h"
#import "EAGLView.h"

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

@interface gestureDriveViewController ()
@property (nonatomic, retain) EAGLContext *context;
- (BOOL)loadShaders;
- (BOOL)compileShader:(GLuint *)shader type:(GLenum)type file:(NSString *)file;
- (BOOL)linkProgram:(GLuint)prog;
- (BOOL)validateProgram:(GLuint)prog;
@end

#pragma mark -
#pragma mark Implementation

@implementation gestureDriveViewController

@synthesize animating, context;
@synthesize messageLabel, tapsLabel, touchesLabel, gestureLabel;

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
		
		//Used in drawing touches
		currentx = INFINITY;
		currenty = INFINITY;
		
		currentx2 = INFINITY;
		currenty2 = INFINITY;
		
		//Used in gesture (2 finger) recognition
		
		currentpos1x = INFINITY;
		currentpos1y = INFINITY;
		currentpos2x = INFINITY;
		currentpos2y = INFINITY;
		
		
		//Initialize the currentx and currenty positions and the touch state.
		/*
		previousx = INFINITY;
		previousy = INFINITY;
		
		currentx = INFINITY;
		currenty = INFINITY;
		touchstate = 1;
		*/
		 
		EAGLContext *aContext;
		
		aContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES1];
		
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

- (void)drawFrame
{
    [(EAGLView *)self.view setFramebuffer];
	
	glClearColor(1.0, 1.0, 1.0, 1.0);
	glClear(GL_COLOR_BUFFER_BIT);
	
	glMatrixMode(GL_PROJECTION);
	glLoadIdentity();
	glMatrixMode(GL_MODELVIEW);
	glLoadIdentity();
	
	//Drawing a circle for first touch
	
	int totalvertices = 120;
	GLfloat position[2] = {currentx,currenty};
	GLfloat radius[2] = {50.0f,50.0f};
	GLfloat color[4] = {0.0f,0.0f,1.0f,1.0f};
	
	[self drawEllipse:totalvertices atPosition:position withRadius:radius withColor:color];
	
	//Drawing a circle for second touch
	
	position[0] = currentx2;
	position[1] = currenty2;
	radius[0] = 50.0f;
	radius[1] = 50.0f;
	color[0] = 1.0f;
	color[1] = 0.0f;
	color[2] = 0.0f;
	color[3] = 1.0f;
	
	[self drawEllipse:totalvertices atPosition:position withRadius:radius withColor:color];
	
    [(EAGLView *)self.view presentFramebuffer];
}

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
	
	close_socket(tigersocket);
	[super viewDidDisappear:(BOOL)animated];
}

#pragma mark -
#pragma mark View Did Load/Unload, Dealloc Code

// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad {
	self.title = @"Gesture Drive";
	
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
	
    if (program)
    {
        glDeleteProgram(program);
        program = 0;
    }
	
    // Tear down context.
    if ([EAGLContext currentContext] == context)
        [EAGLContext setCurrentContext:nil];
	self.context = nil;	
	
	self.messageLabel = nil;
	self.tapsLabel = nil;
	self.touchesLabel = nil;
	
    [super viewDidUnload];
	
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

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
	
	close_socket(tigersocket);
	
	[messageLabel release];
	[tapsLabel release];
	[touchesLabel release];
	
    [super dealloc];
}

#pragma mark -
#pragma mark Update Data (Labels and Points)

- (void) updateLabels:(NSSet*) touches{
	//Label stuff
	
	NSUInteger numTaps = [[touches anyObject] tapCount];
	NSString *tapsMessage = [[NSString alloc] initWithFormat:@"%d taps detected",numTaps];
	tapsLabel.text = tapsMessage;
	[tapsMessage release];
	
	NSUInteger numTouches = [touches count];
	NSString *touchMessage = [[NSString alloc] initWithFormat:@"%d touches detected",numTouches];
	touchesLabel.text = touchMessage;
	[touchMessage release];
}

- (void) updatePoints:(NSSet*) touches{
	UITouch *t = [[touches allObjects] objectAtIndex:0];
	CGPoint touchPos = [t locationInView:t.view];
	
	currentx = (GLfloat)touchPos.x;
	currenty = (GLfloat)touchPos.y;
	
	if([touches count] > 1){
		UITouch *t2 = [[touches allObjects] objectAtIndex:1];
		CGPoint touchPos2 = [t2 locationInView:t2.view];
		
		currentx2 = (GLfloat)touchPos2.x;
		currenty2 = (GLfloat)touchPos2.y;
	}
	else{
		currentx2 = INFINITY;
		currenty2 = INFINITY;
	}
}

#pragma mark -
#pragma mark Gesture Detection Code

/*
	Detects 4 gestures:
	Forward Movement (Single swipe up)
	Reverse Movement (Single swipe down)
	Rotation Right (2 Finger Rotate Right)
	Rotation Left (2 Finger Rotate Left)
 */
- (void) detectGestures:(NSSet*) touches{
	
	SwipeType gestureswipe = noSwipe;
	if([touches count] == 1){
		//Single finger gestures
		UITouch *t = [touches anyObject];
		CGPoint currentpos = [t locationInView:t.view];
		
		CGFloat deltaX = (currentpos.x-gesturestartpoint.x);
		CGFloat deltaY = (currentpos.y-gesturestartpoint.y);
		
		
		if(fabsf(deltaX) >= MINGESTURELENGTH && fabsf(deltaY) <= MAXVARIANCE){
			//Horizontal Swipe
			if(deltaX > 0){
				//Swipe Right
				gestureLabel.text = @"Single Swipe Right";
				[self performSelector:@selector(eraseGestureLabel) withObject:nil afterDelay:2];
				
				sprintf(linebuf,"RIGHT\n");
				writeline(tigersocket, linebuf, strlen(linebuf));
				bzero(linebuf,MAXBUF);
				
				gestureswipe = horizontalSwipeRight;
			}
			else{
				//Swipe Left
				gestureLabel.text = @"Single Swipe Left";
				[self performSelector:@selector(eraseGestureLabel) withObject:nil afterDelay:2];
				
				sprintf(linebuf,"LEFT\n");
				writeline(tigersocket, linebuf, strlen(linebuf));
				bzero(linebuf,MAXBUF);
				
				gestureswipe = horizontalSwipeLeft;
			}
			
			
		}
		if(fabsf(deltaY) >= MINGESTURELENGTH && fabsf(deltaX) <= MAXVARIANCE){
			//Vertical Swipe
			
			if(deltaY > 0){
				//Swipe Up
				gestureLabel.text = @"Reverse Movement";
				[self performSelector:@selector(eraseGestureLabel) withObject:nil afterDelay:2];
				
				sprintf(linebuf,"DOWN\n");
				writeline(tigersocket, linebuf, strlen(linebuf));
				bzero(linebuf,MAXBUF);
				
				gestureswipe = verticalSwipeDown;
			}
			else{
				//Swipe Down
				gestureLabel.text = @"Forward Movement";
				[self performSelector:@selector(eraseGestureLabel) withObject:nil afterDelay:2];
				
				sprintf(linebuf,"UP\n");
				writeline(tigersocket, linebuf, strlen(linebuf));
				bzero(linebuf,MAXBUF);
				
				gestureswipe = verticalSwipeUp;
			}
			
		}
			
	}
	else if([touches count] == 2){
		//Multitouch (2 finger) gestures
		/*if(gesturerestart){
			UITouch *t1 = [[touches allObjects] objectAtIndex:0];
			UITouch *t2 = [[touches allObjects] objectAtIndex:1];
			
			CGPoint gesturestartpoint = [t1 locationInView:t1.view];
			CGPoint gesturestartpoint2 = [t2 locationInView:t2.view];
			
			gesturerestart = NO;
		}
		 */
		//else{
		
		
		
		//This code needs to be written later (w/ internet access)
		
		
		/*
		
		NSArray* toucharray = [touches allObjects];
		UITouch *t1 = [toucharray objectAtIndex:0];
		UITouch *t2 = [toucharray objectAtIndex:1];
		
		//Need to check that the current and previous points are referring to the same finger...
		//Need to do the infinity check...
		//Lots of problems...
		
		prevpos1x = currentpos1x;
		prevpos1y = currentpos1y;
		prevpos2x = currentpos2x;
		prevpos2y = currentpos2y;
		
		CGPoint currentpos1 = [t1 locationInView:t1.view];
		CGPoint currentpos2 = [t2 locationInView:t2.view];
		
		currentpos1x = currentpos1.x;
		currentpos1y = currentpos1.y;
		currentpos2x = currentpos2.x;
		currentpos2y = currentpos2.y;
		
		//Do I need to check for infinity at the beginning now?
		//Maybe...
		
		
		
		*/
		
		
		/*
		CGFloat deltaX1 = (currentpos1.x-gesturestartpoint.x);
		CGFloat deltaY1 = (currentpos1.y-gesturestartpoint.y);
		
		CGFloat deltaX2 = (currentpos2.x-gesturestartpoint2.x);
		CGFloat deltaY2 = (currentpos2.x-gesturestartpoint2.y);
							
		 */
		 
		//}
	}
	
	//gestureLabel.text = @"Rotation Right";
	//gestureLabel.text = @"Rotation Left";
	
}

- (void) eraseGestureLabel{
	gestureLabel.text = @"Gesture";
}
				 
#pragma mark -
#pragma mark Touch Sensing Code

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
	messageLabel.text = @"Touches Began";
	[self updateLabels:touches];
	[self updatePoints:touches];
	
	//gesturestartpoint is the location of ONE of the touches
	UITouch *t = [touches anyObject];
	gesturestartpoint = [t locationInView:t.view];
	
	currentpos1x = INFINITY;
	currentpos1y = INFINITY;
	currentpos2x = INFINITY;
	currentpos2y = INFINITY;
	
	
	//gesturerestart = YES;
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
	messageLabel.text = @"Touches Moved";
	[self updateLabels:touches];
	[self updatePoints:touches];
	[self detectGestures:touches];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
	messageLabel.text = @"Touches Ended";
	[self updateLabels:touches];
	
	sprintf(linebuf,"STOP\n");
	writeline(tigersocket, linebuf, strlen(linebuf));
	bzero(linebuf,MAXBUF);
}

-(void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event{
	messageLabel.text = @"Touches Cancelled";
	[self updateLabels:touches];
	
	sprintf(linebuf,"STOP\n");
	writeline(tigersocket, linebuf, strlen(linebuf));
	bzero(linebuf,MAXBUF);
}

@end
