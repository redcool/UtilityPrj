// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'
// Upgrade NOTE: replaced '_World2Object' with 'unity_WorldToObject'
/**
    法线图
    阴影
    高光,漫射

*/
Shader "Unlit/Pbs1"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _NormalMap("_NormalMap",2d) = ""{}
        _Metallic("_Metallic",range(0,1)) = 0.04
        _Smoothness("_Smoothness",range(0,1)) = 0.5
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100

        Pass
        {
            Tags{"LightMode"="ForwardBase"}
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma target 3.0
            // make fog work
            #pragma multi_compile_fog
            #pragma multi_compile_fwdbase
            #pragma multi_compile_fwdbase_fullshadows
            #include "AutoLight.cginc"
            #include "UnityCG.cginc"
            #include "UnityStandardUtils.cginc"
            #include "UnityStandardBRDF1.cginc"

            #define PI 3.1415

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
                float4 tangent:TANGENT;
            };

            struct v2f
            {
                float4 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 uv2 : TEXCOORD2;
                float4 tSpace0 : TEXCOORD3;
                float4 tSpace1 : TEXCOORD4;
                float4 tSpace2 : TEXCOORD5;
                LIGHTING_COORDS(6,7)
                float4 pos : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            sampler2D _NormalMap;
            float _Smoothness;
            float _Metallic;

            v2f vert (appdata v)
            {
                v2f o;
                o.pos = UnityObjectToClipPos(v.vertex);
                o.uv.xy = TRANSFORM_TEX(v.uv, _MainTex);

                float3 worldPos = mul(unity_ObjectToWorld,v.vertex);
                float3 n = mul(v.normal,unity_WorldToObject);
                float3 t = mul(unity_ObjectToWorld,v.tangent.xyz);
                float3 bt = normalize(cross(n,t) * v.tangent.w);
                o.tSpace0 = float4(t.x,bt.x,n.x,worldPos.x);
                o.tSpace1 = float4(t.y,bt.y,n.y,worldPos.y);
                o.tSpace2 = float4(t.z,bt.z,n.z,worldPos.z);

                UNITY_TRANSFER_FOG(o,o.pos);
                TRANSFER_VERTEX_TO_FRAGMENT(o)
                return o;
            }

            void DiffuseSpecularColor(inout float3 albedo,inout float3 specColor,float metallic){
                specColor = lerp(0.04,albedo,metallic);
                albedo *= (1 - metallic);
            }

            float SmithJoingGGX(float nl,float nv,float rough){
                float l = nl * (nv *(1-rough)+rough);
                float v = nv *(nl * (1-rough)+rough);
                return 0.5/(l+v+0.0001);
            }
            float GGX(float nh,float rough){
                float a2 = rough * rough;
                float d = (nh * a2 - nh) * nh + 1;
                return a2/((d*d+0.000001) * 3.14);
            }

            fixed4 frag (v2f i) : SV_Target
            {
                float3 worldPos = float3(i.tSpace0.w,i.tSpace1.w,i.tSpace2.w);
                //normal map
                float3 tn = UnpackNormal(tex2D(_NormalMap,i.uv));
                float3 n = float3(
                    dot(i.tSpace0.xyz,tn),
                    dot(i.tSpace1.xyz,tn),
                    dot(i.tSpace2.xyz,tn)
                );
                // float3x3 rot = float3x3(i.tSpace0.xyz,i.tSpace1.xyz,i.tSpace2.xyz);
                // float3 n = mul(rot,tn);
                // lighting
                float3 l = UnityWorldSpaceLightDir(worldPos);
                float3 v = UnityWorldSpaceViewDir(worldPos);
                float3 h = normalize(l+v);
                float nl = saturate(dot(l,n));
                float nv = saturate(dot(n,v));
                float nh = saturate(dot(n,h));
                float lv = saturate(dot(l,v));
                float lh = saturate(dot(l,h));
                // shadow
                UNITY_LIGHT_ATTENUATION(atten,i,worldPos);
                float3 attenColor = atten * _LightColor0.rgb;

                // specular
                float rough = 1 - _Smoothness;
                float rough2 = rough * rough;
                float metallic = _Metallic;
                
                // sample the texture
                float4 diffColor = tex2D(_MainTex, i.uv.xy);
                float3 specColor = _Metallic;
                float oneMinusReflectivition;
                // diffColor.rgb = DiffuseAndSpecularFromMetallic(diffColor.rgb,metallic,/**/specColor,/**/oneMinusReflectivition);
                DiffuseSpecularColor(diffColor.rgb,specColor,metallic);
// UnityLight light = {_LightColor0.rgb,_WorldSpaceLightPos0.xyz,0};
// return BRDF1_Unity_PBS(diffColor,specColor,oneMinusReflectivition,_Smoothness,n,v,light,(UnityIndirect)0);
                // float V = SmithJointGGXVisibilityTerm(nl,nv,rough2);
                float V = SmithJoingGGX(nl,nv,rough);
                float D = GGX(nh,rough2);
// return D;
                float F = FresnelTerm(specColor,lh);
                float specTerm = V * D * PI;
                specTerm = max(0,specTerm * nl);
                // specTerm *= any(specColor)?1:0;
                float3 specDirect = specTerm * _LightColor0.rgb * F;
                
                float3 diffuseDirect = diffColor * ( _LightColor0.rgb * nl);
                return (diffuseDirect +specDirect ).rgbr;


                fixed4 col = (float4)0;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }

        UsePass "Legacy Shaders/VertexLit/SHADOWCASTER"
    }
}

