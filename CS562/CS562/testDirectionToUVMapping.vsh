#version 150

// uniforms
uniform sampler2D skydomeImage;
uniform vec2 windowSize;
uniform mat4x4 wvp;

// attributes
in vec3 position;
in float u;
in float v;
in vec3 normal;

// "varyings"
out vec3 worldPosOut;
out vec3 normalOut;
out vec2 st;

void main(void) {
    gl_Position = wvp * vec4(position,1);
    worldPosOut = (world * vec4(position,1)).xyz;
    normalOut   = (world * vec4(normal,0)).xyz;
    st = vec2(u,v);
}