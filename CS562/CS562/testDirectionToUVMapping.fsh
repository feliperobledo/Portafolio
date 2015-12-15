#version 150

// uniforms
uniform sampler2D skydomeImage;
uniform vec2 windowSize;
uniform mat4x4 wvp;

// attributes
in vec3 worldPosOut;
in vec3 normalOut;
in vec2 st;

// "varyings"
out vec4 fragColor;

vec3 BuildRandomDir(in float u,in float v, in float roughness) {
    //           forward  right               up
    // uv = vec2( 0.5 - atan(D.z,D.x) / (2*pi), acos(-D.y ) / pi);
    // skew the v
    v = acos( pow( v, 1 / (roughness + 1) ) ) / pi;
    
    float x = sin(2 * pi * (0.5 - u))*cos(pi * v),
    y = cos(2 * pi * (0.5 - u)),
    z = sin(pi * v);
    return vec3(x,y,z);
}

void main() {
    
}