shader_type canvas_item;

uniform sampler2D screen_texture : hint_screen_texture, repeat_disable, filter_nearest_mipmap;

/* =======================
   Scanline / Chroma Wiggle
   ======================= */
group_uniforms scanline_wiggle;
uniform float color_offset_multiplier : hint_range(0.0, 0.1) = 0.004;
uniform float black_offset_multiplier : hint_range(0.0, 0.1) = 0.1;
uniform float color_offset : hint_range(-0.1, 0.1) = 0.005;

/* =====
   Blur
   ===== */
group_uniforms blur;
uniform float blur_amount : hint_range(0.0, 3.0, 0.1);

/* =====
   Bloom
   ===== */
group_uniforms bloom;
uniform float bloom_spread = 1.0;
uniform float bloom_intensity = 2.0;


/* =======================
   Utility Functions
   ======================= */
float noise(vec2 uv, float offset) {
	return (fract(sin(dot(uv * offset, vec2(12.9898, 78.233))) * 43758.5453) - 0.5) * 2.0;
}

vec3 rgb_to_yuv(vec3 rgb) {
	const mat3 RGB_TO_YUV = mat3(
		vec3(0.299, 0.587, 0.114),
		vec3(-0.14713, -0.28886, 0.436),
		vec3(0.615, -0.51499, -0.10001)
	);
	return rgb * RGB_TO_YUV;
}

vec3 yuv_to_rgb(vec3 yuv) {
	const mat3 YUV_TO_RGB = mat3(
		vec3(1.0, 0.0, 1.13983),
		vec3(1.0, -0.39465, -0.58060),
		vec3(1.0, 2.03211, 0.0)
	);
	return clamp(yuv * YUV_TO_RGB, vec3(0.0), vec3(1.0));
}


/* =======================
   Fragment
   ======================= */
void fragment() {

	/* ---- Base offsets ---- */
	float x_offset = color_offset +
		noise(vec2(floor(UV.y * 487.0), fract(UV.y * 487.0)), TIME)
		* color_offset_multiplier;

	float black_offset =
		noise(vec2(floor(UV.y * 487.0), fract(UV.y * 487.0)), TIME + 69.420)
		* (black_offset_multiplier * 0.01);

	/* ---- Base color ---- */
	vec4 base_color =
		textureLod(screen_texture, SCREEN_UV + vec2(black_offset, 0.0), 0.0);

	vec4 shifted_color =
		textureLod(screen_texture, SCREEN_UV + vec2(x_offset, 0.0), blur_amount);

	/* ---- YUV chroma separation ---- */
	vec3 yuv1 = rgb_to_yuv(base_color.rgb);
	vec3 yuv2 = rgb_to_yuv(shifted_color.rgb);

	vec3 final_rgb = yuv_to_rgb(vec3(yuv1.x, yuv2.yz));


	/* =======================
	   Bloom pass
	   ======================= */
	ivec2 size = textureSize(screen_texture, 0);
	float px = SCREEN_UV.x * float(size.x);
	float py = SCREEN_UV.y * float(size.y);

	vec4 bloom_sum = vec4(0.0);

	for (int y = 0; y < 9; y++) {
		float oy = float(y - 4) * bloom_spread;
		vec4 row_sum = vec4(0.0);

		for (int x = -4; x <= 4; x++) {
			row_sum += texelFetch(
				screen_texture,
				ivec2(int(px) + int(float(x) * bloom_spread), int(py + oy)),
				0
			);
		}

		bloom_sum += row_sum / 9.0;
	}

	vec3 bloom = (bloom_sum.rgb / 9.0) * bloom_intensity;

	/* ---- Final color ---- */
	COLOR.rgb = final_rgb + bloom;
	COLOR.a = base_color.a;
}
