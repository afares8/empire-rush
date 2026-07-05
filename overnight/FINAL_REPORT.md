# Trade Empire Rush — Informe Final del Overnight (5 rondas)

> Generado por la sesión de fine-tuning de la ronda 5
> (2026-07-05 04:38). Análisis honesto y crítico del estado real
> del MVP después de 5 rondas de overnight automatizado.

## Fase alcanzada

- **Fase al final de la ronda 5**: **A (construyendo MVP)** — capa 2
  parcialmente completa, capas 3-6 sin tocar.
- **Justificación**: en git/main solo existen 9 items completados:
  GODOT-1..3 (capa 1) y LOOP-1..6 (capa 2, sin LOOP-7/8/9). No hay
  export HTML5, no hay HUD, no hay pad de desbloqueo, no hay
  contenido (capa 3), no hay automatización (capa 4), no hay
  retención (capa 5), no hay lanzamiento (capa 6).
- **¿Avanzó A → B → C correctamente?**: NO. Se quedó estancado en
  Fase A, ni siquiera completó la capa 2.
- **¿Se saltó la Fase B (pulido)?**: SÍ, pero no porque la haya
  saltado intencionalmente — porque nunca llegó a ella. No hay
  riesgo de anti-patrón "saltarse el pulido"; hay un problema más
  grave: ni siquiera se completó el MVP base.

## Estado del MVP

### Lo que se construyó (en git/main, verificado)

**Capa 1 — Engine + proyecto base** (completa):
- Godot 4.3 stable portable en `godot/godot.exe`
- `project.godot` válido con autoloads `Economy` y `GameManager`
- `scenes/Main.tscn` arranca sin crash

**Capa 2 — Loop base** (parcial, 6 de 9 items):
- `scripts/game/player.gd` + `scenes/Player.tscn` — CharacterBody2D,
  WASD, bob + squash/stretch, carry system (LOOP-1)
- `scripts/game/camera.gd` — Camera2D con smoothing exponencial +
  look-ahead (LOOP-2)
- `scripts/game/pickup.gd` + `scenes/Pickup.tscn` — producto
  recogible con stock regenerable (LOOP-3)
- `scripts/game/shelf.gd` + `scenes/Shelf.tscn` — estante
  reponible con E (LOOP-4)
- `scripts/game/client.gd` + `client_spawner.gd` +
  `scenes/Client.tscn` — NPC cliente con FSM spawn→walk→buy→exit
  (LOOP-5)
- `scripts/game/money_drop.gd` + `scenes/MoneyDrop.tscn` — dinero
  físico recogible, suma a Economy.cash (LOOP-6)

### Lo que NO se construyó (a pesar de que los logs lo claimen)

**LOOP-7, LOOP-8, LOOP-9 fueron implementados 3 veces (rondas 3, 4,
5) pero NUNCA llegaron a git**. Los logs de r3/r4/r5 reportan
"Estado: completado" con smoke tests pasando, pero el controller
hizo timeout a 45 min y mató el proceso devin ANTES del `git commit`.
Verificación: `git ls-tree -r main --name-only | grep -E "unlock|hud"`
devuelve vacío. No existe `scripts/game/unlock_pad.gd`, no existe
`scripts/ui/hud.gd`, no existe `scenes/HUD.tscn`, no existe
`scripts/ui/mission_guide.gd`.

**Items pendientes**:
- LOOP-7 (pad de desbloqueo) — eslabón "invertir → expandir"
- LOOP-8 (HUD base) — sin esto el jugador no ve su cash
- LOOP-9 (primer minuto guiado) — sin esto no hay onboarding
- Toda capa 3 (BIZ-1..5: 3 negocios + taller + almacén)
- Toda capa 4 (AUTO-1..2, UPG-1..5, EMP-1: empleados + upgrades)
- Toda capa 5 (EVT-1..3, RNK-1, MON-1..2, SAVE-1, OFF-1, JUICE-1..2)
- Toda capa 6 (EXP-1 export HTML5, EXP-2 landing, MET-1 métricas)

### Export HTML5

- **Estado**: **FAIL**
- No existe `export_presets.cfg` en el repo.
- No existe `exports/html5/index.html`.
- El directorio `exports/html5/` existe pero está vacío.
- **Esto es CRÍTICO**: el MVP no es jugable en navegador. Todo el
  "smoke" de las 5 rondas fue headless (`--quit-after N`), que NO
  valida `_physics_process`, ni `body_entered` de Area2D, ni el
  feel real del loop. El juego podría crashear al primer input en
  navegador y no lo sabríamos.

### Cómo probarlo (lo que existe hoy)

```bash
# Headless smoke (valida boot + _process, NO valida feel real)
cd /d/empire-rush
DEVIN_SMOKE=1 ./godot/godot.exe --headless --path . --quit-after 300

# Abrir en editor (interactivo, valida feel real)
./godot/godot.exe --path .

# Export HTML5 (FALLA — no hay export_presets.cfg)
./godot/godot.exe --headless --path . --export-release "HTML5" exports/html5/index.html
```

## ¿Es adictivo desde el primer minuto? (honesto)

**Veredicto parcial previo: NO.** El loop base está conectado en
código (recoger → vender → cobrar funciona en headless con
`DEVIN_SMOKE=1`), pero faltan 3 eslabones críticos para siquiera
evaluar la adicción:

- **Loop se siente**: **NO EVALUABLE** — sin HUD (LOOP-8), el
  jugador no ve su cash subir. Sin pad de desbloqueo (LOOP-7), no
  hay meta cercana. Sin export HTML5, no se puede probar en
  navegador. El loop "funciona" en código pero no se siente porque
  no hay feedback visual del progreso.
- **Satisfacción táctil**: **PARCIAL** — hay pop de scale al
  recoger producto (CarryBox) y al recoger dinero (MoneyDrop
  pop-in TRANS_BACK), pero NO hay partículas, NO hay sonido, NO hay
  cash volando al HUD (no hay HUD). El feedback es mínimo.
- **Progreso visible**: **NO** — sin HUD, el cash solo existe en
  `Economy.cash` (interno). El jugador no ve números subiendo.
- **Meta cercana siempre visible**: **NO** — sin LOOP-7 (pad de
  desbloqueo) y sin LOOP-9 (misión guiada), no hay ninguna meta
  visible. El jugador no sabe qué hacer después de recoger dinero.
- **Primer minuto (§25)**: **NO CUMPLE** —
  - 0-10s "Llena tu primer estante": el jugador puede recoger y
    llenar, pero no hay texto que lo guíe (LOOP-9 perdido).
  - 10-20s "Recoge tu dinero": el dinero cae pero no hay texto ni
    HUD que muestre el contador.
  - 20-35s "Invierte para crecer": no hay pad de desbloqueo
    (LOOP-7 perdido).
  - 35-60s "Contrata ayuda": no hay empleados (capa 4 sin tocar).
- **Cómo se siente (§26)**: **NO CUMPLE** — "rápido/satisfactorio/
  cada 10s pasa algo" no se puede evaluar sin jugarlo en navegador.
  En headless, los clientes spawnean cada 3s y compran, pero sin
  feedback visual/sonoro, no hay "satisfacción táctil".
- **Qué es adictivo (§32)**: **NO CUMPLE** —
  - Progreso visual inmediato: NO (sin HUD, sin desbloqueo visible).
  - Metas cortas/medianas/largas: NO (sin pads ni misión guiada).
  - Dinero visible: PARCIAL (MoneyDrop cae, pero no vuela al HUD
    porque no hay HUD).
  - Desbloqueo constante: NO (sin LOOP-7).
  - Automatización progresiva: NO (capa 4 sin tocar).
  - Competencia aspiracional: NO (sin ranking).
  - Eventos sorpresa: NO (capa 5 sin tocar).
- **Qué cansa (§33)**: **RIESGO ALTO** — el loop actual es
  "recoger → llenar estante → repetir" sin variación. Sin
  desbloqueo, sin empleados, sin eventos, el jugador hace lo mismo
  por siempre. Esto es exactamente el riesgo §33.1 "Repetición
  excesiva".

**Veredicto final**: **"Necesita 3-5 rondas más de pulido + rework
de LOOP-7/8/9 + export HTML5"**. El MVP no está listo para lanzar.
No es adictivo porque no se puede siquiera jugar completo en
navegador. El cimiento (capa 1 + 6 items de capa 2) es sólido y
bien hecho (código limpio, duck-typing, headless-safe), pero falta
el eslabón final del loop (invertir → expandir), el feedback visual
(HUD) y el vehículo de entrega (export HTML5).

## Cómo puedo mejorar el MVP (recomendaciones accionables)

Ordenadas por impacto/esfuerzo (las primeras son las que más
acercan el MVP a "adictivo desde el primer minuto"):

1. **Re-hacer LOOP-7 (pad de desbloqueo) y commitear** — sin esto
   no hay meta cercana ni eslabón "invertir → expandir". Es el item
   más crítico faltante. — **esfuerzo S** (ya fue implementado 3
   veces, solo hay que landearlo en git).
2. **Re-hacer LOOP-8 (HUD) y commitear** — sin HUD el jugador no ve
   su cash subir, lo que rompe §32.3 "Dinero visible" y toda la
   satisfacción táctil. — **esfuerzo S**.
3. **Configurar EXP-1 (export HTML5) YA** — sin export no hay MVP
   jugable. Es P0 y debería haberse hecho en ronda 1. Mover al
   inicio de capa 2 como gate. — **esfuerzo M** (configurar
   preset, descargar web export template, smoke en navegador).
4. **Re-hacer LOOP-9 (misión guiada contextual)** — cierra el
   primer minuto §25. Sin esto el jugador no sabe qué hacer. —
   **esfuerzo S**.
5. **JUICE-1 + POLISH-2: cash volando al HUD + partículas al
   recoger** — esto es lo que hace que recoger dinero se sienta
   satisfactorio (§32.3). Sin esto el loop es "clic → número sube
   invisible". — **esfuerzo S**.
6. **POLISH-4: glow/pulso en pads de desbloqueo** — llama la
   atención sobre la meta cercana (§32.2 "Meta corta siempre
   visible"). — **esfuerzo S**.
7. **BIZ-1 (puesto callejero) + BIZ-2 (perfumes)** — el contenido
   da variación al loop y evita §33.1 "Repetición excesiva". —
   **esfuerzo M**.
8. **AUTO-1 (empleado cajero)** — la transición "yo trabajo → mi
   imperio trabaja por mí" (§32.5) es lo que engancha a mediano
   plazo. — **esfuerzo M**.
9. **SAVE-1 (guardado local)** — sin save, el jugador pierde todo
   al refrescar. Para HTML5 usar `localStorage` (no `user://` que
   no existe en web). — **esfuerzo S**.
10. **EVT-1 (Rush Hour 60s)** — eventos sorpresa (§32.7) rompen la
    monotonía. — **esfuerzo S**.
11. **RNK-1 (ranking local con bots)** — competencia aspiracional
    (§32.6). — **esfuerzo M**.
12. **POLISH-6 (balance de precios)** — ajustar para meta corta
    cada 1-2 min (§33.2 "Progreso demasiado lento"). — **esfuerzo S**.
13. **Touch controls (MOB-1)** — el MVP es mobile-first según
    BLUEPRINT; sin touch no se puede probar en teléfono. — **esfuerzo S**.
14. **JUICE-2 (música + SFX placeholders)** — el audio es 50% del
    feel. Generar con Godot o usar freesound CC0. — **esfuerzo S**.
15. **Fix del controller overnight** — sin arreglar el timeout-antes-
    de-commit, las próximas rondas seguirán perdiendo trabajo. Ver
    LEARNINGS ronda 5 lección de proceso #1. — **esfuerzo S**.

## Qué más puedo hacer (roadmap a versión 1.0 y más allá)

### Versión 1.0 (post-MVP) — Fase C

Cerrar el gap entre el MVP y BLUEPRINT §20. Items ya listados en
ROADMAP `## FASE C` (V1-1..V1-23). Prioridad realista:

- **V1-21 (export Android) + V1-22 (export iOS)** — el MVP es
  mobile-first; sin esto no hay lanzamiento real.
- **V1-14 (IAP real) + V1-15 (AdMob recompensado)** — monetización
  real. Solo después de validar retención orgánica del MVP.
- **V1-7 (ligas semanales) + V1-16 (daily missions)** — retención
  diaria (§38).
- **V1-17 (eventos globales) + V1-18 (logros)** — variedad (§33.1).
- **V1-19 (sistema de fatiga + reenganche)** — anti-churn (§40).
- **V1-23 (cloud save)** — sync entre dispositivos.
- **V1-1..V1-6 (negocios nuevos + fábrica + bodega + puerto +
  segunda ciudad)** — contenido de escala (§27 diferenciador).

### Versión 2.0

- Sistema de clanes/conglomerados (§34, §35 visitas a imperios).
- IA dentro del juego (§18 — NPCs con comportamiento emergente,
  mercado dinámico).
- Sistema económico profundo (oferta/demanda, precios dinámicos).
- Temporadas con tema + battle pass expandido.
- Social real: regalos diarios, chat predefinido, visitas.

### Versión 3.0

- Multi-ciudad global con logística intercontinental.
- Modo "imperio" strategic-layer encima del loop tycoon.
- Marketplace entre jugadores (subastas, contratos).
- Esports tycoon: torneos con prize pool ficticio.
- Expansión a otras temáticas (restaurante, tech, moda).

### Lanzamiento mobile (Android/iOS)

Pasos concretos:

**Android**:
1. Instar Godot Android export template (descargar junto con el
   editor o vía `godot --export-templates`).
2. Configurar `export_presets.cfg` con preset Android (keystore,
   package name `com.tuempresa.empireRush`, version code/name).
3. Generar keystore: `keytool -genkey -v -keystore release.keystore
   -alias empire_rush -keyalg RSA -keysize 2048 -validity 10000`.
4. Exportar AAB (no APK — Google Play requiere AAB): `godot
   --headless --export-release "Android" empire_rush.aab`.
5. Crear cuenta Google Play Console ($25 una vez), completar
   listing, subir AAB a internal testing → closed → open →
   production.
6. Integrar AdMob via plugin Godot (Godot AdMob plugin) para ads
   recompensados reales (V1-15).
7. Integrar Google Play Billing via plugin para IAP (V1-14).
8. Configurar Play Games Services (logros + ranking global).

**iOS**:
1. Instalar Godot iOS export template.
2. Tener Mac con Xcode + cuenta Apple Developer ($99/año).
3. Configurar preset iOS (bundle ID, signing, provisioning
   profile).
4. Exportar Xcode project desde Godot, abrir en Xcode, firmar,
   archivar → subir a App Store Connect via Transporter.
5. Integrar AdMob (Google Mobile Ads SDK via plugin).
6. Integrar StoreKit 2 para IAP.
7. Integrar Game Center (logros + leaderboard).
8. App Review (Apple es más estricta — cuidar §16 niños, sin
   loot boxes agresivas, IAP claros).

**Comunidad + cloud**:
- Backend: Firebase (Auth, Firestore, Cloud Functions) o Supabase
  (más simple, PostgreSQL + auth + realtime).
- Cloud save: sincronizar `save.json` con Firestore/Supabase.
- Ranking global: tabla `players` con Empire Value, query top 100.
- Login: Google Sign-In (Android) + Sign in with Apple (iOS,
  obligatorio si hay otros logins).
- Comunidad: empezar con ranking + daily missions (§38); clanes
  en 2.0.

## Métricas a medir desde el día 1

De BLUEPRINT §23, implementar telemetría local (MET-1) primero,
remota (Firebase Analytics / Mixpanel) en 1.0:

- **Tiempo de primera sesión** — ¿el jugador juega 15-30 min?
  Si abandona antes de 5 min, el primer minuto falla (§25).
- **Zonas desbloqueadas por sesión** — mide progreso. Si <1 en
  5 min, el balance de precios está roto (§33.2).
- **Eventos jugados por sesión** — mide variedad. Si 0, el juego
  es repetitivo (§33.1).
- **Ads recompensados vistos** — mide monetización. Si 0, el botón
  no es atractivo o no está visible.
- **Día de retorno (D1/D7/D30)** — retención. Lo más importante.
  Medir con cloud save + analytics.
- **Empire Value al fin de sesión** — progreso total.
- **Empleados contratados** — mide si el jugador llega a
  automatización (§32.5).
- **Tasa de crash** — estabilidad. Crítico para no perder
  jugadores por bugs.
- **FPS promedio** — performance. <30 FPS en mobile = churn.
- **Tiempo hasta primer desbloqueo** — si >2 min, el onboarding
  es lento (§25 20-35s).

Implementación: `GameManager` ya tiene `session_time`,
`events_played`, `ads_watched`. Falta loguear a archivo/localStorage
al cerrar sesión + enviar a analytics en 1.0.

## Riesgos y mitigaciones

- **Riesgo CRÍTICO — El overnight pierde trabajo por timeout antes
  de commit**: las próximas rondas seguirán perdiendo items si no
  se arregla el controller. **Mitigación**: `session.ps1` debe
  hacer `git commit -am "WIP ronda N iter M"` al final de cada
  iteración, ANTES de escribir el snapshot. El controller debe
  hacer `git commit -am "auto-snapshot ronda N"` antes de matar el
  proceso en timeout. Subir timeout a 90 min.
- **Riesgo — Sin export HTML5, deuda técnica invisible**: features
  que pasan headless pero crashean en navegador. **Mitigación**:
  EXP-1 como gate P0 al inicio de capa 2; cada snapshot debe
  reportar "Export HTML5 OK" además de "Headless run OK".
- **Riesgo — Loop repetitivo (§33.1)**: con 1 producto y 1 estante,
  el loop aburre en 2 min. **Mitigación**: BIZ-1..3 (3 negocios)
  + EVT-1 (Rush Hour) + AUTO-1 (empleado) antes de declarar MVP
  "adictivo".
- **Riesgo — Sin save, churn al refrescar**: en HTML5, `user://`
  no persiste entre recargas. **Mitigación**: SAVE-1 con
  `localStorage` (JavaScript bridge) o `IndexedDB`.
- **Riesgo — Performance mobile**: ColorRect placeholders son
  baratos, pero 50+ NPCs + pickups pueden bajar FPS. **Mitigación**:
  object pooling para clientes/money drops, culling fuera de cámara.
- **Riesgo — Apple reject por loot boxes**: §16 niños. **Mitigación**:
  cofres con probabilidades visibles (V1-13), no aleatorias ocultas.
- **Riesgo — Devin huérfano concurrente**: el watchdog no mata
  huérfanos correctamente. **Mitigación**: `taskkill //F //IM
  devin.exe` al inicio de cada ronda.

## Próximos pasos recomendados (esta semana)

1. **Arreglar el controller overnight** (`run_overnight.ps1`):
   commit automático al final de cada iteración + antes de
   timeout-kill + `git reset --hard` al inicio de cada ronda +
   `taskkill //F //IM devin.exe` al inicio. Sin esto, correr más
   rondas es tirar tiempo a la basura.
2. **Correr 1 ronda corta (90 min) con scope limitado a 2 items S**:
   EXP-1 (export HTML5) + LOOP-7 (pad de desbloqueo). Validar que
   el commit llega a git y el export funciona en navegador.
3. **Correr 1 ronda más con LOOP-8 (HUD) + LOOP-9 (misión guiada)
   + JUICE-1 (cash volando + partículas)**. Esto cierra capa 2 con
   feel real y deja el MVP "jugable y adictivo en navegador".
4. **Smoke manual en navegador**: abrir `exports/html5/index.html`,
   jugar 5 min, verificar §25 (primer minuto). Si no engancha,
   ajustar balance (POLISH-6) antes de agregar contenido.
5. **Recién entonces**: capa 3 (BIZ-1..3) + capa 4 (AUTO-1) en
   rondas siguientes. No antes — el loop debe sentirse bien con 1
   negocio antes de agregar 3.

**No correr 5 rondas de overnight seguidas sin arreglar el
controller primero.** Cada ronda perdida es 45 min de compute
tirados. Mejor 1 ronda de 90 min que landee 2 items en git que 5
rondas que reportan "completado" pero no commitean nada.
