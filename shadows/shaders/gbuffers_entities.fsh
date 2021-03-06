#version 120

varying vec2 TexCoords;
varying vec2 LightmapCoords;
varying vec3 Normal117;
varying vec4 Color117;

uniform sampler2D texture;


void main(){
    vec4 Albedo = texture2D(texture, TexCoords) * Color117;
    /* DRAWBUFFERS:012 */
    gl_FragData[0] = Albedo;
    gl_FragData[1] = vec4(Normal117 * 0.5f + 0.5f, 1.0f);
	gl_FragData[2] = vec4(LightmapCoords, 0.0f, 1.0f);
}