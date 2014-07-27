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

@interface GLESViewController () {}
@property (strong, nonatomic) EAGLContext *context;
@property (strong, nonatomic) GLKBaseEffect *effect;

- (void)setupGL;
- (void)tearDownGL;
@end


@implementation GLESViewController

- (void)dealloc {
    [_context release];
    [_effect release];
    [super dealloc];
}


- (void)viewDidLoad {
    [super viewDidLoad];

    self.context = [[[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2] autorelease];

    if (!self.context) {
        NSLog(@"Failed to create ES context");
    }

    GLKView *view = (GLKView *)self.view;
    view.context = self.context;
    view.drawableDepthFormat = GLKViewDrawableDepthFormat24;
    [view  setMultipleTouchEnabled:YES];

    self.preferredFramesPerSecond = 60;
    [self setupGL];
}


- (void)viewDidUnload {
    [super viewDidUnload];

    [self tearDownGL];

    if ([EAGLContext currentContext] == self.context) {
        [EAGLContext setCurrentContext:nil];
    }
    self.context = nil;
}


- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (interfaceOrientation == UIInterfaceOrientationLandscapeLeft ||
            interfaceOrientation == UIInterfaceOrientationLandscapeRight);
}


- (void)tearDownGL {
    [EAGLContext setCurrentContext:self.context];
}


- (void)setupGL {
    [EAGLContext setCurrentContext:self.context];

    glEnable(GL_LINE_SMOOTH);
	glLineWidth(1.0f);
    
    shaderProgram = glCreateProgram();

    GLuint vertexShader = [self compileShader:[[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"vsh"] withType:GL_VERTEX_SHADER];
    GLuint fragmentShader = [self compileShader:[[NSBundle mainBundle] pathForResource:@"Shader" ofType:@"fsh"] withType:GL_FRAGMENT_SHADER];
    assert(vertexShader && fragmentShader);

    glLinkProgram(shaderProgram);

    cameraUniform = glGetUniformLocation(shaderProgram, "camera");

    glDeleteShader(vertexShader);
    glDeleteShader(fragmentShader);

    cameraLocation = glGetUniformLocation(shaderProgram, "camera");
    sampleLocation = glGetUniformLocation(shaderProgram, "color_sampler");
    timeLocation = glGetUniformLocation(shaderProgram, "time");

    positionLocation = glGetAttribLocation(shaderProgram, "position");
    colorLocation = glGetAttribLocation(shaderProgram, "color");
    texCoordLocation = glGetAttribLocation(shaderProgram, "texCoord");

    LoadTexture("lena.png", &textureHandle);
}


- (GLuint)compileShader:(NSString *)filePath withType:(GLenum)type {
    assert(shaderProgram);

    GLuint shader;
    GLint status;
    const GLchar *source;

    if (!(source = (GLchar *)[[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] UTF8String])) {
        NSLog(@"Failed to load vertex shader");
        return FALSE;
    }

    shader = glCreateShader(type);
    glShaderSource(shader, 1, &source, NULL);
    glCompileShader(shader);
    glGetShaderiv(shader, GL_COMPILE_STATUS, &status);

    if (status == 0) {
        GLchar log[2048];
        GLsizei len;

        glGetShaderInfoLog(shader, 2048, &len, log);
        printf("%s\n", log);
        return 0;
    } else {
        glAttachShader(shaderProgram, shader);
        return shader;
    }
}


- (void)update {
    ++frames;
	CurrentTime = CACurrentMediaTime();

	if ((CurrentTime - LastFPSUpdate) > 1.0f) {
        if (self.delegate) {
            [self.delegate performSelector:@selector(ReportFPS:) withObject:[NSNumber numberWithFloat:frames]];
        }

		printf("fps: %d\n", frames);
		frames = 0;
		LastFPSUpdate = CurrentTime;
	}
}


static float zMove = 0.0f;
- (void)glkView:(GLKView *)view drawInRect:(CGRect)rect {
    glClearColor(0.5f, 0.5f, 0.5f, 1.0f);
    glClear(GL_COLOR_BUFFER_BIT);

    // Use shader program
	glUseProgram(shaderProgram);
	zMove += 0.02f;
	zRotate += 0.05f;

	vec3Set(camera.eye, 0.0f, 0.0f, -5.0f + sin(zMove));
	vec3Set(camera.center, sin(zMove), 0.0f, 10.0f);
	vec3Set(camera.up, 0.0f, 1.0f, 0.0f);

#if 0
	aglMatrixLookAtRH(cameraMatrix, camera.eye, camera.center, camera.up);
#else
    aglOrtho(cameraMatrix, -1.0f, 1.0f, -1.5f, 1.5f,  -10000.0f, 10000.0f);
#endif

	aglMatrixRotationZ(rotationMatrix, zRotate);
	glUniformMatrix4fv(cameraLocation, 1, GL_FALSE, cameraMatrix);


	glActiveTexture(GL_TEXTURE0);
    glBindTexture(GL_TEXTURE_2D, textureHandle);
    glUniform1i(sampleLocation, 0);

    glUniform1f(timeLocation, zMove); // sin(zMove));

	aglBegin(GL_TRIANGLE_STRIP);

    aglBindPositionAttribute(positionLocation);
    aglBindColorAttribute(colorLocation);
    aglBindTextureAttribute(texCoordLocation);

    aglTexCoord2f(1.0f, 0.0f);
	aglColor4f(1.0f, 1.0f, 1.0f, 1.0f);
    aglVertex3f(-1.0f, -1.5f, 0.0f);

	aglTexCoord2f(1.0f, 1.0f);
    aglColor4f(1.0f, 1.0f, 1.0f, 1.0f);
	aglVertex3f(1.0f, -1.5f, 0.0f);

    aglTexCoord2f(0.0f, 0.0f);
	aglColor4f(1.0f, 1.0f, 1.0f, 1.0f);
    aglVertex3f(-1.0f, 1.5f, 0.0f);

    aglTexCoord2f(0.0f, 1.0f);
	aglColor4f(1.0f, 1.0f, 1.0f, 1.0f);
    aglVertex3f(1.0f, 1.5f, 0.0f);

	aglEnd();

    ++frames;
    CurrentTime = CACurrentMediaTime();

    if ((CurrentTime - LastFPSUpdate) > 1.0f) {
        printf("fps: %d\n", frames);
        frames = 0;
        LastFPSUpdate = CurrentTime;
    }
}

@end
