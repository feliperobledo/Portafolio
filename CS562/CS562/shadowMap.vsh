#version 150
// uniforms
uniform mat4 world;
uniform mat4 light;
uniform mat4 persp;

// attributes
in vec3 position;

out vec4 transform;

void main() {
    gl_Position = persp * light * world * vec4(position,1);
    transform = gl_Position;
}
