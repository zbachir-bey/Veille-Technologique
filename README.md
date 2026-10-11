# Veille IA & Cybermenaces

Outil de veille technologique automatisé sur l'usage de l'intelligence artificielle en cybersécurité, côté attaquants comme côté défenseurs. Projet réalisé dans le cadre du BTS SIO option SISR.

## Thème

L'IA change l'équilibre entre attaque et défense. Ce projet suit son évolution selon quatre axes :

1. **IA et failles** : découverte et exploitation de vulnérabilités (noyau Linux, applications), génération d'exploits.
2. **IA et attaques** : malwares, phishing, attaques DDoS, fuites de données facilités par l'IA.
3. **Sécurité des LLM** : jailbreaks, injections de prompt, fuites de données, déploiement sécurisé.
4. **Ouverture jeux vidéo** : triche assistée par IA, contournement de protections, détournement de systèmes.

## Fonctionnement

L'outil collecte les actualités, les filtre, les classe, puis les publie sous forme d'alertes et de tableau de bord.

```
Sources (RSS / API) -> n8n -> filtrage et classement -> alerte Discord
                                      |
                                      +-> articles.json -> GitHub -> GitHub Pages (tableau de bord)
```

1. **Collecte** : toutes les heures, un workflow n8n interroge les sources (flux RSS, API). Les sources couvrent les organismes officiels (CERT-FR, base CVE), l'actualité du noyau Linux, les communautés (Reddit, Hacker News), les réseaux sociaux ouverts (Bluesky, Mastodon) et des blogs de sécurité.
2. **Nettoyage** : fusion des flux, suppression des doublons, normalisation (titre, date, source, lien).
3. **Filtrage** : seuls les articles contenant des mots-clés pertinents sont conservés (par exemple `LLM`, `kernel`, `CVE`, `exploit`, `jailbreak`, `DDoS`, `cheat`).
4. **Classement** : chaque article reçoit une catégorie correspondant aux axes du thème. Un résumé court peut être généré par un modèle d'IA via une API.
5. **Alertes** : les articles jugés importants sont envoyés sur Discord par webhook, avec le titre, la catégorie et le lien direct vers la source d'origine.
6. **Publication** : chaque article est ajouté à `articles.json`, poussé sur ce dépôt. GitHub Pages republie automatiquement le tableau de bord, qui lit ce fichier et propose des filtres par catégorie.

## Fiche d'un article

| Champ | Contenu |
|---|---|
| Titre | Titre de l'article d'origine |
| Résumé | Deux phrases maximum |
| Source | Origine (Reddit, CERT-FR, Bluesky...) |
| Catégorie | Un des quatre axes du thème |
| Date | Date de publication |
| Lien | Lien direct vers la publication d'origine |

## Technologies

- **n8n** (auto-hébergé, conteneur Docker) : orchestration des workflows
- **Debian 12** sur machine virtuelle : hébergement, disponible en continu
- **Discord (webhook)** : alertes en temps réel
- **GitHub et GitHub Pages** : stockage des données et tableau de bord statique
- **HTML, CSS, JavaScript** : interface du tableau de bord
- **API d'IA** (optionnel) : résumé automatique des articles

## Choix de sécurité

- Le serveur ne fait que des **connexions sortantes** : aucun port n'est ouvert vers Internet.
- Les secrets (webhook Discord, token GitHub, clés d'API) sont stockés dans les identifiants de n8n et ne figurent **jamais** dans ce dépôt.
- Les sources sont recoupées pour les événements marquants, et les résumés générés par IA sont relus avant d'être présentés.
- Les sources non officielles sont isolées dans des blocs facultatifs : si l'une tombe, le reste de la veille continue de fonctionner.

## Structure du dépôt

```
.
├── index.html        # tableau de bord
├── articles.json     # base d'articles, mise à jour automatiquement
├── workflows/        # exports des workflows n8n (sans identifiants)
└── README.md
```

## Limites et évolutions

- Les sources non officielles peuvent changer ou disparaître sans préavis.
- Évolutions prévues : résumé par IA locale sur une machine plus puissante, synthèse hebdomadaire par mail, statistiques par catégorie.
