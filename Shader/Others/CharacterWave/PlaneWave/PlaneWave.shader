// Upgrade NOTE: replaced '_Object2World' with 'unity_ObjectToWorld'

Shader "Unlit/Transparent/Wave/PlaneWave"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
        _Color("Color",color)=(1,1,1,1)
        _NormalMap("NormalMap",2d) = ""{}

        _Tile("Tile",vector) = (5,5,10,10)
        _Direction("Direction",vector) = (0,1,0,-1)
        
        [Header(Reflection)]
        _ReflectionTex("ReflectionTex",Cube) = ""{}
        _FakeReflectionTex("FakeReflectionTex",2d) = "black"{}

        [Header(Fresnal)]
        _FresnalWidth("FresnalWidth",float) = 1

        [Header(VertexWave)]
        [Toggle]_VertexWave("Vertex Wave ?",float) = 0
        _VertexWaveNoiseTex("VertexWaveNoiseTex",2d) = ""{}
        _VertexWaveIntensity("VertexWaveIntensity",float) = 0.1
        _VertexWaveSpeed("VertexWaveSpeed",float) = 1

        [Header(Specular)]
        _SpecPower("SpecPower",range(0.001,1)) = 10
        _Glossness("Glossness",range(0,1)) = 1
        _SpecWidth("SpecWidth",range(0,1)) = 0.2
    }
    SubShader
    {
        Tags { "RenderType"="Transparent" "LightMode"="ForwardBase" "Queue"="Transparent"}
        LOD 100
        blend one oneMinusSrcAlpha

        Pass
        {
            CGPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            // make fog work
            #pragma multi_compile_fog
            #pragma shader_feature _VERTEXWAVE_ON

            #include "UnityCG.cginc"
            #include "Lighting.cginc"
            //#include "../Include/NodeLib.cginc"

            struct appdata
            {
                float4 vertex : POSITION;
                float2 uv : TEXCOORD0;
                float3 normal:NORMAL;
                float4 color:COLOR;
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 normalUV:COLOR;
                float3 worldPos:TEXCOORD2;
                float3 normal:TEXCOORD3;
                float4 screenPos:TEXCOORD4;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;
            float4 _Color;

            sampler2D _NormalMap;
            float4 _Tile;
            float4 _Direction;
            float _FresnalWidth;
            samplerCUBE _ReflectionTex;
            sampler2D _FakeReflectionTex;

            sampler2D _VertexWaveNoiseTex;
            float _VertexWaveIntensity,_VertexWaveSpeed;

            float _SpecPower,_Glossness,_SpecWidth;

            v2f vert (appdata v)
            {
                v2f o = (v2f)0;

                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normalUV = o.uv.xyxy * _Tile + _Time.xxxx* _Direction;
                o.normal = v.normal;
                o.screenPos = ComputeScreenPos(o.vertex);

                // random vertex motion.
                #if _VERTEXWAVE_ON
                    float3 n = tex2Dlod(_VertexWaveNoiseTex,float4(o.uv + _Time.xx * _VertexWaveSpeed,0,1));
                    float3 fv = v.color * v.normal * (n) * 0.1 * _VertexWaveIntensity;
                    o.vertex = UnityObjectToClipPos(v.vertex + fv);
                #else
                    o.vertex = UnityObjectToClipPos(v.vertex);
                #endif
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //float2 uv = i.worldPos.xz;
                float3 worldNormal = UnityObjectToWorldNormal(i.normal);
                float3 l = normalize(UnityWorldSpaceLightDir(i.worldPos));
                float3 v = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 h = normalize(l+v);

                float3 n = UnpackNormal(tex2D(_NormalMap,i.normalUV.xy));
                n += UnpackNormal(tex2D(_NormalMap,i.normalUV.zw));
                
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv +n.xy * 0.02) * _Color;
                //-------------- diffuse
				float nl = saturate(dot(worldNormal, l));
                fixed3 diffCol = nl * col.rgb;

                //--------------- fresnal
                float nv = dot(worldNormal,v);
                float invertNV = 1-nv;
                fixed3 fresnal = pow(invertNV , _FresnalWidth);//smoothstep(invertNV,invertNV*0.9,_FresnalWidth);


                //--------------specular
                float nh = saturate(dot(worldNormal,h));
                float spec = pow(nh,_SpecPower * 128) * _Glossness;
                spec += smoothstep(spec,spec*0.9,_SpecWidth);
				float3 specCol = spec * _LightColor0.rgb;

                //--------------- reflection
                float3 r = reflect(-v,worldNormal);
                float3 reflCol = texCUBE(_ReflectionTex,r + n );
                reflCol += tex2D(_FakeReflectionTex,i.uv + n.xy * 2);

//return float4(col + specCol,1);
				col.rgb += diffCol+specCol+ fresnal;
//				return col;
                col.rgb *= reflCol * col.a;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
