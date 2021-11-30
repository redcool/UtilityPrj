#if !defined(SHCORE_HLSL)
#define SHCORE_HLSL

/**
    #define Y0(v) (1.0 / 2.0) * sqrt(1.0 / PI)
    #define Y1(v) sqrt(3.0 / (4.0 * PI)) * v.z
    #define Y2(v) sqrt(3.0 / (4.0 * PI)) * v.y
    #define Y3(v) sqrt(3.0 / (4.0 * PI)) * v.x
    #define Y4(v) 1.0 / 2.0 * sqrt(15.0 / PI) * v.x * v.z
    #define Y5(v) 1.0 / 2.0 * sqrt(15.0 / PI) * v.z * v.y
    #define Y6(v) 1.0 / 4.0 * sqrt(5.0 / PI) * (-v.x * v.x - v.z * v.z + 2 * v.y * v.y)
    #define Y7(v) 1.0 / 2.0 * sqrt(15.0 / PI) * v.y * v.x
    #define Y8(v) 1.0 / 4.0 * sqrt(15.0 / PI) * (v.x * v.x - v.z * v.z)
    #define Y9(v) 1.0 / 4.0 * sqrt(35.0 / (2.0 * PI)) * (3 * v.x * v.x - v.z * v.z) * v.z
    #define Y10(v) 1.0 / 2.0 * sqrt(105.0 / PI) * v.x * v.z * v.y
    #define Y11(v) 1.0 / 4.0 * sqrt(21.0 / (2.0 * PI)) * v.z * (4 * v.y * v.y - v.x * v.x - v.z * v.z)
    #define Y12(v) 1.0 / 4.0 * sqrt(7 / PI) * v.y * (2 * v.y * v.y - 3 * v.x * v.x - 3 * v.z * v.z)
    #define Y13(v) 1.0 / 4.0 * sqrt(21.0 / (2.0 * PI)) * v.x * (4 * v.y * v.y - v.x * v.x - v.z * v.z)
    #define Y14(v) 1.0 / 4.0 * sqrt(105.0 / PI) * (v.x * v.x - v.z * v.z) * v.y
    #define Y15(v) 1.0 / 4.0 * sqrt(35.0 / (2 * PI)) * (v.x * v.x - 3 * v.z * v.z) * v.x
*/

#define PI 3.14159265358
#define Y0(v) 0.2820989518850554
#define Y1(v) 0.48860971742684406 * v.z
#define Y2(v) 0.48860971742684406 * v.y
#define Y3(v) 0.48860971742684406 * v.x
#define Y4(v) 1.0925645671244681 * v.x * v.z
#define Y5(v) 1.0925645671244681 * v.z * v.y
#define Y6(v) 0.31539621559387165 * (-v.x*v.x - v.z * v.z + 2 * v.y * v.y)
#define Y7(v) 1.0925645671244681 * v.x * v.y
#define Y8(v) 0.5462822835622341 * (v.x*v.x-v.z*v.z)
#define Y9(v) 0.5900522914234634 * (3 * v.x * v.x - v.z * v.z) * v.z
#define Y10(v) 2.890654071094968 * v.x * v.z * v.y
#define Y11(v) 0.4570525396149198 * v.z * (4 * v.y * v.y - v.x * v.x - v.z * v.z)
#define Y12(v) 0.37318184293421197 * v.y * (2 * v.y * v.y - 3 * v.x * v.x - 3 * v.z * v.z)
#define Y13(v) 0.4570525396149198 * v.x * (4 * v.y * v.y - v.x * v.x - v.z * v.z)
#define Y14(v) 1.445327035547484 * (v.x * v.x - v.z * v.z) * v.y
#define Y15(v) 0.5900522914234634 * (v.x * v.x - 3 * v.z * v.z) * v.x

StructuredBuffer<float4> _SHBuffer;

float3 GetSH16(float3 n){
    float coefs[16] = {Y0(n),Y1(n),Y2(n),Y3(n),Y4(n),Y5(n),Y6(n),Y7(n),Y8(n),Y9(n),Y10(n),Y11(n),Y12(n),Y13(n),Y14(n),Y15(n)};
    float3 c = 0;
    for(int i=0;i<16;i++){
        c += _SHBuffer[i] * coefs[i];
    }
    return c;
}
float3 GetSH9(float3 n){
    float coefs[9] = {Y0(n),Y1(n),Y2(n),Y3(n),Y4(n),Y5(n),Y6(n),Y7(n),Y8(n)};
    float3 c = 0;
    for(int i=0;i<9;i++){
        c += _SHBuffer[i] * coefs[i];
    }
    return c;  
}

#endif //SHCORE_HLSL