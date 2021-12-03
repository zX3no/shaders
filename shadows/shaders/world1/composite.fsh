#version 120

#define ShadowSamples 2 //[1 2 3 4 5]
#define shadowMapResolution 1024 //[256 512 1024 2048 4096]
#define TransparentShadowHardness 2 // [0.5 1 2 3 4 5]

#include "distort.glsl"

varying vec2 TexCoords;
uniform vec3 shadowLightPosition;
uniform vec3 sunPosition;

uniform mat4 gbufferProjectionInverse;
uniform mat4 gbufferModelViewInverse;
uniform mat4 shadowModelView;
uniform mat4 shadowProjection;

uniform sampler2D colortex0;
uniform sampler2D colortex1;
uniform sampler2D colortex2;
uniform sampler2D depthtex0;
uniform sampler2D shadowtex0;
uniform sampler2D shadowtex1;
uniform sampler2D shadowcolor0;
uniform sampler2D noisetex;
uniform sampler2D texture;
uniform sampler2D gcolor;
uniform int worldTime;
uniform float wetness;
uniform ivec2 eyeBrightness;
uniform ivec2 eyeBrightnessSmooth;
uniform float far;
uniform float near;
uniform float rainStrength;
uniform float sunAngle;
varying vec2 texcoord;
varying vec4 glcolor;

/*
const int colortex0Format = RGB16;
const int colortex1Format = RGB16;
const int colortex2Format = RGB16;
*/

//const float sunPathRotation = -35.0f;

float Ambient = 0.025;


//const int noiseTextureResolution = 256;
//const int ShadowSamplesPerSize = 2 * ShadowSamples + 1;
//const int TotalSamples = ShadowSamplesPerSize * ShadowSamplesPerSize;

float lightmapTorch(in float torch) {
    const float K = 2.0f;
    const float P = 5.06f;
    return K * pow(torch, P);
}

float lightmapSky(in float sky) {
    float sky_2 = sky * sky;
    return sky_2 * sky_2;
}

vec2 adjustLightmap(in vec2 Lightmap) {
    vec2 NewLightMap;
    NewLightMap.x = lightmapTorch(Lightmap.x);
    NewLightMap.y = lightmapSky(Lightmap.y);
    return NewLightMap;
}

vec3 lightmapColor(in vec2 Lightmap) {
    Lightmap = adjustLightmap(Lightmap);
    const vec3 torchColor = vec3(3.25, 1.25, 0.625);
    vec3 skyColor = vec3(0.25, 0.375, 0.75);

    vec3 torchLighting = Lightmap.x * torchColor;
    vec3 skyLighting = Lightmap.y * skyColor;
    vec3 lightmapLighting = torchLighting + skyLighting;
    return lightmapLighting;
}


void main() {
    //Shadows
    vec3 Albedo = pow(texture2D(colortex0, TexCoords).rgb, vec3(2.2f));
    vec2 Lightmap = texture2D(colortex2, TexCoords).rg;
    vec3 lightmapColor = lightmapColor(Lightmap);
    //vec3 Diffuse = Albedo * (lightmapColor + NdotL * getShadow(Depth) + Ambient);
    /* DRAWBUFFERS:0 */

    gl_FragData[0] = vec4((Albedo * (lightmapColor + Ambient)), 1.0f);
}
