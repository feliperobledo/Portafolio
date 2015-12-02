#version 150

const float pi = 3.1415926;

struct LightData {
    vec3 position;
    vec4 color;
    float range;
    float attennuation;
};

// uniforms
uniform sampler2D positionBuffer;
uniform sampler2D diffuseBuffer;
uniform sampler2D normalBuffer;
uniform mat4 view;
uniform LightData light;
uniform vec3 eye;
uniform vec2 windowSize;
uniform vec3 Ks;
uniform float roughness;

// varying
in vec2 transform;

// shader outputs
out vec4 fragColor;


// HELPERS ---------------------------------------------------------------------
void halfVector(in vec3 L,in vec3 V,out vec3 h) {
    h = normalize(L + V);
}

// Fresnel term. Specularity
void F(in vec3 L,in vec3 H,out vec3 f) {
    // Note sure if the dot product in the following formular should be
    //    clamped to 0
    f = Ks + (1 - Ks) * pow((1 - max(dot(L,H),0.0)),5);
}

// The shadowing term.
void G(in vec3 L, in vec3 V, in vec3 N,in vec3 H, out float g) {
    float dotNH = max(dot(N,H),0);
    float dotNV = max(dot(N,V),0);
    float dotHV = max(dot(H,V),0);
    float dotHL = max(dot(H,L),0);
    float dotNL = max(dot(N,L),0);
    
    float k = (2 * dotNH * dotNV) / dotHV;
    float d = (2 * dotNH * dotNL) / dotHL;
    
    g = min( 1, min(k,d) );
}

//
void D(in vec3 H,in vec3 N,out float d) {
    d = (roughness + 2) / (2.0 * pi) * pow( max( dot(N,H),0 ),roughness );
}
// HELPERS - END ---------------------------------------------------------------

void main() {
    vec2 uv = vec2(gl_FragCoord.x/windowSize.x,gl_FragCoord.y/windowSize.y);
    
    vec4 pos  = texture(positionBuffer,uv),
         norm = texture(normalBuffer,uv),
         diff = texture(diffuseBuffer, uv);
    
    vec4 lightViewPos = view * vec4(light.position,1);

    vec3 N  = norm.xyz;
    vec3 Kd = diff.xyz;
    vec3 L  = light.position - pos.xyz;
    
    if (length(L) > light.range) {
        fragColor = vec4(0);
        return;
    }
    
    L  = normalize(L);
    vec3 V  = normalize(eye - pos.xyz);
    vec4 I = light.color;
    vec3 H;
    halfVector(L,V,H);
    
    vec3 f;
    float g,d;
    F(L,H,f);
    G(L,V,N,H,g);
    D(H,N,d);
    
    vec3 BRDF = (Kd / pi) +
                    ((f * g * d) /
                     (4 * max(dot(L,N),0) * max(dot(V,N),0)));
    
    fragColor = vec4(BRDF,1) * max(dot(N,L),0) * (I * pi);
}