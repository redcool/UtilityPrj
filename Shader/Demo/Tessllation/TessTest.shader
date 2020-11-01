Shader "Unlit/TessTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _TessellationUniform ("Tessellation Uniform", Range(1, 64)) = 1
		_TessellationEdgeLength ("Tessellation Edge Length", Range(5, 100)) = 50
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" }
        LOD 100



        Pass
        {
            CGPROGRAM
            #pragma vertex tessVertFunc
            #pragma fragment frag
            #pragma hull hullFunc
            #pragma domain domainFunc

            // #define TESS_EDGE

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

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }
//----------------------------------------
            float _TessellationUniform;
            float _TessellationEdgeLength;

            struct TessellationFactors{
                float edge[3]:SV_TessFactor;
                float inside:SV_InsideTessFactor;
            };
            float TessEdgeFactor(float3 p0,float3 p1){
                #if defined(TESS_EDGE)
                    float edgeLength = distance(p0,p1);
                    float3 center = (p0+p1)*0.5;
                    float viewDistance = distance(center,_WorldSpaceCameraPos);
                    return edgeLength * _ScreenParams.y/(_TessellationEdgeLength * viewDistance);
                #endif
                return _TessellationUniform;
            }
            TessellationFactors patchConstFunc(InputPatch<appdata,3> patch){
                float3 p0 = mul(unity_ObjectToWorld,patch[0].vertex).xyz;
                float3 p1 = mul(unity_ObjectToWorld,patch[1].vertex).xyz;
                float3 p2 = mul(unity_ObjectToWorld,patch[2].vertex).xyz;
                TessellationFactors f;
                f.edge[0] = TessEdgeFactor(p1,p2);
                f.edge[1] = TessEdgeFactor(p2,p0);
                f.edge[2] = TessEdgeFactor(p0,p1);
                f.inside = (f.edge[0]+f.edge[1]+f.edge[2])/3;
                return f;
            }

            appdata tessVertFunc(appdata v){
                return v;
            }

            [UNITY_domain("tri")]
            [UNITY_outputcontrolpoints(3)]
            [UNITY_outputtopology("triangle_cw")]
            [UNITY_partitioning("fractional_odd")]
            [UNITY_patchconstantfunc("patchConstFunc")]
            appdata hullFunc(
                InputPatch<appdata,3> patch,
                uint id :SV_OutputControlPointID
            ){
                return patch[id];
            }

            [UNITY_domain("tri")]
            v2f domainFunc(
                TessellationFactors factors,
                OutputPatch<appdata,3> patch,
                float3 coord:SV_DomainLocation
            ){
                appdata data;
                #define DOMAIN_INTERPOLATE(n) data.n = \
                    patch[0].n * coord.x + \
                    patch[1].n * coord.y + \
                    patch[2].n * coord.z;

                DOMAIN_INTERPOLATE(vertex)
                DOMAIN_INTERPOLATE(uv)
                return vert(data);
            }
//------------------------------------------


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
