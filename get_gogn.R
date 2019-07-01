# ------------------------------------------------------------ #
#
# Gögn af Bilasolur.is
#
# ------------------------------------------------------------ #


library(tidyverse)
library(rvest)
library(lubridate)


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


# Sæki gögn
gogn <- list()

for(i in seq_along(slodir)) {
        slodir[i] %>%
                read_html() %>%
                html_nodes(".car-price , .tech-details div, .car-make-and-model") %>%
                html_text() -> gogn[[i]]
}


# list to tibble

gogn_to_df <- function(x) {
        mat <- matrix(x, ncol = 4,  byrow = TRUE)
        df <- as_tibble(mat)
}


df <- map(gogn, gogn_to_df) %>%
        bind_rows()


# Hreinsa gögnin ----------------------------------------------------------

# 23 bílar sem ekki höfuð árgerð og/eða aflgjafa. Hendi þeim út.
df <- df %>%
        separate(V2, into = c("argerd", "aflgjafi"), sep = "·") %>%
        na.omit()


df <- df %>%
        separate("V3", into = c("akstur", "skipting") , sep = "·")


colnames(df) <- c("tegund", "argerd", "aflgjafi", "akstur", "skipting", "verd")


df$verd <- gsub("kr.", "", df$verd)  # hendi út kr.
df$verd <- gsub("V.*", "", df$verd)  # hendi út öllu eftir "V"
df$verd <- gsub("an.*", "", df$verd) # hendi út öllu eftir "an
df$verd <- gsub("án.*", "", df$verd) # hendi út öllu eftir "án"
df$verd <- gsub("\\.", "", df$verd)  # losa mig við "." úr verðinu
df$verd <- as.numeric(df$verd)


df$akstur <- gsub("km.", "", df$akstur)
df$akstur <- gsub("\\.", "", df$akstur)
df$akstur <- as.numeric(df$akstur)


df$argerd <- str_trim(df$argerd)
df <- df %>%
        mutate(argerd = case_when(nchar(argerd) > 7 ~ substr(argerd, 1, nchar(argerd) - 6),
                                  TRUE ~ argerd))

df$argerd <- str_trim(df$argerd)

df <- df %>%
        mutate(ar_argerd =  as.numeric(substr(argerd, nchar(argerd) - 3, nchar(argerd))),
               man_argerd = as.numeric(substr(argerd, 1, nchar(argerd) - 5)))


# Í árgerð vantar stundum mánuð, set inn 06

df$man_argerd[is.na(df$man_argerd)] <- 6

df <- df %>%
        filter(man_argerd <= 12)
