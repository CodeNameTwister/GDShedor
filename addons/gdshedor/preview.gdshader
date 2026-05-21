shader_type canvas_item;

// #include "res://new_shader_include.gdshaderinc"

uniform float custom_uniform = 123.0;
uniform int unused_uniform = 999; // Unused uniform, just trash.
const float CONSTANT_VALUE = 10.2;

float random_function(float my_value){
	// ...
	return my_value * 3.0;
}

float unused_function_for_test(float foo_arg){
	// ...
	return foo_arg;
}

void vertex() {
	float my_value = CONSTANT_VALUE + custom_uniform + random_function(3.0); // This is constant use
	vec2 move_vertex = vec2(my_value * TIME, -my_value * 0.5 * sin(TIME));
	VERTEX += move_vertex;
}

void fragment() {
	float random_value = 0.5;
	// More testing values.
	vec2 foo_value = vec2(CONSTANT_VALUE, 2.0) * random_value;
	//...
}

//void light() {
//	// Called for every pixel for every light affecting the material.
//	// Uncomment to replace the default light processing function with this one.
//}
