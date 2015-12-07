#version 150

const float pi = 3.1415926;

// uniforms
uniform mat4x4 wvp;
uniform sampler2D objectTexture;
uniform vec3 eye;
uniform mat4x4 world;

// "varyings" coming from vectex shader
//in vec2 stworldPosOut
in vec3 worldPosOut;

// outputs
out vec4 worldPos;
out vec4 normal;
out vec4 diffuseCol;

void main(void) {
    //gl_FragDepth = 0.0f;
    vec3 D = normalize(worldPosOut - eye);
    //                  forward  right               up
    vec2 uv = vec2( -atan(D.x,D.z) / (2*pi), acos(-D.y) / pi);
    
    // Here we store a -1 to identify this pixel to belong to the
    //     skydome.
    worldPos = vec4(0,0,0,-5);
    normal = vec4(0,0,0,1);
    diffuseCol = texture(objectTexture,uv);
}