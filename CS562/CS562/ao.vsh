#version 150

/*
 Description: Send quad coordinates to fragment shader
 */

// uniforms
uniform sampler2D positionBuffer;
uniform sampler2D normalBuffer;
uniform sampler2D diffuseBuffer;
uniform vec3 eye;
uniform vec2 windowSize;
uniform float R; //range of influence

// attributes
in vec2 position;

// "varyings"
out vec2 transform;

void main() {
    gl_Position = vec4(position,0,1);
    transform = position;
}