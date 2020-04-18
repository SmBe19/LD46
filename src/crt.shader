shader_type canvas_item;
render_mode skip_vertex_transform;

uniform vec2 size;

void vertex() {
	vec2 uv = 2. * VERTEX / size - 1.;
	float th = atan(uv.y, uv.x);
	float r = length(uv);
	r = pow(r, 0.9);
	
	uv = r * vec2(cos(th), sin(th));
	VERTEX = size * 0.5 * (uv + 1.);
	VERTEX = (EXTRA_MATRIX * (WORLD_MATRIX * vec4(VERTEX, 0.0, 1.0))).xy;
}

void fragment() {
	//COLOR = vec4(1., 0., 0., 1.);
}