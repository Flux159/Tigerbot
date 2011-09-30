//
//  Shader.fsh
//  OpenGL Demo Application
//
//  Created by Suyog S Sonwalkar on 12/24/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

varying lowp vec4 colorVarying;

void main()
{
    gl_FragColor = colorVarying;
}
