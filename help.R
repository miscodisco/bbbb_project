
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

df <- left_join(music, epidem)


#jeg skal mean over landende så der kun er én værdi pr land pr dag 

stringency_new <- aggregate(StringencyIndex~date+alpha2, stringency, mean)

df <- left_join(df, stringency_new)

mobility_new <- aggregate(.~date+alpha2, mobility_new, mean)

df <- left_join(df, mobility_new)

