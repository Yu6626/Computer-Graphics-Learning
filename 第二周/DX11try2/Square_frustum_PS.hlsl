#include "Square_frustum.hlsli"



// 像素着色器
float4 PS(VertexOut pIn) : SV_Target
{   // 允许修改颜色
    return g_UseCustomColor ? g_Color : pIn.color;
}
