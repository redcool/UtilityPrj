Shader "Unlit/ComplexFresnel"
{
    Properties
    {
        _Cube("_Cube",cube)=""{}
        _Rot("_Rot",vector) = (0,0,0,0)

        _IOR("_IOR",float) = 1
        _F0("_F0",float) = 0.01

        [Header(Complex Fresnel)]
        _N("_N",vector) = (0.27105, 0.67693, 1.3164,0)
        _K("_K",vector) = (3.6092, 2.6247, 2.2921,0)

        [Toggle]_NKMapOn("_NKMapOn",int) = 0
        _MapN("_MapN",2d) = ""{}
        _MapK("_MapK",2d) = ""{}
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

            float ComplexFresnel(float n, float k, float c) {
                float k2=k*k;
                float rs_num = n*n + k2 - 2*n*c + c*c;
                float rs_den = n*n + k2 + 2*n*c + c*c;
                float rs = rs_num/ rs_den ;
                
                float rp_num = (n*n + k2)*c*c - 2*n*c + 1;
                float rp_den = (n*n + k2)*c*c + 2*n*c + 1;
                float rp = rp_num/ rp_den ;
                
                return clamp(0.5*( rs+rp ), 0.0, 1.0);
            }

            float3 ComplexIOR(float3 incidentDir,float3 normal,float3 n,float3 k){
                float thetaCos = abs(dot(incidentDir,normal));
                float r = ComplexFresnel(n[0],k[0],thetaCos);
                float g = ComplexFresnel(n[1],k[1],thetaCos);
                float b = ComplexFresnel(n[2],k[2],thetaCos);
                return float3(r,g,b);
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

            float3 _N,_K;
            sampler2D _MapK,_MapN;
            bool _NKMapOn;

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



                float thetaCos = abs(dot(-v,n));
                float3 complexFresnel = ComplexIOR(-v,n,_N,_K);
                if(_NKMapOn){
                    float4 mapN = tex2D(_MapN,i.uv);
                    float4 mapK = tex2D(_MapK,i.uv);
                    complexFresnel = ComplexIOR(-v,n,mapN,mapK);
                }


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
                return lerp(refrColor,reflColor,complexFresnel.x);
                
            }
            ENDCG
        }
    }
}
