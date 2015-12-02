#version 150
// uniforms
uniform mat4 MWLP;

// attributes
in vec3 position;

out vec4 transform;

void main() {
    gl_Position = MWLP * vec4(position,1);
    transform = gl_Position;
}
