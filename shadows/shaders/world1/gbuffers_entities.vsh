#version 120

#define LavaSpeed 0.25 //[0.25 0.5 0.75 1]
#define WaveAmount 0.5 //[0.25 0.5 0.75 1]
#define WaveSpeed 0.75 //[0.5 0.75 1 1.25 1.5]
#define Lava   		10010.0
#define Water		10008.0

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec2 TexCoords;
varying vec2 LightmapCoords;
varying vec3 Normal;
varying vec4 Color;

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;

	gl_Position = ftransform();
    TexCoords = gl_MultiTexCoord0.st;
    LightmapCoords = mat2(gl_TextureMatrix[1]) * gl_MultiTexCoord1.st;
    LightmapCoords = (LightmapCoords * 33.05f / 32.0f) - (1.05f / 32.0f);
    Normal = gl_NormalMatrix * gl_Normal;
    Color = gl_Color;
}