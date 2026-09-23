# Leçons SuiviTransfo → kit v2

Source : le projet SuiviTransfo (juillet à septembre 2026). Corpus analysé : 42 plans avec leurs journaux de
revue, l'audit 001, les notes, INVARIANTS / STACK / CONVENTIONS, CLAUDE.md / AGENTS.md, la mémoire Claude du
projet, ~150 commits et les transcripts de sessions (principales et sous-agents).

Les agents de SuiviTransfo étaient identiques au kit v1. Chaque écart ci-dessous vient donc de l'usage, pas
d'une modification locale.

## Chiffres qui ont guidé la refonte
- **11 plans sur 21** (001-021) sont revenus en REVISE à la première revue. La revue de plan a été le contrôle
  le plus rentable de tout le flux.
- **Premier motif de BLOCKER** : des tests cassés que le plan ne listait pas (6 plans sur 001-021, 7 sur 022-042).
- **2 erreurs d'interprétation de données** sont arrivées jusqu'à l'utilisateur : les types 2/6 inversés
  (une doc fausse recopiée dans 3 endroits du code), et `occupationRate` qui était un pourcentage.
- **7 plans livrés sans journal de revue**, dont les demandes directes et les sessions cloud sans agents.
- **Plans jamais commités** (027-031, 034) ; **deux plans « 038 »** ; renumérotation 040 → 042 qui a laissé
  58 références périmées dans le code.
- **Renvois `§NN` vers INVARIANTS = numéros de ligne** : l'insertion de 5 lignes a décalé 80 références sans
  qu'aucune CI ne le voie. Deux fois.
- **L'audit 001 (i18n) a trouvé un BLOCKER** alors que chaque WP avait été approuvé : du travail perdu au rebase
  et du texte en dur réintroduit par une branche parallèle.

## Leçons et où elles vivent maintenant

### Vérité avant conception
| # | Leçon | Preuve | Encodée dans |
|---|-------|--------|--------------|
| 1 | Sonder la donnée réelle (lecture seule) avant d'encoder une règle ; les faits vérifiés ont une source et une date, le reste est une hypothèse avec une tâche de sonde | 005 `state` vide sur 197 ; 028 « 202/202 unknown » en live ; 032 `occupationRate` = % ; 038 2/6 inversés | vibe (Truth Before Design), plan-reviewer (DATA), INVARIANTS D. |
| 2 | Code et doc en désaccord → sonder, jamais « corriger » l'un pour l'aligner sur l'autre | commit 446e9c5 a inversé des libellés justes pour suivre une doc fausse, régression constatée le lendemain | vibe |
| 3 | Le diagnostic de l'utilisateur est une hypothèse (vrai bug ? déjà là ?) | 027 « FB7 n'est PAS un bug, FB8 existe déjà » ; 037 ; 041 | vibe |
| 4 | Demander « comment tu filtres ça dans l'outil source ? » | la réponse en texte libre a donné le filtre exact des Sales (036) | vibe |
| 5 | Parité UX : partir de l'équivalent sur les écrans frères, vérifier les frères après changement | 7 demandes « sur le même modèle que… » en 2 semaines ; popover copié 3 fois avant extraction | vibe, plan-reviewer |

### Plans et revues
| # | Leçon | Preuve | Encodée dans |
|---|-------|--------|--------------|
| 6 | Blast radius des tests en 3 catégories : casse au typecheck / casse au runtime seulement / appelants | BLOCKER le plus fréquent (012, 017, 029, 031, 034, 036) | plan-reviewer (IMPACT), template de plan, codeur Step 1 |
| 7 | Réutiliser = extraire puis rebrancher l'appelant d'origine, jamais recopier ; corriger à la source | 007 « réutiliser sans extraction = recopie » ; 011 ; 019 | CONVENTIONS A1, plan-reviewer (DRIFT) |
| 8 | Un filtre d'affichage ne touche jamais les données lues par les métriques | 014 « contrainte cardinale » ; 017 ; 019 | CONVENTIONS A3, plan-reviewer (BOUNDARIES), code-reviewer |
| 9 | Simuler les bords : fin d'année, M+N hors fenêtre, bornes vides, absence | 011 bench M+3 en octobre ; 017 barre pleine année sur dates vides | plan-reviewer (LOGIC) |
| 10 | DoD testable : exécutable là où elle est placée, formulée comme une propriété, jamais un chiffre magique | 035 « 5 BLOCKERS … DoD intestables » ; « badge = 7 » | plan-reviewer (TESTABILITY) |
| 11 | Des tests qui peuvent échouer : contrôle positif, fixtures non triviales, baseline non nulle, mutation check | 037 « baseline NON NULLE » ; 042 « garde (b) pouvait passer à vide » | CONVENTIONS A6, codeur, code-reviewer |
| 12 | Les docs et commentaires rendus faux se réécrivent dans le même WP | 036 « le DTO affirme one-to-one » ; 035 VISION promettait encore la rentabilité | CONVENTIONS A7, plan-reviewer (IMPACT) |
| 13 | Template de plan enrichi : demande mot pour mot, faits vérifiés, D#, questions à ratifier, risques, portée OUT, section « Livré » | apparu spontanément dans 20+ plans | vibe (plan_template) |
| 14 | Un WP ajouté après la revue passe lui-même en revue | 036, 027, 042 le font ; 028 non, et un défaut live a suivi | vibe (Anti-Drift) |
| 15 | Questions produit à l'utilisateur, avec un défaut recommandé ; choix intérimaires en constantes réversibles | 011, 016, 019 | vibe, plan-reviewer |

### Vérification réelle
| # | Leçon | Preuve | Encodée dans |
|---|-------|--------|--------------|
| 16 | Des tests verts ne prouvent pas que ça marche : une DoD `live` pour les intégrations et les données, une DoD `render` (capture) pour l'UI | 028 « APPROVE (code) + DEFECT live » ; proxy dev 404 invisible en E2E stubbé ; 042 capture réelle sans marge ni titre | template de plan (niveaux de vérification), codeur Step 4, vibe (revue) |
| 17 | Parité CI réelle par composant ; `tsc` ne voit pas les templates, seul le build fait foi | 042 ; CLAUDE.md « lint + typecheck + test + build » | STACK (COMPONENTS, CI_PARITY), codeur Step 3 |
| 18 | Baseline : la règle est « aucune NOUVELLE erreur » ; jamais d'auto-fix sur tout le repo | 008 « 2025 erreurs dont 2024 CRLF » ; 036 « 5 erreurs tsc = baseline » | STACK (BASELINE), codeur |
| 19 | Suites en séquence, relancer seul avant de crier à la régression, ne pas piper vers `tail` | « N suites failed mais 0 test échoué » (vu 2 fois) | STACK (TEST_POLICY), codeur |
| 20 | E2E sur un serveur frais à ports isolés ; ne jamais toucher les serveurs de l'utilisateur | `reuseExistingServer` sur un bundle périmé ; Playwright testait la session d'à côté | STACK (ports), codeur, code-reviewer |
| 21 | Plancher a11y : contraste AA calculé, pas de lien dans un bouton, rôles corrects | 039 ; 042 contraste 4,24:1 → 14,83:1 ; audit A7-F1 2,6:1 | CONVENTIONS A8, code-reviewer, auditeur A7 |

### Collaboration
| # | Leçon | Preuve | Encodée dans |
|---|-------|--------|--------------|
| 22 | Un GO au niveau du plan couvre les WPs nommés (en séquence, avec revue) ; chaque GO est consigné mot pour mot | « lance le développement » = GO pour 4 WPs ; « vas-y pour le WP02 également » | vibe (Dispatch Gate) |
| 23 | Voie fast pour les petites demandes directes, plutôt qu'un contournement silencieux | 038-041 « livré, demande directe », sans revue | vibe (Lanes) |
| 24 | Proposer l'aperçu local AVANT la PR | « lance en local pour que je voie » ×3 en 2 jours, à chaque fois juste après une offre de PR | vibe (Phase 6 Preview) |
| 25 | Questions groupées et numérotées, chacune avec un défaut recommandé ; lire le texte libre au pied de la lettre | réponses « Q1 … Q12 » en un message ; options contournées en texte libre | vibe (Talking With the User) |
| 26 | Maquettes pour les choix visuels | 032 « option D validée sur maquette » | vibe |
| 27 | DO NOT FIX : figer par un test les bizarreries voulues | 035 « deux libellés vont paraître bancals » | vibe, INVARIANTS F., codeur, reviewers |
| 28 | Lots de retours → tableau de tri (prêt / à cadrer / ops / question) suivi jusqu'au bout | Docs/Feedback/08-07.md, plan 027 | vibe (Feedback Batches) |
| 29 | Contexte d'exécution complet dans chaque dispatch (worktree, branche, ports, arbitrages mot pour mot, pièges) | les 11 dispatches réels le faisaient, contre la consigne v1 « contexte minimum » | vibe (dispatch_contracts) |

### Git, sessions parallèles, livraison
| # | Leçon | Preuve | Encodée dans |
|---|-------|--------|--------------|
| 30 | Un plan = une branche ; worktree dédié quand d'autres sessions tournent sur le même clone | 3-4 sessions en parallèle ; un commit étranger a failli partir dans la PR #46 | vibe (Parallel Work), codeur Step 0 |
| 31 | `.vibes/` versionné et commité par `vibe` ; numéro de plan réservé en commitant le squelette | 027-034 non suivis ; `git pull` avorté ; deux « 038 » | vibe (Separation of Powers, Parallel Work) |
| 32 | Rebase : branche de secours, `range-diff`, re-vérifier les DoD, re-planifier le travail perdu, audit CHANGE | audit 001 A2.1 et A3-F3 : des commits rebasés ne contenaient plus ce que disaient leurs messages | vibe, auditeur (A0) |
| 33 | Après un push : relire l'état de la PR ; une PR sans aucun check n'est pas verte ; vérifier que les workflows ont vraiment tourné | 2 commits ont raté un merge rapide (PR #41) ; workflows de prod pas déclenchés, 3 fois | vibe (Phase 8 Ship), STACK (RELEASE) |
| 34 | Release par ordre de dépendance (celui qui produit un champ part avant celui qui le lit), jamais la prod | CLAUDE.md SuiviTransfo | STACK (RELEASE), vibe |
| 35 | Fichiers de règles de l'organisation prioritaires et réconciliés avec STACK (chemins protégés, dépendances, syntaxe de commit) | AGENTS.md « (TYPE) MESSAGE » contre STACK Conventional Commits : historique mélangé | STACK (RULE_FILES, GUARDRAILS), tous les agents |
| 36 | Identité git par projet (`--local`), jamais en global | 4 identités d'auteur dans l'historique | STACK (GIT), codeur Step 0 |
| 37 | Survivre aux coupures : l'état est dans le fichier de plan ; « continue » = reconstruire depuis git, finir le travail partiel plutôt que le refaire | 5 relances « continue » en 2 jours ; quota atteint en plein dispatch | vibe (Resilience) |
| 38 | Clôture de session : état poussé ou mergé de chaque branche, serveurs arrêtés, worktrees retirés, « safe to archive » | « je peux archiver cette session ? » | vibe (Phase 9 Close) |

### Mémoire du projet
| # | Leçon | Preuve | Encodée dans |
|---|-------|--------|--------------|
| 39 | INVARIANTS à identifiants stables, entrées courtes, amendement en place, budget | 31 Ko, une puce de 3,5 Ko, `comp-api/` et PG16 périmés, marqueurs de conflit commités | template INVARIANTS, vibe (Stewardship), auditeur (A6) |
| 40 | Un mécanisme transverse s'accompagne dès le plan d'un invariant ET d'une garde automatique | audit A1-F4 : « c'est précisément ce qui a manqué » | vibe, plan-reviewer (DRIFT), auditeur (missing anchors) |
| 41 | Rien de projet dans la mémoire des agents : ports, pièges et état vont dans STACK ou dans la ligne Delivery du plan | 15,8 Ko d'état de projet en mémoire locale, invisibles des sessions cloud | vibe, STACK (ENV_PITFALLS, REMOTE_LIMITS) |
| 42 | Cycle de vie des notes : état `partial`, une seule ligne Status, `## Trigger` pour sortir du parking | note avec deux Status ; `k8s-wiring` resté backlog alors que livré ; le trigger « 4e consommateur » a fonctionné | vibe (Notes), auditeur |
| 43 | Langues = réglage projet ; la règle « ASCII only » cassait les textes UI | 017 libellés sans accents, corrigés par 2d6d854 | STACK (LANGUAGES), CONVENTIONS |
| 44 | Agents versionnés dans le repo (exception `.gitignore`) | 042 « l'agent vibe n'est pas installé dans l'environnement cloud » | README, scripts d'installation |

## Ce qui marchait déjà et a été gardé
- La **porte de dispatch** : le GO explicite reste non négociable.
- La **revue fraîche des WPs risqués**. En 042, elle a trouvé une garde qui pouvait passer à vide sur un WP de
  39 fichiers. Elle a désormais son agent dédié.
- Les **notes de l'auditeur** qui suivaient exactement le vocabulaire de statut.
- Le **backlog en fichiers `.vibes/notes/`** et la réconciliation notes ↔ plans.
