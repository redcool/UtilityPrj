            float noise(float2 p){
                float n = (sin(dot(p.xy,float2(100,789)))) * 10000;
                return frac(n);
            }

            float smoothNoise(float2 uv){
                float n = noise(uv);
                float2 lv =frac(uv);
                lv = smoothstep(0,1,lv);
                float2 id = floor(uv);

                float bl = noise(id);
                float br = noise(id + float2(1,0));
                float b = lerp(bl,br,lv.x);

                float tl = noise(id + float2(0,1));
                float tr = noise(id + float2(1,1));
                float t = lerp(tl,tr,lv.x);
                return lerp(b,t,lv.y);
            }