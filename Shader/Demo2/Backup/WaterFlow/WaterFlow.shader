Shader "Unlit/WaterFlow"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "" {}
	_MainTexMask("Texture Mask",2d) = "white"{}

		_NormalMap("NormalMap",2d) = ""{}
		_Tile("Tile",vector) = (5,5,2,2)
		_Direction("Direction",vector) = (1,0,0,0)
		_ReflectionTex("Reflection Tex",2d) = ""{}
		_FakeReflectionTex("Fake Reflection Tex",2d) = ""{}
    }
    SubShader
    {
        Tags { "RenderType"="Opaque" "Queue"="Geometry+1"}
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
				float4 normalUV:TEXCOORD2;
				float4 screenPos:TEXCOORD3;
				float2 refl:COLOR1;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

			sampler2D _MainTexMask;

			sampler2D _NormalMap;
			float4 _Tile;
			float4 _Direction;
			sampler2D _ReflectionTex;
			sampler2D _FakeReflectionTex;

			float2 FakeReflection(float4 vertex) {
				float4 worldPos = mul(unity_ObjectToWorld, vertex);
				return (worldPos.xz - _WorldSpaceCameraPos.xz * 0.5) *0.01;
			}

            v2f vert (appdata v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(v.vertex);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);

				o.normalUV = v.uv.xyxy * _Tile + _Time.xxxx * _Direction;
				o.screenPos = ComputeScreenPos(o.vertex);
				o.refl = FakeReflection(v.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
				float3 n = UnpackNormal(tex2D(_NormalMap,i.normalUV.xy));
				n += UnpackNormal(tex2D(_NormalMap, i.normalUV.zw));

				float4 refl = tex2D(_ReflectionTex, (i.screenPos.xy / i.screenPos.w) + n.xy);
				refl += tex2D(_FakeReflectionTex, i.refl + n.xy * 2);

                // sample the texture
				fixed4 mainMask = tex2D(_MainTexMask, i.uv);
                fixed4 col = tex2D(_MainTex, i.uv + mainMask.r * n.xy * 0.02);
				col += mainMask.r * col.a * refl *0.1;


                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
