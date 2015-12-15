#version 150

// uniforms
uniform sampler2D prevAOBuffer;
uniform sampler2D normalBuffer;
uniform float sFactor;
uniform vec2 windowSize;
uniform float sqrtPiS2;
uniform int blurrWidth;

// attributes
in vec2 position;

// "varyings"
out vec2 transform;

void main() {
    gl_Position = vec4(position,0,1);
    transform = position;
}