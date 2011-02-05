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

#ifndef RENDER_CONTROLLER_H
#define RENDER_CONTROLLER_H

#include <OpenGLES/ES2/gl.h>
#include <OpenGLES/ES2/glext.h>
#include <math.h>


typedef float vec_t;
typedef vec_t vec2_t[2];
typedef vec_t vec3_t[3];
typedef vec_t vec4_t[4];
typedef vec4_t color4_t;


#define vec2Set(__v, __x, __y) __v[0] = __x; __v[1] = __y;
#define vec3Set(__v, __x, __y, __z) __v[0] = __x; __v[1] = __y; __v[2] = __z;
#define vec4Set(__v, __x, __y, __z, __u) __v[0] = __x; __v[1] = __y; __v[2] = __z; __v[3] = __u;


#define __11 0
#define __21 1
#define __31 2
#define __41 3
#define __12 4
#define __22 5
#define __32 6
#define __42 7
#define __13 8
#define __23 9
#define __33 10
#define __43 11
#define __14 12
#define __24 13
#define __34 14
#define __44 15


enum {
    ATTRIB_VERTEX,
    ATTRIB_COLOR,
    ATTRIB_TEXCOORD
};


typedef struct camera_s
{
	vec3_t eye;
	vec3_t center;
	vec3_t up;
} camera_t;


#ifdef __cplusplus
extern "C" {
#endif

void aglBindTextureAttribute(GLint attributeHandle);

void aglCross3(vec3_t vOut, const vec3_t a, const vec3_t b);

void aglNormalize3(vec3_t vOut, const vec3_t vec);

void aglMatrixMultiply(float *mOut,
					   const float *mA,
					   const float *mB);

void aglBegin(GLenum prim);

void aglVertex3f(float x, float y, float z);

void aglColor4f(float r, float g, float b, float a);

void aglTexCoord2f(float s, float t);

void aglEnd();

void aglError(const char *source);

void aglMatrixTranslation(
					   float	*mOut,
					   const float	fX,
					   const float	fY,
					   const float	fZ);

void aglMatrixRotationZ(float	*mOut,
						const float fAngle);

void aglMatrixPerspectiveFovRH(
							float	*mOut,
							const float	fFOVy,
							const float	fAspect,
							const float	fNear,
							const float	fFar);

void aglMatrixLookAtRH(float *mOut, const vec3_t vEye, const vec3_t vAt, const vec3_t vUp);

void aglOrtho(float *mOut, float left, float right, float bottom, float top, float zNear, float zFar);

#ifdef __cplusplus
}
#endif
    
#endif
