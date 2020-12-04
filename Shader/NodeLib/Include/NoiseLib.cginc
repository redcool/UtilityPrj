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

            float smoothNoise2(float2 uv){
                float c = smoothNoise(uv * 4);
                c += smoothNoise(uv * 8) * 0.5;
                c += smoothNoise(uv * 16) * 0.25;
                c += smoothNoise(uv * 32) * 0.125;
                c += smoothNoise(uv * 64) * 0.0625;
                return c/2;
            }

            float Hash21(float2 p){
                p =frac(p * float2(123.34,456.21));
                p += dot(p,p + 45.32);
                return frac(p.x * p.y);
            }