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

        _ReflectionTex("ReflectionTex",Cube) = ""{}
        _FakeReflectionTex("FakeReflectionTex",2d) = "black"{}

        _FresnalWidth("FresnalWidth",float) = 1

        _VertexWaveIntensity("VertexWaveIntensity",range(0,0.5)) = 0.1
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
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
                float4 normalUV:COLOR;
                float3 worldPos:TEXCOORD2;
                float3 worldNormal:TEXCOORD3;
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
            float _VertexWaveIntensity;

            v2f vert (appdata v)
            {
                v2f o = (v2f)0;

                o.worldPos = mul(unity_ObjectToWorld,v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                o.normalUV = o.uv.xyxy * _Tile + _Time.xxxx* _Direction;
                o.worldNormal = UnityObjectToWorldNormal(v.vertex.xyz);
                o.screenPos = ComputeScreenPos(o.vertex);

                // random vertex
                float3 n = UnpackNormal(tex2Dlod(_NormalMap,float4(o.worldPos.xy,0,1)));
				float3 fv = 0.02 * (v.normal + n * 0.01) * abs(sin(n+_Time.y) * _VertexWaveIntensity);                

                o.vertex = UnityObjectToClipPos(v.vertex + fv);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                //float2 uv = i.worldPos.xz;

                float3 l = UnityWorldSpaceLightDir(i.worldPos);
                float3 v = normalize(UnityWorldSpaceViewDir(i.worldPos));
                float3 h = normalize(l+v);

                float3 n = UnpackNormal(tex2D(_NormalMap,i.normalUV.xy));
                n += UnpackNormal(tex2D(_NormalMap,i.normalUV.zw));
                float3 r = reflect(-v,n);

                //float4 reflCol = tex2D(_ReflectionTex,(i.screenPos.xy/i.screenPos.w));
                float4 reflCol = texCUBE(_ReflectionTex,r);
                reflCol += tex2D(_FakeReflectionTex,i.uv + n.xy * 2);
                //reflCol = smoothstep(reflCol,reflCol-0.01,_FresnalWidth);

                float nv = dot(i.worldNormal,v);
                float invertNV = 1-nv;
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv +n.xy * 0.02) * _Color;
                col.rgb += pow(invertNV , _FresnalWidth);//smoothstep(invertNV,invertNV*0.9,_FresnalWidth);

                col *= reflCol * col.a;
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
