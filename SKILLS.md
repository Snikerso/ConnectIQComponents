<!-- managed by codex-skills installer -->
# Skille tego projektu

Źródło: [Snikerso/codex-skills](https://github.com/Snikerso/codex-skills).
Zestaw projektu jest zapisany w [manifeście](.codex/skills.json).

Skille projektowe:

- Brak skilli instalowanych wyłącznie w tym projekcie.

Skille globalne są dobierane do rodzaju zadania. Ich zestaw odtwarza profil `global` w centralnym repo.
Dostępne lub szczególnie przydatne w tym projekcie: `digitalocean`, `fusion-3d-design`, `fusion-materials-textures`, `garmin-watch-app-release`, `linkedin-post-creator`, `project-media-brief`, `social-3d-content`, `video-editor-reels`.

## Nowy komputer

Sklonuj centralne repo do stałego katalogu. Z katalogu tego projektu uruchom (podstaw lokalizację repo skilli):

```sh
git clone https://github.com/Snikerso/codex-skills.git /sciezka/codex-skills
python3 /sciezka/codex-skills/scripts/install.py --profile global
python3 /sciezka/codex-skills/scripts/install.py --project .
```

Gdy masz tylko centralne repo i nową kopię projektu, profil jest też dostępny centralnie:

```sh
python3 /sciezka/codex-skills/scripts/install.py --profile connectiqcomponents --project . --document
```

Manifest i tę dokumentację przechowuj w Git projektu. Lokalne dowiązania są ignorowane przez Git; nie kopiuj ich między komputerami.
Skille aktualizujesz przez `git pull --ff-only` w centralnym repo. Nie przenoś go po instalacji; po przeniesieniu uruchom instalator ponownie.
Konflikty są zatrzymywane; `--backup-conflicts` zachowuje dotychczasową instalację w kopii zapasowej.
Sekrety, konta, SDK i zależności aplikacji konfiguruje się osobno. Sam skill nie udziela dostępu do usług.
