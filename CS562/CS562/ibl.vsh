#version 150

/*
 Description: Send quad coordinates to fragment shader
 */

// uniforms
uniform sampler2D positionBuffer;
uniform sampler2D diffuseBuffer;
uniform sampler2D normalBuffer;
uniform sampler2D environmentBuffer;
uniform sampler2D irradianceBuffer;
uniform sampler2D aoBuffer;
uniform int levelOffset;
uniform vec3 eye;
uniform vec3 Ks;
uniform vec2 windowSize;
uniform float exposure;
uniform float contrast;
uniform int sampleSize;
uniform HammersleyBlock { float N; float hammersley[2*100]; };

// attributes
in vec2 position;

// "varyings"
out vec2 transform;

void main() {
    gl_Position = vec4(position,0,1);
    transform = position;
}