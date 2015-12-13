#version 150
// uniforms
uniform mat4 world;
uniform mat4 light;
uniform mat4 persp;

in vec4 transform;

out vec4 depth;

void main() {
    //float t = gl_FragCoord.z / gl_FragCoord.w;
    float t = transform.w / (100.0 - 1.0);
    depth = vec4(t,t,t,1.0);//(gl_FragCoord.z);
}
