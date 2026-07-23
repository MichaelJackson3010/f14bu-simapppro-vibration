# F-14B(U) Tomcat — WinWing Vibration Support

Anytime, baby — now with feedback. This adds the **F-14B(U)** (Heatblur's
upgraded Tomcat) to WinWing SimAppPro's vibration system, so your WinWing
stick and throttle shake with:

- 🌀 **AoA buffet** — the wing rock warning before the Tomcat departs
- 💥 **Weapon release and cannon fire**
- 🛬 **Gear travel and trap thump**
- 💨 **Speedbrakes, control surfaces and G-loading**
- 👥 Works in **both seats** — pilot and RIO

WinWing supports the classic F-14A/B but hasn't added the new F-14B(U) yet,
so it doesn't appear in SimAppPro. This project fixes that with a small,
fully reversible setup — your B(U) starts with **WinWing's own F-14B
vibration curves**, and if you've tuned custom Tomcat curves, they carry
over automatically.

> Fan project — not affiliated with WinWing or Heatblur, and no WinWing or
> Heatblur files are included. Everything is set up from files already in
> **your own** installation.

## Install

1. Click the green **Code** button (top of this page) → **Download ZIP**, and
   extract it anywhere.
2. Right-click **`install.ps1`** → **Run with PowerShell**.
   - The script first shows you a summary of what it will change and waits
     for you to press Enter.
   - Windows will then show an administrator (UAC) prompt — that's needed to
     edit one SimAppPro file inside Program Files. A backup of that file is
     made automatically first.
3. SimAppPro restarts by itself. Select **DCS** on the vibration page — the
   **F-14B(U)** tile is now in the aircraft row. Fights on!

Want more buffet, earlier? Switch your device to **Advanced** in SimAppPro
and drag the curves around in the built-in editor.

## Is this safe?

Healthy question — random scripts from the internet *should* make you pause.
Here's exactly what's going on, and how to check it yourself:

- **The script is ~130 lines and open for you to read.** Right-click
  `install.ps1` → **Edit** opens it in Notepad. Every step is commented in
  plain English.
- **It downloads nothing and sends nothing.** No internet access, no
  telemetry, no accounts. It only copies files that are already on your PC.
- **It doesn't touch DCS or your Tomcat module at all.** All changes are on
  the SimAppPro side.
- **The one real change** is adding "F-14B(U)" to the aircraft list inside a
  SimAppPro file (`app.asar`). The original is saved as `app.asar.bak` right
  next to it before anything is modified. (Technical note: the entry it
  replaces is a leftover for a module folder name modern DCS no longer uses —
  the MiG-29A, MiG-29 Fulcrum and Flaming Cliffs entries are all separate and
  untouched.)
- **Why the admin prompt?** That one file lives in `C:\Program Files (x86)`,
  which Windows protects. That's the only reason.
- **Why does Windows warn me about the script?** Windows shows a warning for
  *any* PowerShell script that isn't digitally signed by a company. Hobby
  projects like this one aren't signed — the warning is about the signature,
  not the contents.

## Undo / uninstall

Everything is reversible in two minutes:

1. Close SimAppPro. In `C:\Program Files (x86)\SimAppPro\resources\`, delete
   `app.asar` and rename `app.asar.bak` back to `app.asar`.
2. Delete the `F-14BU` and `F-14BU_RIO` folders in:
   - `C:\Program Files (x86)\SimAppPro\resources\app.asar.unpacked\Events\DynamicVibrationMotor\DCS\`
   - `%APPDATA%\SimAppPro\ShakeEffect\default\DCS\` and `...\active\DCS\`

## Good to know

- **SimAppPro updates undo this** (updates replace the files we change). Fix:
  run `install.ps1` again — takes 30 seconds. Any curves you tuned yourself
  are kept safe in `%APPDATA%` and survive both updates and re-installs.
- The RIO seat uses a copy of the pilot curves. To tune the RIO seat
  separately, edit the files in
  `%APPDATA%\SimAppPro\ShakeEffect\active\DCS\F-14BU_RIO\` directly.
- If WinWing ships official F-14B(U) support one day, the installer notices
  and steps aside automatically.
- Flying the F-100D Super Sabre too? Same treatment here:
  [f100d-simapppro-vibration](https://github.com/MichaelJackson3010/f100d-simapppro-vibration).

## Credits

- Research and testing: MichaelJackson3010
- Reverse engineering done with Claude (Anthropic)
- Thanks to Heatblur for the Tomcat and WinWing for hardware that shakes

*Curious how it all works under the hood? See
[TECHNICAL.md](https://github.com/MichaelJackson3010/f100d-simapppro-vibration/blob/main/TECHNICAL.md)
in the F-100D repo for the full write-up of SimAppPro's vibration internals —
everything there applies here too, except the B(U) needs no detection stub
(its module folder already sits where SimAppPro scans).*
