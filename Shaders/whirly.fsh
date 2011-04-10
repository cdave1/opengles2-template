//
//  Shader.fsh
//  opengles2-template
//
//  Created by David Petrie on 18/05/10.
//  Copyright n/a 2011. All rights reserved.
//

precision highp float;
uniform float time;
varying vec2 texture_coordinate;
uniform sampler2D color_sampler;

void main()
{
    // Increasingly crazy whirligig soup
    
    mediump float  x = -1.0 + 2.0 * texture_coordinate[0];
    mediump float  y = -1.0 + 2.0 * texture_coordinate[1];
    
    mediump float d = sqrt(x*x + y*y);
    highp float r = d * cos(time) * sin(time);
    
    lowp float cosr = cos(r);
    lowp float sinr = sin(r);
    
    mediump float u = x*cosr - y*sinr;
    mediump float v = y*cosr + x*sinr;
    
    mediump vec2 a = vec2(u + time, v + time);
    
    gl_FragColor = texture2D(color_sampler, a);
}