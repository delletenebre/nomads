#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;      // Индексы float: 0, 1
uniform float uProgress; // Индекс float: 2
uniform float uMode;     // Индекс float: 3
uniform sampler2D uPattern; // Индекс sampler: 0

out vec4 fragColor;

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;
    
    // ВАЖНО: Мы должны использовать текстуру, чтобы компилятор не удалил её
    vec4 noise = texture(uPattern, uv);
    float value = noise.r;
    
    if (uMode < 0.5) {
        // Режим МАСКИ (вырезаем дырки)
        if (value < uProgress) {
            fragColor = vec4(1.0, 1.0, 1.0, 1.0); // Дырка (для dstOut)
        } else {
            fragColor = vec4(0.0, 0.0, 0.0, 0.0); // Нет дырки
        }
    } else {
        // Режим КАЙМЫ (рисуем огонь)
        float edgeWidth = 0.05; // Тонкая линия
        if (value >= uProgress && value < uProgress + edgeWidth) {
            float intensity = 1.0 - (value - uProgress) / edgeWidth;
            vec3 fireColor = vec3(1.0, 0.7, 0.2); 
            fragColor = vec4(fireColor * intensity, intensity);
        } else {
            fragColor = vec4(0.0);
        }
    }
}