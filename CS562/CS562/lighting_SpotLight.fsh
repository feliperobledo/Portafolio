#version 150

struct LightData {
    vec3 position;
    float color;
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

in vec2 trasform;

out vec4 fragColor;

void main() {
    // get the position given frag coordinate
    vec2 uv = vec2(gl_FragCoord.x/windowSize.x,gl_FragCoord.y/windowSize.y);
    
    vec4 viewPos       = texture(positionBuffer,uv),
    viewPosNormal = texture(normalBuffer,uv),
    diffuseCol    = texture(diffuseBuffer, uv);
    
    vec4 worldPos = viewInverse * viewPos;
    
    vec4 temp = view * worldPos;
    vec4 temp2 = perspective * worldPos;
    
    
    //fragColor = viewPos;
    
    //viewPosNormal.a = 1;
    fragColor = viewPosNormal;
    
    //fragColor = diffuseCol;
    
    // Debugging normal texture
    //fragColor = vec4(uv,0,1);
    //fragColor = vec4(1,0,0,1);
    //fragColor = vec4(1,0,0,1);
}