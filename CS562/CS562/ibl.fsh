#version 150

const float pi = 3.1415926;

// uniforms
uniform sampler2D positionBuffer;
uniform sampler2D diffuseBuffer;
uniform sampler2D normalBuffer;
uniform sampler2D environmentBuffer;
uniform sampler2D irradianceBuffer;
uniform vec3 eye;
uniform vec3 Ks;
uniform vec2 windowSize;
uniform float exposure;
uniform float contrast;

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

void halfVector(in vec3 L,in vec3 V,out vec3 h) {
    h = normalize(L + V);
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

void F(in vec3 L,in vec3 H,out vec3 f) {
    // Note sure if the dot product in the following formular should be
    //    clamped to 0
    f = Ks + (1 - Ks) * pow( (1 - max( dot(L,H),0) ), 5 );
}

void G(in vec3 L, in vec3 V, in vec3 N,in vec3 H, out float g) {
    float dotNH = max(dot(N,H),0);
    float dotNV = max(dot(N,V),0);
    float dotHV = max(dot(H,V),0);
    float dotHL = max(dot(H,L),0);
    float dotNL = max(dot(N,L),0);
    
    float k = (2.0 * dotNH * dotNV) / dotHV;
    float d = (2.0 * dotNH * dotNL) / dotHL;
    
    g = min( 1.0, min(k,d) );
}

float D(in vec3 H,in vec3 N,in float roughness) {
    float a = (roughness + 2.0),
          b = pow( max( dot(N,H),0 ),roughness ),
          c = (2.0 * pi);
    return a / c * b;
}

float CalcLODFromImage(in sampler2D text,in int N,in float DofH) {
    // Get the dimensions of the highest level texture
    ivec2 dim = textureSize(text,0);
    
    float x = log( float(dim.x * dim.y) / float(N) ) / log(2.0),
          y = log(DofH) / log(2.0);
    
    // Calculate the log2 of everything I need manually
    float a  = (log2( float(dim.x * dim.y) / float(N) )) * 0.5,
          b  = (log2(DofH)) * 0.5;
    
    //a = x * 0.5;
    //b = y * 0.5;
    
    return (a - b) - 4;
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
// HELPERS - END ---------------------------------------------------------------

void main(void) {
    vec2 uv = vec2(gl_FragCoord.x/windowSize.x,gl_FragCoord.y/windowSize.y);
    vec4 pos  = texture(positionBuffer,uv), // world space
         norm = texture(normalBuffer,uv),   // world space
         diff = texture(diffuseBuffer, uv);
    
    // If we are calculating the ambient for the skydome, just display the
    //     skydome.
    if(pos.w == -5) {
        fragColor = diff;
        return;
    }
    
    
    // Calculate the diffuse color by:
    // diffuse = (Kd / pi) * irradiance(N)
    vec3 N  = norm.xyz;
    vec3 Kd = diff.xyz;
    
    vec3 Irradiance = vec3(0);
    IrradianceFromDir(N,Irradiance);
    vec3 diffuse = (Kd / pi) * Irradiance;
    /*
        Calculate the specular term by using the monte carlo approximation
        of the integral.
     
        float g;
        vec3 f;
        vec4 specular;
     
        for every dir in randomNormals
            wSubK = dir;
            vec3 lSubi;
            LightFromDir(wSubK,lSubi)
            G(wSubK, V, N, H, g);
            F(wSubK, H, f);
     
            specular += (g * f / 4 * dot(wSubK,N) * dot(V,N)) * lSubi * dot(wSubK,V)
     
        specular *= (1/40)
    */
    vec3 H = vec3(0),
         f = vec3(0),
         specular = vec3(0),
         V = normalize(eye - pos.xyz),
         dir = N,
         lSubi = vec3(0); //Light value of the incoming light
    
    float g = 0,
          d = 0,
          roughness = diff.w, //here is where the rough factor lies
          VDotN = max(dot(V,N),0);
    
    // Direction of the incoming light
    vec3 wSubK = dir;
    
    // Compute half-vector based on direction of incoming light
    halfVector(wSubK,V,H);
    
    // --- Take the light influence ---
    
    // Calculate UV based on direction
    // Calculate LOD based on D term
    // Get light influence based on level computer
    d = D(H,N,roughness);
    UVFromSkydome(wSubK,uv);
    float level = CalcLODFromImage(environmentBuffer,1,d);
    
    //DebugLevel(int(level));
    //return;
    
    lSubi     = textureLod(environmentBuffer, uv, level).xyz;
    //LinearTosRGB(lSubi, lSubi);
    //fragColor = vec4(lSubi,1);
    //return;
    
    F(wSubK,H,f);
    
    G(wSubK,V,N,H,g);
    
    float wSubKDotN = max(dot(wSubK,N),0),
          wSubKDotV = max(dot(wSubK,V),0);
    
    specular += ( (g * f  * lSubi * wSubKDotV ) / ( 4 * wSubKDotN * VDotN ) );

    // Calculate final light value by adding the diffuse and specular
    // final = specular + diffuse;
    fragColor = vec4(specular + diffuse,1);
    
    
    // Since we are going to display the result of the ibl to the screen, we
    //     convert color spaces now.
    LinearTosRGB(fragColor.xyz,fragColor.xyz);
}