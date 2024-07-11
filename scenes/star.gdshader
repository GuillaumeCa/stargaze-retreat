shader_type spatial;
render_mode shadows_disabled, blend_add;

uniform sampler2D tex;


void fragment() {
	SPECULAR = 0.0;
	vec3 v = texture(tex, UV).rrr;
	ALBEDO = v;
	//EMISSION = v;
}
