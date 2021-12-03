#version 120


varying vec2 TexCoords;
varying vec4 Color117;

uniform sampler2D texture;

void main() {
    gl_FragData[0] = texture2D(texture, TexCoords) * Color117;
}