//
//  TigerPoint.m
//  TIGERbot
//
//  Created by Suyog S Sonwalkar on 12/31/10.
//  Copyright 2010 Suyog S Sonwalkar. All rights reserved.
//

/*
 A simple object that only contains x,y coordinates (I realize that CGPoint is almost the same thing, except it uses CGFloats rather than GLfloats)
 */

#import "TigerPoint.h"

@implementation TigerPoint

-(id)initWithX:(GLfloat)xval withY:(GLfloat)yval{
	
	self = [super init];
	
	if(self){
		x = xval;
		y = yval;
	}
	
	return self;    
}

-(GLfloat)getx{
	return x;
}

-(GLfloat)gety{
	return y;
}

-(void)dealloc{
	[super dealloc];
}

@end
