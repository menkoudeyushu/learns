Shader "Unlit/URPBlurHQplus"
{
    Properties
    { 
       _MainTex ("Texture", 2D) = "white" {}
       _BlurHQPlus_Intensity_1("_BlurHQPlus_Intensity_1", Range(1, 64)) = 7.114
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
        Pass
        {
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            #pragma fragmentoption ARB_precision_hint_fastest
            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"            

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float _SpriteFade;
            float _BlurHQPlus_Intensity_1;
            CBUFFER_END

            struct Attributes
            {
                float4 positionOS   : POSITION;
                // The uv variable contains the UV coordinate on the texture for the
                // given vertex.
                float2 texcoord     : TEXCOORD0;
                // 2D物体的顶点颜色
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
            TEXTURE2D(_MainTex);
            // This macro declares the sampler for the _BaseMap texture.
            SAMPLER(sampler_MainTex);

            float BlurHQ_Plus_G(float bhqp, float x)
            {
                return exp(-(x * x) / (2.0 * bhqp * bhqp));
            }



            float4 BlurHQ_Plus(float2 uv,float Intensity)
            {
                int c_samples = 16;
                int c_halfSamples = c_samples / 2;
                float c_pixelSize = 0.00390625;
                float c_sigmaX = 0.1 + Intensity *0.5;
                float c_sigmaY = c_sigmaX;
                float total = 0.0;
                float4 ret = float4(0, 0, 0, 0);
                for (int iy = 0; iy < c_samples; ++iy)
                {
                    float fy = BlurHQ_Plus_G(c_sigmaY, float(iy) - float(c_halfSamples));
                    float offsety = float(iy - c_halfSamples) * c_pixelSize;
                    for (int ix = 0; ix < c_samples; ++ix)
                        {
                            float fx = BlurHQ_Plus_G(c_sigmaX, float(ix) - float(c_halfSamples));
                            float offsetx = float(ix - c_halfSamples) * c_pixelSize;
                            total += fx * fy;
                            ret += SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,uv + float2(offsetx, offsety)) * fx*fy;
                        }
                }
                return ret / total;
            }

    
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

            // 顶点着色器的颜色 * 片元采样后的颜色
            half4 frag(Varyings IN) : SV_Target
            {
                // The SAMPLE_TEXTURE2D marco samples the texture with the given
                // sampler.
                float4 _BlurHQPlus_1 = BlurHQ_Plus(IN.texcoord,_BlurHQPlus_Intensity_1);
                float4 FinalResult = _BlurHQPlus_1;
                FinalResult.rgb *= IN.color.rgb;
                FinalResult.a = FinalResult.a * _SpriteFade * IN.color.a;
                return FinalResult;
            }
            ENDHLSL
        }
    }  
}
