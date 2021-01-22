Shader "Unlit/ShowP"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color1("_Color1",color) = (0,0,0.4,1)
        _Color2("_Color2",color) = (1,0,0,1)
        _MaxVelocity("_MaxVelocity",float) = 10
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            blend srcAlpha one
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag

            #pragma target 5.0

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                uint vid:SV_VertexID;
                uint instanceId:SV_InstanceID;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float4 color:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float4 _Color1,_Color2;
            float _MaxVelocity;

            struct Particle{
                float2 pos;
                float2 velocity;
            };
            StructuredBuffer<Particle> particles;

            v2f vert (appdata v)
            {
                Particle p = particles[v.instanceId];
                v2f o;
                o.vertex = UnityObjectToClipPos(float4(p.pos,1,1));
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);

                float rate = clamp(length(p.velocity) / _MaxVelocity,0,1);
                o.color = lerp(_Color1,_Color2,rate);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                return i.color;
            }
            ENDCG
        }
    }
}
