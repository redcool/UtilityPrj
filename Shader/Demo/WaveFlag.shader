Shader "Unlit/WaveFlag"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _WaveStrength("_WaveStrength",float) = 1
        _WaveSpeed("_WaveSpeed",float) = 1
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
                float2 uv : TEXCOORD0;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            float _WaveSpeed,_WaveStrength;

            float3 FlagWave(float3 vertex,float2 uv,float strength,float speed){
                float sinOff=(vertex.x+vertex.y+vertex.z) * strength;
                float t=-_Time*speed;
                float fx=uv.x;
                float fy=uv.x * uv.y;
                vertex.x+=sin(t*1.45+sinOff)*fx*0.5;
                vertex.y=(sin(t*3.12+sinOff)*fx*0.5-fy*0.9);
                vertex.z-=(sin(t*2.2+sinOff)*fx*0.2);
                return vertex;
            }

            v2f vert (appdata v)
            {
                v2f o;

                v.vertex.xyz = FlagWave(v.vertex,v.uv,_WaveStrength,_WaveSpeed);
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
