Shader "Unlit/NewTurnFire"
{
    Properties
    { 
        _MainTex ("Texture", 2D) = "white" {}
        _Fire_Displacement_Value("_Fire_Displacement_Value", Range(-0.3, 0.3)) = -0.026
        _Fire_Addition_Value("_Fire_Addition_Value", Range(0, 4)) = 0.464
        _SpriteFade("SpriteFade", Range(0, 1)) = 1.0
    }

    SubShader
    {
        Tags { 
            "Queue" = "Transparent"
            "IgnoreProjector" = "true" 
            "RenderType" = "Transparent" 
            "PreviewType"="Plane" 
            "CanUseSpriteAtlas"="True" 
            "RenderPipeline" = "UniversalPipeline"
             }
        ZWrite Off Blend SrcAlpha OneMinusSrcAlpha Cull Off
        HLSLINCLUDE
        #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"            
        CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float _Fire_Displacement_Value;
            float _Fire_Addition_Value;
            float _SpriteFade;
        CBUFFER_END
        ENDHLSL
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastes


            TEXTURE2D(_MainTex);
            SAMPLER(sampler_MainTex);
            
            // UV * param * const ---> frac
            float Generate_Fire_hash2D(float2 x)
            {
            return frac(sin(dot(x, float2(13.454, 7.405)))*12.3043);
            }
            // 生成    voronoi
            float Generate_Fire_voronoi2D(float2 uv, float precision)
            {
            float2 fl = floor(uv);
            float2 fr = frac(uv);
            float res = 1.0;
            for (int j = -1; j <= 1; j++)
            {
            for (int i = -1; i <= 1; i++)
            {
            float2 p = float2(i, j);
            float h = Generate_Fire_hash2D(fl + p);
            float2 vp = p - fr + h;
            float d = dot(vp, vp);
            res += 1.0 / pow(d, 8.0);
            }
            }
            return pow(1.0 / res, precision);
            }

            // 火焰生成的主要代码
            float4 Generate_Fire(float2 uv, float posX, float posY, float precision, float smooth, float speed, float black)
            {
            uv += float2(posX, posY);
            float t = _Time*60*speed;
            float up0 = Generate_Fire_voronoi2D(uv * float2(6.0, 4.0) + float2(0, -t), precision);
            float up1 = 0.5 + Generate_Fire_voronoi2D(uv * float2(6.0, 4.0) + float2(42, -t ) + 30.0, precision);
            float finalMask = up0 * up1  + (1.0 - uv.y);
            finalMask += (1.0 - uv.y)* 0.5;
            finalMask *= 0.7 - abs(uv.x - 0.5);
            float4 result = smoothstep(smooth, 0.95, finalMask);
            result.a = saturate(result.a + black);
            return result;
            }

            // 火焰的噪声图
            float4 Color_PreGradients(float4 rgba, float4 a, float4 b, float4 c, float4 d, float offset, float fade, float speed)
            {
            float gray = (rgba.r + rgba.g + rgba.b) / 3;
            gray += offset+(speed*_Time*20);
            float4 result = a + b * cos(6.28318 * (c * gray + d));
            result.a = rgba.a;
            result.rgb = lerp(rgba.rgb, result.rgb, fade);
            return result;
            }
            
            // UV 偏移                        
            float2 SimpleDisplacementUV(float2 uv,float x, float y, float value)
            {
            return lerp(uv,uv+float2(x,y),value);
            }

            struct Attributes
            {
                float4 positionOS   : POSITION;
                // The uv variable contains the UV coordinate on the texture for the
                // given vertex.
                float2 texcoord     : TEXCOORD0;
                float4 color    : COLOR;
            };

            struct Varyings
            {
                float4 positionHCS  : SV_POSITION;
                // The uv variable contains the UV coordinate on the texture for the
                // given vertex.
                float2 texcoord     : TEXCOORD0;
                float4 color    : COLOR;

            };
            
            
            // This macro declares _BaseMap as a Texture2D object.
            // This macro declares the sampler for the _BaseMap texture.

            Varyings vert(Attributes IN)
            {
                Varyings OUT;
                OUT.positionHCS = TransformObjectToHClip(IN.positionOS.xyz);
                // The TRANSFORM_TEX macro performs the tiling and offset
                // transformation.
                OUT.texcoord = TRANSFORM_TEX(IN.texcoord, _MainTex);
                OUT.color = IN.color;
                return OUT;
            }

            half4 frag(Varyings IN) : SV_Target
            {
                // The SAMPLE_TEXTURE2D marco samples the texture with the given
                // sampler.
                float4 _Generate_Fire_1 = Generate_Fire(IN.texcoord,0,0,0.041,0.634,1,0);
                float2 _Simple_Displacement_1 = SimpleDisplacementUV(IN.texcoord,0,_Generate_Fire_1.g*_Generate_Fire_1.a,_Fire_Displacement_Value);
                float4 _MainTex_1 = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,_Simple_Displacement_1);
                float4 _PremadeGradients_1 = Color_PreGradients(_Generate_Fire_1,float4(1,0,0.13,1),float4(0.42,0.95,0,1),float4(0.99,0.68,0.99,1),float4(0.39,0.39,1,1),-0.41,1,0);
                _MainTex_1 = lerp(_MainTex_1,_MainTex_1*_MainTex_1.a + _PremadeGradients_1*_PremadeGradients_1.a,_Fire_Addition_Value * _MainTex_1.a);
                float4 FinalResult = _MainTex_1;
                FinalResult.rgb *= IN.color.rgb;
                FinalResult.a = FinalResult.a * _SpriteFade * IN.color.a;
                FinalResult.rgb *= FinalResult.a;
                FinalResult.a = saturate(FinalResult.a);
                return FinalResult;
            }
            ENDHLSL
        }
    }
        Fallback "Sprites/Default"
}
