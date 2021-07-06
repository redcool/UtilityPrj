Shader "Unlit/SceneFogFading"
{
    Properties
    {
        _MainTex("_MainTex",2d) = ""{}
        _NoiseMap("_NoiseMap",2d) = ""{}
        _AttenMap("_AttenMap (R)",2d) = ""{}
        _SceneFogColor("_SceneFogColor",color) = (0.2,0.2,0.2,1)
        //_SceneFogProgressOn("_SceneFogProgressOn",float) = 1
        _SceneFogProgress("_SceneFogProgress",range(0,1)) = 0
        [Header(Atten Noise)]
        _Tiling("_Tiling",vector) = (5,5,10,10)
        _Direction("_Direction",vector) = (0,1,0,-1)

        [Header(Main Noise)]
        _MainTiling("_MainTiling",vector) = (1,1,2,2)
        _MainDirection("_MainDirection",vector) = (0,1,0,-1)
    }

    CGINCLUDE
    #include "UnityCG.cginc"

sampler2D _AttenMap;
sampler2D _MainTex,_NoiseMap;
float4 _MainTex_ST;
float4 _NoiseMap_ST;

float4 _SceneFogColor;

float _SceneFogProgressOn;
float _SceneFogProgress;

float Noise(float2 st){
    return frac(sin(dot(st,float2(12.123,78.789))) * 65432);
}

float GradientNoise(float2 uv)
{
    uv = floor(uv * _ScreenParams.xy);
    float f = dot(float2(0.06711056, 0.00583715), uv);
    return frac(52.9829189 * frac(f));
}

float4 GetVertexFogFactor(float3 screenPos,float4 attenNoiseUV){
    float3 worldUV = screenPos/float3(_ScreenParams.xy,100);
    float2 uv = worldUV.xy;
    float4 fogAttenMap = tex2Dlod(_AttenMap,float4(uv,0,0));

    float attenNoise = tex2D(_NoiseMap,attenNoiseUV.xy) + tex2D(_NoiseMap,attenNoiseUV.zw);
    float atten = lerp(-1.5,1,_SceneFogProgress);
    float fadeRate = saturate(fogAttenMap.x + attenNoise.x*0.5 + atten);

    return float4(worldUV,fadeRate);
}

//unity_FogColor
float4 CalcFogColor(float4 worldPosFog,float4 mainNoiseUV){
    float2 uv = worldPosFog.xy;
    float atten = worldPosFog.w;

    // float2 noiseUV = uv * _NoiseMap_ST.xy + _Time.y * _NoiseMap_ST.zw;
    float4 noise = tex2D(_NoiseMap,mainNoiseUV.xy) + tex2D(_NoiseMap,mainNoiseUV.zw);
    // return noise.x;

    float4 mainTex = tex2D(_MainTex,uv + noise.x * 0.2 );
    return mainTex * _SceneFogColor;
}

    ENDCG
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Transparent"}
        LOD 100
        blend srcAlpha oneMinusSrcAlpha

        Pass
        {
            ztest always
            // zwrite off
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 noiseUV:TEXCOORD1;
                float4 mainNoiseUV:TEXCOORD2;
            };

            float4 _Tiling,_Direction;
            float4 _MainTiling,_MainDirection;

            v2f vert (appdata v)
            {
                v2f o;
                // o.vertex = UnityObjectToClipPos(v.vertex);
                v.vertex.xy *= 2;
                o.vertex = v.vertex;
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.noiseUV = o.uv.xyxy * _Tiling + _Direction * _Time.x;
                o.mainNoiseUV = o.uv.xyxy * _MainTiling + _MainDirection * _Time.x;
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 worldUVFog = GetVertexFogFactor(i.vertex,i.noiseUV);
                float3 worldUV = worldUVFog.xyz;
                
                float atten = worldUVFog.w;
                // return atten;
                float4 color = CalcFogColor(worldUVFog,i.mainNoiseUV);
                color.a = smoothstep(0.4,0.6,atten) * _SceneFogColor.a;
                return color;
            }
            ENDCG
        }
    }
}
