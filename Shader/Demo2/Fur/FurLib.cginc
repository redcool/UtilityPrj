    #include "UnityCG.cginc"

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
    };

    sampler2D _MainTex;
    float4 _MainTex_ST;

    sampler2D _FurTex;
    float _Density;
    float _Tile;
    float _Length,_Rigidness;

    v2f vert (appdata v)
    {
        v2f o;
        float3 pos = v.vertex + v.normal * FUR_OFFSET * _Length;
        float4 gravity = float4(0,-1,0,0) * (1 - _Rigidness);
        pos += clamp(mul(unity_WorldToObject,gravity).xyz,-1,1) * pow(FUR_OFFSET,3) * _Length;

        o.vertex = UnityObjectToClipPos(float4(pos,1));
        o.uv = TRANSFORM_TEX(v.uv, _MainTex);
        UNITY_TRANSFER_FOG(o,o.vertex);
        return o;
    }

    fixed4 frag (v2f i) : SV_Target
    {
        // sample the texture
        fixed4 col = tex2D(_MainTex, i.uv * _Tile);
        fixed a = tex2D(_FurTex,i.uv).r;
        fixed3 c = col.rgb - pow(1 - FUR_OFFSET,3) * .1;
        a = clamp(a - pow(FUR_OFFSET,2) * _Density,0,1);
        // apply fog
        UNITY_APPLY_FOG(i.fogCoord, col);
        return float4(c,a);
    }