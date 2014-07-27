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

#include "RenderController.h"
#include <strings.h>

#define MAX_VERTEX_COUNT 8192

typedef struct vertex {
	float xyzv[4];
	float st[2];
	float rgba[4];
} vertex_t;


static vertex_t vertices[MAX_VERTEX_COUNT];
static vertex_t vertex;
static GLenum currentPrimitive = GL_TRIANGLES;
static int vertexCount = 0;


void aglBegin(GLenum prim) {
	currentPrimitive = prim;
	vertexCount = 0;
}


void aglBindPositionAttribute(GLint attributeHandle) {
	glVertexAttribPointer(attributeHandle, 4, GL_FLOAT, 0, sizeof(vertex_t), vertices[0].xyzv);
    glEnableVertexAttribArray(attributeHandle);
}


void aglBindColorAttribute(GLint attributeHandle) {
	glVertexAttribPointer(attributeHandle, 4, GL_FLOAT, 0, sizeof(vertex_t), vertices[0].rgba);
    glEnableVertexAttribArray(attributeHandle);
}


void aglBindTextureAttribute(GLint attributeHandle) {
    glVertexAttribPointer(attributeHandle, 2, GL_FLOAT, 0, sizeof(vertex_t), vertices[0].st); 
    glEnableVertexAttribArray(attributeHandle);
}


void aglVertex3f(float x, float y, float z) {
	if (vertexCount > MAX_VERTEX_COUNT) return;
    vec4Set(vertex.xyzv, x, y, z, 1.0f);
	vertices[vertexCount] = vertex;
	vertexCount++;
}


void aglColor4f(float r, float g, float b, float a) {
    vec4Set(vertex.rgba, r, g, b, a);
}


void aglTexCoord2f(float s, float t) {
    vec2Set(vertex.st, s, t);
}


void aglEnd() {
	if (vertexCount == 0) {
		currentPrimitive = 0;
		return;
	}
	glDrawArrays(currentPrimitive, 0, vertexCount);
	vertexCount = 0;
	currentPrimitive = 0;
}


void aglMatrixTranslation(float	*mOut,
                          const float	fX,
                          const float	fY,
                          const float	fZ) {
	mOut[__11] = 1;	mOut[__12] = 0;	mOut[__13] = 0;	mOut[__14] = 0;
	mOut[__21] = 0;	mOut[__22] = 1;	mOut[__23] = 0;	mOut[__24] = 0;
	mOut[__31] = 0;	mOut[__32] = 0;	mOut[__33] = 1;	mOut[__34] = 0;
	mOut[__41] = fX;	mOut[__42] = fY;	mOut[__43] = fZ;	mOut[__44] = 1;
}


void aglMatrixRotationZ(float	*mOut,
					 const float fAngle) {
	float fsin = sinf(fAngle);
	float fcos = cosf(fAngle);
	
	mOut[__11] = fcos;	mOut[__12] = fsin;	mOut[__13] = 0;	mOut[__14] = 0;
	mOut[__21] = -fsin;	mOut[__22] = fcos;	mOut[__23] = 0;	mOut[__24] = 0;
	mOut[__31] = 0;		mOut[__32] = 0;		mOut[__33] = 1;	mOut[__34] = 0;
	mOut[__41] = 0;		mOut[__42] = 0;	mOut[__43] = 0;	mOut[__44] = 1;
}


void aglMatrixPerspectiveFovRH(float	 *mOut,
                               const float	fFOVy,
                               const float	fAspect,
                               const float	fNear,
                               const float	fFar) {
	float f, n, fRealAspect;
	
	fRealAspect = fAspect;
	
	// cotangent(a) == 1.0f / tan(a);
	f = 1.0f / (float)tan(fFOVy * 0.5f);
	n = 1.0f / (fNear - fFar);
	
	mOut[ 0] = f / fRealAspect;
	mOut[ 1] = 0;
	mOut[ 2] = 0;
	mOut[ 3] = 0;
	
	mOut[ 4] = 0;
	mOut[ 5] = f;
	mOut[ 6] = 0;
	mOut[ 7] = 0;
	
	mOut[ 8] = 0;
	mOut[ 9] = 0;
	mOut[10] = (fFar + fNear) * n;
	mOut[11] = -1;
	
	mOut[12] = 0;
	mOut[13] = 0;
	mOut[14] = (2 * fFar * fNear) * n;
	mOut[15] = 0;
}


void aglCross3(vec3_t vOut, const vec3_t a, const vec3_t b) {
	vec3Set(vOut,
			(a[1] * b[2]) - (a[2] * b[1]),
			(a[2] * b[0]) - (a[0] * b[2]),
			(a[0] * b[1]) - (a[1] * b[0]));
}


void aglNormalize3(vec3_t vOut, const vec3_t vec) {
	float f;
	double temp;
	
	temp = (double)(vec[0] * vec[0] + vec[1] * vec[1] + vec[2] * vec[2]);
	temp = 1.0 / sqrt(temp);
	f = (float)temp;
	vec3Set(vOut, vec[0] * f, vec[1] * f, vec[2] * f);
}


void aglMatrixLookAtRH(float *mOut, const vec3_t vEye, const vec3_t vAt, const vec3_t vUp) {
	vec3_t f, vUpActual, s, u;
	float	t[16];
	
	f[0] = vAt[0] - vEye[0];
	f[1] = vAt[1] - vEye[1];
	f[2] = vAt[2] - vEye[2];
	
	aglNormalize3(f, f);
	aglNormalize3(vUpActual, vUp);
	aglCross3(s, f, vUpActual);
	aglCross3(u, s, f);
	
	mOut[ 0] = s[0];
	mOut[ 1] = u[0];
	mOut[ 2] = -f[0];
	mOut[ 3] = 0;
	
	mOut[ 4] = s[1];
	mOut[ 5] = u[1];
	mOut[ 6] = -f[1];
	mOut[ 7] = 0;
	
	mOut[ 8] = s[2];
	mOut[ 9] = u[2];
	mOut[10] = -f[2];
	mOut[11] = 0;
	
	mOut[12] = 0;
	mOut[13] = 0;
	mOut[14] = 0;
	mOut[15] = 1;
	
	aglMatrixTranslation(t, -vEye[0], -vEye[1], -vEye[2]);
	aglMatrixMultiply(mOut, t, mOut);
}


void aglMatrixMultiply(float *mOut,
					  const float *mA,
					  const float *mB) {
	mOut[__11] = mA[__11]*mB[__11] + mA[__12]*mB[__21] + mA[__13]*mB[__31] + mA[__14]*mB[__41];	
	mOut[__12] = mA[__11]*mB[__12] + mA[__12]*mB[__22] + mA[__13]*mB[__32] + mA[__14]*mB[__42];	
	mOut[__13] = mA[__11]*mB[__13] + mA[__12]*mB[__23] + mA[__13]*mB[__33] + mA[__14]*mB[__43];	
	mOut[__14] = mA[__11]*mB[__14] + mA[__12]*mB[__24] + mA[__13]*mB[__34] + mA[__14]*mB[__44];
	
	mOut[__21] = mA[__21]*mB[__11] + mA[__22]*mB[__21] + mA[__23]*mB[__31] + mA[__24]*mB[__41];	
	mOut[__22] = mA[__21]*mB[__12] + mA[__22]*mB[__22] + mA[__23]*mB[__32] + mA[__24]*mB[__42];	
	mOut[__23] = mA[__21]*mB[__13] + mA[__22]*mB[__23] + mA[__23]*mB[__33] + mA[__24]*mB[__43];	
	mOut[__24] = mA[__21]*mB[__14] + mA[__22]*mB[__24] + mA[__23]*mB[__34] + mA[__24]*mB[__44];
	
	mOut[__31] = mA[__31]*mB[__11] + mA[__32]*mB[__21] + mA[__33]*mB[__31] + mA[__34]*mB[__41];	
	mOut[__32] = mA[__31]*mB[__12] + mA[__32]*mB[__22] + mA[__33]*mB[__32] + mA[__34]*mB[__42];	
	mOut[__33] = mA[__31]*mB[__13] + mA[__32]*mB[__23] + mA[__33]*mB[__33] + mA[__34]*mB[__43];	
	mOut[__34] = mA[__31]*mB[__14] + mA[__32]*mB[__24] + mA[__33]*mB[__34] + mA[__34]*mB[__44];
	
	mOut[__41] = mA[__41]*mB[__11] + mA[__42]*mB[__21] + mA[__43]*mB[__31] + mA[__44]*mB[__41];
	mOut[__42] = mA[__41]*mB[__12] + mA[__42]*mB[__22] + mA[__43]*mB[__32] + mA[__44]*mB[__42];
	mOut[__43] = mA[__41]*mB[__13] + mA[__42]*mB[__23] + mA[__43]*mB[__33] + mA[__44]*mB[__43];
	mOut[__44] = mA[__41]*mB[__14] + mA[__42]*mB[__24] + mA[__43]*mB[__34] + mA[__44]*mB[__44];
}


void aglOrtho(float *mOut, float left, float right, float bottom, float top, float zNear, float zFar) {
    bzero(mOut, sizeof(float) * 16);
    
    if (right != left) {
        mOut[ 0] = 2 / (right - left);
        mOut[ 1] = 0;
        mOut[ 2] = 0;
        mOut[ 3] = - ((right + left) / (right - left));
    }
    
    if (top != bottom) {
        mOut[ 4] = 0;
        mOut[ 5] = 2 / (top - bottom);
        mOut[ 6] = 0;
        mOut[ 7] = - ((top + bottom) / (top - bottom));
    }
	
    if (zFar != zNear) {
        mOut[ 8] = 0;
        mOut[ 9] = 0;
        mOut[10] = -2 / (zFar - zNear);
        mOut[11] = - ((zFar + zNear) / (zFar - zNear));
    }
	
	mOut[12] = 0;
	mOut[13] = 0;
	mOut[14] = 0;
	mOut[15] = 1;
}
