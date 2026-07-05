# Trade Empire Rush — Informe Final del Overnight (rondas 11–15)

> Fine-tuning ronda 15 (2026-07-05 08:52). Cubre las 5 rondas desde
> el último fine-tuning (r10): r11, r12, r13, r14, r15.

## Fase alcanzada
- **Fase al final de la ronda 15**: **A (construyendo MVP)** — capa 4
  a 7/8, capa 5/6/Fase B/Fase C sin tocar.
- **Justificación**: el overnight cerró capa 3 (BIZ-1..5) y casi toda
  capa 4 (AUTO-1/2 + UPG-1..5) en 5 rondas. Solo EMP-1 (rareza de
  empleados) falta para cerrar capa 4. Capa 5 (eventos, save, juice,
  ranking, monetización) y capa 6 (landing, métricas) están intactas.
- **¿Avanzó A → B → C correctamente?**: NO avanzó — se quedó en A.
  Esto es **correcto** según la regla de capas (no saltar a B hasta
  cerrar A). PERO hay un riesgo: el overnight podría saltar de A a C
  sin pulir B si las próximas rondas no priorizan juice. La
  re-priorización r15 sube JUICE-1/POLISH-1/2/3 a P0 dentro de capa 5
  para evitarlo.
- **¿Se saltó la Fase B (pulido)?**: SÍ, pero **no es anti-patrón**
  porque Fase A no está completa. Sería anti-patrón saltarla DESPUÉS
  de cerrar A. La re-priorización r15 explicita "No saltar a Fase C
  hasta que Fase B esté completa y el MVP sea adictivo".

## Estado del MVP

### Lo que se construyó (por capa)

**Capa 1 — Engine + proyecto base** (r1): Godot 4.3 portable,
`project.godot` con autoloads Economy/GameManager, `Main.tscn`.

**Capa 1.5 — Gate export HTML5** (r8): `export_presets.cfg` +
`exports/html5/index.html` + index.pck (108KB) + index.wasm (35MB).
Export HTML5 verde desde r8, mantenido verde en r11-r15.

**Capa 2 — Loop base** (r1-r8): Player (WASD + bob/squash), Camera
(smoothing + look-ahead), Pickup (stock regen + capacidad), Shelf
(fill con E + stock/capacity), Client (FSM + spawn + buy + money
drop), MoneyDrop (recoger + Economy.add_cash), UnlockPad (zona
bloqueada + precio + try_unlock), HUD (cash/empire/mission),
MissionGuide (4 beats: fill→collect→unlock→hire).

**Capa 3 — Contenido MVP** (r11-r12): 5 negocios con patrón
`Business` reutilizable. BIZ-1 puesto callejero (camiseta $5,
unlocked), BIZ-2 perfume ($15, pad $120), BIZ-3 snacks ($3, pad
$400), BIZ-4 taller/factory (raw→máquina→output, pad $250, primer
negocio pasivo), BIZ-5 almacén (buffer logística, pad $600,
deposit/withdraw).

**Capa 4 — Automatización + upgrades** (r13-r15): AUTO-1 cajero
(3 instancias, $100/$150/$200, auto-cobra clientes sin MoneyDrop),
UPG-1..5 (5 upgrades reutilizables vía 1 UpgradePad: speed $80,
carry $120, shelf_cap $150, cashier_speed $180, production $200,
escala ×1.6/nivel, patrón base-meta idempotente), AUTO-2 reponedor
(3 instancias, $120/$180/$240, mueve stock del warehouse al shelf
con mayor déficit cada trip_interval segundos wall-clock).

**Total pads activos**: 5 unlock + 3 cajeros + 3 reponedores + 5
upgrades = **16 pads pulsando** con precios escalonados $80-$600.

### Lo que NO se construyó (pendiente)

- **EMP-1** (capa 4, M) — rareza de empleados (común/raro/épico/
  legendario) + habilidades especiales. Único item pendiente de
  capa 4.
- **Capa 5**: EVT-1/2/3 (eventos Rush Hour/VIP/Flash Sale), RNK-1
  (ranking local con bots), MON-1/2 (ad recompensado + tienda
  placeholder), SAVE-1 (guardado local), OFF-1 (offline earnings),
  JUICE-1 (partículas/sonido/fly-to-HUD al recoger), JUICE-2
  (música/SFX).
- **Capa 6**: EXP-2 (landing page), MET-1 (telemetría local).
- **Fase B (POLISH-1..10)**: feedback visual/sonoro, cash volando
  al HUD, screen shake, glow en pads, meta cercana en HUD, balance
  de precios, spawn rate, animación de clientes, música, tutorial
  pulido.
- **Fase C (V1-1..23)**: farmacia, electrónica, fábrica avanzada,
  bodega+logística, puerto, segunda ciudad, ligas, títulos,
  personalización, empleados premium, skins, pase de temporada,
  cofres, IAP real, ads reales, daily missions, eventos globales,
  logros, fatiga, perfil público, export Android/iOS, cloud save.
- **GATE-1/2/3, MOB-1/2/3**: gates de calidad pre-1.0 + mobile
  readiness.

### Export HTML5
- **Estado**: OK
- **Ruta**: `D:\empire-rush\exports\html5\index.html` (108KB pck,
  35MB wasm, generados en r15).
- **Verificado en este fine-tuning**: headless `--quit-after 60`
  OK (5 businesses, 3 cashiers, 3 stockers, 5 upgrade pads, HUD,
  MissionGuide, 5 unlock pads cargan sin crashes).

### Cómo probarlo
```powershell
# Headless (valida boot sin crash)
D:\empire-rush\godot\godot.exe --headless --path D:\empire-rush --quit-after 60

# Smoke headless (valida lógica de stocker/cashier)
$env:DEVIN_SMOKE=1
D:\empire-rush\godot\godot.exe --headless --path D:\empire-rush --quit-after 12000

# Abrir en navegador (valida feel real — NO automatizable)
start D:\empire-rush\exports\html5\index.html

# Re-exportar tras cambios
D:\empire-rush\godot\godot.exe --headless --path D:\empire-rush --export-release "HTML5" D:\empire-rush\exports\html5\index.html

# Editor interactivo
D:\empire-rush\godot\godot.exe --path D:\empire-rush
```

## ¿Es adictivo desde el primer minuto? (honesto)

- **Loop se siente**: **PARCIAL** — la mecánica está completa y
  conectada en código (factory→pickup→shelf→client→cashier→
  stocker→warehouse→Economy), validada en headless. PERO el "feel"
  no se ha validado en navegador NINGUNA vez en 15 rondas. Nadie
  abrió `index.html` para jugar. Todo el smoke es headless, que no
  valida satisfacción táctil.
- **Satisfacción táctil**: **MALA** — recoger dinero es silencioso
  (sin partículas, sin sonido, sin tween de scale). El MoneyDrop
  tiene un pop-in tween pero nada más. Violación directa de
  BLUEPRINT §32.3 "dinero visible" (billetes, montones, dinero
  volando al contador, sonido agradable) y de la regla de oro del
  AGENTS.md "satisfacción táctil: recoger dinero debe tener feedback
  visual + sonoro inmediato". JUICE-1 y POLISH-1/2 pendientes desde
  r5.
- **Progreso visible**: **BUENO en cantidad, MEDIO en calidad** —
  16 pads pulsando con precios escalonados dan densidad de metas.
  PERO los placeholders son ColorRect planos (sin sprites, sin
  animación de construcción, sin glow). "Cada mejora debe verse"
  (§32.1) se cumple a medias: el pad desaparece y el negocio se
  activa, pero no hay animación impactante.
- **Meta cercana siempre visible**: **BUENO** — con 16 pads a la
  vista, el jugador siempre tiene 2-3 metas alcanzables. Cumple
  §32.2 "metas cortas/medianas/largas al mismo tiempo". PERO
  POLISH-5 (indicador de "próximo pad alcanzable" en HUD) no
  existe — el jugador debe encontrar los pads visualmente.
- **Primer minuto (§25)**: **HIPÓTESIS NO VERIFICADA** — los 4
  beats están en código (MissionGuide r8): 0-10s llena estante,
  10-20s primer cliente + dinero, 20-35s invierte (pad $120
  visible), 35-60s caos + cajero $100. PERO nunca se validó en
  navegador. El 4to beat (HIRE_HELP) ahora tiene cajero real
  (AUTO-1 r13), así que el flujo está completo en teoría.
- **Cómo se siente (§26)**: **PARCIAL** — "rápido/satisfactorio/
  progresivo/lleno de recompensas pequeñas" se cumple en estructura.
  "Cada 10s pasa algo" se cumple (clientes cada 3s, stockers cada
  2s, factory cada 3s). "Cada 1 min desbloquea algo" depende del
  balance (POLISH-6 pendiente). "Cada 5 min cambia visualmente" NO
  se cumple (sin evolución visual de negocios).
- **Qué es adictivo (§32)**: **3 de 7 elementos** — progreso visual
  (parcial), metas escalonadas (sí), desbloqueo constante (sí),
  automatización progresiva (sí, AUTO-1+AUTO-2). Faltan: dinero
  visible con feel (§32.3), competencia aspiracional (RNK-1),
  eventos sorpresa (EVT-1..3).
- **Qué cansa (§33)**: **RIESGO ALTO de repetición** — sin eventos,
  sin música, sin juice, el loop es "recoger→estante→cliente→
  dinero" en silencio. A los 5 min el jugador ha visto todo el
  contenido. La automatización (cajero+stocker) alivia el tedio
  manual PERO sin eventos no hay variación. Violación de §33.1
  "repetición excesiva".
- **Veredicto**: **"Necesita 4-6 rondas más de pulido (Fase B +
  JUICE-1 + SAVE-1 + EVT-1/2) antes de lanzar"**. El MVP es
  **funcional** (corre, no crashea, export HTML5 verde, cadena
  automatizada validada) pero **no es adictivo** (sin feel, sin
  variación, sin retención). Lanzarlo hoy fallaría el objetivo
  "éxito desde el primer lanzamiento" del AGENTS.md.

## Cómo puedo mejorar el MVP (recomendaciones accionables)

1. **JUICE-1: partículas + sonido + cash volando al HUD al recoger
   dinero** — es la brecha #1 hacia "adictivo". Recoger dinero es
   la acción más repetida del loop; si es silenciosa, el loop no
   engancha. Impacto: ALTO en adicción/retención. Esfuerzo: **S**.
2. **POLISH-3: screen shake suave al desbloquear zona** — el
   desbloqueo es el momento de mayor dopamina del loop; sin shake
   se siente plano. Impacto: ALTO en satisfacción. Esfuerzo: **S**.
3. **POLISH-2: tween de cash volando al HUD al recoger** — refuerza
   "dinero visible" (§32.3) y conecta la acción con el contador.
   Impacto: ALTO. Esfuerzo: **S**.
4. **SAVE-1: guardado local (localStorage en HTML5)** — sin save no
   hay retención día 1. El jugador pierde todo al refrescar.
   Impacto: ALTO en retención D1/D7. Esfuerzo: **S** (GameManager
   ya tiene `upgrades` dict + `zones_unlocked` listos para
   persistir).
5. **EVT-1 + EVT-2: eventos Rush Hour (2x clientes 60s) + VIP
   (paga triple)** — rompen la monotonía (§33.1) y dan "eventos
   sorpresa" (§32.7). Impacto: ALTO en variación. Esfuerzo: **S**
   c/u.
6. **POLISH-6: balance de precios validado en navegador** — los
   precios actuales ($5-$600) son estimaciones; sin playtest no se
   sabe si el progreso es ni muy lento ni muy rápido. Meta corta
   cada 1-2 min. Impacto: ALTO en feel. Esfuerzo: **S** (con
   validación navegador).
7. **GATE-3: smoke manual de 5 min en navegador validando los 4
   beats del primer minuto** — convierte la "hipótesis §25" en
   verificado. Es el gate que separa "funciona en headless" de
   "es jugable". Impacto: CRÍTICO para lanzar. Esfuerzo: **M**.
8. **EMP-1: rareza de empleados (común/raro/épico/legendario) +
   3 habilidades** — cierra capa 4 y añade variación a la
   automatización. Impacto: MEDIO en depth. Esfuerzo: **M**.
9. **RNK-1: ranking local con 30 bots** — meta aspiracional (§32.6)
   "ver a otros más avanzados motiva". Impacto: MEDIO en
   retención. Esfuerzo: **M**.
10. **POLISH-4: glow/pulso en pads de desbloqueo** — ya existe
    pulso amarillo básico, pero sin glow/shader los pads se
    confunden con el fondo. Impacto: MEDIO en claridad visual.
    Esfuerzo: **S**.
11. **POLISH-5: indicador de "próximo pad alcanzable" en HUD** —
    el jugador no debe buscar metas, las metas deben buscarlo.
    Impacto: MEDIO en onboarding. Esfuerzo: **S**.
12. **JUICE-2: música de fondo + SFX placeholders** — el silencio
    total es incómodo. Música lo-fi libre de licencia + SFX
    generados con Godot. Impacto: MEDIO en feel. Esfuerzo: **S**.
13. **POLISH-7: spawn rate de clientes ajustado para caos
    controlado** — con cashier+stocker el negocio es pasivo, el
    spawn rate debe escalar para mantener tensión. Impacto: MEDIO.
    Esfuerzo: **S**.
14. **EXP-2: landing page mínima** — `index.html` hoy sirve el
    juego plano; una landing con título + botón "Jugar" mejora la
    primera impresión. Impacto: BAJO en adicción, ALTO en
    presentación. Esfuerzo: **S**.
15. **MET-1: telemetría local (consola)** — mide las métricas del
    blueprint §23 (tiempo primera sesión, zonas desbloqueadas,
    eventos jugados). Base para iterar con datos, no con
    intuición. Impacto: ALTO en decisiones. Esfuerzo: **S**.

## Qué más puedo hacer (roadmap a versión 1.0 y más allá)

### Versión 1.0 (post-MVP) — Fase C
- **V1-1 Farmacia** + **V1-2 Electrónica** — 2 negocios nuevos
  siguiendo el patrón `Business` validado en r11. Cierran la
  promesa "5 negocios" del BLUEPRINT §8 y dan variedad visual.
- **V1-3 Fábrica avanzada** + **V1-4 Bodega+logística+camión** +
  **V1-5 Puerto** — escala el loop de "tienda" a "conglomerado"
  (§27). El patrón Factory (r12) es la base.
- **V1-6 Segunda ciudad** — primer paso de "imperio mundial".
- **V1-7 Ligas semanales** + **V1-8 Títulos** + **V1-20 Perfil
  público** — metas sociales y de status (§32.6).
- **V1-10 Empleados premium** — extensión natural de EMP-1.
- **V1-12 Pase de temporada** + **V1-13 Cofres transparentes** +
  **V1-14 IAP real** + **V1-15 Ads reales** — monetización.
- **V1-16 Daily Login + Daily Missions** + **V1-17 Eventos
  globales** + **V1-18 Logros** + **V1-19 Fatiga+reenganche** —
  retención D1/D7/D30 (§38, §36, §37, §40).
- **V1-23 Cloud save** — sync entre dispositivos.

### Versión 2.0
- Mall + bienes raíces + franquicias (BLUEPRINT §21).
- Ranking mundial avanzado + ligas por país.
- Temporadas por país + conglomerados.
- Personalización avanzada de marca.

### Versión 3.0
- Países + colaboración entre jugadores (§22).

### Lanzamiento mobile (Android/iOS)
1. **Export presets**: crear presets Android (APK + AAB) e iOS en
   `export_presets.cfg`. Instalar templates Android/iOS en
   `%APPDATA%/Godot/export_templates/4.3.stable/`.
2. **MOB-1 Touch controls**: joystick virtual + botón de acción
   (HUD mobile). Godot 4.3 soporta `InputEventScreenTouch` +
   `InputEventScreenDrag`.
3. **MOB-2 UI escalable**: `Theme` + `Control` anchors para
   vertical/horizontal. Test en 9:16 y 16:9.
4. **MOB-3 Performance**: profiler Godot <16ms/frame con 10 NPCs
   + 20 pickups. Optimizar `_physics_process` + draw calls.
5. **Android keystore**: generar keystore release
   `keytool -genkey -v -keystore empire.keystore`. Configurar en
   preset Android. NO commitear el keystore.
6. **Google Play Console**: cuenta $25, crear app, subir AAB,
   fill content rating, privacy policy, store listing.
7. **App Store Connect**: cuenta Apple Developer $99/año, crear
   app, subir IPA via Transporter, TestFlight beta, review.
8. **IAP real (V1-14)**: Godot `InAppPurchase` plugin para
   Android (Google Play Billing) e iOS (StoreKit). Probar sandbox.
9. **Ads reales (V1-15)**: AdMob plugin para Godot. Banner +
   recompensados. Configurar ad units en AdMob console.
10. **Ranking real (RNK-1 → online)**: backend Firebase /
    PlayFab / Supabase para ranking cross-device. Login anónimo
    + Google/Apple sign-in.
11. **Cloud save (V1-23)**: sync progreso via backend. Conflict
    resolution (last-write-wins o merge por timestamp).
12. **Comunidad**: Discord + Reddit + TikTok orgánico. Compartir
    clips del gameplay (el loop es visual, ideal para ads
    orgánicos).

## Métricas a medir desde el día 1
(BLUEPRINT §23 — implementar en MET-1)

- **Tutorial completion**: % jugadores que completan los 4 beats
  del MissionGuide. Objetivo >80%. Implementación: flag por beat
  en GameManager, log al completar.
- **Tiempo de primera sesión**: tiempo hasta primer cierre de
  app. Objetivo >8 min. Implementación: timer en GameManager,
  log al salir.
- **Sesiones por día**: count de app-opens por día. localStorage.
- **Retención D1/D3/D7**: % jugadores que vuelven día 1/3/7.
  Requiere SAVE-1 + timestamp último login.
- **Ads vistos por usuario**: count de ads recompensados vistos.
  Log al ver ad.
- **Compras por usuario**: count de IAP. Log al comprar.
- **Nivel donde abandonan**: último pad comprado / zona
  desbloqueada antes de dejar de jugar. Log al salir.
- **Zonas más desbloqueadas**: count por zona. Histograma.
- **Eventos más jugados**: count por evento (EVT-1/2/3). Log al
  iniciar evento.
- **Empleados más usados**: count contrataciones por empleado.
  Log al contratar.

Implementación: `MET-1` añade un `MetricsLogger` autoload que
escucha señales de GameManager/Economy y escribe a localStorage +
consola. En MVP sin backend, las métricas son locales (el
desarrollador las lee en consola). En 1.0+ se suben a backend.

## Riesgos y mitigaciones

- **Riesgo: lanzar sin feel validado en navegador** — 15 rondas
  sin abrir `index.html`. Mitigación: GATE-3 (smoke navegador 5
  min) es OBLIGATORIO antes de declarar "lanzado". Hacerlo en la
  próxima ronda.
- **Riesgo: "devin huérfano concurrente" cause parse error en
  producción** — r15 tuvo parse error transitorio por shelf.gd
  duplicado. Mitigación: `taskkill //F //IM devin.exe` al START
  de cada sesión (fix del controller, 6ta vez pendiente).
- **Riesgo: el overnight opere a 1/5 de capacidad para siempre**
  — 1 iter/ronda en r11-r15. Mitigación: controller con loop
  interno multi-iter + done-marker por iteración.
- **Riesgo: saltar Fase B (pulido) y lanzar MVP "funcional pero
  no adictivo"** — la presión de "lanzar ya" puede tentar a
  saltar POLISH-*. Mitigación: la re-priorización r15 explicita
  "No saltar a Fase C hasta que Fase B esté completa y el MVP
  sea adictivo según §25/§26/§32/§33".
- **Riesgo: balance roto sin playtest** — los precios $5-$600
  son estimaciones. Mitigación: POLISH-6 + GATE-3 con smoke
  navegador validando "meta corta cada 1-2 min".
- **Riesgo: sin save, retención D1 = 0%** — el jugador pierde
  todo al cerrar. Mitigación: SAVE-1 con localStorage HTML5
  (no solo `user://` que no persiste en web).
- **Riesgo: contenido insuficiente para 15-30 min de retención**
  — 5 negocios + automatización dan ~10-15 min de novedad.
  Mitigación: EVT-1/2/3 (eventos) + RNK-1 (ranking) + futuros
  negocios V1-1/2 extienden el contenido.
- **Riesgo: performance mobile con 16 pads + 10 NPCs + 20
  pickups** — sin profiler, no se sabe. Mitigación: MOB-3 con
  profiler Godot antes de export Android.

## Próximos pasos recomendados (esta semana)

1. **Fix del controller (proceso)** — editar
   `overnight/session.ps1` y `overnight/run_overnight.ps1`:
   (a) `taskkill //F //IM devin.exe` al START de cada sesión
   excepto el controller, (b) loop interno multi-iteración con
   done-marker por iteración, (c) commit WIP cada 10 min. Sin
   esto, el overnight sigue a 1/5 de capacidad y con race
   conditions. Commitear como `fix(controller): kill orphan
   devin + multi-iter + wip commits`.
2. **EMP-1** (cierra capa 4, 1 iter) — rareza de empleados +
   3 habilidades. Patrón Cashier/Stocker per-business.
3. **JUICE-1 + POLISH-2/3** (juice del loop, 1-2 iter) —
   partículas + sonido + cash volando al HUD + screen shake al
   desbloquear. Es lo que más impacta la satisfacción táctil.
4. **SAVE-1** (1 iter) — guardado local localStorage HTML5.
   Retención D1.
5. **EVT-1 + EVT-2** (1 iter) — eventos Rush Hour + VIP.
   Variación anti-monotonía.
6. **GATE-3: smoke manual de 5 min en navegador** — validar los
   4 beats del primer minuto (§25). Es el gate que separa
   "funciona en headless" de "es jugable". Hacerlo ANTES de
   declarar lanzado.
7. **POLISH-6: balance de precios** — ajustar tras GATE-3 para
   que el progreso sea ni muy lento ni muy rápido.
8. **Lanzamiento soft (HTML5)** — subir `exports/html5/` a
   itch.io o GitHub Pages. Compartir con 5-10 testers. Medir
   métricas MET-1. Iterar.

---

*Informe generado por fine-tuning ronda 15 (2026-07-05 08:52).
Ver `overnight/LEARNINGS.md` sección "Ronda 15 — Fine-tuning"
para las lecciones detalladas que originan este informe.*
