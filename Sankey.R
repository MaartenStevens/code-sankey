#######################
# Sankeydiagram maken #
#######################

#################################################################
# Packages laden

# devtools::install_github("fbreitwieser/sankeyD3")

# library(networkD3) # Minder keuze voor opmaak diagram
library(sankeyD3) # Met dit package heb je controle over de font, de opacity, ...
library(tidyverse)

#################################################################
# Dataset laden

sank_pre <- read.csv(file = "./data/clc_1990_2018.csv", sep=";", dec = ",")
code <- read.csv(file = "./data/clc_1990_2018_code.csv", sep=";", dec = ",") %>% 
  select(c(clc_code, nara5_code, nara5_label, nara5_labels))

#################################################################
# Data bewerken

# Data groeperen per NARA-klasse

sank <- sank_pre %>%
  left_join(code, by = c("c1990" = "clc_code")) %>% 
  rename("from" = "nara5_code") %>%
  rename("labelS" = "nara5_labels") %>% 
  left_join(code, by = c("c2018" = "clc_code")) %>% 
  rename("to" = "nara5_code") %>% 
  rename("labelT" = "nara5_labels") %>%
  group_by(from, to) %>% 
  summarise(value = sum(count),
            labelS = unique(labelS),
            labelT = unique(labelT)) %>% 
  ungroup() %>% 
  mutate("jaarS" = 1990) %>% 
  mutate("jaarT" = 2018)

# Dataframe met nodes (= codes van landgebruiksklassen en bijhorende labels)

cp1 <- sank %>% 
  unite("cp1", c("jaarS","from")) %>%
  distinct(cp1) %>% 
  rename("codetxt" = cp1)
cp2 <- sank %>% 
  unite("cp2", c("jaarT","to")) %>% 
  distinct(cp2) %>% 
  rename("codetxt" = cp2)

nodes <- cp1 %>%
  bind_rows(cp2) %>% 
  distinct(codetxt) %>% 
  rownames_to_column() %>%
  rename("code" = rowname) %>% 
  mutate(code = as.numeric(code) - 1)

# Dataframe met links (= source (van), target (naar) en value (oppervlakte))

links_pre <- sank %>%
  unite("cp1", c("jaarS","from")) %>%
  unite("cp2", c("jaarT","to")) %>% 
  left_join(nodes, by = c("cp1" = "codetxt")) %>% 
  rename(source = code) %>% 
  left_join(nodes, by = c("cp2" = "codetxt")) %>% 
  rename(target = code) %>% 
  dplyr::select(c(source, target, value))

# Groepen aanmaken voor kleuren in grafiek en labels

groups <- sank %>%
  unite("cp1", c("jaarS","from"), remove = FALSE) %>%
  unite("cp2", c("jaarT","to"), remove = FALSE) %>% 
  left_join(nodes, by = c("cp1" = "codetxt")) %>% 
  rename(source = code) %>% 
  left_join(nodes, by = c("cp2" = "codetxt")) %>% 
  rename(target = code)
groups_links <- groups %>%
  dplyr::select(labelS, source) %>% 
  distinct(source, .keep_all = TRUE)

# Groepen toewijzen aan nodes en links

links <- links_pre %>% 
  left_join(groups_links, by = "source") %>% 
  rename("group" = "labelS")

nodes <- nodes %>% 
  left_join(select(groups, cp1, labelS), by = c("codetxt" = "cp1")) %>%  
  left_join(select(groups, cp2, labelT), by = c("codetxt" = "cp2")) %>%
  distinct(code, .keep_all = TRUE) %>% 
  mutate(group = coalesce(labelS, labelT))

# Aaneen plakken nodes en links in een List object

data <- list(nodes = nodes, links = links)

#################################################################
# Sankeydiagram maken

sankeyNetwork(Links = data$links, Nodes = data$nodes, Source = 'source',
              Target = 'target', Value = 'value', NodeID = 'codetxt',
              units = 'ha', colourScale = , fontSize = 12, nodeWidth = 25, nodePadding = 20)

# Kleuren voor nodes en links

colors <- 'd3.scaleOrdinal() .domain(["landbouw", "urbaan", "natuur", "water", "zee"]) 
.range(["#feb24c", "#a50f15", "#004529", "#6baed6", "#023858"])'

sankeyNetwork(Links = data$links, Nodes = data$nodes, Source = 'source',
              Target = 'target', Value = 'value', NodeID = 'group',
              units = 'ha', fontSize = 12, nodeWidth = 25, nodePadding = 20,
              NodeGroup = "group", LinkGroup = "group",
              fontFamily = "calibri",
              colourScale = colors, linkOpacity = 0.4,
              showNodeValues = FALSE,
              iterations = 0)
