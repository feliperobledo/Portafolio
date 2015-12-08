#version 150

// uniforms
uniform mat4x4 world;
uniform mat4x4 view;
uniform mat4x4 wvp;
uniform vec4 diffuse;
uniform float roughness;

//uniform mat4x4 persp;

// attributes
in vec3 position;
in vec3 normal;
in float u;
in float v;

// "varyings"
out vec3 worldPosOut;
out vec3 normalOut;
out vec4 diffuseOut;
out vec2 st;


void main() {
    gl_Position = wvp * vec4(position,1);
    worldPosOut = (world * vec4(position,1)).xyz;
    normalOut   = (world * vec4(normal,0)).xyz;
    diffuseOut = diffuse;
    st = vec2(u,v);
}