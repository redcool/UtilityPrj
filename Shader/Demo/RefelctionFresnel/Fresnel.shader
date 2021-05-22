Shader "Unlit/ReflectionFresnel"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Cube("_Cube",cube)=""{}
        _Rot("_Rot",vector) = (0,0,0,0)

        _IOR("_IOR",float) = 1
        _F0("_F0",float) = 0.01
    }
CGINCLUDE

            void RotX(inout float3 v,float x){
                float3x3 rot = {
                    1,0,0,
                    0,cos(x),-sin(x),
                    0,sin(x),cos(x)
                };
                v =  mul(rot,v);
            }
            void RotY(inout float3 v,float y){
                float3x3 rot = {
                    cos(y),0,sin(y),
                    0,1,0,
                    -sin(y),0,cos(y)
                };
                v = mul(rot,v);
            }
            void RotZ(inout float3 v,float z){
                float3x3 rot = {
                    cos(z),-sin(z),0,
                    sin(z),cos(z),0,
                    0,0,1
                };
                v = mul(rot,v);
            }

            float Fresnel(float nv,float f0){
                float nv5 = pow(1 -nv,5);
                return lerp(nv5,1,f0); // (1- f0) * nv5 + f0*1
            }
ENDCG

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
                float3 normal:TEXCOORD1;
                float3 worldPos:TEXCOORD2;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            samplerCUBE _Cube;
            float4 _Rot;
            float _IOR;
            float _F0;

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normal = UnityObjectToWorldNormal(v.normal);
                o.worldPos = mul(unity_ObjectToWorld,v.vertex);

                return o;
            }



            fixed4 frag (v2f i) : SV_Target
            {
                float3 v = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 l = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 n = normalize(i.normal);
                float nv = saturate(dot(n,v));

                float3 reflDir = reflect(-v,n);
                float3 rotate = radians(_Rot);
                // RotX(reflDir/*inout*/,rotate.x);
                // RotY(reflDir/**/,rotate.y);
                // RotZ(reflDir/**/,rotate.z);

                float3 refrDir = refract(-v,n,1/_IOR);
                RotX(refrDir,rotate.x);
                // return refrDir.xyzx;

                float4 reflColor = texCUBE(_Cube,reflDir);
                float4 refrColor = texCUBE(_Cube,refrDir);
                // return refrColor;
                float fresnel = Fresnel(nv,_F0);
                // return fresnel;
                return lerp(refrColor,reflColor,fresnel);
                
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);

                return col;
            }
            ENDCG
        }
    }
}
