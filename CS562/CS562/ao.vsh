#version 150

// uniforms
uniform sampler2D positionBuffer;
uniform sampler2D normalBuffer;
uniform vec2 windowSize;
uniform float R;
uniform float s;
uniform float k;
uniform int randPoints;

// attributes
in vec2 position;

// "varyings"
out vec2 transform;

void main() {
    gl_Position = vec4(position,0,1);
    transform = position;
}