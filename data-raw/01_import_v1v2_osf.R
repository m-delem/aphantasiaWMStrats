library(osfr)

# Creating an OSF Personal Access Token (PAT) is necessary for downloads from
# a private project.
# See: https://docs.ropensci.org/osfr/articles/auth
# osf_auth("ThIsIsNoTaReAlPATbUtYoUgEtIt")

# Retrieving the RDA data files from the "Aphantasia Online Studies Data" OSF
# project (hzqdj), the same umbrella-level source aSD itself extracts from.
# This pulls aSD's already-processed output directly: aWMS does not re-run
# aSD's own extraction pipeline, since that pipeline depends on data from
# DLC-Reason and GPL-DRM that aWMS has no reason to touch.
#
# v1 and v2 CFA-WM data live in this general "Data (raw and processed)"
# component (https://osf.io/pr724/) alongside the other online studies' data,
# not in the CFA-WM-specific OSF component - only v3 (independent, live)
# lives there. See the CFA-WM component wiki's "Version history" page for the
# full rationale.
#
# "full" data is pulled deliberately: aWMS needs raw VVIQ/OSIVQ item
# responses, not just derived scores, to build the item-level list-columns
# created in 03_create_package_data.R. The CFA-WM experiment file itself is
# named" expe_working_memory_data.rda" on OSF.
osf_retrieve_node("pr724") |>
  osf_ls_files() |>
  dplyr::filter(stringr::str_detect(name, "R format")) |>
  osf_ls_files() |>
  dplyr::filter(stringr::str_detect(name, "full|expe_working_memory")) |>
  osf_download(path = here::here("inst/extdata"), conflicts = "overwrite")
