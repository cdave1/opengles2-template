//
//  Shader.fsh
//  opengles2-template
//
//  Created by David Petrie on 18/05/10.
//  Copyright n/a 2011. All rights reserved.
//

precision mediump float;
varying vec2 texture_coordinate;
uniform sampler2D color_sampler;

void main()
{
   // gl_FragColor = colorVarying;
   gl_FragColor = texture2D(color_sampler, texture_coordinate);
}