#version 150

// uniforms
uniform mat4x4 world;
uniform mat4x4 view;
uniform mat4x4 wvp;
uniform vec4 diffuse;
uniform float roughness;

// "varyings" coming from vectex shader
in vec3 worldPosOut;
in vec3 normalOut;
in vec4 diffuseOut;
in vec2 st;

// outputs
out vec4 worldPos;
out vec4 normal;
out vec4 diffuseCol;
//out vec3 TexCoordOut;

void main() {
    float d = (view * vec4(worldPosOut,1)).z;
    
    worldPos = vec4(worldPosOut,d);
    normal   = vec4(normalize(normalOut),0);
    diffuseCol = vec4(diffuseOut.xyz,roughness);
}