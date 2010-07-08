/* lighting.vert - emulates fixed function pipeline lighting */


varying vec3 normal;   // vertex normal in eye space.
varying vec3 position; // vertex position in eye space.


//
// computes light of a single light source.
//
// N normalized vertex normal in eye space.
// V vertex position in eye space.
//
vec4 lightSource( vec3 N, vec3 V, gl_LightSourceParameters light )
{
	float d = length( light.position.xyz - V );
	vec3  L = normalize( light.position.xyz - V );
	vec3  H = normalize( L + vec3( 0.0, 0.0, 1.0 ) ); // eye at (0,0,infinity)
//	vec3  H = normalize( L - V.xyz ); // eye at (0,0,0)

	float NdotL = max( 0.0, dot( N,L ) );
	float NdotH = max( 0.0, dot( N,H ) );

	float Idiff = NdotL;
	float Ispec = pow( NdotH, gl_FrontMaterial.shininess );

	return
		gl_FrontMaterial.ambient  * light.ambient +
		gl_FrontMaterial.diffuse  * light.diffuse  * Idiff +
		gl_FrontMaterial.specular * light.specular * Ispec;
}


//
// computes light of all light sources and the scene.
//
vec4 lighting( void )
{
	vec3 N = normalize( gl_NormalMatrix * gl_Normal );
	vec3 V = ( gl_ModelViewMatrix * gl_Vertex ).xyz;

	return
		gl_FrontMaterial.emission +
		gl_FrontMaterial.ambient * gl_LightModel.ambient +
		lightSource( N, V, gl_LightSource[0] );
}


//
// entry point
//
void main( void )
{
	gl_Position = ftransform();
	gl_TexCoord[0] = gl_MultiTexCoord0;

	normal = gl_NormalMatrix * gl_Normal;
	position = ( gl_ModelViewMatrix * gl_Vertex ).xyz;

	gl_FrontColor = lighting();
}


