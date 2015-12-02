#version 150

// uniforms
uniform mat4x4 wvp;
uniform sampler2D objectTexture;
uniform vec3 eye;
uniform mat4x4 world;

// attributes
in vec3 position;
//in float u;
//in float v;

//out vec2 st;
out vec3 worldPosOut;

void main(void) {
    gl_Position = wvp * vec4(position,1);
    //st = vec2(u,v);
    worldPosOut = (world * vec4(position,1)).xyz;
}