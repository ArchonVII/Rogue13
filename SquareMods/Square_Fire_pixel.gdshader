shader_type canvas_item;

uniform int pixelSize = 4;
uniform vec4 flame_color : source_color = vec4(1.0);
uniform float yoffset = 0.5;
uniform float animation_speed = 0.5;
uniform sampler2D noise_texture: hint_default_black, repeat_enable;
uniform vec4 second_color = vec4(0.1, 0.5, 0.3, 1.0);
uniform vec4 first_color = vec4(1.0);

void fragment() {
	vec2 uv = vec2(UV.x, UV.y + TIME);
	vec4 noise_color = texture(noise_texture, uv);
	vec4 final_color = noise_color;
	final_color.rgb += vec3(UV.y - yoffset);
	final_color.rgb = step(final_color.rgb, vec3(0.5));
	final_color.rgb = vec3(1.0) - final_color.rgb;
	final_color.a = final_color.r;
	//final_color += vec4(0.5, 0.1, 0.1, 1)
	final_color.rgb = flame_color.rgb;
	
	
	ivec2 size = textureSize(TEXTURE, 0);
	int xRes = size.x;
	int yRes = size.y;
	float xFactor = float(xRes) / float(pixelSize);
	float yFactor = float(yRes) / float(pixelSize);
	float grid_uv_x = round(UV.x * xFactor) / xFactor;
	float grid_uv_y = round(UV.y * yFactor) / yFactor;
	vec4 text = texture(TEXTURE, vec2(grid_uv_x, grid_uv_y));
	
	//COLOR = final_color;
	
	
	COLOR = mix(first_color, second_color,1.0);
	
}


