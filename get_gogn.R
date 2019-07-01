# ------------------------------------------------------------ #
#
# Gögn af Bilasolur.is
#
# ------------------------------------------------------------ #


library(tidyverse)
library(rvest)




# Bý til slóðir -----------------------------------------------------------


# Finn fjölda síðna

# sida_1 <- "https://bilasolur.is/SearchResults.aspx?page=1&id=e7b7bcf4-eecd-46b7-8dce-d8e609b0ac0b"
#
# while(
#         slod <- sida_1 %>%
#         read_html() %>%
#         html_nodes(".pagingCell") %>%
#         html_text()
# )


# Bý til slóðir
max_sidur <- 279

slodir <- paste0("https://bilasolur.is/SearchResults.aspx?page=", 1:max_sidur, "&id=e7b7bcf4-eecd-46b7-8dce-d8e609b0ac0b")


gogn <- list()

for(i in seq_along(slodir)) {
        slodir[i] %>%
                read_html() %>%
                html_nodes(".car-price , .tech-details div, .car-make-and-model") %>%
                html_text() -> gogn[[i]]
}



