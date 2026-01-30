#version 460 core

#include <flutter/runtime_effect.glsl>

uniform vec2 uSize;
uniform float uTime;
uniform float uOpacity; // <--- НОВЫЙ ПАРАМЕТР (0.0 = прозрачно, 1.0 = видно)

out vec4 fragColor;

// ... (Оставляем функции hash22, noise, fbm БЕЗ ИЗМЕНЕНИЙ) ...
// Скопируйте их из вашего текущего файла
vec2 hash22(vec2 p) {
    p = vec2(dot(p, vec2(127.1, 311.7)),
             dot(p, vec2(269.5, 183.3)));
    return -1.0 + 2.0 * fract(sin(p) * 43758.5453123);
}

float noise(vec2 p) {
    vec2 i = floor(p);
    vec2 f = fract(p);
    vec2 u = f * f * f * (f * (f * 6.0 - 15.0) + 10.0);
    return mix(mix(dot(hash22(i + vec2(0.0, 0.0)), f - vec2(0.0, 0.0)),
                   dot(hash22(i + vec2(1.0, 0.0)), f - vec2(1.0, 0.0)), u.x),
               mix(dot(hash22(i + vec2(0.0, 1.0)), f - vec2(0.0, 1.0)),
                   dot(hash22(i + vec2(1.0, 1.0)), f - vec2(1.0, 1.0)), u.x), u.y);
}

float fbm(vec2 p) {
    float value = 0.0;
    float amplitude = 0.5;
    float frequency = 2.0;
    mat2 rot = mat2(cos(0.5), sin(0.5), -sin(0.5), cos(0.50));
    for (int i = 0; i < 4; i++) {
        value += amplitude * noise(p * frequency);
        p = rot * p;
        frequency *= 2.0;
        amplitude *= 0.5;
    }
    return value * 0.5 + 0.5;
}
// ...

void main() {
    vec2 uv = FlutterFragCoord().xy / uSize.y;
    float t = uTime * 0.05;

    // Слой 1
    vec2 drift1 = vec2(t * 0.3, t * 0.1);
    float layer1 = fbm(uv * 1.5 + drift1);

    // Слой 2
    vec2 drift2 = vec2(t * 0.5, -t * 0.2);
    float layer2 = fbm(uv * 3.0 + drift2 + vec2(5.2, 1.3));

    float finalNoise = (layer1 + layer2) * 0.5;
    float density = smoothstep(0.2, 0.8, finalNoise);

    vec3 cloudShadow = vec3(0.88, 0.90, 0.92);
    vec3 cloudLight = vec3(1.0, 1.0, 1.0);
    vec3 finalColor = mix(cloudShadow, cloudLight, density);

    // Виньетка
    vec2 vUv = FlutterFragCoord().xy / uSize.xy;
    float vignette = vUv.x * vUv.y * (1.0 - vUv.x) * (1.0 - vUv.y);
    vignette = pow(vignette, 0.25);

    vignette = 1.0;

    float globalAlpha = 0.8;

    // Итоговая альфа с учетом uOpacity
    // uOpacity приходит из Flutter (анимация растворения)
    float finalAlpha = density * globalAlpha * vignette * uOpacity;

    fragColor = vec4(finalColor * finalAlpha, finalAlpha);
}