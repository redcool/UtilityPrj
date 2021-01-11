Shader "Unlit/IrisColor"
{
    Properties
    {
        _MainTex("_MainTex",2d) = ""{}

        _IrisTex ("_IrisTex", 2D) = "white" {}
        _IrisIntensity("_IrisIntensity",float) = 1
        _Tile("_Tile",float) = 1
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

            #include "UnityCG.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                float4 vertex : SV_POSITION;
                float3 posWorld:TEXCOORD2;
                float3 normal:TEXCOORD3;
            };
            
            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _IrisTex;
            float _IrisIntensity;
            
            float _Tile;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                o.posWorld = mul(unity_ObjectToWorld,v.vertex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 viewPos = _WorldSpaceCameraPos * _Tile;
                float3 posWorld = i.posWorld;
                float3 v = normalize(UnityWorldSpaceViewDir(posWorld));
                float3 normal  = normalize(i.normal);

                float nv = dot(normal,v);
                nv = abs(cos(nv) * _Tile);
                float4 irisColor = tex2D(_IrisTex,nv) * _IrisIntensity;

                float4 mainCol = tex2D(_MainTex,i.uv) ;
                mainCol.rgb += mainCol.rgb * irisColor;
                return mainCol;

            }
            ENDCG
        }
    }
}
