Shader "Unlit/URPColorHSV"
{
    Properties
    { 
       _MainTex ("Texture", 2D) = "white" {}
       _Blur_Intensity_1("_Blur_Intensity_1", Range(1, 16)) = 1.914
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

            #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"            

            CBUFFER_START(UnityPerMaterial)
            float4 _MainTex_ST;
            float _SpriteFade;
            float _Blur_Intensity_1;
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
            
            // 每个像素点周围的 8个像素点 分别进行 采样， 乘以不同的权重 颜色最后叠加输出
            float4 Blur(float2 uv,float Intensity)
            {
            float stepU = 0.00390625f * Intensity;
            float stepV = stepU;
            float4 result = float4 (0, 0, 0, 0);
            float2 texCoord = float2(0, 0);
            texCoord = uv + float2(-stepU, -stepV); result += SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,texCoord);
            texCoord = uv + float2(-stepU, 0); result += 2.0 * SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,texCoord);
            texCoord = uv + float2(-stepU, stepV); result += SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,texCoord);
            texCoord = uv + float2(0, -stepV); result += 2.0 * SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,texCoord);
            texCoord = uv; result += 4.0 * SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,texCoord);
            texCoord = uv + float2(0, stepV); result += 2.0 * SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex, texCoord);
            texCoord = uv + float2(stepU, -stepV); result += SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex, texCoord);
            texCoord = uv + float2(stepU, 0); result += 2.0* SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex, texCoord);
            texCoord = uv + float2(stepU, -stepV); result += SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex, texCoord);
            result = result * 0.0625;
            return result;
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
                float4 _Blur_1 = Blur(IN.texcoord,_Blur_Intensity_1);
                float4 FinalResult = _Blur_1;
                FinalResult.rgb *=IN.color.rgb;
                FinalResult.a = FinalResult.a * _SpriteFade * IN.color.a;
                return FinalResult;
            }
            ENDHLSL
        }
    }  
}
