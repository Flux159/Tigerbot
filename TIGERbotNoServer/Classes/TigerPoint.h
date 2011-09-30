//
//  TigerPoint.h
//  TIGERbot
//
//  Created by Suyog S Sonwalkar on 12/31/10.
//  Copyright 2010 Suyog S Sonwalkar. All rights reserved.
//

/*
 Tigerpoint:
 
 A simple object that only contains x,y coordinates (I realize that CGPoint is almost the same thing, except it uses CGFloats rather than GLfloats)
 */

#import <Foundation/Foundation.h>

#import <QuartzCore/QuartzCore.h>

#import <OpenGLES/EAGL.h>

#import <OpenGLES/ES1/gl.h>
#import <OpenGLES/ES1/glext.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>

@interface TigerPoint : NSObject {
	GLfloat x;
	GLfloat y;
    float t;
}

-(GLfloat)getx;
-(GLfloat)gety;
-(id)initWithX:(GLfloat)xval withY:(GLfloat)yval;

@end
