# AGENTS.md instructions for d:\AL\cdc-pinpad

<INSTRUCTIONS>
## Skills
A skill is a set of local instructions to follow that is stored in a `SKILL.md` file.

### Source of truth
- Revisar primero `./SKILLS.md` (raíz) para ver el catálogo de skills y reglas de activación del proyecto.
- La skill local principal para este repositorio está en `./skills/al-alto-nivel/SKILL.md`.
- Para mejores prácticas AL, usar como referencia oficial Microsoft Learn (links curados en `./skills/al-alto-nivel/references/microsoft-learn-al.md`).

### Available skills
- al-alto-nivel: Guía de programación AL de alto nivel para Business Central (diseño, calidad, rendimiento, pruebas y patrones para extensiones POS/pinpad). Úsala para cualquier cambio en archivos `.al` de este repositorio. (file: ./skills/al-alto-nivel/SKILL.md)

### How to use skills
- Discovery: La skill local disponible para este proyecto es `al-alto-nivel`; su cuerpo está en la ruta indicada.
- Trigger rules:
  - Si la tarea toca archivos `.al`, aplicar `al-alto-nivel` de forma obligatoria.
  - Si el usuario nombra la skill explícitamente, aplicarla.
- Coordination and sequencing:
  - Si hay múltiples skills aplicables, usar el conjunto mínimo y comenzar por `al-alto-nivel` para fijar criterios de calidad AL.
- Context hygiene:
  - Cargar solo lo necesario de la skill y mantener respuestas enfocadas en el cambio solicitado.
- Safety and fallback:
  - Si la ruta de la skill no puede leerse, continuar con buenas prácticas AL estándar y reportarlo brevemente.
</INSTRUCTIONS>
