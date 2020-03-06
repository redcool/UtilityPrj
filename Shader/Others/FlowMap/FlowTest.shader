Shader "Unlit/FlowTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _FlowMap("FlowMap",2d) = ""{}
        _Speed("Speed",float) = 1
        _Tiling("Tiling",float) = 1
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
            #include "FlowMap.cginc"

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
            sampler2D _FlowMap;
            float _Speed,_Tiling;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }


            fixed4 frag (v2f i) : SV_Target
            {
                float4 flowMap = tex2D(_FlowMap,i.uv);
                float2 flowVec = flowMap.xy * 2 -1;


                float4 col = ApplyFlowColor(_MainTex,i.uv,flowVec);
                //float4 col = FlowColor(_MainTex,i.uv,flowVec,_Tiling);

                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
