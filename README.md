# SectorsReturn

Aplicación para Assetto Corsa pensada para practicar sectores de un circuito y repetirlos con rapidez. Combina la app original de tiempos por sector con un sistema de puntos de retorno que guarda el estado del auto para cada sector y te teletransporta al instante para volver a intentarlo.

## Cómo funciona
- Detecta automáticamente los sectores del circuito y muestra tiempos en vivo, objetivo y mejores parciales guardados.
- Divide cada sector en microsectores para seguir el ritmo dentro de cada parcial.
- Permite guardar un **punto de retorno** por sector (se almacena el estado completo del auto). Cada guardado es específico para el auto y el trazado/layout actual.
- Incluye un modo de retorno dinámico (Inspirado en DynamicReturn) que registra un tramo entre dos puntos y permite relanzarlo manteniendo la velocidad y posición originales.

## Uso rápido
1. Copia la carpeta `SectorsReturn` en `Assetto Corsa/apps/lua/` y activa la app en Content Manager o en el menú de apps de Assetto Corsa.
2. Abre la ventana de la app en pista. Verás columnas por sector con sus tiempos y barras de microsectores.
3. Asigna teclas a los botones **Return** y **Save Return** en la ventana de settings de la app (icono de engranaje) o usa los botones de la UI:
   - **Guardar retorno (icono de disquete)**: desde el sector previo guarda el estado para el sector siguiente.
   - **Return (icono de reinicio)**: si hay un estado guardado, teletransporta al punto de retorno del sector elegido.
4. Los estados y tiempos se guardan en `Documentos/Assetto Corsa/apps/SectorsReturn/` para cada combinación auto + circuito + layout, de modo que persisten entre sesiones.

## Cuándo usarla
- Practicar una sección concreta sin dar vueltas completas.
- Comparar tus parciales contra mejores tiempos u objetivos sector por sector.
- Preparar salidas repetibles en tandas online y offline sin depender del pitlane.
