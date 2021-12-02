#version 120

varying vec2 TexCoords;
varying vec4 Color;

uniform sampler2D colortex0;

vec3 Uncharted2Tonemap(vec3 x) {
	float A = 0.28;
	float B = 0.29;		
	float C = 0.08;	//default 0.010
	float D = 0.2;
	float E = 0.025;
	float F = 0.35;
	return ((x*(A*x+C*B)+D*E)/(x*(A*x+B)+D*F))-E/F;
}

void main() {
	vec4 tex = texture2D(colortex0, TexCoords.xy) * Color;
	tex.rgb = Uncharted2Tonemap(tex.rgb) * 2.2;
	gl_FragData[0] = tex;
}

