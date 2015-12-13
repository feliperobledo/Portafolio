#version 150

const float pi = 3.1415926;
const float EPSILON = 0.0001;

struct LightData {
    vec3 position;
    vec3 direction;
    vec4 color;
};

// uniforms
uniform sampler2D positionBuffer;
uniform sampler2D diffuseBuffer;
uniform sampler2D normalBuffer;
uniform sampler2D depthBuffer;
uniform mat4 lightView;
uniform mat4 persp;
uniform mat4 view;
uniform LightData light;
uniform vec3 eye;
uniform vec2 windowSize;
uniform vec3 Ks;
uniform float roughness;

// varyings
in vec2 transform;

// shader outputs
out vec4 fragColor;

// HELPERS ---------------------------------------------------------------------
void halfVector(in vec3 L,in vec3 V,out vec3 h) {
    h = normalize(L + V);
}

void F(in vec3 L,in vec3 H,out vec3 f) {
    // Note sure if the dot product in the following formular should be
    //    clamped to 0
    f = Ks + (1 - Ks) * pow( (1 - max( dot(L,H),0.0) ), 5 );
}

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

void D(in vec3 H,in vec3 N,out float d) {
    d = ((roughness + 2.0) / (2.0 * pi)) *
        pow( max( dot(N,H),0 ),roughness );
}
// HELPERS - END ---------------------------------------------------------------

void main() {
    // the [-1,1] NDC quad will have been transformed to screen space at
    // this point, which is why this works.
    vec2 uv = vec2(gl_FragCoord.x/windowSize.x,gl_FragCoord.y/windowSize.y);
    fragColor = texture(depthBuffer,uv);
    return;
    
    vec4 pos  = texture(positionBuffer,uv), // world space
         norm = texture(normalBuffer,uv),   // world space
         diff = texture(diffuseBuffer, uv);
    
    vec4 lightViewPos = view * vec4(light.position,1);

    vec3 N  = norm.xyz;
    vec3 Kd = diff.xyz;
    vec3 L  = normalize(-light.direction); // fragment -> light direction
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
    
    // checked the half-matrix output, and it looks fine
    mat4 halfMatrix = mat4(0.5, 0.0, 0.0, 0.0,
                           0.0, 0.5, 0.0, 0.0,
                           0.0, 0.0, 0.5, 0.0,
                           0.5, 0.5, 0.5, 1.0);
    
    vec4 temp = persp * lightView * pos;
    
    // HalfMatrix shifts [-1,1] to [0,1]
    vec4 shadowCoord = halfMatrix * persp * lightView * pos;
    
    // Perform Perspective-Divide
    vec2 shadowIndex = shadowCoord.xy / shadowCoord.w;
    
    // Perspective-Divide gives us a range of [0,1]
    vec4 lightSpaceCoord = texture(depthBuffer,shadowIndex.xy);
    //fragColor = vec4(lightSpaceCoord.r);
    //return;
    
    float divisor = 100.0 - 1.0;
    float currFragLightSpaceDepth = lightSpaceCoord.r;
    
    // This makes sure that that the index to the depth buffer is valid
    // This makes sure to not consider geometry behind the light
    bool mask = shadowIndex.x > 1 && shadowIndex.x < 0 ||
                shadowIndex.y > 1 && shadowIndex.y < 0 ||
                shadowCoord.w < 0;
    
    // bias helps us remove possible shadow acne
    float bias = 0.005;// * tan(acos(dot(N,L)));
    // Herron says this should use the w, but it is not working with it. z does
    //     work.
    float currFragmentDepth = ((shadowCoord.w / divisor));
    
    float visibility = 1.0;
    if (!mask && (currFragLightSpaceDepth  <  (currFragmentDepth - EPSILON))){
        visibility = 0.5;
    }
    
    //fragColor = vec4(shadowCoord.xy,0,1);
    //fragColor = vec4(currFragmentDepth);
    //fragColor = vec4(currFragLightSpaceDepth);
    fragColor.xyz *= visibility;
}
