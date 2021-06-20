Shader "Unlit/NormalMapTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        [NormalMap]_NormalMap("_NormalMap",2d)=""{}
        [Toggle]_ZUP("_ZUP",float) = 1
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

            float _ZUP;

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;

                float4 tSpace0:TEXCOORD2;
                float4 tSpace1:TEXCOORD3;
                float4 tSpace2:TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalMap;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);

                float3 n = UnityObjectToWorldNormal(v.normal);
                float3 t = mul(unity_ObjectToWorld,v.tangent.xyz) ;
                float3 b = normalize(cross(n,t)) * v.tangent.w;
                float3 worldPos = mul(unity_ObjectToWorld,v.vertex);

                if(_ZUP){
                    o.tSpace0 = float4(t.x,b.x,n.x,worldPos.x);
                    o.tSpace1 = float4(t.y,b.y,n.y,worldPos.y);
                    o.tSpace2 = float4(t.z,b.z,n.z,worldPos.z);
                }else{
                    o.tSpace0 = float4(t.x,n.x,b.x,worldPos.x);
                    o.tSpace1 = float4(t.y,n.y,b.y,worldPos.y);
                    o.tSpace2 = float4(t.z,n.z,b.z,worldPos.z);
                }
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float4 pn = tex2D(_NormalMap,i.uv);

                float3 tn = UnpackNormal(pn);
                // if(!_ZUP){
                //     tn.xyz = float3(tn.x,tn.z,tn.y);
                // }
                
                // {t,b,n}
                float3 n = float3(
                    dot(i.tSpace0.xyz,tn),
                    dot(i.tSpace1.xyz,tn),
                    dot(i.tSpace2.xyz,tn)
                );
                // {t,n,b}
                // if(!_ZUP){
                //     n = float3(
                //     dot(i.tSpace0.xzy,tn),
                //     dot(i.tSpace1.xzy,tn),
                //     dot(i.tSpace2.xzy,tn)
                // );
                // }
                float3 worldPos = float3(i.tSpace0.w,i.tSpace1.w,i.tSpace2.w);
                float3 l = UnityWorldSpaceLightDir(worldPos);
                return dot(n,l);
            }
            ENDCG
        }
    }
}
