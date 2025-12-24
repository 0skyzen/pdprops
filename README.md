# Police Department Props System

FiveM script pre správu policejných props (kužele, spike strips, bariéry) pre ESX framework.

## Popis

Tento script umožňuje policajtom nosiť, klásť a odstraňovať policejné props pomocou inventárových itemov. Props sa automaticky synchronizujú medzi hráčmi a majú realistické animácie a fyziku.

## Funkcie

- **Nosenie props** - Hráči môžu použiť item z inventára na vytiahnutie propu
- **Kladenie props** - Props sa môžu položiť na zem s realistickou animáciou
- **Odstraňovanie props** - Props sa môžu odstrániť pomocou ox_target a vrátiť sa do inventára
- **Spike strips** - Automaticky poškodzujú pneumatiky vozidiel pri prejazde
- **Cooldown systém** - Zabráni spamovaniu kladenia props
- **Job restriction** - Iba policajti môžu používať props

## Podporované Props

- **pd_cone** - Dopravný kužeľ (`prop_roadcone02a`)
- **pd_spikestrip** - Spike strip (`p_ld_stinger_s`)
- **pd_barrier** - Bariéra (`prop_barrier_work05`)

## Závislosti

- [ox_lib](https://github.com/overextended/ox_lib) - Pre UI a utility funkcie
- [ox_target](https://github.com/overextended/ox_target) - Pre interakcie s props
- [ox_inventory](https://github.com/overextended/ox_inventory) - Pre správu inventára
- [ESX](https://github.com/esx-framework/esx_core) - Framework

## 🔧 Inštalácia

1. Stiahnite a umiestnite script do vášho `resources` priečinka
2. Pridajte do `server.cfg`:
   ```
   ensure pdprops
   ```
3. Vytvorte itemy v `ox_inventory/data/items.lua`:
   ```lua
    ['pd_cone'] = {
        label = 'Policejní kužel',
        weight = 500,
        stack = true,
        close = true,
        server = {
            export = 'pdprops.useItem'
        }
    },
    ['pd_spikestrip'] = {
        label = 'Ostnatý pás',
        weight = 2000,
        stack = true,
        close = true,
        server = {
            export = 'pdprops.useItem'
        }
    },
    ['pd_barrier'] = {
        label = 'Policejní bariéra',
        weight = 3000,
        stack = true,
        close = true,
        server = {
            export = 'pdprops.useItem'
        }
    },
   ```

## Použitie

### Pre hráčov:
1. Použite item z inventára (`pd_cone`, `pd_spikestrip`, alebo `pd_barrier`)
2. Prop sa automaticky vytiahne a hráč ho drží
3. Stlačte **E** pre polozenie propu na zem
4. Stlačte **X** pre schovanie propu (odstránenie bez vrátenia do inventára)

### Pre odstránenie props:
1. Priblížte sa k položenému propu
2. Použite ox_target interakciu "Odstrániť objekt"
3. Po dokončení progress baru sa prop odstráni a vráti do vášho inventára

## Konfigurácia

V súbore `client/pdprops/pdprops.lua` môžete upraviť:

```lua
local Config = {
    TextUI = 'ox_lib' -- 'ox_lib' alebo 'sk_textui'
}
```

## Animácie

- **Kužele**: `anim@move_m@trash` - `idle`
- **Spike strips**: `anim@heists@box_carry@` - `idle`
- **Bariéry**: `anim@heists@box_carry@` - `idle`

## Job Restriction

Script je obmedzený na tieto joby:
- `police`
- `sheriff`
- `sahp`

## Poznámky

- Spike strips automaticky poškodzujú všetky pneumatiky vozidiel pri prejazde
- Cooldown 4 sekundy medzi kladením props
- Props sa synchronizujú medzi všetkými hráčmi
- Odstránenie props trvá 3.5 sekundy s progress barom

