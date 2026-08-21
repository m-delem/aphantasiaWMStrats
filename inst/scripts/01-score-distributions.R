# -----------------------------------------------------------------------
# 01-score-distributions.R
#
# Targeted checks on the scores produced by compute_scores(), run before
# any of them are relied on downstream. Diagnostic, not exported package
# functionality — see 03-validity-checks.md §4 for why this kind of work
# lives in inst/scripts/.
#
# Answers four questions, in the order they gate each other:
#
#   Q1  Does the orientation period (180 vs 360) change any downstream
#       conclusion? The period itself is settled on structural grounds
#       (01-score-computation.md §2); this is a sensitivity analysis, not
#       a decision procedure.
#   Q2  Is per-version standardisation stable at v2's N=9 and v3's N=21?
#       (01-score-computation.md §3's flagged caution.)
#   Q3  Do raw and standardised scores actually tell different stories, and
#       is each usable by the strand 01 §4 assigns it to?
#   Q4  Closes out the cross-check and the Damerau-vs-plain question, both
#       largely settled during implementation.
#
# Plus two data-quality items that surfaced while writing this and belong
# in exclusion review rather than in a score column.
#
# Figures are written to inst/scripts/figures/ at base_size = 16 for reuse
# in the scoring vignette.
# -----------------------------------------------------------------------

devtools::load_all()

library(ggplot2)

fig_dir <- here::here("inst/scripts/figures")
fs::dir_create(fig_dir)
# Vector PDFs at printed size, not screen-size PNGs: these figures are for
# the poster and the thesis chapter, not for the pkgdown site (which uses
# theme_pdf(base_size = 16) instead).
theme_set(theme_pdf())

save_fig <- function(plot, name, ncol = 2, height = 75) {
  save_ggplot(
    fs::path("inst/scripts/figures", paste0(name, ".pdf")),
    plot, ncol = ncol, height = height
  )
}

rule <- function(txt) cat("\n", strrep("-", 70), "\n", txt, "\n", sep = "")

# Blocks only: tutorial rows carry front-end placeholders and training rows
# precede the blocks by design (01 §2.5.1).
blocks <- dplyr::filter(all_data, grepl("^expe_block", expe_phase))

features <- c("score_word", "score_angle", "score_color")
labels <- c(score_word = "Word", score_angle = "Orientation",
            score_color = "Colour")

# Participant-by-version is the analysis unit throughout: one participant
# completed both v1 and v3 (01 §3), so `id` alone would silently merge them.
blocks <- dplyr::mutate(blocks, unit = paste(id, version, sep = "_"))

# -----------------------------------------------------------------------
# Q1. Orientation period sensitivity
# -----------------------------------------------------------------------
rule("Q1. Does the orientation period change anything downstream?")

blocks <- dplyr::mutate(
  blocks,
  score_angle_p360 = score_angular(target_angle, response_angle, period = 360),
  score_angle_p360 = ifelse(responded_angle, score_angle_p360, 0)
)

cat("\nStimulus level:\n")
cat("  Pearson  r(period 180, period 360) =",
    round(cor(blocks$score_angle, blocks$score_angle_p360), 4), "\n")
cat("  Spearman r                         =",
    round(cor(blocks$score_angle, blocks$score_angle_p360,
              method = "spearman"), 4), "\n")
cat("  range under 180:",
    paste(round(range(blocks$score_angle), 3), collapse = " - "), "\n")
cat("  range under 360:",
    paste(round(range(blocks$score_angle_p360), 3), collapse = " - "), "\n")

# Participant means are what the compositional and clustering strands
# actually consume, so rank stability there matters more than at stimulus
# level.
per_unit <- blocks |>
  dplyr::group_by(unit, version) |>
  dplyr::summarise(
    dplyr::across(dplyr::all_of(c(features, "score_angle_p360")), mean),
    .groups = "drop"
  )

cat("\nParticipant level (n =", nrow(per_unit), "):\n")
cat("  Spearman r(period 180, period 360) =",
    round(cor(per_unit$score_angle, per_unit$score_angle_p360,
              method = "spearman"), 4), "\n")

rank_shift <- abs(rank(per_unit$score_angle) - rank(per_unit$score_angle_p360))
cat("  max rank shift:", max(rank_shift), "places of", nrow(per_unit), "\n")
cat("  participants shifting >5 places:", sum(rank_shift > 5), "\n")

# The consequence that actually matters: the compositional strand works on
# relative allocation, so ask whether the period changes the composition.
comp <- per_unit |>
  dplyr::mutate(
    prop_angle_180 = score_angle / (score_word + score_angle + score_color),
    prop_angle_360 = score_angle_p360 /
      (score_word + score_angle_p360 + score_color)
  )
cat("\n  mean orientation share of the composition:\n")
cat("    under period 180:", round(mean(comp$prop_angle_180), 4), "\n")
cat("    under period 360:", round(mean(comp$prop_angle_360), 4), "\n")
cat("    max per-participant shift:",
    round(max(abs(comp$prop_angle_180 - comp$prop_angle_360)), 4), "\n")

p_q1 <- per_unit |>
  tidyr::pivot_longer(c(score_angle, score_angle_p360),
                      names_to = "period", values_to = "score") |>
  dplyr::mutate(period = ifelse(period == "score_angle",
                                "Period 180 (adopted)", "Period 360")) |>
  ggplot(aes(score, fill = period)) +
  geom_histogram(bins = 30, alpha = 0.75, position = "identity") +
  facet_wrap(~period) +
  labs(x = "Mean orientation score", y = "Participants",
       title = "Orientation score under the two angular periods") +
  theme(legend.position = "none")
save_fig(p_q1, "q1-orientation-period")

# -----------------------------------------------------------------------
# Q2. Is per-version standardisation stable at small N?
# -----------------------------------------------------------------------
rule("Q2. Per-version standardisation stability (01 §3's flagged caution)")

cat("\nParticipants per version:\n")
print(table(per_unit$version))

# Leave-one-participant-out: drop each unit, recompute that version's
# moments from the rest, and see how far everyone else's z-score moves.
loo_shift <- function(df, col) {
  out <- list()
  for (v in unique(df$version)) {
    d <- df[df$version == v, ]
    x <- d[[col]]
    full <- (x - mean(x)) / stats::sd(x)
    shifts <- vapply(seq_along(x), function(i) {
      mu <- mean(x[-i]); sdev <- stats::sd(x[-i])
      max(abs((x[-i] - mu) / sdev - full[-i]))
    }, numeric(1))
    out[[v]] <- data.frame(version = v, feature = col,
                           n = length(x),
                           median_shift = median(shifts),
                           max_shift = max(shifts))
  }
  do.call(rbind, out)
}

loo <- do.call(rbind, lapply(features, function(f) loo_shift(per_unit, f)))
cat("\nMax movement in any participant's z-score when one participant is\n")
cat("removed from the standardisation sample (in SD units):\n\n")
print(loo, row.names = FALSE, digits = 3)

p_q2 <- per_unit |>
  tidyr::pivot_longer(dplyr::all_of(features),
                      names_to = "feature", values_to = "score") |>
  dplyr::mutate(feature = labels[feature]) |>
  ggplot(aes(version, score, colour = version)) +
  geom_boxplot(outlier.shape = NA, alpha = 0.3) +
  geom_jitter(width = 0.15, alpha = 0.6, size = 1.8) +
  facet_wrap(~feature) +
  labs(x = NULL, y = "Mean score", colour = NULL,
       title = "Per-version score distributions") +
  theme(legend.position = "none")
save_fig(p_q2, "q2-version-distributions")

# -----------------------------------------------------------------------
# Q3. Raw vs standardised, and whether each strand can use its assigned input
# -----------------------------------------------------------------------
rule("Q3. Raw vs standardised divergence")

cat("\nWithin a version, z is a linear transform of raw, so rank order is\n")
cat("identical by construction. The interesting divergence is elsewhere:\n")

for (f in features) {
  r <- cor(blocks[[f]], blocks[[paste0(f, "_z")]], method = "spearman")
  cat(sprintf("  %-12s spearman(raw, z) = %.4f\n", labels[f], r))
}

# 01 §4 assigns standardised scores to the compositional strand. Both
# log-ratio families (ILR included) need strictly positive parts.
z_cols <- paste0(features, "_z")
cat("\nCompositional feasibility check (log-ratio needs strictly positive parts):\n")
cat("  negative values among standardised scores:",
    sum(blocks[z_cols] < 0, na.rm = TRUE), "of",
    prod(dim(blocks[z_cols])), "\n")
cat("  exact zeros among raw scores, by feature:\n")
for (f in features) {
  cat(sprintf("    %-12s %5d rows (%.1f%%)\n", labels[f],
              sum(blocks[[f]] == 0), 100 * mean(blocks[[f]] == 0)))
}
cat("  participants with a zero mean on some feature:",
    sum(apply(per_unit[features], 1, function(r) any(r == 0))), "\n")

p_q3 <- blocks |>
  tidyr::pivot_longer(dplyr::all_of(features),
                      names_to = "feature", values_to = "score") |>
  dplyr::mutate(feature = labels[feature]) |>
  ggplot(aes(score)) +
  geom_histogram(bins = 40) +
  facet_wrap(~feature, scales = "free_y") +
  labs(x = "Raw similarity score", y = "Stimuli",
       title = "Raw score distributions, experimental blocks") 
save_fig(p_q3, "q3-raw-distributions")

# -----------------------------------------------------------------------
# Q4. Closing out the cross-check and the Damerau question
# -----------------------------------------------------------------------
rule("Q4. Cross-check against live_diff_*, and Damerau vs plain Levenshtein")

resp_a <- dplyr::filter(blocks, responded_angle)
lin_a <- 1 - abs(resp_a$target_angle - resp_a$response_angle) / 180
cat("\nAngle : cor(linear analogue, 1 - live_diff_angle) =",
    round(cor(lin_a, 1 - resp_a$live_diff_angle), 6), "\n")

resp_c <- dplyr::filter(blocks, responded_color)
craw <- abs(resp_c$target_color_angle - resp_c$response_color_angle)
lin_c <- 1 - ifelse(craw > 180, 360 - craw, craw) / 180
cat("Colour: cor(linear analogue, 1 - live_diff_color) =",
    round(cor(lin_c, 1 - resp_c$live_diff_color), 6), "\n")
cat("  (residual is the front end's 2-decimal rounding, not disagreement)\n")

resp_w <- dplyr::filter(blocks, responded_word)
tw <- normalise_word(resp_w$target_word)
rw <- normalise_word(resp_w$response_word)
lev <- mapply(function(a, b) as.integer(utils::adist(a, b)), tw, rw,
              USE.NAMES = FALSE)
dl <- mapply(damerau_levenshtein, tw, rw, USE.NAMES = FALSE)
plain_score <- (nchar(tw) - pmin(lev, nchar(tw))) / nchar(tw)

cat("\nWord, Gonthier denominator held fixed, metric varied:\n")
cat("  rows where Damerau-Levenshtein < plain Levenshtein:", sum(dl < lev), "\n")
cat("  cor(DL score, plain-Lev score) =",
    round(cor(resp_w$score_word, plain_score), 6), "\n")

cat("\nWord: decomposing Gonthier's formula against a naive normalised\n")
cat("distance, one design choice at a time (n =", length(dl), "responded trials):\n")
no_cap <- (nchar(tw) - dl) / nchar(tw)
denom_score <- (nchar(tw) - pmin(dl, nchar(tw))) / pmax(nchar(tw), nchar(rw))
cat(sprintf("  metric      (Damerau-Levenshtein vs plain): %4d rows changed\n",
            sum(abs(resp_w$score_word - plain_score) > 1e-9)))
cat(sprintf("  denominator (len(target) vs max-len)      : %4d rows changed\n",
            sum(abs(resp_w$score_word - denom_score) > 1e-9)))
cat(sprintf("  the cap     (floor at 0)                  : %4d rows changed\n",
            sum(abs(resp_w$score_word - no_cap) > 1e-9)))
cat("\n  Without the cap, scores run as low as",
    round(min(no_cap), 3), "- the cap is not cosmetic.\n")

# -----------------------------------------------------------------------
# Data-quality items for exclusion review, not for a score column
# -----------------------------------------------------------------------
rule("Data-quality items to raise in data-raw/review/")

nonresp <- blocks |>
  dplyr::group_by(unit, version) |>
  dplyr::summarise(
    nonresp_word  = 1 - mean(responded_word),
    nonresp_angle = 1 - mean(responded_angle),
    nonresp_color = 1 - mean(responded_color),
    vviq = dplyr::first(vviq_total_score),
    .groups = "drop"
  )

flagged <- dplyr::filter(
  nonresp,
  dplyr::if_any(dplyr::starts_with("nonresp_"), ~ .x >= 0.9)
)
cat("\nParticipants with >=90% non-response on any feature:\n")
print(as.data.frame(flagged), row.names = FALSE, digits = 3)
cat("\nUnder 01 §2.5.2 these acquire a mean score of ~0 on that feature,\n")
cat("which reads as 'maximally poor memory' when it means 'no data'.\n")
cat("Exclusion candidates, or at minimum a documented caveat.\n")

dup <- names(which(table(unique(blocks[c("id", "version")])$id) > 1))
cat("\nParticipants appearing in more than one version:",
    if (length(dup)) paste(dup, collapse = ", ") else "none", "\n")

rule("Done. Figures written to inst/scripts/figures/")
