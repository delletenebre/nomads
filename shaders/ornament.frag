#version 460 core
precision mediump float;

// Входящие данные (порядок важен!)
uniform vec2 uSize;       // Индекс 0
uniform float uProgress;  // Индекс 1
uniform sampler2D uTexture; // Индекс 2 (в коде не задается setFloat, Flutter сам биндит текстуру)

// Выходной цвет
out vec4 fragColor;

// Функция для создания узора (Шырдак / Рог барана)
float getKyrgyzPattern(vec2 uv) {
    // Масштабируем UV для повторения узора (5 раз по горизонтали)
    vec2 st = uv * 5.0;
    vec2 grid = fract(st) - 0.5;
    
    // Полярные координаты в ячейке
    float r = length(grid);
    float a = atan(grid.y, grid.x);
    
    // Формула спирали (упрощенная имитация рога)
    float horn = sin(a * 2.0 + r * 5.0);
    
    // Смешиваем круг и спираль для получения орнамента
    return smoothstep(0.2, 0.3, r + horn * 0.1);
}

void main() {
    // Нормализуем координаты пикселя (от 0 до 1)
    vec2 uv = gl_FragCoord.xy / uSize;
    
    // Исходный цвет пикселя карты
    vec4 color = texture(uTexture, uv);
    
    // Получаем значение узора в этой точке
    float pattern = getKyrgyzPattern(uv);
    
    // Добавляем градиент, чтобы карта исчезала снизу вверх, но по узору
    // (1.0 - uv.y) инвертирует Y, так как в GLSL Y=0 снизу (обычно)
    float maskBase = pattern + (1.0 - uv.y) * 0.8;
    
    // Порог исчезновения (умножаем прогресс, чтобы покрыть весь диапазон)
    float threshold = uProgress * 2.5;
    
    // 1. Видимость (0 = исчезло, 1 = видно)
    float visibility = 1.0 - step(threshold, maskBase);
    
    // 2. Огненная кайма (Edge)
    float edgeWidth = 0.15;
    float edgeZone = 1.0 - step(threshold + edgeWidth, maskBase);
    float glowMask = edgeZone - visibility;
    
    // Цвета каймы (Золото/Огонь)
    vec4 glowColor = vec4(1.0, 0.8, 0.2, 1.0);
    vec4 burnColor = vec4(0.8, 0.2, 0.0, 1.0);
    vec4 finalGlow = mix(burnColor, glowColor, 0.5);
    
    // Смешиваем цвет карты с цветом каймы
    vec4 finalColor = mix(color, finalGlow, glowMask);
    
    // Применяем прозрачность (альфа-канал)
    // visibility + glowMask = общая видимая область
    fragColor = finalColor * (visibility + glowMask) * color.a;
}