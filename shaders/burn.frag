#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uProgress;
uniform float uMode; // 0.0 = Mask (вырезание), 1.0 = Fire (рисование огня)

out vec4 fragColor;

float hash(vec2 p) {
    p = fract(p * vec2(123.34, 456.21));
    p += dot(p, p + 45.32);
    return fract(p.x * p.y);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * (3.0 - 2.0 * f);
    return mix(mix(hash(i + vec2(0.0, 0.0)), hash(i + vec2(1.0, 0.0)), u.x),
               mix(hash(i + vec2(0.0, 1.0)), hash(i + vec2(1.0, 1.0)), u.x), u.y);
}

float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    for (int i = 0; i < 4; i++) {
        value += amplitude * noise(p);
        p *= 2.0;
        amplitude *= 0.5;
    }
    return value;
}

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize;
    float noiseVal = fbm(uv * 6.0);

    // Увеличили коэффициент (1.3), чтобы в конце карта гарантированно исчезала
    float threshold = uProgress * 1.3 - 0.1;
    float edgeWidth = 0.06;

    if (noiseVal < threshold) {
        // Зона сгорания: всегда полностью прозрачная
        fragColor = vec4(0.0);
    } else {
        // Зона существования карты
        
        // 1. Режим МАСКИ (вырезаем карту)
        if (uMode < 0.5) {
            // Возвращаем непрозрачный цвет.
            // BlendMode.dstIn обрежет карту там, где здесь прозрачно (выше),
            // и оставит там, где здесь непрозрачно (тут).
            fragColor = vec4(1.0, 1.0, 1.0, 1.0);
        } 
        // 2. Режим ОГНЯ (рисуем пламя)
        else {
            float edgeFactor = smoothstep(threshold, threshold + edgeWidth, noiseVal);
            
            // Если мы далеко от края сгорания (в глубине карты) - огня нет
            if (edgeFactor >= 1.0) {
                fragColor = vec4(0.0);
            } else {
                // Мы на краю - рисуем огонь
                float fireIntensity = 1.0 - edgeFactor;
                vec3 fireColor = mix(vec3(1.0, 0.2, 0.0), vec3(1.0, 0.9, 0.5), fireIntensity);
                
                // Прозрачность огня зависит от интенсивности
                fragColor = vec4(fireColor, fireIntensity);
            }
        }
    }
}