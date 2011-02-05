//
//  Shader.vsh
//  opengles2-template
// 

attribute vec4 position;
attribute vec4 color;
attribute vec2 texCoord;

varying vec2 texture_coordinate;

uniform mat4 camera;

void main()
{
    gl_Position = (camera * position);
    texture_coordinate = texCoord;
}
