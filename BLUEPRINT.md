# Trade Empire Rush — Blueprint del juego (COMPLETO)

> **Tagline:** "Empieza con nada. Construye un imperio."
> **Stack:** Godot 4.x (engine) → export HTML5 (MVP web) → Android → iOS.
> **Género:** Idle tycoon / management runner isométrico casual.
> **Público:** Todas las edades. Aspiracional, no manipulativo.
>
> **Este blueprint es la fuente de verdad del DISEÑO.** Contiene las
> 41 secciones del blueprint original, literales. La AI del overnight
> lo lee completo en cada iteración. Las secciones marcadas
> **[MVP]** son críticas para el MVP; las marcadas **[1.0+]** son
> para versiones futuras pero la AI debe conocerlas para no tomar
> decisiones que las bloqueen.

---

## 1. Concepto principal  [MVP]

Trade Empire Rush es un juego mobile para iOS y Android donde el
jugador empieza con un pequeño puesto de venta y poco a poco
construye un imperio comercial mundial.

El jugador camina por un mapa isométrico, recoge productos, atiende
clientes, cobra dinero, desbloquea zonas, contrata empleados, abre
nuevos negocios, crea fábricas, compra edificios, expande ciudades y
compite contra otros jugadores para ver quién construye el
conglomerado más grande.

La promesa del juego es:

"El juego que sí se juega como el anuncio: cobras, recoges dinero,
expandes y construyes tu imperio en tiempo real."

## 2. Referencia visual y estilo  [MVP]

El estilo debe parecerse a esos anuncios de juegos tipo
Gardenscapes/Tycoon donde ves:

- cámara isométrica desde arriba
- personaje caminando por el mapa
- clientes haciendo fila
- zonas bloqueadas con precio
- dinero visible
- construcción instantánea
- colores brillantes
- animaciones satisfactorias
- progreso constante

Pero el juego real debe cumplir lo que muestra el anuncio.

**Estilo gráfico:**
- 3D low-poly limpio (o 2D isométrico estilizado para el MVP web)
- colores vivos
- personajes caricaturescos
- mapas claros
- UI grande y entendible
- apto para todas las edades
- sin violencia gráfica
- sin contenido adulto
- sensación de "juguete vivo"

Debe sentirse como una mezcla entre:

- idle tycoon
- supermarket simulator casual
- business empire
- city builder ligero
- management runner

## 3. Fantasía central del jugador  [MVP]

La fantasía no es solo "ganar dinero".

La fantasía es:

"Ser alguien que empezó pequeño y terminó controlando un imperio."

El jugador debe sentir que pasó de:

vendedor pequeño → dueño de tienda → dueño de cadena → fabricante →
importador → magnate → dueño de conglomerado mundial.

Ese es el sueño aspiracional.

No se vende como "trabajo aburrido". Se vende como:

crecimiento, poder, expansión, estatus, inteligencia comercial y
progreso visual.

## 4. Loop principal del juego  [MVP]

El loop base debe ser extremadamente simple:

1. El jugador recoge productos.
2. Lleva productos a una mesa, estante o mostrador.
3. Llegan clientes.
4. Los clientes compran.
5. El jugador cobra.
6. El dinero aparece físicamente.
7. El jugador recoge el dinero.
8. Camina hacia una zona bloqueada.
9. Invierte el dinero.
10. Se desbloquea una mejora, empleado, negocio o zona nueva.

**Loop resumido:**

Recoger → vender → cobrar → invertir → expandir → automatizar →
desbloquear → repetir.

Este loop debe sentirse bien cada 5 a 10 segundos.

## 5. El mapa inicial  [MVP]

El juego empieza con un mapa pequeño.

**Nivel 1: Puesto callejero**

El jugador tiene:

- una mesa pequeña
- un producto básico
- pocos clientes
- una caja manual
- dinero en el piso
- un área bloqueada que cuesta poco desbloquear

Ejemplo:

Producto inicial: camisetas, perfumes pequeños, snacks o flores.

El primer minuto debe enseñar todo sin tutorial pesado:

- "Camina aquí"
- "Recoge producto"
- "Llévalo al mostrador"
- "Cobra"
- "Recoge dinero"
- "Desbloquea nueva zona"

El jugador debe sentir progreso antes de los primeros 30 segundos.

## 6. Progresión grande del juego  [MVP estructura, 1.0+ contenido]

Aquí está la parte importante: hasta dónde llega el juego.

El juego debe tener una progresión por etapas de imperio.

**Etapa 1: Sobreviviente**

El jugador empieza vendiendo en pequeño.

Negocios:

- puesto callejero
- mesa de ropa
- carrito de snacks
- mini venta de perfumes
- puesto de accesorios

Objetivo: aprender el loop.

**Etapa 2: Comerciante local**

El jugador abre su primera tienda.

Negocios:

- tienda de ropa
- tienda de perfumes
- mini market
- tienda de cosméticos
- tienda de zapatos
- tienda de electrónicos pequeños

Nuevas mecánicas:

- estantes
- caja registradora
- clientes con paciencia
- reposición de mercancía
- empleados básicos

**Etapa 3: Dueño de cadena**

El jugador ya no tiene una sola tienda. Tiene varias secciones o
sucursales.

Negocios:

- ropa
- perfumes
- farmacia
- supermercado
- electrónica
- tienda de juguetes
- tienda de celulares
- tienda de belleza

Nuevas mecánicas:

- administrar varias áreas
- contratar gerentes
- automatizar cobros
- mejorar velocidad de empleados
- abrir cajas adicionales
- manejar filas

**Etapa 4: Fabricante**

El jugador deja de solo comprar y vender. Ahora produce.

Negocios nuevos:

- taller de ropa
- fábrica de perfumes
- laboratorio cosmético
- fábrica de snacks
- ensambladora de electrónicos
- imprenta de empaques
- fábrica de juguetes

Nuevas mecánicas:

- materia prima
- producción
- máquinas
- tiempos de fabricación
- mejora de capacidad
- transporte interno
- almacén

Ejemplo:

Para vender perfumes, ahora necesitas:

- frascos
- líquido
- cajas
- etiquetas
- empaquetado
- distribución a tienda

Esto agrega profundidad sin hacerlo complicado.

**Etapa 5: Importador / Exportador**

El jugador ya maneja comercio internacional.

Negocios:

- bodega
- puerto
- contenedores
- camiones
- importación de productos
- exportación a otras ciudades
- centro de distribución

Nuevas mecánicas:

- llegada de contenedores
- rutas de camiones
- pedidos grandes
- almacén central
- desbloqueo de países
- productos exóticos
- eventos de demanda

Ejemplo:

"Llegó un contenedor de electrónicos. Descárgalo, llévalo a bodega y
distribúyelo a tus tiendas."

**Etapa 6: Magnate de ciudad**

El jugador ya domina una ciudad.

Puede comprar:

- locales
- centros comerciales
- edificios
- bodegas
- fábricas
- farmacias
- supermercados
- tiendas premium

Nuevas mecánicas:

- mapa de ciudad
- zonas comerciales
- reputación
- turismo
- clientes VIP
- eventos masivos
- competencia contra negocios rivales

**Etapa 7: Conglomerado nacional**

El jugador abre operaciones en varias ciudades.

Ciudades ejemplo:

- Ciudad inicial
- zona comercial
- puerto
- ciudad turística
- ciudad industrial
- capital

Nuevas mecánicas:

- sucursales
- gerentes regionales
- logística entre ciudades
- rankings nacionales
- contratos grandes
- licencias de marcas

**Etapa 8: Imperio mundial**

El jugador expande a países.

Mundos posibles:

- Panamá / Zona Libre
- Miami
- Dubai
- Tokio
- París
- Estambul
- Singapur
- Nueva York
- São Paulo
- Ciudad de México

Cada mundo tiene estética y productos especiales.

Ejemplo:

- Dubai: lujo, perfumes premium, joyería.
- Tokio: tecnología, gadgets, clientes rápidos.
- Miami: moda, sneakers, lifestyle.
- París: perfumes, belleza, boutique.
- Panamá: importación, bodega, Zona Libre.
- Estambul: textiles, bazar, comercio rápido.

**Etapa 9: El conglomerado**

Aquí está el "endgame".

El jugador ya no solo tiene tiendas. Tiene grupos empresariales.

Ramas del conglomerado:

- retail
- moda
- belleza
- farmacia
- alimentos
- electrónica
- logística
- fábricas
- bienes raíces
- marketing
- lujo
- tecnología

El jugador puede formar su holding:

Empire Group

Y ver el valor total:

- dinero generado
- activos
- ciudades dominadas
- fábricas
- empleados
- marcas
- reputación mundial
- ranking global

## 7. La pregunta clave: ¿cuál es el tope?  [MVP define tope MVP]

El juego no debe tener un "final" cerrado. Debe tener capas infinitas.

**Tope inicial del MVP**

Para la primera versión:

- 1 ciudad
- 3 negocios
- 1 fábrica pequeña
- 1 bodega
- 30 zonas desbloqueables
- 20 empleados
- 50 upgrades

**Tope versión 1.0**

- 3 ciudades
- 8 tipos de negocio
- 3 fábricas
- 1 puerto
- ranking global
- eventos semanales
- clanes/conglomerados

**Tope versión grande**

- 10 países
- 20 tipos de negocios
- 100+ edificios
- 500+ upgrades
- ligas globales
- temporadas
- fusiones
- franquicias
- imperios de jugadores

**Endgame**

El máximo no es "terminar".

El máximo es:

ser el conglomerado número 1 del mundo.

Ranking global:

- Mayor valor de imperio
- Más ingresos por minuto
- Más ciudades dominadas
- Más fábricas activas
- Más clientes atendidos
- Más expansión internacional
- Mejor reputación
- Más eventos ganados

## 8. Tipos de negocios  [MVP: 3 negocios, 1.0+: el resto]

El juego debe tener varios negocios para que no se sienta
repetitivo.

**Negocio 1: Ropa**  [MVP]

Mecánica:

- recoger ropa
- llenar racks
- clientes se prueban rápido
- caja
- taller de costura después

Upgrades:

- camisetas
- jeans
- zapatos
- vestidos
- ropa premium
- marca propia

**Negocio 2: Perfumería**  [MVP]

Mecánica:

- llenar vitrinas
- clientes piden aromas
- productos premium dan más dinero
- fábrica de perfumes más adelante

Upgrades:

- fragancias básicas
- fragancias premium
- empaque de lujo
- boutique
- línea propia

**Negocio 3: Farmacia**  [1.0+]

Mecánica segura y simple:

- vender productos de cuidado personal
- vitaminas ficticias/no médicas
- higiene
- belleza
- atención rápida

No debe entrar en consejos médicos reales. Es solo fantasía de
tienda.

Upgrades:

- mostrador
- estanterías
- productos wellness ficticios
- caja rápida
- delivery

**Negocio 4: Mini market**  [MVP]

Mecánica:

- snacks
- bebidas ficticias
- frutas
- productos diarios
- clientes constantes

Upgrades:

- neveras
- cajas rápidas
- autoservicio
- supermercado

**Negocio 5: Electrónica**  [1.0+]

Mecánica:

- celulares
- audífonos
- consolas ficticias
- tablets
- gadgets

Upgrades:

- vitrina segura
- técnico
- reparación
- ensambladora

**Negocio 6: Fábrica**  [MVP: 1 fábrica pequeña]

Mecánica:

- materias primas
- máquinas
- cajas
- productos terminados
- envío a tiendas

Debe ser simple visualmente:

Materia prima entra → máquina produce → caja sale → camión recoge.

**Negocio 7: Logística**  [1.0+]

Mecánica:

- bodega
- cajas
- pallets
- camiones
- rutas
- contenedores

Esto puede diferenciar mucho tu juego porque casi ningún juego casual
lo hace bien.

**Negocio 8: Mall / Centro comercial**  [2.0+]

El jugador puede comprar locales y rentarlos.

Mecánica:

- abrir tiendas dentro del mall
- atraer clientes
- mejorar decoración
- subir reputación
- cobrar renta

## 9. Actividades dentro del juego  [MVP: subset, 1.0+: todas]

Para que sea entretenido, no puede ser solo caminar y cobrar.

Debe tener actividades rápidas.

**Actividades principales**

- recoger dinero
- reponer productos
- atender clientes VIP
- abrir cajas
- desbloquear zonas
- mejorar empleados
- construir nuevas áreas
- fabricar productos
- mover cajas
- cargar camiones
- recibir contenedores
- lanzar promociones
- decorar tiendas
- resolver eventos

**Mini eventos**

- hora pico
- cliente VIP
- influencer llega
- camión especial
- Black Friday
- inspección sorpresa
- producto viral
- competencia bajó precios
- falta mercancía
- fila gigante
- apertura de nueva tienda
- pedido corporativo grande

**Eventos de 60 segundos**  [MVP: 3 eventos]

Estos son muy importantes para la adicción sana del juego.

Ejemplos:

- **Rush Hour**: atiende 50 clientes en 1 minuto.
- **VIP Order**: completa un pedido grande rápido.
- **Mega Delivery**: descarga un camión antes de que se vaya.
- **Flash Sale**: vende todo antes de que termine el tiempo.
- **Factory Boost**: produce el doble durante 60 segundos.
- **Clean Store**: ordena la tienda para ganar reputación.

## 10. Competencia entre jugadores  [MVP: ranking simple, 1.0+: ligas]

Esto es clave:

"Que todos quieran ser como ese hombre que tiene el conglomerado."

La competencia no debe ser pelea directa. Debe ser aspiracional.

**Ranking global**

Cada jugador tiene un Empire Value.

Empire Value se calcula con:

- dinero total
- negocios abiertos
- ingresos por minuto
- empleados
- ciudades desbloqueadas
- reputación
- fábricas
- logística
- propiedades

**Ligas**

Los jugadores suben por ligas:

- Rookie Seller
- Local Boss
- Store Owner
- Chain Builder
- City Tycoon
- National Magnate
- Global Empire
- World Conglomerate
- Legendary Founder

Cada semana el jugador compite con 30 a 50 jugadores similares.

Premios:

- skins
- monedas premium
- decoraciones
- empleados raros
- trofeos

**Perfil público del imperio**

Cada jugador tiene una tarjeta:

```
Ahmed's Empire Group
Valor: $4.2B
Ciudades: 7
Negocios: 42
Fábricas: 5
Ranking: #128 mundial
Especialidad: Perfumes + Logística
```

Esto crea deseo.

## 11. Sistema de estatus  [1.0+]

El jugador debe sentir que sube de categoría social dentro del juego.

Títulos:

- vendedor principiante
- comerciante
- dueño
- empresario
- inversionista
- magnate
- billonario
- fundador de conglomerado
- leyenda mundial

Cada título desbloquea:

- ropa del personaje
- oficina
- vehículos visuales
- nuevos negocios
- nuevos países
- nuevos empleados
- efectos visuales

## 12. Personaje principal  [1.0+ personalización, MVP: 1 avatar fijo]

El jugador debe poder personalizar su avatar.

Opciones:

- hombre / mujer
- ropa casual
- ropa elegante
- traje de empresario
- uniforme de tienda
- accesorios
- peinados
- colores
- mascotas
- vehículos pequeños

Importante: que el personaje evolucione.

Al principio:

- ropa sencilla
- puesto pequeño

Después:

- ropa más formal
- oficina
- asistentes
- vehículos
- edificios
- logo propio

## 13. Empleados  [MVP: 3 empleados, 1.0+: todos los tipos]

Los empleados son clave para automatización y monetización.

Tipos:

- cajero
- reponedor
- vendedor
- gerente
- guardia amigable
- conductor
- operador de fábrica
- encargado de bodega
- influencer de marketing
- gerente regional

Cada empleado tiene:

- velocidad
- capacidad
- rareza
- skin
- habilidad especial

Rarezas:

- común
- raro
- épico
- legendario

Ejemplo:

- **Carlos el Cajero Rápido** — +25% velocidad de cobro.
- **Maya Marketing** — atrae 10% más clientes.
- **Omar Logística** — camiones cargan 20% más rápido.

## 14. Economía del juego  [MVP: cash + gems, 1.0+: empire value + reputación]

Debe haber varias monedas, pero no demasiadas.

**Moneda principal: Cash**

Se gana vendiendo.

Sirve para:

- desbloquear zonas
- comprar upgrades
- contratar empleados básicos
- mejorar tiendas

**Moneda premium: Gems**

Se gana poco a poco o se compra.

Sirve para:

- skins
- cofres
- aceleradores
- empleados especiales
- decoraciones premium

**Valor de imperio: Empire Value**

No se gasta. Es el número de estatus.

Representa cuánto vale tu conglomerado.

**Reputación**

Afecta:

- cantidad de clientes
- clientes VIP
- rankings
- acceso a negocios premium

Se gana atendiendo rápido, manteniendo stock y completando eventos.

## 15. Monetización  [MVP: placeholders de UI, 1.0+: real]

Debe monetizar desde temprano, pero sin arruinar la experiencia.

**Ads recompensados**  [MVP: placeholder]

- duplicar ganancias por 5 minutos
- recibir camión especial
- acelerar construcción
- contratar empleado temporal
- abrir cofre
- revivir evento perdido
- recibir clientes VIP
- auto recoger dinero por 2 minutos

**Compras in-app**  [1.0+]

- quitar anuncios
- paquetes de gems
- empleados premium
- skins de tiendas
- skins del personaje
- pase de temporada
- starter pack
- business pack
- factory pack

**Pase de temporada**  [1.0+]

Cada temporada dura 30 días.

Ejemplos:

- Dubai Luxury Season
- Tokyo Tech Season
- Panama Trade Zone Season
- Miami Fashion Season
- Paris Perfume Season

Incluye:

- misiones
- skins
- empleados
- negocios temporales
- ranking especial

## 16. Cuidado con los niños y tiendas  [MVP: reglas aplican]

Como quieres que sea atractivo para niños, jóvenes y adultos, debe
ser seguro y apto para todas las edades.

Reglas importantes:

- no apuestas
- no loot boxes agresivas para menores
- no chat libre entre niños al inicio
- no contenido violento
- no contenido adulto
- no presión excesiva de compra
- control parental si hay funciones sociales
- privacidad fuerte
- compras protegidas por sistema Apple/Google

Debe ser entretenido y aspiracional, pero no manipulativo.

## 17. Social sin riesgo  [MVP: sin social, 1.0+: ranking, 2.0+: visitas]

Al inicio, no metas chat libre.

Mejor usar social indirecto:

- ranking
- ver perfil de imperio
- visitar imperio de otro jugador
- dar like
- enviar regalo diario
- competir en liga
- eventos globales

Más adelante:

- clanes/conglomerados
- chat con mensajes predefinidos
- cooperación para eventos
- torneos

Ejemplos de mensajes predefinidos:

- "Buen imperio"
- "Te envié energía"
- "Vamos por el top"
- "Gran expansión"

## 18. IA dentro del juego  [2.0+, NO MVP]

La IA no debe ser el centro al principio. Debe ayudar a crear
contenido y variedad.

Usos buenos de IA:

**IA para misiones**

Generar misiones diarias:

- atiende 100 clientes
- vende 50 perfumes
- llena 10 estantes
- abre 1 nueva zona
- mejora 2 empleados

**IA para eventos**

Crear eventos dinámicos:

- "Hoy hay fiebre por productos premium"
- "Un influencer visitará tu tienda"
- "Una empresa quiere un pedido grande"

**IA para nombres**

Generar:

- nombres de clientes
- nombres de negocios
- nombres de ciudades
- nombres de productos ficticios

**IA para personalización**

El jugador puede escribir:

"Quiero que mi tienda se vea lujosa y dorada."

Y la IA sugiere decoración o temas.

Pero esto puede ir en versión 2.0. No es necesario para MVP.

## 19. MVP recomendado  [MVP — ESTA ES LA FASE ACTUAL]

No construyas el juego completo desde el día uno.

El MVP debe probar si el loop engancha.

**MVP: "Mini Market + Ropa + Perfume"**

Contenido mínimo:

**Mapa**

1 mapa isométrico pequeño.

Zonas:

- puesto inicial
- caja
- estante de ropa
- estante de perfumes
- mini almacén
- zona de empleados
- zona de expansión
- pequeña fábrica/taller

**Mecánicas**

- mover personaje
- recoger producto
- llenar estante
- cliente compra
- cobrar
- dinero visible
- recoger dinero
- desbloquear zona
- contratar empleado
- upgrade de velocidad
- upgrade de capacidad
- ads recompensados (placeholder)

**Contenido**

- 3 productos
- 3 tipos de clientes
- 3 empleados
- 10 zonas desbloqueables
- 20 upgrades
- 3 eventos rápidos
- 1 ranking simple

**Tiempo ideal de MVP**

El primer MVP debe poder jugarse 15 a 30 minutos sin aburrirse.

## 20. Versión 1.0  [1.0+]

Después del MVP:

- 3 negocios: ropa, perfume, mini market
- 1 taller/fábrica
- 1 bodega
- 1 sistema de camión
- 30 zonas desbloqueables
- 10 empleados
- 50 upgrades
- ranking semanal
- pase de temporada
- ads recompensados
- compras básicas
- guardado en la nube
- iOS + Android

## 21. Versión 2.0  [2.0+]

Agregar:

- farmacia
- electrónica
- fábrica avanzada
- puerto
- contenedores
- segunda ciudad
- clanes
- visitar imperios
- eventos globales
- empleados raros
- skins premium
- IA para eventos diarios

## 22. Versión 3.0  [3.0+]

Agregar:

- países
- mall
- bienes raíces
- franquicias
- ranking mundial avanzado
- ligas
- temporadas por país
- conglomerados
- colaboración entre jugadores
- personalización avanzada de marca

## 23. Métricas que debe medir el juego  [MVP: telemetría local]

Desde el primer día, el juego debe medir:

- tutorial completion
- tiempo de primera sesión
- sesiones por día
- retención día 1
- retención día 3
- retención día 7
- ads vistos por usuario
- compras por usuario
- nivel donde abandonan
- zonas más desbloqueadas
- eventos más jugados
- empleados más usados

Objetivos iniciales:

- tutorial completion: más de 80%
- primera sesión: más de 8 minutos
- retención día 1: más de 35%
- retención día 7: más de 10%
- ads recompensados: mínimo 3 por usuario activo al día

## 24. Pantallas principales  [MVP: juego + HUD, 1.0+: resto]

**Pantalla de juego**  [MVP]

- mapa principal
- personaje
- clientes
- dinero
- zonas bloqueadas
- botones mínimos
- indicadores de misión

**Pantalla de upgrades**  [MVP básico]

- velocidad
- capacidad
- empleados
- caja
- estantes
- producción

**Pantalla de imperio**  [1.0+]

- valor total
- negocios
- empleados
- ciudades
- reputación
- ranking

**Pantalla de empleados**  [1.0+]

- contratar
- mejorar
- asignar
- skins

**Pantalla de ranking**  [MVP simple, 1.0+ completo]

- liga semanal
- ranking mundial
- amigos
- premios

**Pantalla de tienda**  [MVP placeholder, 1.0+ real]

- gems
- remove ads
- skins
- pase
- packs

## 25. Diseño del primer minuto  [MVP — CRÍTICO]

El primer minuto es lo más importante.

**Segundo 0 a 10**

El jugador aparece al lado de una mesa vacía.

Texto:

"Llena tu primer estante."

El jugador recoge producto y lo coloca.

**Segundo 10 a 20**

Llega primer cliente.

Cliente compra.

Aparece dinero.

Texto:

"Recoge tu dinero."

**Segundo 20 a 35**

El jugador recoge dinero y ve zona bloqueada.

Texto:

"Invierte para crecer."

Compra una caja registradora o nuevo estante.

**Segundo 35 a 60**

Llegan más clientes.

El jugador siente caos.

Aparece primer empleado bloqueado.

Texto:

"Contrata ayuda."

Ese primer minuto debe cerrar con una mejora visual clara.

## 26. Cómo debe sentirse  [MVP — CRÍTICO]

El juego debe sentirse:

- rápido
- satisfactorio
- aspiracional
- fácil
- visual
- progresivo
- lleno de recompensas pequeñas
- con metas grandes
- sin tutorial aburrido

Cada 10 segundos debe pasar algo.

Cada 1 minuto debe desbloquear algo.

Cada 5 minutos debe cambiar visualmente el negocio.

Cada 15 minutos debe aparecer una meta grande.

Cada día debe haber una razón para volver.

## 27. Diferenciador principal  [MVP: loop, 1.0+: escala]

El diferenciador no es solo "tycoon".

El diferenciador es:

Pasas de atender tú mismo una tienda pequeña a controlar un
conglomerado mundial con fábricas, logística, marcas, países y
rankings.

La mayoría de juegos se quedan en una tienda.

Este debe escalar a:

tienda → cadena → fábrica → bodega → puerto → ciudad → país →
imperio mundial.

## 28. Prompt para pasarle a tu AI  [incluido en prompt.txt]

Quiero que desarrolles un juego mobile para iOS y Android llamado
provisionalmente "Trade Empire Rush".

Es un juego 3D isométrico estilo idle tycoon / management runner,
inspirado en anuncios donde el jugador camina, recoge productos,
atiende clientes, cobra dinero físico visible, desbloquea zonas y
expande un negocio. La diferencia clave es que el gameplay real debe
ser exactamente como el anuncio: mover, vender, cobrar, recoger
dinero, invertir, expandir, automatizar y crecer.

El concepto central es que el jugador empieza con un pequeño puesto
de venta y termina construyendo un conglomerado mundial. La
progresión debe ir desde puesto callejero, tienda local, cadena de
negocios, fábrica, bodega, importación/exportación, ciudad, país y
finalmente imperio mundial.

El juego debe ser apto para todas las edades, visualmente atractivo,
con gráficos 3D low-poly limpios, colores vivos, personajes
caricaturescos, UI grande y clara, cámara isométrica, pads de
desbloqueo en el piso, clientes visibles, dinero físico visible y
construcción inmediata.

Loop principal:

1. Jugador recoge productos.
2. Lleva productos a estantes o mostradores.
3. Llegan clientes.
4. Clientes compran.
5. Jugador cobra.
6. Dinero aparece físicamente.
7. Jugador recoge dinero.
8. Jugador invierte en zonas bloqueadas.
9. Se desbloquean nuevas áreas, empleados, productos o negocios.
10. Se repite con más automatización y expansión.

El MVP debe incluir:

- 1 mapa isométrico pequeño.
- 3 tipos de negocio iniciales: ropa, perfume y mini market.
- 1 zona de pequeño taller/fábrica.
- 1 mini almacén.
- Movimiento simple del personaje.
- Clientes con fila.
- Dinero físico recogible.
- Zonas bloqueadas con precio.
- Contratación de empleados.
- Upgrades de velocidad, capacidad, caja, estantes y producción.
- Ads recompensados.
- Ranking semanal simple.
- Guardado de progreso.

Progresión futura:

- Etapa 1: puesto callejero.
- Etapa 2: tienda local.
- Etapa 3: cadena de negocios.
- Etapa 4: fábrica propia.
- Etapa 5: bodega y logística.
- Etapa 6: importación/exportación.
- Etapa 7: dominio de ciudad.
- Etapa 8: expansión nacional.
- Etapa 9: expansión mundial.
- Etapa 10: conglomerado global.

Tipos de negocios futuros:

- ropa
- perfumes
- farmacia ficticia / cuidado personal
- mini market
- electrónica
- juguetes
- belleza
- fábrica
- bodega
- logística
- puerto
- mall
- bienes raíces comerciales

Sistema de competencia:

Crear ranking basado en "Empire Value". El valor del imperio se
calcula usando dinero total, negocios abiertos, ingresos por minuto,
empleados, ciudades desbloqueadas, fábricas, reputación y
propiedades. Los jugadores compiten en ligas semanales, no con
combate directo. Debe sentirse aspiracional: todos quieren construir
el conglomerado más grande.

Monetización:

- Ads recompensados para duplicar dinero, acelerar construcción,
  abrir cofres, traer clientes VIP, contratar empleados temporales y
  activar boosts.
- Compras in-app: quitar anuncios, gems, skins, empleados premium,
  pase de temporada, packs de expansión.
- Pase de temporada mensual con nuevos temas como Dubai Luxury,
  Tokyo Tech, Panama Trade Zone, Miami Fashion y Paris Perfume.

Importante:

- No hacer chat libre al inicio.
- No hacer apuestas.
- No hacer mecánicas agresivas para menores.
- No hacer violencia gráfica.
- No hacer mundo abierto gigante al principio.
- Priorizar que el primer minuto sea extremadamente entretenido.

El primer minuto debe ser:

- recoger producto
- llenar estante
- atender primer cliente
- cobrar
- recoger dinero
- desbloquear primera mejora
- contratar primer empleado o mostrarlo como meta cercana

El objetivo es crear un juego adictivo de forma sana, visualmente
satisfactorio y con progresión infinita, donde el jugador sienta que
está construyendo un imperio desde cero hasta convertirse en magnate
mundial.

## 29. Recomendación final  [MVP: corazón]

Tu idea buena no es solo "un juego de tienda".

La idea fuerte es:

El sueño de volverse magnate, convertido en un juego simple de mover,
cobrar y expandir.

La frase que resume todo:

"Empieza con una mesa. Termina con un conglomerado mundial."

Ese es el corazón del juego.

## 30. Monetización: cómo gana dinero el juego  [MVP: placeholders, 1.0+: real]

El juego debe ganar dinero sin sentirse abusivo. La monetización debe
estar basada en comodidad, estatus, personalización, aceleración y
competencia, no en obligar al jugador a pagar para poder jugar.

La idea es que el jugador pueda avanzar gratis, pero que pagar se
sienta tentador porque mejora la experiencia, acelera el progreso o
le da más estatus dentro de la comunidad.

**Fuentes principales de ingresos**

**1. Anuncios recompensados**  [MVP: placeholder]

Los anuncios recompensados deben ser la primera fuente de ingresos
al inicio.

El jugador no debe sentir que el anuncio interrumpe demasiado. Debe
sentir:

"Si veo este anuncio, me conviene."

Ejemplos:

- duplicar ganancias por 5 minutos
- recibir un cliente VIP
- acelerar una construcción
- traer un camión especial
- desbloquear un cofre
- contratar un empleado temporal
- recuperar un evento perdido
- producir más rápido en fábrica
- activar auto-recolección por 2 minutos

Ejemplo de oferta:

"Mira un anuncio y recibe un camión lleno de productos premium."

Esto funciona porque el jugador ya está dentro del loop de crecer y
desbloquear.

**2. Tienda dentro del juego**  [MVP: placeholder UI]

Debe existir una tienda clara con productos digitales.

**Categorías de tienda**

**A. Gems**

Moneda premium.

Sirve para:

- acelerar mejoras
- comprar skins
- abrir cofres
- comprar empleados especiales
- desbloquear decoraciones premium
- comprar boosts

Paquetes:

- 100 gems
- 500 gems
- 1,200 gems
- 3,000 gems
- 7,000 gems

**B. Quitar anuncios**

Producto muy importante.

Remove Ads

Beneficio:

- elimina anuncios forzados, si existen
- mantiene anuncios recompensados opcionales
- puede dar bono permanente de +10% cash

Debe ser una compra simple:

$2.99 a $9.99, dependiendo del mercado.

**C. Starter Pack**

Oferta para nuevos jugadores.

Debe aparecer después de que el jugador ya entendió el juego, no al
segundo 1.

Incluye:

- gems
- empleado raro
- skin exclusiva
- boost de 24 horas
- decoración especial

Ejemplo:

Starter Boss Pack
"Empieza tu imperio más rápido."

Precio recomendado:

$1.99 a $4.99

**D. Empleados premium**  [1.0+]

Los empleados son una de las mejores formas de monetizar porque
afectan progreso y personalidad.

Tipos:

- cajero rápido
- gerente experto
- reponedor veloz
- conductor premium
- influencer de marketing
- operador de fábrica
- asesor financiero
- gerente regional

Cada empleado premium debe tener:

- habilidad
- apariencia única
- rareza
- animación especial

Ejemplo:

- **Maya Marketing — Épica** — Atrae clientes VIP cada cierto tiempo.
- **Omar Logistics — Legendario** — Hace que los camiones descarguen
  30% más rápido.

**E. Skins y personalización**  [1.0+]

Esto monetiza por estatus.

Skins para:

- personaje
- tienda
- caja registradora
- empleados
- vehículos
- fábricas
- oficinas
- logo del imperio
- mascotas
- efectos visuales del dinero

Ejemplos:

- traje de magnate
- ropa urbana
- uniforme premium
- tienda de lujo dorada
- fábrica futurista
- camión deportivo
- oficina de CEO
- mascota que recoge dinero

Lo importante: que los demás puedan verlo en rankings, perfil
público o visitas al imperio.

**F. Pase de temporada**  [1.0+]

El pase de temporada debe ser una de las monetizaciones principales.

Duración:

30 días

Incluye:

- misiones especiales
- recompensas diarias
- skins exclusivas
- empleados únicos
- decoraciones limitadas
- boosts
- cofres
- título especial
- trofeo para el perfil

Ejemplos de temporadas:

- Dubai Luxury Season
- Panama Trade Zone Season
- Miami Fashion Season
- Tokyo Tech Season
- Paris Perfume Season
- Global Factory Season

Precio recomendado:

$4.99 a $9.99

La clave es que el pase haga sentir:

"Si no lo compro, todavía juego. Pero si lo compro, mi imperio se ve
más premium y avanzo mejor."

**G. Cofres**  [1.0+, con cuidado]

Los cofres pueden existir, pero deben manejarse con cuidado,
especialmente si el juego es para todas las edades.

Mejor usar cofres como recompensas frecuentes y compras
transparentes.

Tipos:

- cofre común
- cofre raro
- cofre épico
- cofre empresarial
- cofre de temporada

Pueden traer:

- empleados
- gems
- cash
- decoraciones
- piezas de skins
- boosts

Importante: si hay cofres comprables, deben mostrar probabilidades y
no deben ser el centro agresivo del juego.

**H. Suscripción VIP opcional**  [2.0+]

Una suscripción mensual puede existir más adelante.

Beneficios:

- gems diarios
- boost permanente
- cola de construcción extra
- perfil VIP
- skins mensuales
- más recompensas de liga
- auto-recolección diaria limitada

Precio:

$4.99 a $9.99 mensual

Debe ser opcional, no necesaria.

## 31. Qué hará que la gente quiera pagar  [1.0+, pero MVP debe sembrar]

La gente no paga solo por avanzar. Paga por emoción, estatus,
identidad, comodidad y miedo a quedarse atrás de forma sana.

**Motivos psicológicos de compra**

**1. Querer crecer más rápido**

El jugador ve una zona bloqueada que cuesta mucho.

Piensa:

"Estoy cerca. Si compro o veo un anuncio, la desbloqueo ya."

Esto funciona si siempre hay una meta visible cerca.

**2. Querer verse diferente**

Si el jugador tiene un imperio visualmente único, quiere
personalizarlo.

Ejemplos:

- tienda de lujo
- personaje elegante
- logo propio
- oficina premium
- vehículos raros
- empleados legendarios

La personalización debe verse en el perfil público.

**3. Querer competir**

Si hay ranking, ligas y tabla global, la gente paga más por avanzar,
destacar y mantener posición.

Ejemplo:

"Estás en puesto #4 de tu liga. Con un boost puedes entrar al top 3."

Esto debe hacerse sin manipular de forma excesiva, pero sí con
motivación clara.

**4. Querer completar colecciones**

Colecciones de:

- empleados
- negocios
- países
- skins
- vehículos
- fábricas
- decoraciones
- trofeos

Ejemplo:

"Completa la colección Dubai Luxury y desbloquea el título Sheikh of
Trade."

**5. Querer aprovechar eventos limitados**

Eventos de temporada hacen que la gente vuelva y compre.

Ejemplos:

- Black Friday Empire
- Dubai Luxury Week
- Global Trade Fair
- Factory Madness
- Perfume Festival
- Mega Mall Opening

Recompensas limitadas:

- empleado único
- decoración rara
- skin especial
- trofeo de temporada

**6. Querer comodidad**

Muchos jugadores pagan para evitar trabajo repetitivo.

Compras útiles:

- auto-recolector
- cajero automático
- gerente que administra una tienda
- camión automático
- producción automática
- remove ads

La comodidad no debe quitar el juego, solo hacerlo más fluido.

## 32. Qué es lo adictivo del juego  [MVP — CRÍTICO]

La adicción sana del juego viene de tener siempre algo cerca por
desbloquear.

El jugador debe sentir:

"Estoy a punto de lograr algo."

**Elementos adictivos principales**

**1. Progreso visual inmediato**

Cada mejora debe verse.

Ejemplos:

- estante más grande
- más clientes
- más dinero
- tienda más bonita
- empleados más rápidos
- nueva zona construida
- nueva fábrica funcionando
- camión entrando al mapa

Si el jugador paga o mejora algo y no lo ve visualmente, pierde
emoción.

**2. Metas cortas, medianas y largas**

Debe haber tres niveles de meta al mismo tiempo.

Meta corta:

"Recoge $100 para abrir este estante."

Meta mediana:

"Completa la tienda de ropa."

Meta larga:

"Conviértete en el #1 de la ciudad."

Meta gigante:

"Construye el conglomerado mundial más grande."

**3. Dinero visible**

El dinero debe ser físico y satisfactorio.

- billetes en el piso
- montones en caja
- dinero volando al contador
- sonido agradable al recoger
- barras de progreso llenándose

Esto genera satisfacción inmediata.

**4. Desbloqueo constante**

El juego debe desbloquear algo frecuentemente:

- nuevo producto
- nuevo empleado
- nueva zona
- nuevo cliente
- nuevo negocio
- nuevo mapa
- nueva fábrica
- nueva ciudad
- nuevo ranking
- nueva temporada

**5. Automatización progresiva**

Al principio el jugador hace todo.

Después contrata empleados.

Luego gerentes.

Luego fábricas.

Luego logística.

Luego ciudades completas.

Esa transición de "yo trabajo" a "mi imperio trabaja por mí" es muy
poderosa.

**6. Competencia aspiracional**

Ver a otros jugadores más avanzados motiva.

Ejemplo:

"Este jugador tiene 12 fábricas, 4 ciudades y $8.5B de Empire Value."

El jugador piensa:

"Yo también quiero llegar ahí."

**7. Eventos sorpresa**

El juego no puede sentirse igual siempre.

Deben aparecer eventos:

- cliente VIP
- hora pico
- producto viral
- pedido gigante
- camión raro
- descuento global
- competencia semanal
- feria comercial
- temporada especial

## 33. Qué puede hacer que una persona se canse  [MVP: evitar desde el inicio]

Es muy importante evitar que el juego se vuelva repetitivo.

**Riesgos principales**

**1. Repetición excesiva**

Si el jugador solo recoge dinero y llena estantes durante horas, se
cansa.

Solución:

- nuevos negocios
- nuevas mecánicas
- eventos
- fábricas
- logística
- rankings
- temporadas

**2. Progreso demasiado lento**

Si desbloquear algo tarda demasiado, el jugador abandona.

Solución:

- recompensas frecuentes
- metas pequeñas
- ads opcionales útiles
- balance correcto de precios
- eventos que aceleran progreso

**3. Demasiados anuncios**

Si el juego interrumpe con anuncios constantes, el jugador se va.

Solución:

- priorizar anuncios recompensados
- pocos anuncios forzados
- opción clara de quitar anuncios
- nunca poner anuncio en medio de una acción importante

**4. Pagar se siente obligatorio**

Si sin pagar el juego se vuelve imposible, el jugador se frustra.

Solución:

- free-to-play justo
- pagar acelera, pero no bloquea todo
- recompensas gratis diarias
- eventos accesibles para todos

**5. Falta de meta grande**

Si el jugador no sabe para qué sigue, se cansa.

Solución:

- mostrar siempre el próximo gran objetivo
- ciudad siguiente
- ranking siguiente
- negocio siguiente
- título siguiente
- país siguiente

**6. Todo se ve igual**

Si cada tienda se siente igual, aburre.

Solución:

Cada negocio debe tener una mecánica distinta:

- ropa: racks y probadores
- perfume: vitrinas y clientes premium
- mini market: alta rotación
- farmacia/cuidado personal: pedidos rápidos
- electrónica: productos caros y seguridad
- fábrica: producción
- bodega: cajas y camiones
- puerto: contenedores
- mall: múltiples locales

**7. No hay comunidad**

Si el jugador siente que juega solo, abandona más rápido.

Solución:

- ranking
- ligas
- perfiles públicos
- visitas a imperios
- regalos diarios
- eventos globales
- clanes/conglomerados

## 34. Comunidad de superación y competencia global  [1.0+ ranking, 2.0+ clanes]

El juego debe tener una comunidad donde la gente no solo compita,
sino que se inspire.

La comunidad debe girar alrededor de esta idea:

"Todos empezamos desde cero. ¿Quién construye el imperio más grande?"

No debe ser una comunidad tóxica de insultos. Debe ser aspiracional,
de progreso y superación.

**Sistema de perfil público**

Cada jugador tiene un perfil de imperio.

Debe mostrar:

- nombre del jugador
- nombre del imperio
- avatar
- logo del grupo
- título actual
- Empire Value
- ciudad principal
- negocios abiertos
- fábricas
- empleados legendarios
- país más avanzado
- trofeos
- ranking global
- ranking semanal
- fecha de inicio
- lema del imperio

Ejemplo:

```
Ahmed Empire Group
Título: Global Magnate
Empire Value: $12.8B
Negocios: 84
Fábricas: 11
Ciudades: 7
Ranking Global: #42
Especialidad: Perfumes + Logística
Lema: "From zero to empire."
```

**Tabla global**

Debe existir una tabla global con varias categorías.

Ranking principal:

Top Empire Value

Mide quién tiene el imperio más valioso.

Rankings secundarios:

- mayor ingreso por minuto
- más ciudades desbloqueadas
- más fábricas
- más clientes atendidos
- más reputación
- más negocios premium
- más eventos ganados
- mejor temporada actual
- mayor crecimiento semanal

Esto es importante porque permite que diferentes tipos de jugador
destaquen.

No todo debe depender solo de quién pagó más.

**Ligas semanales**

Cada jugador entra en una liga semanal con jugadores de nivel parecido.

Ligas:

- Street Seller
- Local Trader
- Shop Owner
- Chain Boss
- City Tycoon
- National Magnate
- Global Founder
- Empire Legend

Cada semana:

- los mejores suben
- los últimos bajan o se mantienen
- todos reciben premios según posición

Premios:

- gems
- cofres
- skins
- empleados
- trofeos
- títulos temporales

**Conglomerados / clanes**  [2.0+]

Más adelante, los jugadores pueden crear grupos llamados
Conglomerates.

Un conglomerado es como un clan, pero con temática empresarial.

Funciones:

- unir jugadores
- sumar valor de imperio
- competir contra otros conglomerados
- donar recursos
- completar eventos grupales
- desbloquear recompensas colectivas
- tener ranking de conglomerados

Ejemplos:

- Latam Empire Club
- Dubai Trade Group
- Panama Bosses
- Global Tycoons
- Zero to Billion Club

**Comunidad de superación**

La app puede tener una sección tipo comunidad motivacional, pero
controlada.

Nombre posible:

Empire Club

Contenido:

- logros de jugadores
- rankings
- progreso semanal
- imperios destacados
- eventos activos
- consejos del juego
- retos de superación
- historias automáticas de progreso

Ejemplo:

"Juan pasó de puesto callejero a dueño de 3 fábricas en 12 días."
"Top 10 jugadores con mayor crecimiento esta semana."
"Reto global: atender 100 millones de clientes entre todos."

**Sin chat libre al inicio**

Para proteger la comunidad y hacer el juego apto para todas las
edades, no debe haber chat libre al principio.

En su lugar:

- likes a imperios
- regalos diarios
- mensajes predefinidos
- stickers seguros
- emojis limitados
- felicitaciones automáticas
- solicitudes de ayuda

Mensajes predefinidos:

- "Gran imperio"
- "Buen crecimiento"
- "Vamos por el top"
- "Te envié ayuda"
- "Excelente expansión"
- "Nos vemos en la liga"

Más adelante, si se agrega chat, debe tener moderación fuerte,
reportes y filtros.

## 35. Sistema de visitas a imperios  [2.0+]

El jugador debe poder visitar el imperio de otros.

Al visitar, puede ver:

- tiendas
- fábricas
- ciudad
- avatar
- empleados raros
- decoraciones
- trofeos
- ranking
- estilo visual

Puede hacer acciones simples:

- dar like
- enviar regalo
- recoger una recompensa diaria
- inspirarse
- seguir al jugador
- invitar a conglomerado

Esto genera deseo de personalizar y pagar.

Si otros pueden ver tu imperio, te importa más cómo se ve.

## 36. Eventos globales  [1.0+]

Los eventos globales hacen que la comunidad se sienta viva.

Ejemplos:

**Global Trade Fair**

Todos venden productos para alcanzar una meta mundial.

**Black Friday Rush**

Durante 48 horas hay más clientes y recompensas especiales.

**Factory Madness**

Las fábricas producen más rápido.

**Luxury Week**

Negocios premium generan más dinero.

**Panama Trade Zone**

Evento de contenedores, bodega y exportación.

**Dubai Luxury Expo**

Evento de perfumes, joyas, lujo y clientes VIP.

**World Empire Cup**

Competencia global por ligas y conglomerados.

## 37. Sistema de logro y estatus social  [1.0+]

Los títulos son muy importantes.

Ejemplos de títulos:

- Started From Zero
- Street Hustler
- Local Boss
- First Million
- City Owner
- Factory King
- Logistics Master
- Retail Legend
- Global Magnate
- World Founder
- Empire God

Estos títulos pueden verse en el perfil y ranking.

También pueden existir trofeos:

- primer millón
- primera fábrica
- primera ciudad
- primer país
- 1 millón de clientes
- top 100 semanal
- top 10 global
- temporada completada

## 38. Retención diaria  [MVP: save + offline, 1.0+: daily missions]

El juego debe tener razones para volver todos los días.

**Daily Login**

Recompensa diaria creciente.

- Día 1: cash
- Día 2: gems
- Día 3: boost
- Día 4: cofre
- Día 5: empleado temporal
- Día 6: decoración
- Día 7: cofre épico

**Daily Missions**  [1.0+]

Misiones diarias:

- atiende 100 clientes
- recoge 50 montones de cash
- mejora 3 estantes
- completa 1 evento
- visita 3 imperios
- envía 5 regalos

**Weekly Goals**  [1.0+]

Metas semanales:

- subir de liga
- desbloquear nuevo negocio
- completar pase
- ganar evento
- mejorar Empire Value

**Offline Earnings**  [MVP]

Cuando el jugador vuelve, ve:

"Tu imperio generó $240,000 mientras estabas fuera."

Luego puede:

- reclamar normal
- ver anuncio para duplicar
- usar boost para triplicar

## 39. Balance entre diversión y monetización  [MVP: free-to-play justo]

Regla de oro:

El jugador gratis debe divertirse. El jugador que paga debe sentirse
más poderoso, más rápido y más único.

Nunca debe sentirse:

"Si no pago, no puedo jugar."

Debe sentirse:

"Si pago, mi imperio crece más rápido y se ve más impresionante."

## 40. Sistema de fatiga y solución  [1.0+]

El juego debe detectar señales de cansancio.

**Señales de cansancio**

- jugador deja de mejorar
- repite la misma zona mucho tiempo
- no ve anuncios
- no entra por varios días
- falla eventos
- no desbloquea nada nuevo

**Soluciones automáticas**

- ofrecer evento especial
- dar recompensa de regreso
- desbloquear misión nueva
- mostrar meta cercana
- ofrecer boost gratis
- mostrar ranking de jugadores similares
- mostrar "estás cerca de desbloquear fábrica"
- activar cliente VIP sorpresa

Ejemplo:

"Estás a solo $5,000 de abrir tu primera fábrica."

Eso reengancha.

## 41. Blueprint adicional para la AI: monetización y comunidad  [1.0+]

Agregar al blueprint del juego "Trade Empire Rush" el siguiente
sistema de monetización, retención y comunidad:

El juego debe ganar dinero mediante una combinación de anuncios
recompensados, compras dentro de la app, pase de temporada, skins,
empleados premium, remove ads, boosts y personalización. La
monetización debe sentirse justa: el jugador gratis puede avanzar y
divertirse, mientras que el jugador que paga avanza más rápido, se ve
más premium y gana más estatus dentro de la comunidad.

Implementar una tienda dentro del juego con:

- Gems como moneda premium.
- Remove Ads.
- Starter Pack.
- Empleados premium.
- Skins de personaje, tienda, empleados, vehículos, fábricas y
  oficinas.
- Boosts temporales.
- Cofres transparentes.
- Pase de temporada mensual.

Los anuncios recompensados deben permitir:

- duplicar ganancias
- acelerar construcción
- traer clientes VIP
- recibir camiones especiales
- abrir cofres
- contratar empleados temporales
- activar auto-recolección
- mejorar producción de fábrica temporalmente

Lo que hace adictivo al juego debe ser:

- progreso visual inmediato
- dinero físico visible
- metas cortas, medianas y largas
- desbloqueo constante
- automatización progresiva
- competencia aspiracional
- eventos sorpresa
- rankings
- temporadas
- personalización visible para otros jugadores

Evitar que el jugador se canse:

- no repetir la misma mecánica demasiado tiempo
- agregar nuevos tipos de negocio
- agregar fábricas, logística, bodegas, puerto y ciudades
- balancear bien los precios
- evitar demasiados anuncios
- hacer que pagar no sea obligatorio
- mostrar siempre una meta cercana y una meta grande
- variar eventos y recompensas

Crear una comunidad llamada Empire Club o equivalente, enfocada en
superación, progreso e imperios. La comunidad debe permitir:

- ranking global
- ligas semanales
- perfil público de imperio
- visitas a imperios de otros jugadores
- likes
- regalos diarios
- eventos globales
- conglomerados/clanes
- mensajes predefinidos seguros
- trofeos
- títulos de estatus

No implementar chat libre al inicio. Usar mensajes predefinidos,
likes, regalos y visitas para mantener la comunidad segura y apta
para todas las edades.

Crear una tabla global con:

- mayor Empire Value
- mayor ingreso por minuto
- más ciudades desbloqueadas
- más fábricas
- más clientes atendidos
- más reputación
- más eventos ganados
- mejor crecimiento semanal

Crear ligas semanales:

- Street Seller
- Local Trader
- Shop Owner
- Chain Boss
- City Tycoon
- National Magnate
- Global Founder
- Empire Legend

Crear un perfil público donde se vea:

- nombre del imperio
- avatar
- logo
- título
- Empire Value
- negocios abiertos
- ciudades
- fábricas
- empleados legendarios
- trofeos
- ranking global
- lema

El objetivo de la comunidad es que todos quieran superarse y
construir el imperio más grande, sin competencia agresiva directa.
Debe sentirse aspiracional: empezar desde cero y convertirse en
magnate mundial.

La frase clave para esta parte sería:

"El jugador no paga solo por avanzar; paga por sentirse más magnate."

---

## Resumen de fases para la AI

| Sección | Fase | Aplica al MVP |
|---|---|---|
| 1–9 (concepto, estilo, loop, mapa, etapas, tope, negocios, actividades) | MVP estructura | SÍ — estructura y loop |
| 10 (competencia) | MVP ranking simple, 1.0+ ligas | ranking simple SÍ |
| 11 (estatus) | 1.0+ | NO (sembrar base) |
| 12 (personaje) | 1.0+ personalización | 1 avatar fijo |
| 13 (empleados) | MVP 3 empleados | SÍ |
| 14 (economía) | MVP cash+gems | SÍ |
| 15 (monetización) | MVP placeholders | placeholders SÍ |
| 16 (seguridad) | MVP | SÍ — reglas aplican |
| 17 (social) | MVP sin social | NO |
| 18 (IA) | 2.0+ | NO |
| 19 (MVP recomendado) | **MVP — FASE ACTUAL** | **SÍ — CRÍTICO** |
| 20 (versión 1.0) | 1.0+ | NO |
| 21 (versión 2.0) | 2.0+ | NO |
| 22 (versión 3.0) | 3.0+ | NO |
| 23 (métricas) | MVP telemetría local | SÍ |
| 24 (pantallas) | MVP juego+HUD+upgrades | SÍ básico |
| 25 (primer minuto) | **MVP — CRÍTICO** | **SÍ — CRÍTICO** |
| 26 (cómo sentirse) | **MVP — CRÍTICO** | **SÍ — CRÍTICO** |
| 27 (diferenciador) | MVP loop | SÍ |
| 28 (prompt AI) | MVP | SÍ |
| 29 (recomendación) | MVP corazón | SÍ |
| 30 (monetización detallada) | MVP placeholders, 1.0+ real | placeholders SÍ |
| 31 (psicología de pago) | 1.0+ | sembrar SÍ |
| 32 (qué es adictivo) | **MVP — CRÍTICO** | **SÍ — CRÍTICO** |
| 33 (qué cansa) | MVP evitar | SÍ |
| 34 (comunidad) | 1.0+ ranking, 2.0+ clanes | ranking simple SÍ |
| 35 (visitas) | 2.0+ | NO |
| 36 (eventos globales) | 1.0+ | NO |
| 37 (logros) | 1.0+ | NO |
| 38 (retención diaria) | MVP save+offline | SÍ |
| 39 (balance) | MVP | SÍ |
| 40 (fatiga) | 1.0+ | NO |
| 41 (blueprint adicional) | 1.0+ | sembrar SÍ |

**Para el MVP, la AI debe enfocarse en:** secciones 1–9 (estructura +
loop), 13 (3 empleados), 14 (cash+gems), 15 (placeholders),
16 (seguridad), 19 (MVP recomendado — CRÍTICO), 23 (telemetría
local), 24 (juego+HUD+upgrades básico), 25 (primer minuto —
CRÍTICO), 26 (cómo sentirse — CRÍTICO), 27 (diferenciador loop),
28 (prompt), 29 (corazón), 30 (placeholders), 32 (qué es adictivo —
CRÍTICO), 33 (evitar cansancio), 38 (save+offline), 39 (balance
free-to-play).

**Para versión 1.0+ (NO construir en el MVP pero conocer para no
bloquear):** secciones 10 (ligas), 11 (estatus), 12
(personalización), 20 (1.0), 30 (monetización real), 31
(psicología), 34 (comunidad), 36 (eventos globales), 37 (logros),
40 (fatiga), 41 (comunidad detallada).

**Para versión 2.0+ (NO construir):** 17 (social), 18 (IA), 21
(2.0), 35 (visitas).

**Para versión 3.0+:** 22 (3.0).
