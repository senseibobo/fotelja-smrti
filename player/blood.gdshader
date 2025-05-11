shader_type canvas_item;


uniform sampler2D bloodTexture;
uniform sampler2D SCREEN_TEXTURE: hint_screen_texture;
uniform float strength: hint_range(0.0, 1.0, 0.0) = 0.5;

void vertex() {
	// Called for every vertex the material is visible on.
}

void fragment() {
	COLOR = texture(SCREEN_TEXTURE,SCREEN_UV);
	float dist = (1.0-distance(SCREEN_UV, vec2(0.5,0.5)));
	vec4 sample = texture(bloodTexture, SCREEN_UV);
	float d = pow(sample.a, 2.0);
	d -= dist;
	d *= strength;
	d *= mod(-TIME*2.5, 2.0);
	d = clamp(d, 0.0, 1.0);
	COLOR.rgb = mix(COLOR.rgb, sample.rgb, d*0.6);
	COLOR.rgb = mix(COLOR.rgb, vec3(0.4,0.0,0.0), clamp(1.5-dist*2.0, 0.0, 1.0)*strength);
}

//void light() {
//	// Called for every pixel for every light affecting the CanvasItem.
//	// Uncomment to replace the default light processing function with this one.
//}
