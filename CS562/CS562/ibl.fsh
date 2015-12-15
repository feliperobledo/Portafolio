#version 150

const float pi = 3.1415926;
const float pi2 = pi * pi;

// uniforms
uniform sampler2D positionBuffer;
uniform sampler2D diffuseBuffer;
uniform sampler2D normalBuffer;
uniform sampler2D environmentBuffer;
uniform sampler2D irradianceBuffer;
uniform sampler2D aoBuffer;
uniform int levelOffset;
uniform vec3 eye;
uniform vec3 Ks;
uniform vec2 windowSize;
uniform float exposure;
uniform float contrast;
uniform int sampleSize;
uniform HammersleyBlock { float HN; float hammersley[2*40]; };

// input "varyings"
in vec2 transform;

// output
out vec4 fragColor;

// HELPERS ---------------------------------------------------------------------
void LinearTosRGB(in vec3 C, out vec3 Cout) {
    vec3 eC = exposure * C;
    vec3 power = vec3(contrast / 2.2);
    Cout = pow(  eC / (eC + vec3(1,1,1) ), power);
}

void sRGBToLinear(in vec3 C, out vec3 Cout) {
    // I don't know if this is correct
    vec3 eC = exposure * C;
    vec3 power = vec3(2.2 / contrast);
    Cout = pow( C, power );
    Cout /= exposure;
    Cout *= (eC + vec3(1,1,1));
}

void UVFromSkydome(in vec3 D, out vec2 uv) {
    //           forward  right               up
    uv = vec2( 0.5 - atan(D.z,D.x) / (2*pi), acos(-D.y ) / pi);
}

vec3 halfVector(in vec3 L,in vec3 V) {
    return normalize(L + V);
}

void IrradianceFromDir(in vec3 N,out vec3 intensity) {
    vec2 uv;
    UVFromSkydome(normalize(N),uv);
    intensity = texture(irradianceBuffer,uv).xyz;
}

void LightFromDir(in vec3 N,out vec3 color) {
    vec2 uv; UVFromSkydome(N,uv);
    color = texture(environmentBuffer,uv).xyz;
}

vec3 F(in vec3 L,in vec3 H) {
    // Note sure if the dot product in the following formular should be
    //    clamped to 0
    return Ks + (1 - Ks) * pow( (1 - max( dot(L,H),0) ), 5 );
}

float G(in vec3 L, in vec3 V, in vec3 N,in vec3 H) {
    float dotNH = max(dot(N,H),0);
    float dotNV = max(dot(N,V),0);
    float dotHV = max(dot(H,V),0);
    float dotHL = max(dot(H,L),0);
    float dotNL = max(dot(N,L),0);
    
    float k = (2.0 * dotNH * dotNV) / dotHV;
    float d = (2.0 * dotNH * dotNL) / dotHL;
    
    //return min( 1.0, min(k,d) );
    return 1 / pow( max(0.0001, dotHL), 2);
}

float D(in vec3 H,in vec3 N,in float roughness) {
    float a = (roughness + 2.0),
          b = pow( max( dot(N,H),0.01 ),roughness ),
          c = (2.0 * pi);
    return a / c * b;
}

float CalcLODFromImage(in sampler2D text,in uint N,in float DofH) {
    // Get the dimensions of the highest level texture
    ivec2 dim = textureSize(text,0);
    
    float x = log( float(dim.x * dim.y) / float(N) ) / log(2.0),
          y = log(DofH) / log(2.0);
    
    // Calculate the log2 of everything I need manually
    float a  = (log2( float(dim.x * dim.y) / float(N) )) * 0.5,
          b  = (log2(DofH)) * 0.5;
    
    //a = x * 0.5;
    //b = y * 0.5;
    
    return (a - b) - levelOffset;
}

void DebugLevel(in int level) {
    switch (level) {
        case 0:
            fragColor = vec4(1,0,0,1); //red
            break;
        case 1:
            fragColor = vec4(0,1,0,1); //green
            break;
        case 2:
            fragColor = vec4(0,0,1,1); //blue
            break;
        case 3:
            fragColor = vec4(1,1,0,1); //yellow
            break;
        case 4:
            fragColor = vec4(1,0,1,1); //magenta
            break;
        case 5:
            fragColor = vec4(0,1,1,1); //teal
            break;
        case 6:
            fragColor = vec4(0.8,0.4,0.2,1); //orange
            break;
        case 7:
            fragColor = vec4(0.8,0.4,0,1);
            break;
        case 8:
            fragColor = vec4(0,0.8,0.4,1);
            break;
        case 9:
            fragColor = vec4(0.4,0,0.8,1);
            break;
            
        default:
            fragColor = vec4(0,0,0,1);
            break;
    }
}

// Random rotation based on the current fragment's coordinates
float randAngle()
{
    uint x = uint(gl_FragCoord.x);
    uint y = uint(gl_FragCoord.y);
    return float(30u * x ^ y + 10u * x * y);
}

vec2 skew(in vec2 E,in float roughness) {
    //float a = roughness * roughness;
    //E.x = atan(sqrt((a * E.x) / (1.0 - E.x)));
    //E.y = pi2 * E.y + randAngle();
    
    float a = 1 / (roughness + 1);
    float b = pow(E.y, a);
    E.x = E.x;
    E.y = acos( b ) / pi;
    return E;
}

vec3 BuildRandomDir(in vec2 E, in float roughness) {
    //float x = cos(2 * pi * (0.5 - u))*sin(pi * v),
    //      y = sin(2 * pi * (0.5 - u))*sin(pi * v),
    //      z = sin(pi * v);
    //return vec3(x,y,z);
    
    float SineTheta = sin(E.x);
    
    float x = cos(E.y) * SineTheta;
    float y = sin(E.y) * SineTheta;
    float z = cos(E.x);
    
    return vec3(x, y, z);
}

vec3 ReflectionVector(in vec3 N,in vec3 V){
    return 2 * max(dot(N,V),0) * N - V;
}

int bitFieldReverse(int x)
{
    int res = 0;
    int i, shift, mask;
    
    for(i = 0; i < 32; i++) {
        mask = 1 << i;
        shift = 32 - 2*i - 1;
        mask &= x;
        mask = (shift > 0) ? mask << shift : mask >> -shift;
        res |= mask;
    }
    
    return res;
}

// Hammersley function (return random low-discrepency points)
vec2 randHammersley(uint i, uint N)
{
    return vec2(
                float(i) / float(N),
                float(bitFieldReverse(int(i))) * 2.3283064365386963e-10
                );
}

float radicalInverse_VdC(uint bits) {
    bits = (bits << 16u) | (bits >> 16u);
    bits = ((bits & 0x55555555u) << 1u) | ((bits & 0xAAAAAAAAu) >> 1u);
    bits = ((bits & 0x33333333u) << 2u) | ((bits & 0xCCCCCCCCu) >> 2u);
    bits = ((bits & 0x0F0F0F0Fu) << 4u) | ((bits & 0xF0F0F0F0u) >> 4u);
    bits = ((bits & 0x00FF00FFu) << 8u) | ((bits & 0xFF00FF00u) >> 8u);
    return float(bits) * 2.3283064365386963e-10; // / 0x100000000
}

vec2 hammersley2d(uint i, uint N) {
    return vec2(float(i)/float(N), radicalInverse_VdC(i));
}
// HELPERS - END ---------------------------------------------------------------

void main(void) {
    vec2 uv = vec2(gl_FragCoord.x/windowSize.x,gl_FragCoord.y/windowSize.y);
    vec4 pos  = texture(positionBuffer,uv), // world space
    norm = texture(normalBuffer,uv),   // world space
    ao   = texture(aoBuffer,uv),
    diff = texture(diffuseBuffer, uv);
    
    // If we are calculating the ambient for the skydome, just display the
    //     skydome.
    if(pos.w == -5) {
        LinearTosRGB(diff.xyz,fragColor.xyz);
        fragColor.w = 1;
        return;
    }
    
    // Calculate the diffuse color by:
    // diffuse = (Kd / pi) * irradiance(N)
    vec3 N  = norm.xyz;
    vec3 Kd = diff.xyz;
    
    vec3 Irradiance = vec3(0);
    IrradianceFromDir(N,Irradiance);
    vec3 diffuse = (Kd / pi) * Irradiance;
    
    vec3 V = normalize(eye - pos.xyz);
    float roughness = diff.w, //here is where the rough factor lies
          VDotN     = max(dot(V,N),0.01);
    
    //DebugLevel(int(level));
    //return;
    
    vec3 R = normalize(ReflectionVector(N,V)),
         Z = vec3(0,0,1);
    
    vec3 A = normalize(cross(Z,R));
    vec3 B = normalize(cross(R,A));
    
    vec3 specular = vec3(0);
    uint samples = uint(sampleSize);//uint(20);
    for(uint i = uint(0); i < samples; ++i) {
        vec2 E = skew( randHammersley(i,samples), roughness );
        //vec3 L = BuildRandomDir(tHammersley.x,tHammersley.y,roughness);
        //vec2 E = vec2(hammersley[i],hammersley[i+1]);
        vec3 L = BuildRandomDir(E,roughness);
        vec3 wSubK = normalize( L.x * A + L.y * B + L.z * R);
        
        // Compute half-vector based on direction of incoming light
        vec3 H = halfVector(wSubK,V);
        float d = D(H,N,roughness);
        float level = CalcLODFromImage(environmentBuffer,samples,d);
        
        // Get light influence based on mip-map level computed
        // Color is in Linear Space by default
        UVFromSkydome(wSubK,uv);
        vec3 lSubi = textureLod(environmentBuffer, uv, level).xyz;
        
        vec3 f = F(wSubK,H);
        float g = G(wSubK,V,N,H);
        
        // Since the normal was facing just away from the light, this calculation
        // results in a 0, which makes the denominator a zero. In that case
        // the resulting color will be 0;
        float wSubKDotN = max(dot(wSubK,N),0.01);
        
        float wSubKDotV = max(dot(wSubK,V),0.0);
        
        specular += (g * f  * lSubi * wSubKDotV ) / ( 4 * wSubKDotN * VDotN );
    }
    specular /= samples;
    
    // Calculate final light value by adding the diffuse and specular
    // final = specular + diffuse;
    fragColor = vec4(specular + /*ao.r */ diffuse,1);
    
    // Since we are going to display the result of the ibl to the screen, we
    //     convert color spaces now.
    LinearTosRGB(fragColor.xyz,fragColor.xyz);
}