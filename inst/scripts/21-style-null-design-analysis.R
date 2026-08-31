# ------------------------------------------------------------------------- #
# 21-style-null-design-analysis.R ----
#
# What the OSIVQ null in the allocation model can and cannot mean.
#
# The floor-group offset and the OSIVQ coefficients come from the same 78
# participants and the same model (alloc-full.rds), so "the sample was too
# small" cannot be what separates the one that cleared the ROPE from the
# two that did not. What separates them is effect size. This script puts a
# number on that, two ways:
#
#   1. From the fitted posterior. The posterior SD of the OSIVQ verbal
#      coefficient is the resolution the study had. The smallest effect
#      whose 95% interval would have excluded zero is about twice that SD,
#      expressed in outcome-SD units so it can be read against the floor
#      offset's d.
#
#   2. By simulation. The allocation model is Gaussian, so a frequentist
#      refit is a faithful stand-in for power purposes and runs in
#      milliseconds where brms takes minutes. The fitted design matrix is
#      kept, the OSIVQ verbal coefficient is replaced by a target value,
#      ilr1 is simulated from the fitted residual SD, and the model is
#      refitted. For larger n, design rows are resampled with replacement,
#      which preserves v1's covariate structure, including its sparse
#      middle of the VVIQ range: this is "the same study, bigger", not an
#      idealised one.
#
# Two success criteria are recorded: the 95% CI sitting above zero, and
# the 95% CI sitting entirely above a ROPE of 0.1 outcome SD, which is the
# standard the EOR's composition page applies to every coefficient.
#
# Caveats the text should carry. The residual SD from lm() is marginally
# smaller than the brms marginal SD, since no prior shrinks it, so the
# simulated power is marginally optimistic. And the effect sizes are in
# outcome SD per predictor SD (the predictors are z-scored in the model
# frame), which is how the EOR's ROPE tables report d.
# ------------------------------------------------------------------------- #

devtools::load_all()
library(dplyr)
library(ggplot2)

set.seed(20260831)

result_dir <- here::here("inst/results")
fig_dir    <- here::here("inst/scripts/figures/thesis")
fs::dir_create(c(result_dir, fig_dir))

style_model <- readRDS(here::here("inst/models/alloc-full.rds"))
d <- style_model$data

f <- ilr1 ~ vviq + complete_aphant + parity_rate +
  osivq_spatial + osivq_verbal + nieq_inner_voice + nieq_unsymbolised

fit0  <- lm(f, data = d)
sigma <- summary(fit0)$sigma
sd_y  <- sd(d$ilr1)
beta  <- coef(fit0)
n_obs <- nrow(d)

# ------------------------------------------------------------------------- #
# 1. Resolution, from the posterior ----
# ------------------------------------------------------------------------- #
draws <- brms::as_draws_df(style_model)

resolution <- tibble(
  coefficient = c("OSIVQ verbal, on ilr1", "OSIVQ spatial, on ilr2",
                  "Floor offset, on ilr1"),
  posterior_sd = c(sd(draws$b_ilr1_osivq_verbal),
                   sd(draws$b_ilr2_osivq_spatial),
                   sd(draws$b_ilr1_complete_aphantfloor)),
  outcome_sd = c(sd(d$ilr1), sd(d$ilr2), sd(d$ilr1))
) |>
  mutate(
    posterior_sd_d = posterior_sd / outcome_sd,
    # the smallest effect whose central 95% interval would have excluded zero
    minimal_detectable_d = 1.96 * posterior_sd_d
  )

cat("\nResolution from the fitted posterior (d = outcome SD units):\n")
print(resolution, digits = 3)

# ------------------------------------------------------------------------- #
# 2. Power by simulation ----
#
# The bug in the first draft: `ci[1]` keeps its name ("2.5 %"), and
# c(excl_zero = ci[1] > 0) then produces a name like "excl_zero.2.5 %",
# which is why `r["excl_zero", ]` failed. `ci[[1]]` drops the name.
# ------------------------------------------------------------------------- #
sim_once <- function(effect_d, n) {
  rows <- if (n == n_obs) seq_len(n) else sample(n_obs, n, replace = TRUE)
  dd <- d[rows, ]
  b <- beta
  b["osivq_verbal"] <- effect_d * sd_y     # predictors are z-scored
  X <- model.matrix(f, dd)
  dd$ilr1 <- as.vector(X %*% b) + rnorm(n, 0, sigma)
  ci <- confint(lm(f, data = dd))["osivq_verbal", ]
  c(above_zero = ci[[1]] > 0,
    above_rope = ci[[1]] > 0.1 * sd_y)
}

n_sims <- 2000
design <- expand.grid(effect_d = c(0.1, 0.2, 0.3, 0.5),
                      n = c(n_obs, 150, 300, 600))

power <- purrr::map(seq_len(nrow(design)), \(i) {
  r <- replicate(n_sims, sim_once(design$effect_d[i], design$n[i]))
  tibble(effect_d = design$effect_d[i], n = design$n[i],
         power_above_zero = mean(r["above_zero", ]),
         power_above_rope = mean(r["above_rope", ]))
}) |>
  purrr::list_rbind()

cat("\nPower to detect an OSIVQ verbal effect on allocation:\n")
print(power, n = Inf)

saveRDS(list(resolution = resolution, power = power, n_sims = n_sims,
             sigma = sigma, sd_y = sd_y),
        fs::path(result_dir, "style-null-design.rds"))

# ------------------------------------------------------------------------- #
# 3. Figure ----
# ------------------------------------------------------------------------- #
floor_d <- resolution$posterior_sd_d[3]   # kept for the caption, not drawn

t7 <- power |>
  mutate(effect = factor(sprintf("d = %.1f", effect_d))) |>
  ggplot(aes(x = n, y = power_above_zero, colour = effect, group = effect)) +
  geom_hline(yintercept = 0.8, linetype = "dashed", linewidth = 0.25,
             colour = "grey60") +
  geom_vline(xintercept = n_obs, linetype = "dotted", linewidth = 0.25,
             colour = "grey60") +
  geom_line(linewidth = 0.5) +
  geom_point(size = 1.6) +
  scale_colour_viridis_d(end = 0.85, name = "Effect of OSIVQ verbal on allocation\n(outcome SD per predictor SD)") +
  scale_x_continuous(breaks = c(n_obs, 150, 300, 600)) +
  scale_y_continuous(limits = c(0, 1), labels = \(x) paste0(100 * x, "%")) +
  labs(x = "Participants", y = "Power (95% interval above zero)") +
  theme_pdf(base_size = 8) +
  theme(legend.position = "top", legend.title.position = "top")

save_ggplot(
  fs::path(fig_dir, "t7-style-null-power.pdf"),
  t7,
  width = 100,
  height = 80
)

cat("\nDone. Results in inst/results/style-null-design.rds\n")
