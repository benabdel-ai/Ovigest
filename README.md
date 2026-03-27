# Troupeau Ovins

Application Flutter de gestion simple de troupeau ovins avec suivi global :
- tableau de bord
- cheptel global
- dépenses
- revenus
- historique

## Ce qui a été préparé

- interface mobile revue avec boutons plus grands
- navigation complète avec historique
- structure pensée pour GitHub + Codemagic
- pipeline de build qui régénère les fichiers plateforme automatiquement

## Lancer localement

```bash
flutter create . --platforms=android,web
flutter pub get
flutter run
```

## Build Android

```bash
flutter create . --platforms=android,web
flutter pub get
flutter build apk --release
```

## Build Web

```bash
flutter create . --platforms=android,web
flutter pub get
flutter build web --release
```

## Mise sur GitHub

```bash
git init
git add .
git commit -m "Initial commit"
git branch -M main
git remote add origin <URL_DU_REPO>
git push -u origin main
```

## Codemagic

Le fichier `codemagic.yaml` est inclus.

Workflow prévu :
1. régénération des dossiers plateforme (`flutter create . --platforms=android,web`)
2. installation des dépendances
3. analyse du code
4. build APK release
5. build web release

## Remarque

Si tu veux publier plus tard sur Play Store, il faudra ajouter une vraie signature release Android au lieu de la configuration de debug par défaut.
