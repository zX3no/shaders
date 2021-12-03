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

const float sunPathRotation = -35.0f;

float Ambient = 0.005;

const int noiseTextureResolution = 256;
const int ShadowSamplesPerSize = 2 * ShadowSamples + 1;
const int TotalSamples = ShadowSamplesPerSize * ShadowSamplesPerSize;

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
    vec3 sunPosNorm = mat3(gbufferModelViewInverse) * sunPosition;
    sunPosNorm = normalize(sunPosNorm);
    vec3 skyColor = mix((vec3(166, 219, 255)/255), (vec3(4, 21, 56)/255), vec3(pow(abs(sunPosNorm.y), 2.0f)));
    if (worldTime > 11000 && worldTime < 23800) {
        skyColor = mix((vec3(166, 219, 255)/255), (vec3(0, 31, 255)/255), vec3(abs(sunPosNorm.y)));
    }

    vec3 torchLighting = Lightmap.x * torchColor;
    vec3 skyLighting = Lightmap.y * skyColor;
    if (worldTime > 13550 && worldTime < 23800) {
        skyLighting = mix(vec3(Lightmap.y * skyColor), vec3(Lightmap.y * skyColor/3), vec3(abs(sunPosNorm.y)));
    }
    vec3 lightmapLighting = torchLighting + skyLighting;
    return lightmapLighting;
}

float Visibility(in sampler2D ShadowMap, in vec3 SampleCoords) {
    return step(SampleCoords.z - 0.001f, texture2D(ShadowMap, SampleCoords.xy).r);
}

vec3 TransparentShadow(in vec3 SampleCoords){
    float ShadowVisibility0 = Visibility(shadowtex0, SampleCoords);
    float ShadowVisibility1 = Visibility(shadowtex1, SampleCoords);
    vec4 ShadowColor0 = texture2D(shadowcolor0, SampleCoords.xy);
    vec3 TransmittedColor = ShadowColor0.rgb * (TransparentShadowHardness - ShadowColor0.r);
    return mix(TransmittedColor * ShadowVisibility1, vec3(1.0f), ShadowVisibility0);
}

vec3 getShadow(float depth) {
    vec3 ClipSpace = vec3(TexCoords, depth) * 2.0f - 1.0f;
    vec4 ViewW = gbufferProjectionInverse * vec4(ClipSpace, 1.0f);
    vec3 View = ViewW.xyz / ViewW.w;
    vec4 World = gbufferModelViewInverse * vec4(View, 1.0f);
    vec4 ShadowSpace = shadowProjection * shadowModelView * World;
    ShadowSpace.xy = DistortPosition(ShadowSpace.xy);
    vec3 SampleCoords = ShadowSpace.xyz * 0.5f + 0.5f;
    float RandomAngle = texture2D(noisetex, TexCoords * 20.0f).r * 10.0f;
    float cosTheta = cos(RandomAngle);
	float sinTheta = sin(RandomAngle);
    mat2 Rotation =  mat2(cosTheta, -sinTheta, sinTheta, cosTheta) / shadowMapResolution;
    vec3 ShadowAccum = vec3(0.0f);
    for(int x = -ShadowSamples; x <= ShadowSamples; x++){
        for(int y = -ShadowSamples; y <= ShadowSamples; y++){
            vec2 Offset = Rotation * vec2(x, y);
            vec3 CurrentSampleCoordinate = vec3(SampleCoords.xy + Offset, SampleCoords.z);
            ShadowAccum += TransparentShadow(CurrentSampleCoordinate);
        }
    }
    ShadowAccum /= TotalSamples;
    return ShadowAccum;
}


void main() {
    //Shadows
    vec3 Albedo = pow(texture2D(colortex0, TexCoords).rgb, vec3(1.9f));
    float Depth = texture2D(depthtex0, TexCoords).r;
    if(Depth == 1.0f){
        gl_FragData[0] = vec4(Albedo, 1.0f);
        return;
    }
    vec2 Lightmap = texture2D(colortex2, TexCoords).rg;
    vec3 lightmapColor = lightmapColor(Lightmap);
    vec3 Normal117 = normalize(texture2D(colortex1, TexCoords).rgb * 2.0f - 1.0f);
    float NdotL = max(dot(Normal117, normalize(shadowLightPosition)), 0.0f);
    vec3 Diffuse = Albedo * (lightmapColor + NdotL * getShadow(Depth) + Ambient);
    if (rainStrength > 0.1f ) {
        //Normal117 = mix(normalize(texture2D(colortex1, TexCoords).rgb * 2.0f - 1.0f), normalize(texture2D(colortex1, vec2(0.0,1.0)).rgb * 2.0f - 1.0f), vec3(abs(rainStrength)));
        NdotL = mix(max(dot(Normal117, normalize(shadowLightPosition)), 0.0f), 0.05f, abs(rainStrength));
        if(worldTime > 12700 && worldTime < 23500) {
            NdotL = 0.005f;
        }
        Diffuse = Albedo * (lightmapColor + NdotL * getShadow(Depth) + Ambient);
    }
    else if(worldTime > 12700 && worldTime < 23500) {
        NdotL = 0.005f;
        Diffuse = Albedo * (lightmapColor + NdotL * getShadow(Depth) + Ambient);

    }

    /* DRAWBUFFERS:0 */
    
    gl_FragData[0] = vec4(Diffuse, 1.0f);
}
