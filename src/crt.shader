shader_type canvas_item;
render_mode skip_vertex_transform;

uniform vec2 origin;
uniform vec2 size;
uniform float distortion = 0.02;
uniform vec4 color : hint_color = vec4(0., 0.6, 0., 1.0);

uniform vec4 border_color : hint_color = vec4(0.5, 0.4, 0.3, 1.0) ;

uniform float lines_velocity = 30.;
uniform float lines_distance = 4.0;

varying vec2 xy;
varying mat4 world_matrix;

void vertex() {
	world_matrix = WORLD_MATRIX;
	xy = VERTEX;
	VERTEX = (WORLD_MATRIX * vec4(VERTEX, 0., 1.)).xy;
}

float random (float x) {
    return fract(sin(x) * 43758.5453123);
}

void fragment() {
	//COLOR = vec4(xy-origin, 0., 1.);
	
	vec2 uv = (xy - origin) / size;
	
	//COLOR = vec4(uv, 0., 1.);
	uv = 2.*uv - 1.;
	
	//vec2 uv = 2.*UV - 1.;
	float r = length(uv);
	uv = uv + distortion*r*r*uv;//pow(r, distortion-1.);
	//uv = 0.5*(uv+1.);
	vec2 local = 0.5*(uv+1.)*size;//+origin;
	vec2 world = (world_matrix * vec4(local, 0., 1.)).xy;
	//COLOR=vec4(local, 0., 1.);
	
	
	
	vec2 screen = world * SCREEN_PIXEL_SIZE;
	screen.y = 1.-screen.y;
	vec3 c = texture(SCREEN_TEXTURE, screen).rgb;
	//COLOR = vec4(c, 1.0);
	c += 0.1 * color.rgb * (1.-0.7*r);
	vec3 lc = texture(SCREEN_TEXTURE, screen-vec2(1.38, 0.)*SCREEN_PIXEL_SIZE).rgb;
	//vec3 rc = texture(SCREEN_TEXTURE, screen+vec2(1.38, 0.)*SCREEN_PIXEL_SIZE).rgb;
	
	vec3 final_color = 0.6*c+0.4*lc;
	
	float line = abs(mod(local.y, 2.)-1.);
	final_color *= 1.-0.4*(1.-line);
	
	// scanline
	final_color += 0.1 * fract(smoothstep(-1.2, -1.0, uv.y-2.2*fract(TIME*0.1))) * color.rgb;
	
	// static
	final_color += 0.2 * random(dot(vec3(uv, TIME), vec3(12.9898,78.233, 1.))) * (1.-0.7*r) * color.rgb;
	
	// flicker
	final_color *= 1.+(random(TIME)-0.5)*0.1;
	
	// clip border
	float border = max((abs(uv).x-1.)*size.x, (abs(uv).y-1.)*size.y);
	final_color *= step(10., -border);
	final_color += max(0., min(1., 0.02*border)) * border_color.rgb;
	COLOR = vec4(final_color, 1.0);
}