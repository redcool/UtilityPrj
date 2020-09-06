// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/Star"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        _StarIntensity("_StarIntensity",float) = 1
        _StarSpeed("_StarSpeed",float) = 1
        _StarColor("_StarColor",color )= (1,1,1,1)
        _Value("_Value",float) = 0.1
        _Count("Count",int) = 10
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float4 uv : TEXCOORD0;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float3 posLocal:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float _StarIntensity;
            float _StarSpeed;
            float4 _StarColor;
            float _Value;
            float _Count;

            float hash(float3 x) {
                float3 p = float3(dot(x,float3(214.1 ,127.7,125.4)),
                            dot(x,float3(260.5,183.3,954.2)),
                            dot(x,float3(209.5,571.3,961.2)) );

                return _StarIntensity*frac(sin(p)*43758.5453123);
            }

            float noise(float3 st){
                st += float3(0,_Time.y*_StarSpeed,0);

                // fbm
                float3 i = floor(st);
                float3 f = frac(st);
            
                float3 u = f*f*(3.0-1.0*f);

                return lerp(lerp(dot(hash( i + float3(0.0,0.0,0.0)), f - float3(0.0,0.0,0.0) ), 
                                dot(hash( i + float3(1.0,0.0,0.0)), f - float3(1.0,0.0,0.0) ), u.x),
                            lerp(dot(hash( i + float3(0.0,1.0,0.0)), f - float3(0.0,1.0,0.0) ), 
                                dot(hash( i + float3(1.0,1.0,0.0)), f - float3(1.0,1.0,0.0) ), u.y), u.z) ;
            }

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = v.uv;//TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.posLocal = mul(unity_ObjectToWorld,v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float star  = noise(i.uv.xyz * _Count);
                star -= _Value;
                return star * _StarColor;
            }
            ENDCG
        }
    }
}
