#version 120

varying vec2 TexCoords;
varying vec2 LightmapCoords;
varying vec3 Normal;
varying vec4 Color;
uniform int isEyeInWater;

uniform sampler2D texture;


void main(){
    vec4 Albedo = texture2D(texture, TexCoords) * Color;
    /* DRAWBUFFERS:012 */
    gl_FragData[0] = Albedo;
    gl_FragData[1] = vec4(Normal * 0.5f + 0.5f, 1.0f);
	gl_FragData[2] = vec4(LightmapCoords, 0.0f, 1.0f);

    if (isEyeInWater == 2) {
		gl_FragData[0].rgb = mix(vec3(0.5, 0.2, 0.1), /*gl_Fog.color.rgb*/vec3(Albedo), 0.1 /*- clamp(exp(-gl_Fog.density * gl_FogFragCoord), 0.0, 1.0))*/);
	}

}