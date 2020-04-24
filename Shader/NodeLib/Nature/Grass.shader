// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/Nature/Grass"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",color) = (1,1,1,1)
        _ColorScale("ColorScale",range(0,3)) = 1
        _Cutoff ("Alpha cutoff", Range(0,1)) = 0.5

        _WaveSpeed("WaveSpeed",float) = 1
        _WaveIntensity("WaveIntensity",float) = 1

        _PushRadius("Radius",float) = 0.5
        _PushIntensity("_PushIntensity",float) = 1
        //_PlayerPos("playerPos",vector) = (0,0,0,0)
    }

    CGINCLUDE
    #include "NodeLib.cginc"
    struct appdata
    {
        float4 pos : POSITION;
        float2 uv : TEXCOORD0;
        float2 uv1:TEXCOORD1;
        float4 color:COLOR;
        float3 normal:NORMAL;
    };
    float _WaveIntensity;
    float _WaveSpeed;

    float3 _PlayerPos;
    float _PushRadius;
    float _PushIntensity;

    float3 CalcForce(float3 pos,float2 uv,float3 color){
        //---interactive
        float3 dir = pos - _PlayerPos;
        dir.y *= 0.1;

        float dist = length(dir);
        float atten = uv.y * max(0,_PushRadius - dist) * color * _PushIntensity;
        return normalize(dir) * atten;
    }

    float4 WaveVertex(appdata v,float waveSpeed,float waveIntensity){
        float4 pos = mul(unity_ObjectToWorld,v.pos);

        float2 timeOffset = _Time.y * waveSpeed;
        float2 uv = pos.xz + timeOffset;

        float noise = 0;
        Unity_GradientNoise_float(uv,1,noise);
        noise -= 0.5;
        noise = noise * v.uv.y * 0.2 * waveIntensity;

        pos.x += noise;
        pos.xyz += CalcForce(pos.xyz,v.uv,v.color);
        return mul(unity_WorldToObject,pos);
    }
    ENDCG

    SubShader
    {
        Tags {"Queue"="AlphaTest" "IgnoreProjector"="True" "RenderType"="TransparentCutout" "LightMode"="ForwardBase"}
        LOD 100
        cull off

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            //#pragma multi_compile _ LIGHTMAP_ON
            #pragma multi_compile_fwdbase 

            #include "UnityCG.cginc"

            #include "AutoLight.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 pos : SV_POSITION;
                float4 lmap:TEXCOORD2;
                // UNITY_SHADOW_COORDS(3)
                SHADOW_COORDS(3)
                float diff:TEXCOORD5;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _Cutoff;
            float4 _Color;
            float _ColorScale;

            v2f vert (appdata v)
            {
                v2f o = (v2f)0;
                o.pos = UnityObjectToClipPos( WaveVertex(v,_WaveSpeed,_WaveIntensity) );
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                #if defined(LIGHTMAP_ON)
                    o.lmap.xy = v.uv1.xy * unity_LightmapST.xy + unity_LightmapST.zw;
                #endif
                //UNITY_TRANSFER_LIGHTING(o,v.uv.xy);
                TRANSFER_SHADOW(o)
                UNITY_TRANSFER_FOG(o,o.pos);
                //float3 normal = UnityObjectToWorldNormal(v.normal);
                float3 lightDir = length(_WorldSpaceLightPos0.xyz) > 0 ? _WorldSpaceLightPos0.xyz : float3(0.1,.35,0.02);
                float3 normal = UnityObjectToWorldNormal(v.pos.xyz);
                float nl = dot(normal,lightDir) ;
                o.diff = smoothstep(0.3,.32,nl);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // return i.diff;
                //return smoothstep(0.2,.4,i.diff)+.2;
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                clip(col.a - _Cutoff);
                col *= _Color * _ColorScale;
                
                //UNITY_LIGHT_ATTENUATION(atten, i, i.worldPos)
                fixed atten = SHADOW_ATTENUATION(i);
                float diff = smoothstep(0.2,0.4,i.diff) + .5;
                col *= diff * atten;
                //return atten;
                #if defined(LIGHTMAP_ON)
                    half4 bakedColorTex = UNITY_SAMPLE_TEX2D(unity_Lightmap, i.lmap.xy);
                    half3 bakedColor = DecodeLightmap(bakedColorTex);

                    col.rgb *= bakedColor;
                #endif
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }

        Pass
        {
            Tags {"LightMode"="ShadowCaster"}

            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma multi_compile_shadowcaster
            #include "UnityCG.cginc"

            sampler2D _MainTex;
            float _Cutoff;

            struct v2f { 
                V2F_SHADOW_CASTER;
                float2 uv : TEXCOORD0;
            };

            v2f vert(appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos( WaveVertex(v,_WaveSpeed,_WaveIntensity) );
                //TRANSFER_SHADOW_CASTER_NORMALOFFSET(o)
                o.uv = v.uv;
                return o;
            }

            float4 frag(v2f i) : SV_Target
            {
                fixed4 col = tex2D(_MainTex, i.uv);
                clip(col.a- _Cutoff);

                SHADOW_CASTER_FRAGMENT(i)
                
            }
            ENDCG
        }

    }
}
