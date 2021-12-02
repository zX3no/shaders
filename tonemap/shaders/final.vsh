#version 120

varying vec2 TexCoords;
varying vec4 Color;

void main() {
   gl_Position = ftransform();
   TexCoords = gl_MultiTexCoord0.xy;
   Color = gl_Color;
}