#version 120

varying vec2 TexCoords;
varying vec2 LightmapCoords;
varying vec3 Normal117;
varying vec4 Color117;
varying vec2 texcoord;
varying vec4 glcolor;

uniform sampler2D texture;

void main() {
	gl_Position = ftransform();
    TexCoords = gl_MultiTexCoord0.st;
    LightmapCoords = mat2(gl_TextureMatrix[0]) * gl_MultiTexCoord1.st;
    LightmapCoords = (LightmapCoords * 33.05f / 32.0f) - (1.05f / 32.0f);
    Normal117 = gl_NormalMatrix * gl_Normal;
    Color117 = gl_Color;
}