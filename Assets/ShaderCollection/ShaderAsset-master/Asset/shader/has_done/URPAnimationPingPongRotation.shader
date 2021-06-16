Shader "Unlit/URPAnimationPingPongRotation"
{
    Properties
    { 
       _MainTex ("Texture", 2D) = "white" {}
       AnimatedRotationUV_AnimatedRotationUV_Rotation_1("AnimatedRotationUV_AnimatedRotationUV_Rotation_1", Range(-360, 360)) = -16.715
       AnimatedRotationUV_AnimatedRotationUV_PosX_1("AnimatedRotationUV_AnimatedRotationUV_PosX_1", Range(-1, 2)) = 0.5
       AnimatedRotationUV_AnimatedRotationUV_PosY_1("AnimatedRotationUV_AnimatedRotationUV_PosY_1", Range(-1, 2)) = 0.5
       AnimatedRotationUV_AnimatedRotationUV_Intensity_1("AnimatedRotationUV_AnimatedRotationUV_Intensity_1", Range(0, 4)) = 0.5
       AnimatedRotationUV_AnimatedRotationUV_Speed_1("AnimatedRotationUV_AnimatedRotationUV_Speed_1", Range(-10, 10)) = 4.107
       _LerpUV_Fade_1("_LerpUV_Fade_1", Range(0, 1)) = 1
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
            float AnimatedRotationUV_AnimatedRotationUV_Rotation_1;
            float AnimatedRotationUV_AnimatedRotationUV_PosX_1;
            float AnimatedRotationUV_AnimatedRotationUV_PosY_1;
            float AnimatedRotationUV_AnimatedRotationUV_Intensity_1;
            float AnimatedRotationUV_AnimatedRotationUV_Speed_1;
            float _LerpUV_Fade_1;
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
                    
                 
            float2 AnimatedRotationUV(float2 uv, float rot, float posx, float posy, float radius, float speed)
            {
                uv = uv - float2(posx, posy);
                // Π / 180  转化为弧度制
                float angle = rot * 0.01744444;
                angle += sin(_Time * speed * 20) * radius;
                float sinX = sin(angle);
                float cosX = cos(angle);
                // 乘以一个 2x2 的矩阵 旋转UV 坐标
                float2x2 rotationMatrix = float2x2(cosX, -sinX, sinX, cosX);
                uv = mul(uv, rotationMatrix) + float2(posx, posy);
            return uv;
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
                float2 AnimatedRotationUV_1 = AnimatedRotationUV(IN.texcoord,AnimatedRotationUV_AnimatedRotationUV_Rotation_1,AnimatedRotationUV_AnimatedRotationUV_PosX_1,AnimatedRotationUV_AnimatedRotationUV_PosY_1,AnimatedRotationUV_AnimatedRotationUV_Intensity_1,AnimatedRotationUV_AnimatedRotationUV_Speed_1);
                IN.texcoord = lerp(IN.texcoord,AnimatedRotationUV_1,_LerpUV_Fade_1);
                float4 _MainTex_1 = SAMPLE_TEXTURE2D(_MainTex,sampler_MainTex,IN.texcoord);
                float4 FinalResult = _MainTex_1;
                FinalResult.rgb *= IN.color.rgb;
                FinalResult.a = FinalResult.a * _SpriteFade * IN.color.a;
                return FinalResult;
            }
            ENDHLSL
        }
    }
}
