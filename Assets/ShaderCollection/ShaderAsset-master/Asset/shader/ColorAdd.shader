Shader "Unlit/ColorAdd"
{
    Properties
    {
        _BaseMap("Base Texture",2D) = "white"{}
        _BaseColor("Base Color",Color) = (1,1,1,1)
        _AddColor("Add Color",Color) = (1,1,1,1)
        _ParamSize("Blur Size", Float) = 1.0
    }
        SubShader
        {
             Tags
            {
                "RenderPipeline" = "UniversalPipeline"//这是一个URP Shader！
                "Queue" = "Geometry"
                "RenderType" = "Opaque"
            }
        
        

        HLSLINCLUDE

           #include "Packages/com.unity.render-pipelines.universal/ShaderLibrary/Core.hlsl"
            CBUFFER_START(UnityPerMaterial)
            half4 _BaseColor;
            half4 _AddColor;
            float _ParamSize;
            CBUFFER_END

        ENDHLSL


        pass
        {  
            HLSLPROGRAM
            #pragma vertex vert
            #pragma fragment frag
            
        
            TEXTURE2D(_BaseMap);//在CG中会写成sampler2D _BaseMap;
            SAMPLER(sampler_BaseMap);
            float4 _BaseMap_ST;
         // 顶点着色器的输入
            struct Attributes
            {
                float3 positionOS : POSITION;
                float2 uv :TEXCOORD0;
            };
           // 顶点着色器的输出
            struct Varyings
            {
                float4 positionCS : SV_POSITION;
                float2 uv :TEXCOORD0;

            }; 

         Varyings vert(Attributes v)
            {
                Varyings o = (Varyings)0;
                o.uv = TRANSFORM_TEX(v.uv,_BaseMap);
                o.positionCS = TransformObjectToHClip(v.positionOS);
                return o;
            }
           half4 frag(Varyings i) : SV_TARGET 
            {    
                //进行纹理采样 SAMPLE_TEXTURE2D(纹理名，采样器名，uv)
                half4 mainTex = SAMPLE_TEXTURE2D(_BaseMap,sampler_BaseMap,i.uv);
                half4 c = mainTex * _AddColor ;
                return c;
            }
            ENDHLSL
        }
    }


}
