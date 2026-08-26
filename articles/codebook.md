# Codebook

This page documents every column in `all_data`, the pooled,
stimulus-level dataset from the Working Memory Feature Trade-off Task
(WM-FTT): word, orientation and colour recall under a parity-judgement
distractor, combining all three study versions (v1 original, v2 added a
parity-error penalty, v3 added recall-order randomisation).

The task was called CFA-WM during data collection, and column names, OSF
component names and the front-end code still use that prefix, for
example `strats_cfa_q01_colors_1`. Those identifiers are deliberately
unchanged so that exports stay comparable with earlier ones and with the
raw JATOS data. WM-FTT and CFA-WM refer to the same task.

The tables below are computed directly from `all_data` rather than typed
out by hand, so they cannot drift out of sync with the data itself.
`all_data` has one row per item (three per trial), so a given
participant’s demographic and questionnaire-score values repeat across
their rows; the counts and ranges below reflect that (`N missing` counts
item rows, not participants).

The five nested list-columns holding raw questionnaire items are
described only briefly here (see the last section below). For full
item-level detail (every raw VVIQ/OSIVQ/NIEQ/strategy-report column,
computed the same way) see the codebook that ships alongside
`all_data_surveys` and `all_data_full` on
[OSF](https://osf.io/3649s/files/osfstorage), the two flat exports built
for sharing this data outside the package.

## Identifiers and version

| Variable | Description | Type | Range / levels | N missing |
|:---|:---|:---|:---|---:|
| id | Participant identifier, unique within a version. | string | \[free text\] | 0 |
| version | WM-FTT task version: v1 (original), v2 (added a parity-error penalty), v3 (added recall-order randomisation, independent front-end infrastructure). | string | v1, v2, v3 | 0 |
| language | UI language of the experiment in the browser. | string | en, fr | 0 |

## Trial and item structure

| Variable | Description | Type | Range / levels | N missing |
|:---|:---|:---|:---|---:|
| trial_number | Trial index. A trial is one encode-distract-recall cycle: 21 test trials in three blocks of seven, numbered 1-21, preceded by 3 training trials numbered 1-3 and one tutorial trial numbered 0. | integer | 0-21 | 0 |
| response_order | Order in which the three response modalities were collected for this trial. Fixed in v1/v2 (always word/angle/colour); randomised per trial in v3. | string | angle_color_word, angle_word_color, color_angle_word, color_word_angle, word_angle_color, word_color_angle | 0 |
| item_number | Item index, running 1-63 across the three test blocks (1-21, 22-42, 43-63) and 1-9 in training. Three items per trial; each item is one word shown at one orientation in one colour, so an item row carries all three features rather than one of them. | integer | 1-63 | 0 |
| expe_phase | Task phase: tutorial, training, or one of the three test blocks. | string | expe_block_1, expe_block_2, expe_block_3, training, tutorial | 0 |

## Stimulus content and response

| Variable | Description | Type | Range / levels | N missing |
|:---|:---|:---|:---|---:|
| target_word | The to-be-remembered word. | string | advance, aile, amant, amer, amour, angoisse, anxiety, article, attente, avance, basket, black, blood, board, bottom, boule, branch, branche, breast, cadaver, cadavre, cadeau, cafe, camion, cat, cesse, chair, chaise, chaleur, chat, chemise, client, cloud, coffee, compte, count, courant, cousin, cow, crainte, crazy, current, deed, dernier, detail, drap, eleve, empty, ensemble, espece, etude, example, exemple, eye, fait, fear, feather, fish, flame, flamme, folle, fond, foot, forme, franc, frank, genie, genius, genou, gift, glace, haine, hand, hate, heat, honte, ice, idea, idee, instant, joie, jouet, joy, knee, lamp, lampe, last, lecture, light, long, love, lover, lumiere, main, middle, milieu, mystere, mystery, navire, noir, nuage, oeil, ombre, panier, path, piano, piece, pied, plume, poisson, police, post, poste, reading, road, roof, room, rose, route, salle, sang, seat, second, seconde, sein, shadow, shame, shape, sheet, ship, shirt, siege, silk, sister, size, soeur, soie, soif, solid, solide, souci, species, stop, student, study, table, taille, taste, temps, thing, time, together, toit, tool, tout, trace, travail, truc, truck, vache, veille, vide, voie, wait, watch, water, whole, wing, worry | 0 |
| target_angle | The to-be-remembered rectangle orientation, in degrees. The range shown is over ALL rows, including tutorial and training; experimental-block targets run -63 to 61, which is what the `responded_angle` caveat below is stated over. | integer | -72-71 | 0 |
| target_color_angle | The to-be-remembered colour, as an angle on the colour wheel. | float | 0-359 | 0 |
| target_color | The to-be-remembered colour, as its nearest named colour. | string | \#0000FF, \#0004FF, \#0008FF, \#000DFF, \#0011FF, \#0015FF, \#0018FF, \#001AFF, \#0022FF, \#0026FF, \#002AFF, \#002FFF, \#0031FF, \#0033FF, \#0037FF, \#003CFF, \#0040FF, \#0044FF, \#0048FF, \#0049FF, \#004CFF, \#0051FF, \#0055FF, \#0059FF, \#005EFF, \#0061FF, \#0062FF, \#006AFF, \#006EFF, \#0077FF, \#0079FF, \#007BFF, \#0080FF, \#0084FF, \#0088FF, \#008CFF, \#0091FF, \#0092FF, \#0095FF, \#0099FF, \#009DFF, \#00A2FF, \#00A6FF, \#00AAFF, \#00AEFF, \#00B3FF, \#00B7FF, \#00BBFF, \#00BFFF, \#00C2FF, \#00C3FF, \#00CCFF, \#00D0FF, \#00D5FF, \#00D9FF, \#00DBFF, \#00DDFF, \#00E1FF, \#00E5FF, \#00EAFF, \#00F2FF, \#00F3FF, \#00F7FF, \#00FBFF, \#00FF00, \#00FF04, \#00FF08, \#00FF0D, \#00FF11, \#00FF15, \#00FF18, \#00FF1A, \#00FF1E, \#00FF22, \#00FF26, \#00FF2A, \#00FF2F, \#00FF31, \#00FF33, \#00FF37, \#00FF3C, \#00FF40, \#00FF44, \#00FF48, \#00FF49, \#00FF4C, \#00FF51, \#00FF55, \#00FF5E, \#00FF61, \#00FF62, \#00FF66, \#00FF6A, \#00FF6E, \#00FF73, \#00FF77, \#00FF79, \#00FF7B, \#00FF80, \#00FF84, \#00FF88, \#00FF8C, \#00FF91, \#00FF92, \#00FF95, \#00FF99, \#00FF9D, \#00FFA2, \#00FFA6, \#00FFAA, \#00FFAE, \#00FFB7, \#00FFBB, \#00FFBF, \#00FFC2, \#00FFC8, \#00FFCC, \#00FFD0, \#00FFD5, \#00FFD9, \#00FFDB, \#00FFDD, \#00FFE1, \#00FFE5, \#00FFEA, \#00FFEE, \#00FFF2, \#00FFF3, \#00FFF7, \#00FFFB, \#00FFFF, \#0400FF, \#04FF00, \#0800FF, \#09FF00, \#0DFF00, \#1100FF, \#11FF00, \#1500FF, \#15FF00, \#1800FF, \#18FF00, \#1900FF, \#1AFF00, \#1E00FF, \#1EFF00, \#2200FF, \#22FF00, \#2600FF, \#26FF00, \#2B00FF, \#2BFF00, \#2F00FF, \#2FFF00, \#3100FF, \#31FF00, \#3300FF, \#33FF00, \#3700FF, \#37FF00, \#3C00FF, \#3CFF00, \#4000FF, \#40FF00, \#4400FF, \#44FF00, \#4800FF, \#48FF00, \#4900FF, \#49FF00, \#4C00FF, \#5100FF, \#51FF00, \#5500FF, \#55FF00, \#5900FF, \#59FF00, \#5D00FF, \#5EFF00, \#6100FF, \#61FF00, \#6200FF, \#62FF00, \#6600FF, \#66FF00, \#6A00FF, \#6AFF00, \#6F00FF, \#6FFF00, \#7300FF, \#73FF00, \#7700FF, \#7900FF, \#79FF00, \#7B00FF, \#7BFF00, \#8000FF, \#80FF00, \#8400FF, \#84FF00, \#8800FF, \#88FF00, \#8C00FF, \#8CFF00, \#9000FF, \#91FF00, \#9200FF, \#92FF00, \#9500FF, \#95FF00, \#9900FF, \#9D00FF, \#A200FF, \#A2FF00, \#A600FF, \#AA00FF, \#AAFF00, \#AE00FF, \#AEFF00, \#B300FF, \#B3FF00, \#B700FF, \#B7FF00, \#BB00FF, \#BBFF00, \#BF00FF, \#BFFF00, \#C200FF, \#C2FF00, \#C300FF, \#C3FF00, \#C800FF, \#C8FF00, \#CC00FF, \#CCFF00, \#D000FF, \#D0FF00, \#D400FF, \#D4FF00, \#D900FF, \#D9FF00, \#DB00FF, \#DBFF00, \#DD00FF, \#DDFF00, \#E100FF, \#E1FF00, \#E5FF00, \#E600FF, \#EA00FF, \#EAFF00, \#EE00FF, \#EEFF00, \#F200FF, \#F2FF00, \#F300FF, \#F3FF00, \#F6FF00, \#F700FF, \#FB00FF, \#FBFF00, \#FF0000, \#FF0004, \#FF0008, \#FF000D, \#FF0011, \#FF0015, \#FF0018, \#FF0019, \#FF001E, \#FF0022, \#FF002B, \#FF002F, \#FF0031, \#FF0033, \#FF0037, \#FF003C, \#FF0040, \#FF0044, \#FF0048, \#FF0049, \#FF004C, \#FF0051, \#FF0055, \#FF0059, \#FF0061, \#FF0062, \#FF0066, \#FF006A, \#FF006F, \#FF0073, \#FF0077, \#FF0079, \#FF007B, \#FF0080, \#FF0084, \#FF0088, \#FF008C, \#FF0090, \#FF0092, \#FF0095, \#FF0099, \#FF009D, \#FF00A2, \#FF00A6, \#FF00AA, \#FF00AE, \#FF00B3, \#FF00BB, \#FF00BF, \#FF00C2, \#FF00C3, \#FF00C8, \#FF00CC, \#FF00D0, \#FF00D4, \#FF00D9, \#FF00DB, \#FF00DD, \#FF00E1, \#FF00E6, \#FF00EA, \#FF00EE, \#FF00F2, \#FF00F3, \#FF00F7, \#FF00FB, \#FF00FF, \#FF0400, \#FF0800, \#FF0D00, \#FF1100, \#FF1500, \#FF1800, \#FF1900, \#FF1E00, \#FF2200, \#FF2A00, \#FF2F00, \#FF3100, \#FF3300, \#FF3700, \#FF3C00, \#FF4000, \#FF4400, \#FF4800, \#FF4900, \#FF4D00, \#FF5100, \#FF5500, \#FF5900, \#FF5E00, \#FF6100, \#FF6200, \#FF6600, \#FF6A00, \#FF6F00, \#FF7300, \#FF7700, \#FF7900, \#FF7B00, \#FF8000, \#FF8400, \#FF8800, \#FF8C00, \#FF9100, \#FF9200, \#FF9500, \#FF9900, \#FF9D00, \#FFA200, \#FFA600, \#FFAA00, \#FFAE00, \#FFB300, \#FFB700, \#FFBB00, \#FFBF00, \#FFC200, \#FFC400, \#FFC800, \#FFCC00, \#FFD000, \#FFD500, \#FFD900, \#FFDB00, \#FFDD00, \#FFE100, \#FFE600, \#FFEA00, \#FFEE00, \#FFF200, \#FFF300, \#FFF700, \#FFFB00, \#FFFF00 | 0 |
| response_word | Participant’s recalled word. | string | , 7, advance, aile, ailes, aman, amand, amant, amende, amer, amour, angle, angoise, angoisse, animal, annonce, anxiety, arbre, aricle, arrange, article, artiste, atente, attend, attente, avance, banc, base, basket, black, blanc, bleu, blonde, blood, board, bottom, boule, boulle, branch, branche, brap, bras, breast, cabane, cadaver, cadavre, cadeau, cadeaux, cadran, cafe, camion, canal, canard, caresse, casse, cat, centre, cesse, cesser, chair, chaise, chaleur, chat, chaud, chemin, chemise, choix, cible, ciel, classe, client, cloud, coffee, compte, comte, couleur, count, courant, courrier, cours, court, cousin, coussin, cow, craint, crainte, crazy, crete, croix, current, deed, derneir, dernier, detail, detaille, detente, doigt, doux, drap, draps, droit, eleve, eleves, empty, endroit, enemble, ensembe, ensemble, espace, espece, etude, etudes, example, exemple, exmaple, eye, f, fais, fait, falmme, fauteuil, fds, fear, feather, femme, feu, feuille, feve, fish, flame, flamme, flanc, flemme, fleur, fluide, foie, foire, fois, folie, folle, fond, foot, foret, forme, frais, franc, france, frange, frank, frein, froid, front, galce, genie, genius, genou, genoux, gift, glace, grenie, grenier, haine, hand, hate, heat, histoire, ho,yr, honte, humeur, ice, idea, idee, impair, impasse, imper, index, influence, insistante, instant, ivre, j, jardin, jaune, jeu, jeune, joie, joint, joue, jouet, joy, knee, lamp, lampe, lance, last, lecture, light, ligne, loi, long, love, lover, lumiere, maillot, main, mains, maison, mer, middle, mileu, milieu, milieux, millieu, miroir, moment, monte, mot, mystere, mystery, nature, navir, navire, nbavire, neuf, noir, noire, nuage, odd, oeil, oeuil, offre, oiseau, ombre, orage, orange, oubli, paino, pair, paire, panier, pannier, pantalon, papa, papier, passion, path, peinte, permis, peur, piano, pianon, piece, pied, piege, pino, plafond, plule, plume, poisson, police, pomme, pont, post, poste, r, reading, rectangle, rejet, road, rond, roof, room, rose, rouge, roule, route, sable, sac, sage, sale, salle, salon, sang, saut, seat, seche, second, seconde, sein, seins, sept, serre, shadow, shame, shape, sheet, ship, shirt, siege, silk, sister, size, soeur, soie, soif, soin, sois, soit, soleil, solid, solide, sombre, souci, soucie, soucis, souris, species, state, stop, student, study, table, tache, taill, taille, taste, temps, tente, thing, timbre, time, together, toi, toit, tomb, tool, tout, toux, trace, travail, triangle, truc, truck, vache, vahce, valeur, valide, valise, veille, velo, verre, vert, vertu, veste, vide, vieille, vielle, vierge, vitre, voie, voile, voilet, voit, voiture, voix, volant, volet, voyage, wait, watch, water, whole, wing, worry, z | 0 |
| response_angle | Participant’s recalled orientation, in degrees. | float | -90-90 | 0 |
| response_color_angle | Participant’s recalled colour, as an angle on the colour wheel. | integer | 0-999 | 0 |
| response_color | Participant’s recalled colour, as its nearest named colour. | string | \#0000FF, \#0004FF, \#0008FF, \#000DFF, \#0011FF, \#0015FF, \#001AFF, \#001EFF, \#0022FF, \#0026FF, \#002AFF, \#002FFF, \#0033FF, \#0037FF, \#003CFF, \#0040FF, \#0044FF, \#0048FF, \#004CFF, \#0051FF, \#0055FF, \#0059FF, \#005EFF, \#0062FF, \#0066FF, \#006AFF, \#006EFF, \#0073FF, \#0077FF, \#007BFF, \#0080FF, \#0084FF, \#0088FF, \#008CFF, \#0091FF, \#0095FF, \#0099FF, \#009DFF, \#00A2FF, \#00A6FF, \#00AAFF, \#00AEFF, \#00B3FF, \#00B7FF, \#00BBFF, \#00BFFF, \#00C3FF, \#00C8FF, \#00CCFF, \#00D0FF, \#00D5FF, \#00D9FF, \#00DDFF, \#00E1FF, \#00E5FF, \#00EAFF, \#00EEFF, \#00F2FF, \#00F7FF, \#00FBFF, \#00FF00, \#00FF04, \#00FF08, \#00FF0D, \#00FF11, \#00FF15, \#00FF1A, \#00FF1E, \#00FF22, \#00FF26, \#00FF2A, \#00FF2F, \#00FF33, \#00FF37, \#00FF3C, \#00FF40, \#00FF44, \#00FF48, \#00FF4C, \#00FF51, \#00FF55, \#00FF59, \#00FF5E, \#00FF62, \#00FF66, \#00FF6A, \#00FF6E, \#00FF73, \#00FF77, \#00FF7B, \#00FF80, \#00FF84, \#00FF88, \#00FF8C, \#00FF91, \#00FF95, \#00FF99, \#00FF9D, \#00FFA2, \#00FFA6, \#00FFAA, \#00FFAE, \#00FFB3, \#00FFB7, \#00FFBB, \#00FFBF, \#00FFC3, \#00FFC8, \#00FFCC, \#00FFD0, \#00FFD5, \#00FFD9, \#00FFDD, \#00FFE1, \#00FFE5, \#00FFEA, \#00FFEE, \#00FFF2, \#00FFF7, \#00FFFB, \#00FFFF, \#0400FF, \#04FF00, \#0800FF, \#09FF00, \#0D00FF, \#0DFF00, \#1100FF, \#11FF00, \#1500FF, \#15FF00, \#1900FF, \#1AFF00, \#1E00FF, \#1EFF00, \#2200FF, \#22FF00, \#2600FF, \#26FF00, \#2B00FF, \#2BFF00, \#2F00FF, \#2FFF00, \#3300FF, \#33FF00, \#3700FF, \#37FF00, \#3C00FF, \#3CFF00, \#4000FF, \#40FF00, \#4400FF, \#44FF00, \#4800FF, \#48FF00, \#4C00FF, \#4DFF00, \#5100FF, \#51FF00, \#5500FF, \#55FF00, \#5900FF, \#59FF00, \#5D00FF, \#5EFF00, \#6200FF, \#62FF00, \#6600FF, \#66FF00, \#6A00FF, \#6AFF00, \#6F00FF, \#6FFF00, \#7300FF, \#73FF00, \#7700FF, \#77FF00, \#7B00FF, \#7BFF00, \#8000FF, \#80FF00, \#8400FF, \#84FF00, \#8800FF, \#88FF00, \#8C00FF, \#8CFF00, \#9000FF, \#91FF00, \#9500FF, \#95FF00, \#9900FF, \#99FF00, \#9D00FF, \#9DFF00, \#A200FF, \#A2FF00, \#A600FF, \#A6FF00, \#AA00FF, \#AAAAAA, \#AAFF00, \#AE00FF, \#AEFF00, \#B300FF, \#B3FF00, \#B700FF, \#B7FF00, \#BB00FF, \#BBFF00, \#BF00FF, \#BFFF00, \#C300FF, \#C3FF00, \#C800FF, \#C8FF00, \#CC00FF, \#CCFF00, \#D000FF, \#D0FF00, \#D400FF, \#D4FF00, \#D900FF, \#D9FF00, \#DD00FF, \#DDFF00, \#E100FF, \#E1FF00, \#E5FF00, \#E600FF, \#EA00FF, \#EAFF00, \#EE00FF, \#EEFF00, \#F200FF, \#F2FF00, \#F6FF00, \#F700FF, \#FB00FF, \#FBFF00, \#FF0000, \#FF0004, \#FF0008, \#FF000D, \#FF0011, \#FF0015, \#FF0019, \#FF001E, \#FF0022, \#FF0026, \#FF002B, \#FF002F, \#FF0033, \#FF0037, \#FF003C, \#FF0040, \#FF0044, \#FF0048, \#FF004C, \#FF0051, \#FF0055, \#FF0059, \#FF005D, \#FF0062, \#FF0066, \#FF006A, \#FF006F, \#FF0073, \#FF0077, \#FF007B, \#FF0080, \#FF0084, \#FF0088, \#FF008C, \#FF0090, \#FF0095, \#FF0099, \#FF009D, \#FF00A2, \#FF00A6, \#FF00AA, \#FF00AE, \#FF00B3, \#FF00B7, \#FF00BB, \#FF00BF, \#FF00C3, \#FF00C8, \#FF00CC, \#FF00D0, \#FF00D4, \#FF00D9, \#FF00DD, \#FF00E1, \#FF00E6, \#FF00EA, \#FF00EE, \#FF00F2, \#FF00F7, \#FF00FB, \#FF00FF, \#FF0400, \#FF0800, \#FF0D00, \#FF1100, \#FF1500, \#FF1900, \#FF1E00, \#FF2200, \#FF2600, \#FF2A00, \#FF2F00, \#FF3300, \#FF3700, \#FF3C00, \#FF4000, \#FF4400, \#FF4800, \#FF4D00, \#FF5100, \#FF5500, \#FF5900, \#FF5E00, \#FF6200, \#FF6600, \#FF6A00, \#FF6F00, \#FF7300, \#FF7700, \#FF7B00, \#FF8000, \#FF8400, \#FF8800, \#FF8C00, \#FF9100, \#FF9500, \#FF9900, \#FF9D00, \#FFA200, \#FFA600, \#FFAA00, \#FFAE00, \#FFB300, \#FFB700, \#FFBB00, \#FFBF00, \#FFC400, \#FFC800, \#FFCC00, \#FFD000, \#FFD500, \#FFD900, \#FFDD00, \#FFE100, \#FFE600, \#FFEA00, \#FFEE00, \#FFF200, \#FFF700, \#FFFB00, \#FFFF00 | 0 |
| rt_word | Response time for the word recall response (ms). | integer | 427-84750 | 0 |
| rt_angle | Response time for the orientation recall response (ms). | float | 493.5-75741.2 | 0 |
| rt_color | Response time for the colour recall response (ms). | float | 394.1-82248 | 0 |
| parity_1_stim | First parity-judgement distractor digit embedded in this trial. | integer | 1-9 | 0 |
| parity_1_resp | Participant’s parity judgement for parity_1_stim. | string | f, j | 3998 |
| parity_1_acc | Accuracy of the first parity judgement (1 = correct). | integer | 0-1 | 0 |
| parity_1_rt | Response time for the first parity judgement (ms). | integer | 4-120665 | 3998 |
| parity_2_stim | Second parity-judgement distractor digit embedded in this trial. | integer | 1-9 | 0 |
| parity_2_resp | Participant’s parity judgement for parity_2_stim. | string | f, j | 3384 |
| parity_2_acc | Accuracy of the second parity judgement (1 = correct). | integer | 0-1 | 0 |
| parity_2_rt | Response time for the second parity judgement (ms). | integer | 2-120665 | 3384 |

v2/v3 carry a real parity-error penalty in the task design; the parity
columns exist for v1 too, but the penalty was not applied at recall.

## Recall scores

These are the analysis variables. They are computed in R from the raw
target and response values by
[`compute_scores()`](https://m-delem.github.io/aphantasiaWMStrats/reference/compute_scores.md),
not derived from the task’s own feedback columns, for reasons set out on
the
[Scoring](https://m-delem.github.io/aphantasiaWMStrats/articles/scoring.md)
page.

Two things to know before using them. Non-responses are scored 0 and
flagged by the `responded_*` columns, so any analysis of recall
*accuracy* should filter on those flags; leaving them out combines
accuracy with willingness to respond, which are different quantities.
And word recall is near ceiling in this task and its split-half
reliability is far below the other two features’, so it does not support
individual-differences claims. The [task
validity](https://m-delem.github.io/aphantasiaWMStrats/articles/task-validity.md)
page computes all three and is where those figures live.

| Variable | Description | Type | Range / levels | N missing |
|:---|:---|:---|:---|---:|
| score_word | Word recall similarity, 1 = exact match. Edit-distance scoring (Gonthier, 2022): Damerau-Levenshtein distance capped at the target’s length, subtracted from it and divided by it. See the reliability caveat above. | float | 0-1 | 0 |
| score_angle | Orientation recall similarity, 1 = exact match. Cosine of the angular error on a 180-degree period, since a rectangle’s tilt is symmetric under 180-degree rotation. | float | 0-1 | 0 |
| score_color | Colour recall similarity, 1 = exact match. Cosine of the angular error on the 360-degree hue wheel. Reliability 0.83. | float | 0-1 | 0 |
| score_word_z | `score_word`, z-scored within task version using experimental-block rows only. Retained for provenance: no analysis in this package uses it, since the compositional coordinates handle cross-feature comparison and per-version standardisation is unstable in v2 (see the version scope page). | float | -2.58-0.6 | 0 |
| score_angle_z | `score_angle`, z-scored within task version. | float | -1.68-1.24 | 0 |
| score_color_z | `score_color`, z-scored within task version. | float | -2.38-0.73 | 0 |
| responded_word | Whether the participant entered a word at all. | string | FALSE, TRUE | 0 |
| responded_angle | Whether the participant moved the orientation widget. Unlike the other two flags this is an *inference* rather than an observation: the widget starts at 90 degrees and returns that value if untouched, so a deliberate 90-degree response cannot be distinguished from no response. No experimental-block target lies within 20 degrees of 90, so such a response can never be near-correct. | string | FALSE, TRUE | 0 |
| responded_color | Whether the participant moved the colour wheel. Non-response appears in the raw data as `response_color_angle == 999`. | string | FALSE, TRUE | 0 |

## Live feedback from the task display

**Not analysis variables.** These drove the feedback screen participants
saw between trials, and are kept for provenance and reproducibility
only. Note that `live_diff_*` are *dissimilarities* (0 = exact match),
the opposite direction from the `score_*` columns above.

`live_diff_word`, and therefore `feedback_score_word` and the word
totals derived from it, rest on a defective edit-distance implementation
in the task’s front end: a loop whose condition is an assignment leaves
the distance matrix half-initialised, so the function does not compute
the distance its name claims. The
[Scoring](https://m-delem.github.io/aphantasiaWMStrats/articles/scoring.md)
page demonstrates this against the data. Use `score_word` instead.

| Variable | Description | Type | Range / levels | N missing |
|:---|:---|:---|:---|---:|
| live_diff_word | Front-end word dissimilarity, 0 = exact match. Not a valid edit distance; see above. | float | 0-1 | 0 |
| live_diff_angle | Front-end orientation error, absolute difference divided by 180. Linear rather than cosine, with no handling of the rectangle’s 180-degree symmetry. | float | 0-1 | 0 |
| live_diff_color | Front-end colour error, circular difference divided by 180. Non-responses are mapped to 1 by an explicit guard. | float | 0-1 | 0 |
| feedback_score_word | Points shown for the word response (0, 0.5 or 1), thresholded from `live_diff_word`. | float | 0-1 | 0 |
| feedback_score_angle | Points shown for the orientation response (0, 0.5 or 1). | float | 0-1 | 0 |
| feedback_score_color | Points shown for the colour response (0, 0.5 or 1). | float | 0-1 | 0 |
| feedback_trial_score | Points shown for the whole trial: the three per-feature scores summed, minus 0.5 per incorrect parity judgement, floored at 0. **The parity deduction applies in v2 and v3 only** - v1 has no penalty, so there it is exactly the sum of the three feature scores. Trial-level, so constant across a trial’s three item rows. | float | 0-9 | 0 |
| feedback_total_score_word | Cumulative word points shown at the end of the task. | float | 6-70.5 | 0 |
| feedback_total_score_angle | Cumulative orientation points shown at the end of the task. | float | 0-64.5 | 0 |
| feedback_total_score_color | Cumulative colour points shown at the end of the task. | float | 5-64 | 0 |
| feedback_total_score | Combined total points shown to the participant. This is the number they were told to maximise, so it describes what they were optimising, but it is not a performance measure. | float | 11.5-195.5 | 0 |

Tutorial rows carry placeholder values in these columns: every
`live_diff_*` is exactly 1 and every `feedback_score_*` exactly 0,
regardless of what the participant did.

## Questionnaire scores

Raw questionnaire items are in the nested list-columns described at the
end of this page, not here: these are the derived,
cross-version-comparable scores.

| Variable | Description | Type | Range / levels | N missing |
|:---|:---|:---|:---|---:|
| vviq_total_score | Total score on the Vividness of Visual Imagery Questionnaire (Marks, 1973), summed across all 16 items. Lower scores indicate weaker/absent visual imagery. | integer | 16-80 | 146 |
| vviq_group_2 | VVIQ group, 2 levels: aphantasia (\<= 32), typical (\> 32). | string | aphantasia, typical | 146 |
| vviq_group_4 | VVIQ group, 4 levels: aphantasia (= 16), hypophantasia (17-32), typical (33-74), hyperphantasia (\>= 75). | string | aphantasia, hyperphantasia, hypophantasia, typical | 146 |
| nieq_mental_imagery | NIEQ (Heavey et al., 2019) mental imagery dimension score (mean of frequency and proportion items). | float | 0-94.5 | 0 |
| nieq_inner_voice | NIEQ inner voice/speaking dimension score. | float | 0-100 | 0 |
| nieq_emotions | NIEQ feelings/emotions dimension score. | float | 4.5-100 | 0 |
| nieq_sensory_focus | NIEQ sensory awareness dimension score. | float | 0-100 | 0 |
| nieq_unsymbolised | NIEQ unsymbolized thinking dimension score. | float | 0-100 | 0 |
| object_mean | OSIVQ (Blazhenkova & Kozhevnikov, 2009) object-imagery subscale mean. | float | 1-4.64 | 146 |
| spatial_mean | OSIVQ spatial-imagery subscale mean. | float | 1-5 | 146 |
| verbal_mean | OSIVQ verbal cognitive-style subscale mean. | float | 1.33-5 | 146 |

**Item wording is not reproduced here**, as the VVIQ, OSIVQ, and NIEQ
item text is copyrighted by their respective authors - see Marks (1973),
Blazhenkova & Kozhevnikov (2009), and Heavey et al. (2019) for the
original items.

## Demographics

| Variable | Description | Type | Range / levels | N missing |
|:---|:---|:---|:---|---:|
| age | Participant age in years, self-reported. | integer | 18-71 | 0 |
| gender | Gender, as freely typed by the participant. | string | f, female/agender, m, Masculin/non-binaire, Non binaire, Non-binaire, Non-binaire (mais née femme) | 0 |
| country | Self-reported country of residence. | string | belg, can, fra, mona, usa | 0 |
| job | Self-reported occupation. | string | Auxiliaire de Vie Sociale, eseg_10_manager, eseg_20_intellect, eseg_30_intermed, eseg_40_entrepren, eseg_50_clerks, eseg_60_indust, eseg_70_less_sk, eseg_80_retired, eseg_91_student, eseg_91_unemployed, ETAM, invalidité, Petit entrepreneur.e (non salarié.e) + profession salariée peu qualifiée et dans un mois profession intermédiaire salariée, Restauration, SAPEUR POMPIER | 219 |
| education | Self-reported education level. | string | BTS, CAP coiffure et vente, DUT, isced_02_secondary, isced_03_college, isced_04_high, isced_06_licence, isced_07_master, isced_08_doctorat | 73 |
| field | Self-reported field of study or work. | string | Animation, animation sociale, Bac général, Banque finance, Basic generalized educational studies across all simplified topics., comptabilité, Droit, Immobilier (promotion immobilière), Industrie, isced_f_00_generic, isced_f_01_education, isced_f_02_arts_letters, isced_f_03_social_journ_info, isced_f_04_busi_admin_law, isced_f_05_bio_phys_math_stat, isced_f_06_comp_science, isced_f_07_engin_constr, isced_f_09_health_protecc, Juridiques, Licence 2 de droit, Licence biologie + master communication scientifique + M2 évènementiel, management du sport, Mécanique et Automatisme industriel, petite enfance, Philosophie, Psychologie, Psychology, Qualité, hygiène, santé, sécurité et environnement, sciences cognitives, Sciences humaines, psychologie, Sciences Politiques, Tourisme, Transport et logistique | 73 |
| where_from | Self-reported source of how the participant heard about the study. | string | aph_club, aph_network, fb_generic, randomly, risc, séminaire de Gaën Plancher au CRPN, word | 7081 |
| prognosis | Free-text self-report on aphantasia status, collected at sign-up in some versions and never harmonised into categories. No analysis uses it; the VVIQ is what defines imagery group throughout. | string | no, yes | 0 |
| treatment | Self-reported relevant treatment. NA throughout for v3 (not asked in that version’s demographics form). | string | no, yes | 7811 |
| neuro_trouble | Self-reported neurological condition, freely typed. NA throughout for v3 (not asked in that version’s demographics form). | string | dépression / anxiété généralisée, depression suite a un burnout, TDAH, TDAH , Aphantasie, Trouble de l’anxieté et agoraphobie, Trouble du Spectre de l’Autisme + Trouble Anxieux Généralisé, Trouble spécifique des apprentissages, TSA, VIRUS Babesia divergens et Toxoplasma | 7811 |

`gender` and `neuro_trouble` are free text (French and English mixed for
`gender`; French for `neuro_trouble`), not a controlled vocabulary - the
table above lists the observed values as-is rather than collapsing them
into fixed categories.

## Nested item list-columns

Five list-columns hold the raw questionnaire and strategy-report items,
kept nested rather than forced into a common wide schema, because v1/v2
and v3 don’t ask exactly the same raw items (different front-end
versions). Unnest with
[`tidyr::unnest_wider()`](https://tidyr.tidyverse.org/reference/unnest_wider.html)
to get the raw items as regular columns.

| List-column | Description |
|:---|:---|
| vviq_items | Raw VVIQ item responses (vviq_q01-vviq_q16), 1-5 each. Same names in v1/v2 and v3. |
| osivq_items | Raw OSIVQ item responses. **Reverse-keyed items are stored inconsistently across versions:** v1 and v2 store `osivq_q02v`, `osivq_q09v`, `osivq_q41v` and `osivq_q42s` *unreversed*, while v3 stores them already reversed. The `object_mean`/`spatial_mean`/`verbal_mean` columns are correct in both; only these nested items differ. Recomputing subscale scores or reliabilities from the items without reversing them for v1/v2 gives wrong answers (verbal alpha comes out at 0.25 rather than 0.84). |
| nieq_items | Raw NIEQ item responses: 2 items per dimension (frequency, proportion), both 0-100 sliders. Same names in v1/v2 and v3. |
| strategy_items | Raw strategy-report answers. Mixed shape: v1/v2’s colour/orientation/word strategy fields are free text (mostly French); a separate scoring-strategy field uses a small coded vocabulary, asked slightly differently in v1/v2 (3 legacy slots) vs v3 (2 slots). |
| extra_demographics | Additional demographic items not promoted to top-level columns: country, job, education, field, where_from, language_native, language_usual. |

For the full per-item breakdown - every raw column name, its exact
range, missingness, and (where applicable) coded vocabulary - see the
codebook that ships with `all_data_surveys` on
[OSF](https://osf.io/3649s/files/osfstorage): a participant-level export
where these list-columns are unnested wide, alongside
`dataset_description.json`
([Psych-DS](https://psych-ds.github.io/)-compliant) and a PDF version of
the same information.

------------------------------------------------------------------------

**Continuing through the Extended Online Report:** this page is a
technical reference, meant to be partially independent from the rest of
the vignettes. Get back to the [home
page](https://m-delem.github.io/aphantasiaWMStrats/index.html).

------------------------------------------------------------------------

## References

Blazhenkova, O., & Kozhevnikov, M. (2009). The new object-spatial-verbal
cognitive style model: Theory and measurement. *Applied Cognitive
Psychology*, *23*(5), 638–663. <https://doi.org/10.1002/acp.1473>

Gonthier, C. (2022). An easy way to improve scoring of memory span
tasks: The edit distance, beyond “correct recall in the correct serial
position.” *Behavior Research Methods*, *55*(4).
<https://doi.org/10.3758/s13428-022-01908-2>

Heavey, C. L., Moynihan, S. A., Brouwers, V. P., Lapping-Carr, L.,
Krumm, A. E., Kelsey, J. M., Turner, D. K., & Hurlburt, R. T. (2019).
Measuring the frequency of inner-experience characteristics by
self-report: The nevada inner experience questionnaire. *Frontiers in
Psychology*, *9*, 2615. <https://doi.org/10.3389/fpsyg.2018.02615>

Marks, D. F. (1973). Visual imagery differences in the recall of
pictures. *British Journal of Psychology*, *64*(1), 17–24.
<https://doi.org/10.1111/j.2044-8295.1973.tb01322.x>

------------------------------------------------------------------------

    #> ─ Session info ───────────────────────────────────────────────────────────────
    #>  setting  value
    #>  version  R version 4.6.1 (2026-06-24)
    #>  os       Ubuntu 24.04.4 LTS
    #>  system   x86_64, linux-gnu
    #>  ui       X11
    #>  language en
    #>  collate  C.UTF-8
    #>  ctype    C.UTF-8
    #>  tz       UTC
    #>  date     2026-08-26
    #>  pandoc   3.8.3 @ /opt/hostedtoolcache/pandoc/3.8.3/x64/ (via rmarkdown)
    #>  quarto   NA
    #> 
    #> ─ Packages ───────────────────────────────────────────────────────────────────
    #>  package            * version date (UTC) lib source
    #>  aphantasiaWMStrats * 0.1     2026-08-26 [1] local
    #>  bslib                0.12.0  2026-08-04 [2] CRAN (R 4.6.1)
    #>  cachem               1.1.0   2024-05-16 [2] CRAN (R 4.6.1)
    #>  cli                  3.6.6   2026-04-09 [2] CRAN (R 4.6.1)
    #>  crayon               1.5.3   2024-06-20 [2] CRAN (R 4.6.1)
    #>  desc                 1.4.3   2023-12-10 [2] CRAN (R 4.6.1)
    #>  digest               0.6.39  2025-11-19 [2] CRAN (R 4.6.1)
    #>  dplyr                1.2.1   2026-04-03 [2] CRAN (R 4.6.1)
    #>  evaluate             1.0.5   2025-08-27 [2] CRAN (R 4.6.1)
    #>  fastmap              1.2.0   2024-05-15 [2] CRAN (R 4.6.1)
    #>  fs                   2.1.0   2026-04-18 [2] CRAN (R 4.6.1)
    #>  generics             0.1.4   2025-05-09 [2] CRAN (R 4.6.1)
    #>  glue                 1.8.1   2026-04-17 [2] CRAN (R 4.6.1)
    #>  htmltools            0.5.9   2025-12-04 [2] CRAN (R 4.6.1)
    #>  jquerylib            0.1.4   2021-04-26 [2] CRAN (R 4.6.1)
    #>  jsonlite             2.0.0   2025-03-27 [2] CRAN (R 4.6.1)
    #>  knitr                1.51    2025-12-20 [2] CRAN (R 4.6.1)
    #>  lifecycle            1.0.5   2026-01-08 [2] CRAN (R 4.6.1)
    #>  magrittr             2.0.5   2026-04-04 [2] CRAN (R 4.6.1)
    #>  otel                 0.2.0   2025-08-29 [2] CRAN (R 4.6.1)
    #>  pillar               1.11.1  2025-09-17 [2] CRAN (R 4.6.1)
    #>  pkgconfig            2.0.3   2019-09-22 [2] CRAN (R 4.6.1)
    #>  pkgdown              2.2.1   2026-07-07 [2] any (@2.2.1)
    #>  purrr                1.2.2   2026-04-10 [2] CRAN (R 4.6.1)
    #>  R6                   2.6.1   2025-02-15 [2] CRAN (R 4.6.1)
    #>  ragg                 1.5.2   2026-03-23 [2] CRAN (R 4.6.1)
    #>  renv                 1.0.7   2024-04-11 [2] RSPM (R 4.6.1)
    #>  rlang                1.3.0   2026-07-05 [2] CRAN (R 4.6.1)
    #>  rmarkdown            2.31    2026-03-26 [2] CRAN (R 4.6.1)
    #>  sass                 0.4.10  2025-04-11 [2] CRAN (R 4.6.1)
    #>  sessioninfo          1.2.4   2026-06-04 [2] CRAN (R 4.6.1)
    #>  systemfonts          1.3.2   2026-03-05 [2] CRAN (R 4.6.1)
    #>  textshaping          1.0.5   2026-03-06 [2] CRAN (R 4.6.1)
    #>  tibble               3.3.1   2026-01-11 [2] CRAN (R 4.6.1)
    #>  tidyr                1.3.2   2025-12-19 [2] CRAN (R 4.6.1)
    #>  tidyselect           1.2.1   2024-03-11 [2] CRAN (R 4.6.1)
    #>  vctrs                0.7.3   2026-04-11 [2] CRAN (R 4.6.1)
    #>  withr                3.0.3   2026-06-19 [2] CRAN (R 4.6.1)
    #>  xfun                 0.60    2026-07-09 [2] CRAN (R 4.6.1)
    #>  yaml                 2.3.12  2025-12-10 [2] CRAN (R 4.6.1)
    #> 
    #>  [1] /tmp/Rtmph67Pun/temp_libpath87a93012435a
    #>  [2] /home/runner/.cache/R/renv/library/aphantasiaWMStrats-f7ce8556/linux-ubuntu-noble/R-4.6/x86_64-pc-linux-gnu
    #>  [3] /home/runner/.cache/R/renv/sandbox/linux-ubuntu-noble/R-4.6/x86_64-pc-linux-gnu/e7c0fad7
    #>  * ── Packages attached to the search path.
    #> 
    #> ──────────────────────────────────────────────────────────────────────────────
