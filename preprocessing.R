
pacman::p_load(tidyverse)

setwd("~/Documents/UNI/sem 5/bachelor/bbbb_project")


music <- read_csv("test.csv")
non_music <- read_csv("test2.csv")

music$alpha2 <- toupper(music$country)
non_music$alpha2 <- toupper(non_music$country)


country_codes <- read_csv("country_codes_all.csv") %>% 
  select(starts_with("alpha")) %>% 
  rename(alpha2 = `alpha-2`,
         alpha3 = `alpha-3`)


epidem <- read_csv("epidem.csv")%>% 
  filter(date >= "2020-02-01" & date <= "2020-05-01")

epidem <- merge(epidem, country_codes)

mobility <- read_csv("mobility.csv")%>% 
  filter(date >= "2020-02-01" & date <= "2020-05-01") 

stringency <- read_csv("stringency.csv")%>% 
  filter(date >= "2020-02-01" & date <= "2020-05-01")

stringency <- merge(stringency, country_codes)

df_music <- left_join(music, epidem)
df_non_music <- left_join(non_music, epidem)

stringency_new <- aggregate(StringencyIndex~date+alpha2, stringency, mean)

df_music <- left_join(df_music, stringency_new)
df_non_music <- left_join(df_non_music, stringency_new)


mobility_new <- aggregate(.~date+alpha2, mobility_new, mean)

df_music <- left_join(df_music, mobility_new)
df_non_music <- left_join(df_non_music, mobility_new)

write_csv(df_music, "df_music.csv")
write_csv(df_non_music, "df_non.csv")

######

df_m <- read_csv("df_music_sentiment.csv")
df_n <- read_csv("df_non_sentiment.csv")
df_m_old <- read_csv("df_music.csv")
df_n_old <- read_csv("df_non.csv")

df_m <- cbind(df_m, df_m_old)
df_n <- cbind(df_n, df_n_old)

df_m$type <- "music"
df_n$type <- "non"

full_df <- rbind(df_m, df_n)

write_csv(full_df, "full_df.csv")

