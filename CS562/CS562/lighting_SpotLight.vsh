#version 150

struct LightData {
    vec3 position;
    float color; // every byte is a component
    float range;
    float attennuation;
};

// uniforms
uniform sampler2D positionBuffer;
uniform sampler2D normalBuffer;
uniform sampler2D diffuseBuffer;
uniform vec2 windowSize;
uniform mat4 view;
uniform mat4 viewInverse;
uniform mat4 perspective;

//uniform vec3 eye;
//uniform float ambient;
//uniform LightData light;


// attributes
in vec2 position;

// "varyings"
out vec2 transform;

void main() {
    gl_Position = vec4(position,0,1);
    transform = position;
}

