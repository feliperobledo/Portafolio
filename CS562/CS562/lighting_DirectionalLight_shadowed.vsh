#version 150

struct LightData {
    vec3 position;
    vec3 direction;
    vec4 color;
};

// uniforms
uniform sampler2D positionBuffer;
uniform sampler2D diffuseBuffer;
uniform sampler2D normalBuffer;
uniform sampler2D depthBuffer;
uniform mat4 LP;
uniform mat4 view;
uniform LightData light;
uniform vec3 eye;
uniform vec2 windowSize;
uniform vec3 Ks;
uniform float roughness;

// attributes
in vec2 position;

// "varyings"
out vec2 transform;

void main() {
    gl_Position = vec4(position,0,1);
    transform = position;
}
