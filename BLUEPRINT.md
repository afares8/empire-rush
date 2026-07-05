# Trade Empire Rush — Blueprint del juego

> **Tagline:** "Empieza con nada. Construye un imperio."
> **Stack:** Godot 4.x (engine) → export HTML5 (MVP web) → Android → iOS.
> **Género:** Idle tycoon / management runner isométrico casual.
> **Público:** Todas las edades. Aspiracional, no manipulativo.

---

## 1. Concepto

Trade Empire Rush es un juego donde el jugador empieza con un pequeño
puesto de venta y construye un imperio comercial mundial. El jugador
camina por un mapa isométrico, recoge productos, atiende clientes,
cobra dinero físico visible, desbloquea zonas, contrata empleados,
abre nuevos negocios, crea fábricas, compra edificios, expande
ciudades y compite en rankings globales.

**Promesa:** "El juego que sí se juega como el anuncio: cobras,
recoges dinero, expandes y construyes tu imperio en tiempo real."

## 2. Estilo visual

- 3D low-poly limpio (o 2D isométrico estilizado para el MVP web).
- Colores vivos, personajes caricaturescos.
- Cámara isométrica desde arriba.
- UI grande y clara, apta para dedo en mobile.
- Sin violencia gráfica, sin contenido adulto.
- Sensación de "juguete vivo".

Referencia: anuncios tipo Gardenscapes/Tycoon — pero el gameplay real
cumple lo que muestra el anuncio.

## 3. Fantasía central

"Ser alguien que empezó pequeño y terminó controlando un imperio."

Progresión emocional:
vendedor pequeño → dueño de tienda → dueño de cadena → fabricante →
importador → magnate → dueño de conglomerado mundial.

## 4. Loop principal (5–10 segundos por ciclo)

1. Jugador recoge productos.
2. Lleva productos a estante/mostrador.
3. Llegan clientes.
4. Clientes compran.
5. Jugador cobra.
6. Dinero aparece físicamente.
7. Jugador recoge el dinero.
8. Camina a zona bloqueada.
9. Invierte → desbloquea mejora/empleado/negocio/zona.
10. Repite con más automatización y expansión.

**Loop resumido:** Recoger → vender → cobrar → invertir → expandir →
automatizar → desbloquear → repetir.

## 5. Mapa inicial (Nivel 1: Puesto callejero)

- Una mesa pequeña.
- Un producto básico (camisetas, perfumes pequeños, snacks o flores).
- Pocos clientes.
- Una caja manual.
- Dinero en el piso.
- Un área bloqueada que cuesta poco desbloquear.

**Primer minuto (sin tutorial pesado):**
- 0–10s: "Llena tu primer estante." Recoger producto, colocarlo.
- 10–20s: Llega primer cliente, compra, aparece dinero. "Recoge tu dinero."
- 20–35s: Recoge dinero, ve zona bloqueada. "Invierte para crecer."
- 35–60s: Llegan más clientes, caos controlado, aparece empleado
  bloqueado. "Contrata ayuda."

El jugador debe sentir progreso antes de los 30 segundos.

## 6. Progresión grande (etapas de imperio)

| Etapa | Nombre | Negocios | Mecánicas nuevas |
|---|---|---|---|
| 1 | Sobreviviente | puesto callejero, mesa de ropa, carrito de snacks, mini perfumes, accesorios | aprender el loop |
| 2 | Comerciante local | tienda de ropa, perfumes, mini market, cosméticos, zapatos, electrónicos pequeños | estantes, caja, paciencia, reposición, empleados básicos |
| 3 | Dueño de cadena | ropa, perfumes, farmacia, supermercado, electrónica, juguetes, celulares, belleza | varias áreas, gerentes, automatizar cobros, mejorar empleados, abrir cajas, manejar filas |
| 4 | Fabricante | taller de ropa, fábrica de perfumes, laboratorio cosmético, fábrica de snacks, ensambladora, imprenta, fábrica de juguetes | materia prima, producción, máquinas, tiempos, capacidad, transporte interno, almacén |
| 5 | Importador/Exportador | bodega, puerto, contenedores, camiones, importación, exportación, centro de distribución | llegada de contenedores, rutas, pedidos grandes, almacén central, desbloqueo de países, productos exóticos, eventos de demanda |
| 6 | Magnate de ciudad | locales, centros comerciales, edificios, bodegas, fábricas, farmacias, supermercados, tiendas premium | mapa de ciudad, zonas comerciales, reputación, turismo, clientes VIP, eventos masivos, competencia rivales |
| 7 | Conglomerado nacional | sucursales en varias ciudades | gerentes regionales, logística inter-ciudad, rankings nacionales, contratos grandes, licencias de marcas |
| 8 | Imperio mundial | Panamá/Zona Libre, Miami, Dubai, Tokio, París, Estambul, Singapur, NY, São Paulo, CDMX | cada mundo con estética y productos especiales |
| 9 | El conglomerado | holding "Empire Group" con retail, moda, belleza, farmacia, alimentos, electrónica, logística, fábricas, bienes raíces, marketing, lujo, tecnología | valor total, activos, ciudades, fábricas, empleados, marcas, reputación, ranking global |

### Tope del MVP (versión 0.1)

- 1 ciudad.
- 3 negocios (ropa, perfume, mini market).
- 1 fábrica pequeña / taller.
- 1 bodega.
- 30 zonas desbloqueables.
- 20 empleados.
- 50 upgrades.

### Tope versión 1.0

- 3 ciudades.
- 8 tipos de negocio.
- 3 fábricas.
- 1 puerto.
- Ranking global.
- Eventos semanales.
- Clanes/conglomerados.

### Tope versión grande

- 10 países.
- 20 tipos de negocios.
- 100+ edificios.
- 500+ upgrades.
- Ligas globales, temporadas, fusiones, franquicias, imperios de jugadores.

### Endgame

Ser el conglomerado #1 del mundo. Ranking global por:
- Mayor valor de imperio.
- Más ingresos por minuto.
- Más ciudades dominadas.
- Más fábricas activas.
- Más clientes atendidos.
- Más expansión internacional.
- Mejor reputación.
- Más eventos ganados.

## 7. Tipos de negocios

| Negocio | Mecánica | Upgrades |
|---|---|---|
| Ropa | recoger ropa, llenar racks, clientes se prueban, caja, taller de costura | camisetas, jeans, zapatos, vestidos, ropa premium, marca propia |
| Perfumería | llenar vitrinas, clientes piden aromas, premium da más dinero, fábrica de perfumes | fragancias básicas/premium, empaque de lujo, boutique, línea propia |
| Farmacia | cuidado personal, vitaminas ficticias, higiene, belleza, atención rápida (NO consejos médicos reales) | mostrador, estanterías, wellness ficticio, caja rápida, delivery |
| Mini market | snacks, bebidas ficticias, frutas, productos diarios, clientes constantes | neveras, cajas rápidas, autoservicio, supermercado |
| Electrónica | celulares, audífonos, consolas ficticias, tablets, gadgets | vitrina segura, técnico, reparación, ensambladora |
| Fábrica | materia prima → máquina → caja → camión | capacidad, velocidad, máquinas, almacén |
| Logística | bodega, cajas, pallets, camiones, rutas, contenedores | capacidad, rutas, descarga, distribución |
| Mall / Centro comercial | abrir tiendas dentro, atraer clientes, decoración, reputación, renta | decoración, locales, eventos, marketing |

## 8. Actividades

**Principales:** recoger dinero, reponer productos, atender VIPs,
abrir cajas, desbloquear zonas, mejorar empleados, construir áreas,
fabricar, mover cajas, cargar camiones, recibir contenedores, lanzar
promociones, decorar, resolver eventos.

**Mini eventos:** hora pico, cliente VIP, influencer, camión especial,
Black Friday, inspección sorpresa, producto viral, competencia bajó
precios, falta mercancía, fila gigante, apertura nueva tienda, pedido
corporativo.

**Eventos de 60 segundos:**
- Rush Hour: atiende 50 clientes en 1 min.
- VIP Order: completa un pedido grande rápido.
- Mega Delivery: descarga un camión antes de que se vaya.
- Flash Sale: vende todo antes del tiempo.
- Factory Boost: produce el doble por 60s.
- Clean Store: ordena la tienda para ganar reputación.

## 9. Competencia entre jugadores (aspiracional, no combate)

**Empire Value** = f(dinero total, negocios abiertos, ingresos/min,
empleados, ciudades, reputación, fábricas, logística, propiedades).

**Ligas semanales** (30–50 jugadores similares):
Rookie Seller → Local Boss → Store Owner → Chain Builder → City
Tycoon → National Magnate → Global Empire → World Conglomerate →
Legendary Founder.

**Perfil público del imperio:**
```
Ahmed's Empire Group
Valor: $4.2B
Ciudades: 7
Negocios: 42
Fábricas: 5
Ranking: #128 mundial
Especialidad: Perfumes + Logística
```

## 10. Sistema de estatus (títulos)

vendedor principiante → comerciante → dueño → empresario →
inversionista → magnate → billonario → fundador de conglomerado →
leyenda mundial.

Cada título desbloquea: ropa del personaje, oficina, vehículos
visuales, nuevos negocios, países, empleados, efectos visuales.

## 11. Personaje principal

Personalizable: hombre/mujer, ropa casual/elegante/traje, uniforme,
accesorios, peinados, colores, mascotas, vehículos pequeños. El
personaje evoluciona visualmente con el progreso.

## 12. Empleados

Tipos: cajero, reponedor, vendedor, gerente, guardia amigable,
conductor, operador de fábrica, encargado de bodega, influencer
marketing, gerente regional.

Cada empleado: velocidad, capacidad, rareza (común/raro/épico/
legendario), skin, habilidad especial.

Ejemplos:
- **Carlos el Cajero Rápido** (raro): +25% velocidad de cobro.
- **Maya Marketing** (épico): atrae 10% más clientes.
- **Omar Logística** (legendario): camiones cargan 20% más rápido.

## 13. Economía

- **Cash** (moneda principal): se gana vendiendo. Desbloquear zonas,
  upgrades, empleados básicos, mejorar tiendas.
- **Gems** (premium): se gana poco a poco o se compra. Skins, cofres,
  aceleradores, empleados especiales, decoraciones premium.
- **Empire Value**: no se gasta. Número de estatus.
- **Reputación**: afecta clientes, VIPs, rankings, acceso a negocios
  premium. Se gana atendiendo rápido, manteniendo stock, completando
  eventos.

## 14. Monetización (justa, no abusiva)

**Ads recompensados:** duplicar ganancias 5 min, cliente VIP,
acelerar construcción, camión especial, abrir cofre, empleado
temporal, revivir evento, clientes VIP, auto-recoger 2 min, boost
fábrica.

**Compras in-app:**
- Remove Ads ($2.99–$9.99, +10% cash permanente).
- Gems (100/500/1200/3000/7000).
- Starter Pack ($1.99–$4.99, después de entender el juego).
- Empleados premium (cajero rápido, gerente experto, reponedor veloz,
  conductor premium, influencer, operador, asesor financiero, gerente
  regional).
- Skins (personaje, tienda, caja, empleados, vehículos, fábricas,
  oficinas, logo, mascotas, efectos de dinero).
- Pase de temporada ($4.99–$9.99, 30 días, misiones + skins +
  empleados + decoraciones + boosts + cofres + título + trofeo).
- Cofres (común/raro/épico/empresarial/temporada, con probabilidades
  visibles).
- Suscripción VIP opcional ($4.99–$9.99/mes).

**Principio:** el jugador gratis se divierte. El que paga avanza más
rápido, se ve más premium y gana más estatus. NUNCA "si no pago no
puedo jugar".

## 15. Seguridad (todas las edades)

- No apuestas.
- No loot boxes agresivas para menores.
- No chat libre al inicio.
- No violencia gráfica, no contenido adulto.
- No presión excesiva de compra.
- Control parental si hay funciones sociales.
- Privacidad fuerte.
- Compras protegidas por Apple/Google.

## 16. Social sin riesgo (al inicio)

Social indirecto: ranking, ver perfil de imperio, visitar imperio,
dar like, enviar regalo diario, competir en liga, eventos globales.

Mensajes predefinidos: "Buen imperio", "Te envié energía", "Vamos
por el top", "Gran expansión", "Excelente expansión", "Nos vemos en
la liga".

Más adelante: clanes/conglomerados, chat con mensajes predefinidos,
cooperación, torneos.

## 17. IA dentro del juego (versión 2.0+, no MVP)

- Misiones diarias generadas.
- Eventos dinámicos.
- Nombres de clientes/negocios/ciudades/productos.
- Personalización: "Quiero que mi tienda se vea lujosa y dorada" →
  la IA sugiere decoración.

## 18. MVP recomendado

**Contenido mínimo:**
- 1 mapa isométrico pequeño.
- Zonas: puesto inicial, caja, estante de ropa, estante de perfumes,
  mini almacén, zona de empleados, zona de expansión, pequeña
  fábrica/taller.
- Mecánicas: mover personaje, recoger producto, llenar estante,
  cliente compra, cobrar, dinero visible, recoger dinero, desbloquear
  zona, contratar empleado, upgrade de velocidad/capacidad, ads
  recompensados.
- Contenido: 3 productos, 3 tipos de clientes, 3 empleados, 10 zonas
  desbloqueables, 20 upgrades, 3 eventos rápidos, 1 ranking simple.
- Tiempo ideal: 15–30 min sin aburrirse.

## 19. Versión 1.0

- 3 negocios (ropa, perfume, mini market).
- 1 taller/fábrica.
- 1 bodega.
- 1 sistema de camión.
- 30 zonas desbloqueables.
- 10 empleados.
- 50 upgrades.
- Ranking semanal.
- Pase de temporada.
- Ads recompensados.
- Compras básicas.
- Guardado en la nube.
- iOS + Android.

## 20. Versión 2.0

Farmacia, electrónica, fábrica avanzada, puerto, contenedores,
segunda ciudad, clanes, visitar imperios, eventos globales,
empleados raros, skins premium, IA para eventos diarios.

## 21. Versión 3.0

Países, mall, bienes raíces, franquicias, ranking mundial avanzado,
ligas, temporadas por país, conglomerados, colaboración,
personalización avanzada de marca.

## 22. Métricas (desde el día 1)

- Tutorial completion > 80%.
- Primera sesión > 8 min.
- Retención D1 > 35%.
- Retención D7 > 10%.
- Ads recompensados ≥ 3/usuario activo/día.
- Nivel donde abandonan.
- Zonas más desbloqueadas.
- Eventos más jugados.
- Empleados más usados.

## 23. Pantallas principales

- **Juego:** mapa, personaje, clientes, dinero, zonas bloqueadas,
  botones mínimos, indicadores de misión.
- **Upgrades:** velocidad, capacidad, empleados, caja, estantes,
  producción.
- **Imperio:** valor total, negocios, empleados, ciudades,
  reputación, ranking.
- **Empleados:** contratar, mejorar, asignar, skins.
- **Ranking:** liga semanal, ranking mundial, amigos, premios.
- **Tienda:** gems, remove ads, skins, pase, packs.

## 24. Cómo debe sentirse

- Rápido, satisfactorio, aspiracional, fácil, visual, progresivo.
- Lleno de recompensas pequeñas y metas grandes.
- Sin tutorial aburrido.
- Cada 10s pasa algo.
- Cada 1 min se desbloquea algo.
- Cada 5 min cambia visualmente el negocio.
- Cada 15 min aparece una meta grande.
- Cada día hay una razón para volver.

## 25. Diferenciador

Pasas de atender tú mismo una tienda pequeña a controlar un
conglomerado mundial con fábricas, logística, marcas, países y
rankings. La mayoría de juegos se quedan en una tienda. Este escala:
tienda → cadena → fábrica → bodega → puerto → ciudad → país →
imperio mundial.

## 26. Comunidad (Empire Club)

Aspiracional, no tóxica. "Todos empezamos desde cero. ¿Quién
construye el imperio más grande?"

- Perfil público de imperio.
- Tabla global (Empire Value + 8 rankings secundarios).
- Ligas semanales.
- Conglomerados/clanes (versión 2.0+).
- Visitas a imperios (like, regalo, inspirarse, seguir).
- Eventos globales (Global Trade Fair, Black Friday Rush, Factory
  Madness, Luxury Week, Panama Trade Zone, Dubai Luxury Expo, World
  Empire Cup).
- Sin chat libre al inicio.

## 27. Retención diaria

- **Daily Login** creciente (día 7 = cofre épico).
- **Daily Missions** (atiende 100 clientes, recoge 50 cash, mejora 3
  estantes, completa 1 evento, visita 3 imperios, envía 5 regalos).
- **Weekly Goals** (subir de liga, desbloquear negocio, completar
  pase, ganar evento, mejorar Empire Value).
- **Offline Earnings:** "Tu imperio generó $240,000 mientras estabas
  fuera." Reclamar / ver ad para duplicar / boost para triplicar.

## 28. Sistema de fatiga

Señales: deja de mejorar, repite misma zona, no ve ads, no entra
varios días, falla eventos, no desbloquea nada.

Soluciones automáticas: evento especial, recompensa de regreso,
misión nueva, meta cercana visible, boost gratis, ranking de
similares, "estás a $5,000 de tu primera fábrica".

## 29. Frase clave

> "El jugador no paga solo por avanzar; paga por sentirse más magnate."
> "Empieza con una mesa. Termina con un conglomerado mundial."
