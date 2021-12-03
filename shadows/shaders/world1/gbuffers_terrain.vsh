#version 120

#define LavaSpeed 0.25 //[0.25 0.5 0.75 1]
#define WaveAmount 0.5 //[0.25 0.5 0.75 1]
#define WaveSpeed 0.75 //[0.5 0.75 1 1.25 1.5]
#define Lava   		10010.0
#define Water		10008.0
#define WavingLiquids

//Water Stuff
#ifdef WavingLiquids
attribute vec4 mc_Entity;
attribute vec2 mc_midTexCoord;
varying vec3 vworldpos;
uniform float frameTimeCounter;
varying vec2 lmcoord;
varying vec2 texcoord;
varying vec4 glcolor;
uniform mat4 gbufferModelView;
uniform mat4 gbufferModelViewInverse;
uniform vec3 cameraPosition;
#endif

//Shadow Stuff
varying vec2 TexCoords;
varying vec2 LightmapCoords;
varying vec3 Normal;
varying vec4 Color;

void main() {
	#ifdef WavingLiquids
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	vec4 position = gl_ModelViewMatrix * gl_Vertex;
	vec4 vpos = gbufferModelViewInverse*position;
	vworldpos = vpos.xyz + cameraPosition;
	float WaveDisplacement = 0.0;

	if(mc_Entity.x == Water) {
		float FractY = fract(vworldpos.y + 0.001);
		float Waves = 0.05 * sin(3.14 * (frameTimeCounter*WaveSpeed + vworldpos.x/5 + vworldpos.z/6)) + 0.10 * sin(frameTimeCounter*WaveSpeed + vworldpos.x/2.5 + vworldpos.z/10);
		WaveDisplacement = clamp(Waves, -FractY, 1.0-FractY);
		vpos.y += WaveDisplacement*WaveAmount;
	}
	

	if(mc_Entity.x == Lava) {
		float FractY = fract(vworldpos.y + 0.001);
		float Waves = 0.05 * sin(3.14 * (frameTimeCounter*LavaSpeed + vworldpos.x/10 + vworldpos.z/12)) + 0.15 * sin(frameTimeCounter*LavaSpeed + vworldpos.x/5 + vworldpos.z/15);
		WaveDisplacement = clamp(Waves, -FractY, 1.0-FractY);
		vpos.y += WaveDisplacement*0.5;
	}
	

	vpos = gbufferModelView * vpos;
	gl_Position = gl_ProjectionMatrix * vpos;
	#endif

	#ifndef WavingLiquids
	gl_Position = ftransform();
	#endif
    TexCoords = gl_MultiTexCoord0.st;
    LightmapCoords = mat2(gl_TextureMatrix[1]) * gl_MultiTexCoord1.st;
    LightmapCoords = (LightmapCoords * 33.05f / 32.0f) - (1.05f / 32.0f);
    Normal = gl_NormalMatrix * gl_Normal;
    Color = gl_Color;
}