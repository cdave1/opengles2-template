/*
 
 Copyright (c) 2011 David Petrie david@davidpetrie.com
 
 This software is provided 'as-is', without any express or implied warranty.
 In no event will the authors be held liable for any damages arising from the 
 use of this software. Permission is granted to anyone to use this software for
 any purpose, including commercial applications, and to alter it and 
 redistribute it freely, subject to the following restrictions:
 
 1. The origin of this software must not be misrepresented; you must not claim 
 that you wrote the original software. If you use this software in a product, an 
 acknowledgment in the product documentation would be appreciated but is not 
 required.
 2. Altered source versions must be plainly marked as such, and must not be 
 misrepresented as being the original software.
 3. This notice may not be removed or altered from any source distribution.
 
 */


#import "GLESViewController.h"
#import "TextureLoader.h"


@interface GLESViewController (PrivateMethods)
- (GLuint) compileShader:(NSString *)filePath withType:(GLenum)type;
- (void) setupGL;
- (void) render;
@end


@implementation GLESViewController

- (id)initWithFrame:(CGRect)frame
{
    if ((self = [super init]))
    {
        glView = [[GLESView alloc] initWithFrame:frame];
        self.view = glView;
        
        animating = FALSE;
        displayLinkSupported = FALSE;
        displayLink = nil;
        animationFrameInterval = 1;
        animationTimer = nil;
        
        NSString *reqSysVer = @"3.1";
        NSString *currSysVer = [[UIDevice currentDevice] systemVersion];
        if ([currSysVer compare:reqSysVer options:NSNumericSearch] != NSOrderedAscending)
            displayLinkSupported = TRUE;
        
        [self setupGL];
    }
    return self;
}


- (void)setupGL
{
    shaderProgram = glCreateProgram();
    
    GLuint vertexShader = [self compileShader:[[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"] withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:[[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"] withType:GL_FRAGMENT_SHADER];
    assert(vertexShader && fragmentShader);
    
    glBindAttribLocation(shaderProgram, ATTRIB_VERTEX, "position");
    glBindAttribLocation(shaderProgram, ATTRIB_COLOR, "color");
    
    glLinkProgram(shaderProgram);
    
    cameraUniform = glGetUniformLocation(shaderProgram, "camera");
    
    // Release vertex and fragment shaders
    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);
    
    
    cameraLocation = glGetUniformLocation(shaderProgram, "camera");
    sampleLocation = glGetUniformLocation(shaderProgram, "color_sampler");
    texCoordLocation = glGetAttribLocation(shaderProgram, "texCoord");
    
    LoadTexture("wood.png", &textureHandle); 
}


- (GLuint)compileShader:(NSString *)filePath withType:(GLenum)type
{
    assert(shaderProgram);
    
    GLuint shader;
    GLint status;
    const GLchar *source;
	
    if (!(source = (GLchar *)[[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] UTF8String]))
    {
        NSLog(@"Failed to load vertex shader");
        return FALSE;
    }
    
    shader = glCreateShader(type);
    glShaderSource(shader, 1, &source, NULL);
    glCompileShader(shader);
    glGetShaderiv(shader, GL_COMPILE_STATUS, &status);
    assert(status != 0);
    
    glAttachShader(shaderProgram, shader);
    return shader;
}


- (NSInteger)animationFrameInterval
{
    return animationFrameInterval;
}


- (void)setAnimationFrameInterval:(NSInteger)frameInterval
{
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
    if (!animating)
    {
        if (displayLinkSupported)
        {
			displayLink = [NSClassFromString(@"CADisplayLink") displayLinkWithTarget:self selector:@selector(render)];
            [displayLink setFrameInterval:animationFrameInterval];
            [displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
        }
        else
            animationTimer = [NSTimer scheduledTimerWithTimeInterval:(NSTimeInterval)((1.0 / 60.0) * animationFrameInterval) target:self selector:@selector(render) userInfo:nil repeats:TRUE];
        
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


static float zMove = 0.0f;
- (void)render
{
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);
	
    // Use shader program
	glUseProgram(shaderProgram);
	zMove += 0.05f;
	zRotate += 0.05f;
    
	vec3Set(camera.eye, 0.0f, 0.0f, -5.0f + sin(zMove));
	vec3Set(camera.center, sin(zMove), 0.0f, 10.0f);
	vec3Set(camera.up, 0.0f, 1.0f, 0.0f);
    
#if 1
	aglMatrixLookAtRH(cameraMatrix, camera.eye, camera.center, camera.up);
#else
    aglOrtho(cameraMatrix, -1.0f, 1.0f, -1.333333f, 1.333333f,  -10000.0f, 10000.0f);
#endif	
	
	aglMatrixRotationZ(rotationMatrix, zRotate);
	glUniformMatrix4fv(cameraLocation, 1, GL_FALSE, cameraMatrix);
	
    
	glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureHandle);
    glUniform1i(sampleLocation, 0);
    
	aglBegin(GL_TRIANGLE_STRIP);
    aglBindTextureAttribute(texCoordLocation);
	
    aglTexCoord2f(0.0f, 0.0f);
	aglColor4f(1.0f, 1.0f, 1.0f, 1.0f);
    aglVertex3f(-0.5f, -0.5f, 0.0f);
    
	aglTexCoord2f(1.0f, 0.0f);
    aglColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	aglVertex3f(0.5f, -0.5f, 0.0f);
    
    aglTexCoord2f(0.0f, 1.0f);
	aglColor4f(1.0f, 1.0f, 1.0f, 1.0f);
    aglVertex3f(-0.5f, 0.5f, 0.0f);
    
    aglTexCoord2f(1.0f, 1.0f);
	aglColor4f(1.0f, 1.0f, 1.0f, 1.0f);
    aglVertex3f(0.5f, 0.5f, 0.0f);
    
	aglEnd();
	
    [glView swapBuffers];
}


- (void)dealloc
{	
    if (shaderProgram)
    {
        glDeleteProgram(shaderProgram);
        shaderProgram = 0;
    }
	
    [self.view release];
	
    [super dealloc];
}


@end
