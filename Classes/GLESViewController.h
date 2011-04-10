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

#import "GLESView.h"
#import "RenderController.h"

@interface GLESViewController : UIViewController 
{
    GLESView * glView;
    BOOL animating;
    BOOL displayLinkSupported;
    NSInteger animationFrameInterval;
    NSTimer *animationTimer;
    CADisplayLink * displayLink;
    
    
    GLuint textureHandle;
    
    GLint texCoordLocation;
    GLint cameraLocation;
    GLint sampleLocation;
    GLint timeLocation;
    GLuint shaderProgram;
    GLuint cameraUniform;
    
    camera_t camera;
    float zRotate;
    float cameraMatrix[16]; // column major order
    float rotationMatrix[16];
    vec4_t translationVector;
    
    int frames;
    CFTimeInterval CurrentTime;
    CFTimeInterval LastFPSUpdate;
}

- (id)initWithFrame:(CGRect)frame;
- (void)startAnimation;
- (void)stopAnimation;

@end
