#version 120

#define LavaSpeed 0.25 //[0.25 0.5 0.75 1]
#define Lava   		10010.0
#define WavingLiquids

//Lava Stuff
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



#define Lava   		10010.0



void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;
	vec4 position = gl_ModelViewMatrix * gl_Vertex;
	vec4 vpos = gbufferModelViewInverse*position;

	vec3 viewPos = (gl_ModelViewMatrix * gl_Vertex).xyz;
	vec3 feetPlayerPos = (gbufferModelViewInverse * vec4(viewPos, 1.0)).xyz;
	vec3 worldPos = feetPlayerPos + cameraPosition;
	


	float WaveDisplacement = 0.0;

	if(mc_Entity.x == Lava) {
		if (worldPos.y <= 31.99f) {
			float FractY = fract(vworldpos.y + 0.001);
			float Waves = 0.05 * sin(3.14 * (frameTimeCounter*LavaSpeed + vworldpos.x/10 + vworldpos.z/12)) + 0.15 * sin(frameTimeCounter*LavaSpeed + vworldpos.x/5 + vworldpos.z/15);
			WaveDisplacement = clamp(Waves, -FractY, 1.0-FractY);
			vpos.y += WaveDisplacement*0.5;
		}
	}

	vpos = gbufferModelView * vpos;
	gl_Position = gl_ProjectionMatrix * vpos;

    TexCoords = gl_MultiTexCoord0.st;
    LightmapCoords = mat2(gl_TextureMatrix[1]) * gl_MultiTexCoord1.st;
    LightmapCoords = (LightmapCoords * 33.05f / 32.0f) - (1.05f / 32.0f);
    Normal = gl_NormalMatrix * gl_Normal;
    Color = gl_Color;
}