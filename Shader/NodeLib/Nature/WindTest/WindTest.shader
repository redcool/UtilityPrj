Shader "Unlit/WindTest"
{
    Properties
    {
        _MainTex ("Texture", 2D) = "white" {}

        [Header(Wind)]
        //[Toggle(PLANTS_OFF)]_PlantsOff("禁用风力",float) = 0
        [Toggle(PLANTS_OFF)]_Plants_Off("禁用风力",float) = 1
        // [Toggle(EXPAND_BILLBOARD)]_ExpandBillboard("叶片膨胀?",float) = 0
        _Wave("抖动(树枝,边抖动,风向偏移,风向回弹)",vector) = (0,0.2,0.2,0.1)
        _Wind("风力(xyz:方向,w:风强)",vector) = (1,1,1,1)
        _AttenField("无抖动范围 (x: 水平距离,y:竖直距离)",vector) = (1,1,1,1)
        _WorldPos("_WorldPos",vector)=(0,0,0,0)
        _WorldScale("_WorldScale",vector)=(1,1,1,1)
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
            #include "windCore.cginc"

            struct v2f
            {
                float2 uv : TEXCOORD0;
                UNITY_FOG_COORDS(1)
                float4 vertex : SV_POSITION;
            };

            sampler2D _MainTex;
            float4 _MainTex_ST;

            v2f vert (appdata_full v)
            {
                v2f o;
                o.vertex = UnityObjectToClipPos(ClampVertexWave(v,_Wave,_AttenField.y,_AttenField.x));
                o.uv = TRANSFORM_TEX(v.texcoord, _MainTex);
                UNITY_TRANSFER_FOG(o,o.vertex);
                return o;
            }

            fixed4 frag (v2f i) : SV_Target
            {
                // sample the texture
                fixed4 col = tex2D(_MainTex, i.uv);
                clip(col.a - 0.5);
                // apply fog
                UNITY_APPLY_FOG(i.fogCoord, col);
                return col;
            }
            ENDCG
        }
    }
}
