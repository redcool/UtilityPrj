Shader "Unlit/TestCloud"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NoiseTex("_NoiseTex",3d) = ""{}
        _NoiseDetail("_NoiseDetail",3d)=""{}
        _MaskNoise("_MaskNoise",2d)=""{}
        _WeatherMap("_WeatherMap",2d)=""{}
        
        _Color1("_Color1",color ) = (0.6,0.4,0.,1)
        _ColorOffset1("_ColorOffset1",range(0,1)) = 0

        _Color2("_Color2",color ) = (0.,0.4,0.7,1)
        _ColorOffset2("_ColorOffset2",range(0,1)) = 0
        _DarknessThreshold("_DarknessThreshold",range(0,1)) = 0.1
    }
    HLSLINCLUDE
    #include "Packages\com.unity.render-pipelines.universal\ShaderLibrary\Core.hlsl"
    half3 ScreenToWorldPos(half2 uv,half depth,half4x4 invVP)
    {
        #if defined(UNITY_UV_STARTS_AT_TOP)
            uv.y =1-uv.y;
        #endif
        half4 p = half4(uv*2-1,depth,1);
        p = mul(invVP,p);
        return p.xyz/p.w;
    }

                        //边界框最小值       边界框最大值         
    float2 RayBoxDist(float3 boundsMin, float3 boundsMax, 
                    //世界相机位置      光线方向倒数
                    float3 rayOrigin, float3 invRaydir) 
    {
        float3 t0 = (boundsMin - rayOrigin) * invRaydir;
        float3 t1 = (boundsMax - rayOrigin) * invRaydir;
        float3 tmin = min(t0, t1);
        float3 tmax = max(t0, t1);

        float dstA = max(max(tmin.x, tmin.y), tmin.z); //进入点
        float dstB = min(tmax.x, min(tmax.y, tmax.z)); //出去点

        float dstToBox = max(0, dstA);
        float dstInsideBox = max(0, dstB - dstToBox);
        return float2(dstToBox, dstInsideBox);
    }

float sdBox( half3 p, half3 b )
{
  half3 q = abs(p) - b;
  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);
}
    ENDHLSL

    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 worldPos:TEXCOORD1;
            };

            sampler2D _CameraDepthTexture;
            sampler2D _CameraOpaqueTexture;

            sampler3D _NoiseTex;
            sampler3D _NoiseDetail;
            sampler2D _WeatherMap;
            sampler2D _MaskNoise;

            half4 _NoiseTex_ST;

            half4 _Color1,_Color2;
            half _ColorOffset1,_ColorOffset2;
            half _DarknessThreshold;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = TransformObjectToHClip(v.vertex);
                o.uv = v.uv;
                o.worldPos = TransformObjectToWorld(v.vertex);
                return o;
            }

            const static half3 _BoundMin = half3(-5,-5,-5);
            const static half3 _BoundMax = half3(5,5,5);

            half remap(half t,half a,half b,half na,half nb){
                return lerp(na,nb,(t-a)/(b-a));
            }

            half SampleDensity(half3 pos){
                // return tex3D(_NoiseTex,pos * _NoiseTex_ST.x + _NoiseTex_ST.z);

                half3 boundCenter = (_BoundMax+_BoundMin)*.5;
                half3 size = _BoundMax-_BoundMin;
                half speedShape = _Time.y*0.01;
                half speedDetail = _Time.y*0.1;
                half3 uvwShape = pos * 0.1 + half3(speedShape,speedShape*0.2,speedShape);
                half3 uvwDetail = pos * 0.1 + half3(speedDetail,speedDetail*0.2,0);
                half2 uv = (size.xz * 0.5 + (pos.xz - boundCenter.xz))/(max(size.x,size.z));

                half4 maskNoise = tex2Dlod(_MaskNoise,half4(uv+half2(speedShape*0.5,0),0,0));
                half4 weatherMap = tex2Dlod(_WeatherMap,half4(uv+half2(speedShape*0.4,0),0,0));
                half4 shapeNoise = tex3Dlod(_NoiseTex,half4(uvwShape+(maskNoise.x * 0.1),0));

                half gMin = lerp(0.1,0.6,weatherMap.x);
                half gMax = lerp(gMin,0.9,weatherMap.x);
                half heightPercent = (pos.y - _BoundMin.y)/size.y;

                half hp = saturate(remap(heightPercent, weatherMap.r,0, 0,1));
                half hp2 = saturate(remap(heightPercent, 1, gMax, 0, 1));

                hp = (hp2  + hp) * 0.5;
                float4 _shapeNoiseWeights = float4(4,19,-3,-18);
                float4 normalizedShapeWeights = _shapeNoiseWeights / dot(_shapeNoiseWeights, 1);
                float shapeFBM = dot(shapeNoise, normalizedShapeWeights) * hp;
// return shapeFBM;
                return saturate(shapeFBM - 1 * pow(1-shapeFBM,3));// done
 
            }


            half GetDist(half3 p){
                return sdBox(p,half3(5,5,5));
                return distance(p , half3(0,0,0)) - 1;
            }

            half3 Lightmarch(half3 pos,half dist){

                const half lightAbsorption = 1;

                half3 lightDir = _MainLightPosition.xyz;
                half2 distBox = RayBoxDist(_BoundMin,_BoundMax,pos,1/lightDir).y;
                half stepSize = distBox/10;
                half sumDensity=0;
                [loop]for(int i=0;i<2;i++){
                    pos += lightDir * stepSize;
                    sumDensity += SampleDensity(pos);
                }
                
                // return lerp(_Color1,_Color2,sumDensity/8);
                half transmit= exp(-sumDensity * lightAbsorption);
                // return transmit;
                // return lerp(_Color1,_Color2,transmit);

                half3 cloudColor = lerp(_Color1,_MainLightColor,saturate(transmit * _ColorOffset1));
                cloudColor = lerp(_Color2,cloudColor,saturate(pow(transmit * _ColorOffset2,3)));
                return lerp(transmit,cloudColor,_DarknessThreshold);
            }

            half4 Raymarch(half3 rayPos,half3 rayDir,half distLimit){
                const half stepSize = 0.1;
                half dist = 0;
                half3 p=0;
                half sum = 1;
                half3 lightDensity=0;
                [loop]for(int i=0;i<32;i++){
                    p = rayPos + rayDir * dist;
                    if(GetDist(p)<0){
                        half density = pow(SampleDensity(p),5);
                        
                        if(density > 0){
                            half3 lightTransmit = Lightmarch(p,dist);
                        lightDensity += lightTransmit * sum * density * 1;

                            sum *= exp(-density * 1);

                            if(sum < 0.01)
                                break;
                        }
                    }
                    dist += stepSize;

                    if(dist > distLimit) break;
                }
                return half4(lightDensity,sum);
            }

            half4 frag (v2f i) : SV_Target
            {

                half2 screenUV = i.vertex.xy/_ScreenParams.xy;
// return half4(screenUV.xy,0,0);
                half depth = tex2D(_CameraDepthTexture,screenUV);
                half3 worldPos = ScreenToWorldPos(screenUV,depth,unity_MatrixInvVP);
                half3 worldNormal = normalize(cross(ddy(worldPos),ddx(worldPos)));
                half nl = saturate(dot(worldNormal,_MainLightPosition));
// return SampleDensity(worldPos);
                half3 rayPos = i.worldPos;
                half3 rayDir = normalize(worldPos - _WorldSpaceCameraPos);
                half maxDist = distance(worldPos,i.worldPos);

                half2 rayBoxDist = RayBoxDist(_BoundMin,_BoundMax,rayPos,1/rayDir);

                half distLimit = min(maxDist,rayBoxDist.y);
                half4 c = Raymarch(rayPos,rayDir,distLimit);
                half4 screenColor = tex2D(_CameraOpaqueTexture,screenUV);
                // c.xyz *= nl;
                c.xyz += screenColor;
                return half4(c.xyz,1);
            }
            ENDHLSL
        }
    }
}
