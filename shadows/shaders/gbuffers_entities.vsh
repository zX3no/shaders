#version 120

varying vec2 lmcoord;
varying vec2 texcoord;
varying vec2 TexCoords;
varying vec2 LightmapCoords;
varying vec3 Normal117;
varying vec4 Color117;

void main() {
    texcoord = (gl_TextureMatrix[0] * gl_MultiTexCoord0).xy;
	lmcoord  = (gl_TextureMatrix[1] * gl_MultiTexCoord1).xy;

	gl_Position = ftransform();
    TexCoords = gl_MultiTexCoord0.st;
    LightmapCoords = mat2(gl_TextureMatrix[1]) * gl_MultiTexCoord1.st;
    LightmapCoords = (LightmapCoords * 33.05f / 32.0f) - (1.05f / 32.0f);
    Normal117 = gl_NormalMatrix * gl_Normal;
    Color117 = gl_Color;
}