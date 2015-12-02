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
    
    worldPos = vec4(0,0,0,1);
    normal = vec4(0,0,0,1);
    diffuseCol = texture(objectTexture,uv);

    //gl_FragDepth = 0.99f;
}