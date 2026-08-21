# -----------------------------------------------------------------------
# 02-reliability.R
#
# Implements the reliability core of 03-validity-checks.md: §2.1 per-feature
# split-half reliability, §2.2 split-half stability of the compositional
# profile, §2.3 behavioural allocation vs self-reported strategy.
#
# Sample: v1 only (N=88), per 02-pooling-strategy.md §3.5.
# Scores: responders only, per 03 §2.1 as amended — non-responses are
# scored 0 in the package columns, and a participant who never touched a
# widget would otherwise show perfect trial-to-trial consistency while
# measuring nothing.
#
# Engagement threshold: a participant contributes to a feature only if
# they responded on enough trials for their mean to be worth comparing to
# other participants' — specifically, standard error of the mean at most
# half the between-person SD, which gives n >= (sd_within / (0.5 *
# sd_between))^2. Computed from the data below rather than assumed, and
# fixed before any VVIQ contact per 03 §2.1.
#
# Split-half procedure: splits are drawn at the TRIAL level, not the item
# level, and repeated. 03 §5 flagged that a naive odd/even split should not
# be assumed appropriate; §1 below is that check.
# -----------------------------------------------------------------------

devtools::load_all()
library(ggplot2)

set.seed(20260820)
N_SPLITS <- 1000

fig_dir <- here::here("inst/scripts/figures")
fs::dir_create(fig_dir)
theme_set(theme_pdf())
rule <- function(txt) cat("\n", strrep("-", 70), "\n", txt, "\n", sep = "")

features <- c("word", "angle", "color")
labels <- c(word = "Word", angle = "Orientation", color = "Colour")

d <- all_data |>
  dplyr::filter(version == "v1", grepl("^expe_block", expe_phase)) |>
  dplyr::mutate(
    trial_uid = paste(expe_phase, trial_number, sep = "_"),
    within_trial_pos = ((item_number - 1L) %% 3L) + 1L
  )

# -----------------------------------------------------------------------
# 1. Why the split is at trial level (03 §5's open question, answered)
# -----------------------------------------------------------------------
rule("1. Split unit: trials, not items")

cat("\nWithin-trial serial position, responders only:\n")
for (f in features) {
  x <- d[[paste0("score_", f)]]; r <- d[[paste0("responded_", f)]]
  m <- tapply(x[r], d$within_trial_pos[r], mean)
  cat(sprintf("  %-12s pos1 %.3f  pos2 %.3f  pos3 %.3f  (drop %.3f)\n",
              labels[f], m[1], m[2], m[3], m[1] - m[3]))
}
cat("\nThere is a primacy effect, strongest for word. Items within a trial\n")
cat("also share an encoding episode, so they are not exchangeable units.\n")
cat("Splits are therefore drawn over the 21 trials, keeping each trial's\n")
cat("three items together, which balances serial position across halves by\n")
cat("construction. Repeated random splits rather than a single odd/even\n")
cat("split, to avoid depending on one arbitrary partition.\n")

# -----------------------------------------------------------------------
# 2. Engagement threshold (03 §2.1), derived before any VVIQ contact
# -----------------------------------------------------------------------
rule("2. Engagement threshold, derived from precision requirements")

feature_mean <- function(df, f) {
  sc <- df[[paste0("score_", f)]]; rp <- df[[paste0("responded_", f)]]
  tapply(seq_len(nrow(df)), df$id,
         function(i) if (any(rp[i])) mean(sc[i][rp[i]]) else NA_real_)
}
feature_n <- function(df, f) tapply(df[[paste0("responded_", f)]], df$id, sum)

N_TRIALS <- 63L
FLOOR <- 32L   # fallback: half the available trials, a data-sufficiency
               # floor rather than a precision guarantee

thresholds <- setNames(integer(length(features)), features)
infeasible <- character(0)
for (f in features) {
  sc <- d[[paste0("score_", f)]]; rp <- d[[paste0("responded_", f)]]
  sd_within <- median(tapply(seq_len(nrow(d)), d$id,
    function(i) if (sum(rp[i]) > 2) stats::sd(sc[i][rp[i]]) else NA_real_), na.rm = TRUE)
  sd_between <- stats::sd(feature_mean(d, f), na.rm = TRUE)
  need <- ceiling((sd_within / (0.5 * sd_between))^2)
  feasible <- need <= N_TRIALS
  if (!feasible) infeasible <- c(infeasible, f)
  thresholds[f] <- if (feasible) need else FLOOR
  cat(sprintf("  %-12s sd_within %.3f  sd_between %.3f  -> needs %d of %d%s\n",
              labels[f], sd_within, sd_between, need, N_TRIALS,
              if (feasible) "" else "  ** NOT ACHIEVABLE **"))
}

if (length(infeasible)) {
  cat("\n  ** ", paste(labels[infeasible], collapse = ", "),
      ": the precision criterion cannot be met at any achievable trial\n",
      "  count. Between-person variance is too small relative to\n",
      "  trial-level noise — a participant's mean cannot be estimated\n",
      "  precisely enough to rank them against other participants, no\n",
      "  matter how many of the 63 trials they answer.\n",
      "  Falling back to a floor of ", FLOOR, " responded trials, which is a\n",
      "  data-sufficiency rule, NOT a precision guarantee. Any\n",
      "  individual-differences claim for these features is unsupported\n",
      "  by the measurement, independently of what the models return.\n", sep = "")
}
n_resp <- sapply(features, function(f) feature_n(d, f))
cat("\nParticipants excluded per feature: ",
    paste(sprintf("%s %d", labels[features],
                  colSums(t(t(n_resp) < thresholds))), collapse = " | "),
    "\n  (of ", nrow(n_resp), " in v1)\n", sep = "")
cat("\nThese exclusions are not random with respect to imagery, so all\n")
cat("estimates below are conditional: accuracy given response, among those\n")
cat("who responded often enough for a mean to be estimable.\n")

# -----------------------------------------------------------------------
# 3. §2.1 — per-feature split-half reliability
# -----------------------------------------------------------------------
rule("3. §2.1 Per-feature split-half reliability")

trials <- unique(d$trial_uid)

split_half_r <- function(f, n_splits = N_SPLITS) {
  sc <- d[[paste0("score_", f)]]; rp <- d[[paste0("responded_", f)]]
  keep <- names(which(feature_n(d, f) >= thresholds[f]))
  idx <- d$id %in% keep
  out <- numeric(n_splits)
  for (k in seq_len(n_splits)) {
    a <- sample(trials, length(trials) %/% 2)
    ha <- idx & rp & d$trial_uid %in% a
    hb <- idx & rp & !(d$trial_uid %in% a)
    ma <- tapply(sc[ha], d$id[ha], mean)
    mb <- tapply(sc[hb], d$id[hb], mean)
    common <- intersect(names(ma), names(mb))
    out[k] <- if (length(common) > 2)
      suppressWarnings(stats::cor(ma[common], mb[common])) else NA_real_
  }
  out
}

sb <- function(r) 2 * r / (1 + r)   # Spearman-Brown, half-test -> full-test

rel <- lapply(features, split_half_r)
names(rel) <- features

cat("\n", N_SPLITS, " random trial-level splits, Spearman-Brown corrected:\n", sep = "")
rel_tab <- do.call(rbind, lapply(features, function(f) {
  r <- rel[[f]][!is.na(rel[[f]])]
  data.frame(feature = labels[f], n = sum(feature_n(d, f) >= thresholds[f]),
             threshold = unname(thresholds[f]),
             raw_median = median(r), sb_median = sb(median(r)),
             sb_lo = sb(stats::quantile(r, .025)),
             sb_hi = sb(stats::quantile(r, .975)))
}))
print(rel_tab, row.names = FALSE, digits = 3)

cat("\nBenchmark: .70 is the conventional floor for group-level research use,\n")
cat(".80+ for anything approaching individual-level interpretation. 03 §2.1\n")
cat("is explicit that a weak-but-nonzero result is reportable rather than a\n")
cat("stop condition — but it changes how much weight downstream models bear.\n")

p_rel <- data.frame(
  feature = rep(labels[features], each = N_SPLITS),
  r = sb(unlist(rel))
) |> dplyr::filter(!is.na(r)) |>
  ggplot(aes(r, fill = feature)) +
  geom_histogram(bins = 40, show.legend = FALSE) +
  geom_vline(xintercept = 0.7, linetype = "dashed") +
  facet_wrap(~feature) +
  scale_discrete_feature(aesthetics = "fill") +
  labs(x = "Split-half reliability (Spearman-Brown corrected)",
       y = paste("Count of", N_SPLITS, "splits"),
       title = "Per-feature reliability, v1, responders only")
save_ggplot("inst/scripts/figures/r1-split-half-reliability.pdf", p_rel,
            ncol = 2, height = 70)

# -----------------------------------------------------------------------
# 4. §2.2 — stability of the compositional profile
# -----------------------------------------------------------------------
rule("4. §2.2 Split-half stability of the compositional profile")

cat("\nThis is the gate 06-compositional-analysis.md §8.5 makes the whole\n")
cat("compositional strand conditional on. Composition built from\n")
cat("responders-only means; participants must clear all three thresholds.\n")

keep_all <- Reduce(intersect, lapply(features, function(f)
  names(which(feature_n(d, f) >= thresholds[f]))))
cat("Participants clearing all three thresholds:", length(keep_all), "\n")

ilr <- function(p1, p2, p3) cbind(
  ilr1 = sqrt(2/3) * log(p1 / sqrt(p2 * p3)),   # word vs (colour, orientation)
  ilr2 = sqrt(1/2) * log(p2 / p3)               # colour vs orientation
)

comp_half <- function(ids, trial_set) {
  sel <- d$id %in% ids & d$trial_uid %in% trial_set
  parts <- sapply(features, function(f) {
    sc <- d[[paste0("score_", f)]]; rp <- d[[paste0("responded_", f)]]
    s <- sel & rp
    tapply(sc[s], factor(d$id[s], levels = ids), mean)
  })
  tot <- rowSums(parts)
  ilr(parts[, "word"] / tot, parts[, "color"] / tot, parts[, "angle"] / tot)
}

stab <- matrix(NA_real_, N_SPLITS, 2, dimnames = list(NULL, c("ilr1", "ilr2")))
for (k in seq_len(N_SPLITS)) {
  a <- sample(trials, length(trials) %/% 2)
  ca <- comp_half(keep_all, a)
  cb <- comp_half(keep_all, setdiff(trials, a))
  ok <- stats::complete.cases(ca) & stats::complete.cases(cb)
  if (sum(ok) > 2) {
    stab[k, "ilr1"] <- stats::cor(ca[ok, 1], cb[ok, 1])
    stab[k, "ilr2"] <- stats::cor(ca[ok, 2], cb[ok, 2])
  }
}

cat("\nProfile stability across random trial halves, Spearman-Brown corrected:\n")
cat(sprintf("  ilr1  word vs (colour+orientation) : %.3f  [%.3f, %.3f]\n",
    sb(median(stab[, "ilr1"], na.rm = TRUE)),
    sb(stats::quantile(stab[, "ilr1"], .025, na.rm = TRUE)),
    sb(stats::quantile(stab[, "ilr1"], .975, na.rm = TRUE))))
cat(sprintf("  ilr2  colour vs orientation        : %.3f  [%.3f, %.3f]\n",
    sb(median(stab[, "ilr2"], na.rm = TRUE)),
    sb(stats::quantile(stab[, "ilr2"], .025, na.rm = TRUE)),
    sb(stats::quantile(stab[, "ilr2"], .975, na.rm = TRUE))))
cat("\nilr1 is the theoretically motivated coordinate (06 §2) and the\n")
cat("low-variance one (06 §2's amendment). If it is also the unstable one,\n")
cat("that is the compositional strand's central problem, not a detail.\n")

# -----------------------------------------------------------------------
# 5. §2.3 — behavioural allocation vs self-reported priority
# -----------------------------------------------------------------------
rule("5. §2.3 Behavioural allocation vs self-reported scoring priority")

strat <- do.call(rbind, lapply(which(!duplicated(d$id)), function(i) {
  s <- d$strategy_items[[i]][1, ]
  data.frame(id = d$id[i],
             p1 = as.character(s$strats_cfa_q04_scoring_strat_1_1),
             p2 = as.character(s$strats_cfa_q04_scoring_strat_2_1),
             p3 = as.character(s$strats_cfa_q04_scoring_strat_3_1),
             stringsAsFactors = FALSE)
}))
strat$priority <- apply(strat[c("p1", "p2", "p3")], 1, function(r) {
  r <- r[!is.na(r) & r %in% c("words", "colours", "orientations")]
  if (length(r) == 1) r else if (length(r) > 1) "multiple" else "none/other"
})
cat("\nSelf-reported scoring priority (v1):\n")
print(table(strat$priority, useNA = "ifany"))

parts <- sapply(features, function(f) feature_mean(d, f))
tot <- rowSums(parts)
props <- data.frame(id = rownames(parts), prop_word = parts[, "word"] / tot,
                    prop_angle = parts[, "angle"] / tot,
                    prop_color = parts[, "color"] / tot)
m <- merge(props, strat[c("id", "priority")], by = "id")
m <- m[m$id %in% keep_all, ]

cat("\nBehavioural composition by self-reported priority (n per group in brackets):\n")
agg <- do.call(rbind, lapply(split(m, m$priority), function(g) data.frame(
  priority = g$priority[1], n = nrow(g),
  prop_word = mean(g$prop_word), prop_angle = mean(g$prop_angle),
  prop_color = mean(g$prop_color))))
print(agg, row.names = FALSE, digits = 3)

cat("\n03 §2.3 is explicit that divergence here is NOT evidence of\n")
cat("invalidity — the v1 finding that self-report favoured colour while\n")
cat("performance favoured word is a real dissociation worth reporting.\n")
cat("The check exists so the relationship is known and stated.\n")

rule("Done. Figures written to inst/scripts/figures/")
