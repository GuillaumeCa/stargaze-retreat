shader_type spatial;
render_mode cull_disabled;

uniform sampler2D leaf_albedo;
uniform sampler2D leaf_alpha;
uniform float threshold;

void fragment() {
	ALBEDO = texture(leaf_albedo, UV).rgb;
	float a = texture(leaf_alpha, UV).r;
	if (a < threshold) {
		discard;
	}
}