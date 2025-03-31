shader_type canvas_item;

uniform bool on = false;

void fragment() {
    if (on){
            vec4 color = texture(TEXTURE,UV);
    COLOR.rgb = vec3(1);
    }

    // mix(color,vec4(1,1,1,1),white);
}