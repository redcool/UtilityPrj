Shader "Unlit/AnimTex"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}
		_AnimTex("Anim Tex",2d) = ""{}
		_AnimSampleRate("Anim Sample Rate",float) = 30
		_StartTime("Start Time",float) = 0
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
			// 开发gpu实例化
			#pragma multi_compile_instancing

            #include "UnityCG.cginc"

            struct appdata
            {
                float2 uv : TEXCOORD0;
				uint vertexId:SV_VertexID;
				// 准备从vertex shader获取批量数据
				UNITY_VERTEX_INPUT_INSTANCE_ID
            };

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

			sampler2D _AnimTex;
			float4 _AnimTex_TexelSize;
			

			//准备需要批量处理的数据.
			UNITY_INSTANCING_BUFFER_START(Props)
				UNITY_DEFINE_INSTANCED_PROP(float, _StartTime)
				UNITY_DEFINE_INSTANCED_PROP(float,_AnimSampleRate)
			UNITY_INSTANCING_BUFFER_END(Props)

            v2f vert (appdata v)
            {
                v2f o;
				UNITY_SETUP_INSTANCE_ID(v);

				float startTime = UNITY_ACCESS_INSTANCED_PROP(Props, _StartTime);
				//动画长度 = 帧数/采样率
				float animLen = _AnimTex_TexelSize.w / UNITY_ACCESS_INSTANCED_PROP(Props, _AnimSampleRate);
				float y = (startTime + _Time.y) / animLen;
				//SV_VertexID从左边界开始,纹理从纹素中心点开始.
				float x = (v.vertexId + 0.5) * _AnimTex_TexelSize;

				float4 animPos = tex2Dlod(_AnimTex,float4(x,y,0,0));

				o.vertex = UnityObjectToClipPos(animPos);
                o.uv = TRANSFORM_TEX(v.uv, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);

                return o;
            }

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
