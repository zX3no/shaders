#version 120

#include "distort.glsl"

varying vec2 TexCoords;
varying vec4 Color117;

void main(){
    gl_Position = ftransform();
    gl_Position.xy = DistortPosition(gl_Position.xy);
    TexCoords = gl_MultiTexCoord0.st;
    Color117 = gl_Color;
}